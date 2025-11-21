# CRITICAL Security Fixes - Immediate Action Required

Патчи для исправления CRITICAL уязвимостей. Применить ДО production деплоя.

---

## Fix 1: YooKassa Webhook Signature Verification

### Файл: `backend/src/routes/payment.js`

**Добавить после импортов (строка 6):**
```javascript
const crypto = require('crypto');
```

**Заменить webhook handler (строка 116-209) на:**
```javascript
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

    // Проверяем что donation принадлежит правильному пользователю
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
```

**Проверка после применения:**
```bash
# Отправить fake webhook (должен вернуть 403)
curl -X POST http://localhost:3000/api/payment/webhook \
  -H "Content-Type: application/json" \
  -d '{"event":"payment.succeeded","object":{"id":"test"}}'

# Ответ: 403 Forbidden (правильно!)
```

---

## Fix 2: Rate Limiting для Auth Endpoints

### Файл: `backend/src/server.js`

**После строки 63 (существующего limiter) добавить:**
```javascript
// Strict rate limiting для auth endpoints (защита от brute-force)
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 минут
  max: 5, // максимум 5 попыток за 15 минут
  message: 'Слишком много попыток входа. Попробуйте через 15 минут',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Не считать успешные попытки
  handler: (req, res) => {
    console.warn(`Rate limit exceeded for IP: ${req.ip}, path: ${req.path}`);
    res.status(429).json({
      error: 'Слишком много попыток входа. Попробуйте через 15 минут'
    });
  }
});

// Применяем к auth routes
app.use('/api/auth/login', authLimiter);
app.use('/api/auth/register', authLimiter);
```

**Проверка:**
```bash
# Попробовать 6 раз подряд
for i in {1..6}; do
  curl -X POST http://localhost:3000/api/auth/login \
    -H "Content-Type: application/json" \
    -d '{"username":"test","password":"wrong"}'
  echo ""
done

# 6-й запрос должен вернуть 429
```

---

## Fix 3: JWT Secret Validation

### Файл: `backend/src/server.js`

**После строки 13 (const PORT) добавить:**
```javascript
// SECURITY: Проверяем JWT_SECRET на безопасность
const JWT_SECRET = process.env.JWT_SECRET;

if (!JWT_SECRET) {
  console.error('❌ FATAL: JWT_SECRET не установлен в .env');
  console.error('Запустите: npm run generate-secrets');
  process.exit(1);
}

if (JWT_SECRET.length < 32) {
  console.error(`❌ FATAL: JWT_SECRET слишком короткий (${JWT_SECRET.length} символов)`);
  console.error('JWT_SECRET должен быть минимум 32 символа');
  console.error('Запустите: npm run generate-secrets');
  process.exit(1);
}

if (JWT_SECRET.includes('change_this') ||
    JWT_SECRET.includes('your_super_secret') ||
    JWT_SECRET === 'secret') {
  console.error('❌ FATAL: JWT_SECRET использует дефолтное значение');
  console.error('Это критическая уязвимость безопасности!');
  console.error('Запустите: npm run generate-secrets');
  process.exit(1);
}

console.log('✅ JWT_SECRET validated');
```

---

## Fix 4: Error Leakage Protection

### Файл: `backend/src/routes/payment.js`

**Заменить строки 106-112:**
```javascript
// БЫЛО:
} catch (error) {
  console.error('Payment creation error:', error);
  res.status(500).json({
    error: 'Ошибка создания платежа',
    details: error.response?.data || error.message
  });
}

// СТАЛО:
} catch (error) {
  console.error('Payment creation error:', error);

  // SECURITY: Не возвращаем детали в production
  const response = {
    error: 'Ошибка создания платежа'
  };

  // Детали только для development
  if (process.env.NODE_ENV === 'development') {
    response.details = error.message;
  }

  res.status(500).json(response);
}
```

---

## Fix 5: CORS Strict Mode для Production

### Файл: `backend/src/server.js`

**Заменить строки 23-43:**
```javascript
// SECURITY: CORS configuration
const allowedOrigins = process.env.NODE_ENV === 'production'
  ? [
      process.env.FRONTEND_URL  // Только production URL
    ].filter(Boolean)  // Удаляем undefined
  : [
      'http://localhost:3001',  // Vite dev
      'http://localhost:80',    // Docker frontend
      'http://localhost'        // Общий localhost
    ];

app.use(cors({
  origin: (origin, callback) => {
    // В production ТРЕБУЕМ origin
    if (process.env.NODE_ENV === 'production' && !origin) {
      console.warn('CORS: Request without origin blocked in production');
      return callback(new Error('Origin required'));
    }

    // В development разрешаем запросы без origin (Postman, curl)
    if (!origin && process.env.NODE_ENV !== 'production') {
      return callback(null, true);
    }

    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      console.warn(`CORS blocked origin: ${origin}`);
      callback(new Error('Not allowed by CORS'));
    }
  },
  credentials: true
}));

console.log(`✅ CORS configured for: ${allowedOrigins.join(', ')}`);
```

---

## Fix 6: Input Validation

### Файл: `backend/src/routes/auth.js`

