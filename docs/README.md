# NetTyanMC Documentation

Полная документация проекта NetTyanMC - Minecraft сервер с веб-платформой и AI Research.

---

## Оглавление

### Быстрый старт
- **[POST_CLONE_SETUP.md](POST_CLONE_SETUP.md)** - ⭐ Полная инструкция развертывания после клонирования
- **[QUICK_START_HTTPS.md](QUICK_START_HTTPS.md)** - Быстрая настройка HTTPS за 30 минут

### Развертывание и конфигурация
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)** - Детальное руководство по развертыванию
- **[HTTPS_SETUP.md](HTTPS_SETUP.md)** - Настройка HTTPS с Let's Encrypt
- **[LUCKPERMS_SETUP.md](LUCKPERMS_SETUP.md)** - Система ролей и прав
- **[RUNNER_SETUP.md](RUNNER_SETUP.md)** - Настройка GitHub Actions Self-Hosted Runner
- **[CRAFTY_CONTROLLER.md](CRAFTY_CONTROLLER.md)** - Веб-панель управления серверами

### Миграции и обновления
- **[MIGRATION_TO_ITZG.md](MIGRATION_TO_ITZG.md)** - Миграция на itzg/minecraft-server образ

### Операционное управление
- **[BACKUP_GUIDE.md](BACKUP_GUIDE.md)** - Стратегия резервного копирования
- **[MONITORING_GUIDE.md](MONITORING_GUIDE.md)** - Мониторинг и логирование
- **[SECURITY_GUIDE.md](SECURITY_GUIDE.md)** - Безопасность и secrets management

### Статус проекта
- **[STATUS.md](STATUS.md)** - Текущий статус проекта и выполненные задачи

---

## Структура документации

```
docs/
├── README.md                    # Этот файл
├── POST_CLONE_SETUP.md          # Быстрый старт
├── DEPLOYMENT_GUIDE.md          # Полное развертывание
├── STATUS.md                    # Статус проекта
├── HTTPS_SETUP.md               # HTTPS конфигурация
├── QUICK_START_HTTPS.md         # Быстрый HTTPS
├── LUCKPERMS_SETUP.md           # Права и роли
├── MIGRATION_TO_ITZG.md         # История миграции
├── RUNNER_SETUP.md              # GitHub Runner
├── CRAFTY_CONTROLLER.md         # Веб-панель
├── BACKUP_GUIDE.md              # Резервное копирование
├── MONITORING_GUIDE.md          # Мониторинг
└── SECURITY_GUIDE.md            # Безопасность
```

---

## Быстрая навигация по задачам

### Первое развертывание
1. Читать [POST_CLONE_SETUP.md](POST_CLONE_SETUP.md)
2. Следовать шагам 1-9
3. Проверить работоспособность

### Настройка HTTPS
1. Купить домен
2. Следовать [QUICK_START_HTTPS.md](QUICK_START_HTTPS.md)
3. Обновить `.env`

### Настройка доступов
1. Читать [LUCKPERMS_SETUP.md](LUCKPERMS_SETUP.md)
2. Выполнить команды в консоли
3. Проверить права в игре

### Операционное управление
1. Настроить backup: [BACKUP_GUIDE.md](BACKUP_GUIDE.md)
2. Настроить мониторинг: [MONITORING_GUIDE.md](MONITORING_GUIDE.md)
3. Проверить безопасность: [SECURITY_GUIDE.md](SECURITY_GUIDE.md)

### CI/CD
1. Настроить runner: [RUNNER_SETUP.md](RUNNER_SETUP.md)
2. Проверить `.github/workflows/`
3. Сделать тестовый deploy

---

## Архитектура проекта

```
Velocity Proxy (25565)
    ├─> Lobby (25569) - Точка входа с авторизацией
    ├─> Survival (25571) - Классический выживание
    ├─> AI Research (25570) - Сервер для AI ботов
    └─> Survival+ (25572) - В разработке

PostgreSQL (5432) - Единая БД
Backend API (3000) - REST API
Frontend (80) - Веб-сайт
Caddy (nettyanweb) - HTTPS Reverse Proxy
Crafty Controller (8443) - Веб-панель управления (опционально)
```

---

## Поддержка и контакты

- **GitHub Issues:** [github.com/kragger-ra/NetTyanMC/issues](https://github.com/kragger-ra/NetTyanMC/issues)
- **Основной README:** [../README.md](../README.md)

---

**Последнее обновление:** 2025-11-21
**Версия документации:** 2.0
