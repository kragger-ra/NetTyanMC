const express = require('express');
const axios = require('axios');
const crypto = require('crypto');
const { v4: uuidv4 } = require('uuid');
const { authenticateToken } = require('../middleware/auth');
const db = require('../models/db');

const router = express.Router();

// YooKassa credentials
const SHOP_ID = process.env.YOOKASSA_SHOP_ID;
const SECRET_KEY = process.env.YOOKASSA_SECRET_KEY;

// Получить список продуктов (ранги + AgiCoins пакеты)
router.get('/products', async (req, res) => {
  try {
    const result = await db.query(`
      SELECT id, name, description, price_agicoins, luckperms_group,
             duration_days, product_type
      FROM web_donate_products
      WHERE is_active = true
      ORDER BY product_type, price_agicoins ASC
    `);

    res.json({ products: result.rows });
  } catch (error) {
    console.error('Products fetch error:', error);
    res.status(500).json({ error: 'Ошибка получения списка продуктов' });
  }
});

// Создать платёж через YooKassa
router.post('/create', authenticateToken, async (req, res) => {
  const { product_id } = req.body;

  if (!product_id) {
    return res.status(400).json({ error: 'ID продукта обязателен' });
  }

  try {
    // Получаем информацию о продукте
    const productResult = await db.query(
      'SELECT * FROM web_donate_products WHERE id = $1 AND is_active = true',
      [product_id]
    );

    if (productResult.rows.length === 0) {
      return res.status(404).json({ error: 'Продукт не найден' });
    }

    const product = productResult.rows[0];

    // Создаём запись о донате (pending)
    const donationResult = await db.query(`
      INSERT INTO web_donations (user_id, product_id, amount_paid, payment_status)
      VALUES ($1, $2, $3, 'pending')
      RETURNING id
    `, [req.user.id, product_id, product.price_agicoins]);

    const donationId = donationResult.rows[0].id;

    // Создаём платёж в YooKassa (тестовый режим)
    const idempotenceKey = uuidv4();
    const yookassaPayment = await axios.post(
      'https://api.yookassa.ru/v3/payments',
      {
        amount: {
          value: product.price_agicoins.toFixed(2),
          currency: 'RUB'
        },
        confirmation: {
          type: 'redirect',
          return_url: `${process.env.YOOKASSA_RETURN_URL}?donation_id=${donationId}`
        },
        capture: true,
        description: `Покупка: ${product.name}`,
        metadata: {
          donation_id: donationId,
          user_id: req.user.id,
          product_id: product_id
        }
      },
      {
        auth: {
          username: SHOP_ID,
          password: SECRET_KEY
        },
        headers: {
          'Idempotence-Key': idempotenceKey,
          'Content-Type': 'application/json'
        }
      }
    );

    // Сохраняем payment_id от YooKassa
    await db.query(
      'UPDATE web_donations SET payment_id = $1 WHERE id = $2',
      [yookassaPayment.data.id, donationId]
    );

    res.json({
      message: 'Платёж создан',
      confirmation_url: yookassaPayment.data.confirmation.confirmation_url,
      payment_id: yookassaPayment.data.id
    });

  } catch (error) {
    console.error('Payment creation error:', error);

    // SECURITY: Не возвращаем детали в production
    const response = {
      error: 'Ошибка создания платежа'
    };

    if (process.env.NODE_ENV === 'development') {
      response.details = error.message;
    }

    res.status(500).json(response);
  }
});