**После строки 6 добавить:**
```javascript
// SECURITY: Validation helpers
const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const minecraftNicknameRegex = /^[A-Za-z0-9_]{3,16}$/;
const usernameRegex = /^[A-Za-z0-9_]{3,16}$/;
```

**В register handler (после строки 15) добавить:**
```javascript
// Валидация username
if (!usernameRegex.test(username)) {
  return res.status(400).json({
    error: 'Логин должен содержать только буквы, цифры и _ (3-16 символов)'
  });
}

// Валидация email
if (!emailRegex.test(email)) {
  return res.status(400).json({
    error: 'Некорректный формат email'
  });
}

// Валидация Minecraft nickname
if (!minecraftNicknameRegex.test(minecraft_nickname)) {
  return res.status(400).json({
    error: 'Minecraft ник должен содержать только A-Z, 0-9, _ (3-16 символов)'
  });
}

// Валидация пароля
if (password.length < 8) {
  return res.status(400).json({
    error: 'Пароль должен содержать минимум 8 символов'
  });
}

// Дополнительно: проверка сложности пароля
const passwordHasUpper = /[A-Z]/.test(password);
const passwordHasLower = /[a-z]/.test(password);
const passwordHasNumber = /[0-9]/.test(password);

if (!passwordHasUpper || !passwordHasLower || !passwordHasNumber) {
  return res.status(400).json({
    error: 'Пароль должен содержать заглавные буквы, строчные буквы и цифры'
  });
}
```

---

## Fix 7: Docker Non-Root User

### Файл: `backend/Dockerfile`

**Заменить весь файл:**
```dockerfile
FROM node:20-alpine

# SECURITY: Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Устанавливаем build tools для нативных модулей
RUN apk add --no-cache python3 make g++

# Устанавливаем рабочую директорию
WORKDIR /app

# Копируем package.json и package-lock.json
COPY --chown=appuser:appgroup package*.json ./

# Устанавливаем зависимости
RUN npm ci --production

# Копируем исходный код
COPY --chown=appuser:appgroup . .

# SECURITY: Switch to non-root user
USER appuser

# Открываем порт
EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Команда запуска
CMD ["npm", "start"]
```

### Файл: `frontend/Dockerfile`

**Заменить production stage (строки 21-33):**
```dockerfile
# Production stage
FROM nginx:alpine

# SECURITY: Run as non-root
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Копируем собранные файлы
COPY --from=builder --chown=nginx:nginx /app/dist /usr/share/nginx/html

# Копируем конфиг nginx
COPY --chown=nginx:nginx nginx.conf /etc/nginx/conf.d/default.conf

# SECURITY: Switch to non-root user
USER nginx

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

---

## Применение всех фиксов

### 1. Применить патчи

```bash
# Скопировать исправленные файлы
# (вручную применить изменения выше)
```

### 2. Обновить .env

```bash
# Запустить генератор секретов
./scripts/generate-secrets.sh

# Скопировать сгенерированные секреты в .env
```

### 3. Пересобрать Docker образы

```bash
# Пересобрать backend и frontend с security fixes
docker-compose build backend frontend

# Перезапустить сервисы
docker-compose down
docker-compose up -d
```

### 4. Проверить логи

```bash
# Backend должен показать:
# ✅ JWT_SECRET validated
# ✅ CORS configured for: ...

docker-compose logs backend | grep "✅"
```

### 5. Тестирование

```bash
# Тест 1: Fake webhook должен быть заблокирован
curl -X POST http://localhost:3000/api/payment/webhook \
  -H "Content-Type: application/json" \
  -d '{"event":"payment.succeeded"}'
# Ожидаем: 403 Forbidden

# Тест 2: Rate limiting работает
for i in {1..6}; do
  curl -X POST http://localhost:3000/api/auth/login \
    -d '{"username":"test","password":"wrong"}' \
    -H "Content-Type: application/json"
done
# 6-й запрос должен вернуть 429

# Тест 3: Email валидация
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username":"test",
    "email":"notanemail",
    "password":"Test1234",
    "minecraft_nickname":"TestUser"
  }'
# Ожидаем: 400 "Некорректный формат email"

# Тест 4: Docker контейнер не root
docker exec backend whoami
# Ожидаем: appuser (НЕ root!)
```

---

## Checklist перед production

- [ ] Все патчи применены
- [ ] JWT_SECRET сгенерирован через generate-secrets.sh
- [ ] POSTGRES_PASSWORD изменен на безопасный
- [ ] Docker образы пересобраны
- [ ] Rate limiting протестирован
- [ ] Webhook signature проверен
- [ ] Email валидация работает
- [ ] CORS настроен правильно для production URL
- [ ] Docker контейнеры запускаются от non-root
- [ ] Backend логи показывают ✅ security checks

---

## Откат в случае проблем

```bash
# Если что-то сломалось, откатиться на предыдущую версию
git checkout HEAD~1

# Пересобрать
docker-compose build
docker-compose up -d
```

---

**ВАЖНО:** Все эти патчи **ОБЯЗАТЕЛЬНЫ** перед production деплоем. Без них система имеет критические уязвимости, которые могут привести к финансовым потерям и взлому аккаунтов.

**Estimated time:** 2-3 часа на применение всех фиксов + тестирование

**Автор:** Claude Code
**Приоритет:** CRITICAL
