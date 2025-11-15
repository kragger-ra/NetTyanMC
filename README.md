# NetTyan Minecraft Server

Полнофункциональный Minecraft сервер с веб-интерфейсом, системой донатов и AI Research платформой.

---

## 🎮 Архитектура

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
```

**⚠️ Интеграция с nettyanweb:**
Проект использует Caddy из репозитория [nettyanweb](https://github.com/kragger-ra/nettyanweb) для HTTPS и reverse proxy. Backend и frontend подключаются к сети `nettyan_ssl`.

---

## ⚡ Быстрый старт

### 1. Клонировать репозиторий

```bash
git clone https://github.com/kragger-ra/NetTyanMC.git
cd NetTyanMC
```

### 2. Следовать инструкции

**📖 Подробная инструкция:** [POST_CLONE_SETUP.md](POST_CLONE_SETUP.md)

Кратко:
1. Скачать Java 21+ и Docker
2. **Не нужно** скачивать Paper/Velocity JAR - автоматически через itzg/minecraft-server
3. Скачать плагины (список в POST_CLONE_SETUP.md)
4. Создать `.env` из `.env.example`
5. Убедиться что nettyanweb развернут и сеть `nettyan_ssl` создана
6. Запустить: `docker-compose up -d`

---

## 📚 Документация

| Документ | Описание |
|----------|----------|
| **[POST_CLONE_SETUP.md](POST_CLONE_SETUP.md)** | ⭐ Полная инструкция развертывания после клонирования |
| [STATUS.md](STATUS.md) | Текущий статус проекта и выполненные задачи |
| [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) | Детальное руководство по развертыванию |
| [LUCKPERMS_SETUP.md](LUCKPERMS_SETUP.md) | Система ролей и прав (команды для настройки) |
| [HTTPS_SETUP.md](HTTPS_SETUP.md) | Настройка HTTPS с Let's Encrypt |
| [QUICK_START_HTTPS.md](QUICK_START_HTTPS.md) | Быстрая настройка HTTPS |

---

## 🔧 Технологии

### Minecraft инфраструктура
- **itzg/minecraft-server** - Docker образ для Minecraft серверов
- **Paper 1.21.1** - серверное ядро (автозагрузка)
- **Velocity** - прокси-сервер (автозагрузка)
- **PostgreSQL 16** - база данных
- **Docker** - контейнеризация

### Плагины
- **LuckPerms** - система прав
- **AuthMe** - авторизация (Lobby)
- **WorldGuard / WorldEdit** - защита регионов
- **EssentialsX** - базовые команды
- **PlayerPoints** - валюта (AgiCoins)
- **ShopGUIPlus** - магазин
- **DecentHolograms / FancyNpcs** - NPC и голограммы

### Веб-платформа
- **Backend:** Node.js, Express, JWT, YooKassa API
- **Frontend:** React, Vite, Zustand
- **Reverse Proxy:** Caddy из nettyanweb (авто SSL через Let's Encrypt)

---

## 📦 Структура проекта

```
NetTyanMC/
├── lobby/               # Lobby сервер (itzg/minecraft-server)
│   └── plugins/         # Конфиги плагинов (AuthMe, LuckPerms, и т.д.)
├── survival/            # Survival сервер (itzg/minecraft-server)
│   └── plugins/         # Конфиги плагинов
├── ai_research/         # AI Research сервер (itzg/minecraft-server)
│   └── plugins/
├── velocity/            # Velocity прокси (itzg/minecraft-server)
│   └── velocity.toml
├── backend/             # Backend API
│   ├── src/
│   └── package.json
├── frontend/            # React frontend
│   ├── src/
│   └── package.json
├── postgres/            # PostgreSQL схемы
│   └── init.sql
├── docker-compose.yml   # Оркестрация всех сервисов
├── .gitignore           # Исключения Git
└── POST_CLONE_SETUP.md  # ⭐ НАЧАТЬ ЗДЕСЬ

# Paper/Velocity JAR автоматически загружаются через itzg образ
# Миры в .gitignore
```

---

## 🚀 Требования

- **Java:** 21+
- **Docker:** 20.10+ и Docker Compose
- **RAM:** Минимум 24GB
  - Velocity: 1GB
  - Lobby: 2GB
  - Survival: 10GB
  - AI Research: 10GB
  - PostgreSQL: 512MB
  - Backend: 512MB
- **Диск:** 10GB+ свободно (без учета миров)
- **nettyanweb:** Развернутый репозиторий с Caddy