// Webhook от YooKassa (обработка платежа)
router.post('/webhook', async (req, res) => {
  // SECURITY: Проверяем подпись от YooKassa
  const receivedSignature = req.headers['x-yookassa-signature'];

  if (!receivedSignature) {
    console.error('Missing YooKassa signature');
    return res.status(403).send('Forbidden');
  }

  // Вычисляем ожидаемую подпись
  const body = JSON.stringify(req.body);
  const expectedSignature = crypto
    .createHmac('sha256', SECRET_KEY)
    .update(body)
    .digest('hex');

  if (receivedSignature !== expectedSignature) {
    console.error('Invalid YooKassa signature', {
      received: receivedSignature,
      expected: expectedSignature
    });
    return res.status(403).send('Forbidden');
  }

  const { event, object } = req.body;

  if (event !== 'payment.succeeded') {
    return res.status(200).send('OK');
  }

  const paymentId = object.id;
  const metadata = object.metadata;

  // SECURITY: Валидация metadata
  const donationId = parseInt(metadata.donation_id, 10);
  const userId = parseInt(metadata.user_id, 10);
  const productId = parseInt(metadata.product_id, 10);

  if (!donationId || !userId || !productId) {
    console.error('Invalid metadata in webhook', metadata);
    return res.status(400).send('Invalid metadata');
  }

  try {
    // Получаем информацию о донате
    const donationResult = await db.query(
      'SELECT * FROM web_donations WHERE id = $1',
      [donationId]
    );

    if (donationResult.rows.length === 0) {
      console.error('Donation not found:', donationId);
      return res.status(404).send('Donation not found');
    }

    const donation = donationResult.rows[0];

    // Проверяем, не обработан ли уже платёж
    if (donation.payment_status === 'completed') {
      return res.status(200).send('Already processed');
    }

    // SECURITY: Проверяем что donation принадлежит правильному пользователю
    if (donation.user_id !== userId) {
      console.error('User ID mismatch', {
        donation_user: donation.user_id,
        webhook_user: userId
      });
      return res.status(403).send('User mismatch');
    }

    // Получаем продукт
    const productResult = await db.query(
      'SELECT * FROM web_donate_products WHERE id = $1',
      [donation.product_id]
    );

    if (productResult.rows.length === 0) {
      console.error('Product not found:', donation.product_id);
      return res.status(404).send('Product not found');
    }

    const product = productResult.rows[0];

    // Получаем Minecraft nickname пользователя
    const userResult = await db.query(
      'SELECT minecraft_nickname FROM web_users WHERE id = $1',
      [donation.user_id]
    );

    const minecraftNickname = userResult.rows[0].minecraft_nickname;

    // Выполняем транзакцию
    await db.transaction(async (client) => {
      // Обновляем статус доната
      await client.query(
        'UPDATE web_donations SET payment_status = $1, completed_at = CURRENT_TIMESTAMP WHERE id = $2',
        ['completed', donationId]
      );

      // Если это покупка AgiCoins пакета
      if (product.product_type === 'agicoins') {
        // Начисляем AgiCoins
        await client.query(`
          INSERT INTO web_agicoins_balance (user_id, balance)
          VALUES ($1, $2)
          ON CONFLICT (user_id) DO UPDATE
          SET balance = web_agicoins_balance.balance + $2,
              updated_at = CURRENT_TIMESTAMP
        `, [donation.user_id, product.price_agicoins]);

        // Записываем транзакцию
        await client.query(`
          INSERT INTO web_agicoins_transactions (user_id, amount, transaction_type, description)
          VALUES ($1, $2, 'purchase', $3)
        `, [donation.user_id, product.price_agicoins, `Покупка пакета ${product.name}`]);
      }

      // Если это покупка ранга
      if (product.product_type === 'rank' && product.luckperms_group) {
        // TODO: Выдать ранг через docker exec или другой механизм
        console.log(`ВНИМАНИЕ: Необходимо вручную выдать ранг ${product.luckperms_group} игроку ${minecraftNickname} на ${product.duration_days} дней`);
      }
    });

    res.status(200).send('OK');

  } catch (error) {
    console.error('Webhook processing error:', error);
    res.status(500).send('Error');
  }
});

// Проверка статуса платежа (для фронтенда)
router.get('/status/:donationId', authenticateToken, async (req, res) => {
  const { donationId } = req.params;

  try {
    const result = await db.query(`
      SELECT payment_status, completed_at
      FROM web_donations
      WHERE id = $1 AND user_id = $2
    `, [donationId, req.user.id]);

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Платёж не найден' });
    }

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Payment status error:', error);
    res.status(500).json({ error: 'Ошибка проверки статуса' });
  }
});

module.exports = router;
