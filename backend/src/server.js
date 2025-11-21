const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/user');
const paymentRoutes = require('./routes/payment');
const newsRoutes = require('./routes/news');

const app = express();
const PORT = process.env.PORT || 3000;

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

// Trust proxy (для работы за Caddy reverse proxy)
// 1 = доверяем первому прокси в цепочке (Caddy)
app.set('trust proxy', 1);

// Middleware
app.use(helmet());

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

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 минут
  max: 100, // максимум 100 запросов с одного IP
  message: 'Слишком много запросов с этого IP, попробуйте позже',
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => false,
  handler: (req, res) => {
    res.status(429).json({
      error: 'Слишком много запросов с этого IP, попробуйте позже'
    });
  }
});
app.use('/api/', limiter);

// SECURITY: Strict rate limiting для auth endpoints (защита от brute-force)
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

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/news', newsRoutes);

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    service: 'AgiCraft Backend API'
  });
});

// Error handling
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    error: err.message || 'Внутренняя ошибка сервера',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack })
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Маршрут не найден' });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 AgiCraft Backend API запущен на порту ${PORT}`);
  console.log(`📡 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🗄️  Database: ${process.env.POSTGRES_HOST}:${process.env.POSTGRES_PORT}/${process.env.POSTGRES_DB}`);
});

module.exports = app;
