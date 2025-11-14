# Minecraft MVP Network

## Требования

- **Docker:** 20.10+ и Docker Compose
- **RAM:** 24GB minimum (10GB Survival + 10GB AI_Research + 1GB Velocity + 512MB MySQL)
- **ОС:** Windows 10/11 или Linux
- **Публичный статичный IP:** 188.242.12.214
- **Локальный IP сервера:** 192.168.0.246

## Архитектура

```
Internet (nettyan.ddns.net:25565)
    ↓
Router (Port Forwarding)
    ↓
Velocity Proxy (0.0.0.0:25565) [Docker Container]
    ├─> Lobby (lobby:25569) [Docker Container]
    │   ├─> world (lobby spawn)
    │   └─> AuthMe авторизация (bypass для AI групп)
    ├─> Survival (survival:25571) [Docker Container]
    │   ├─> world (main survival world)
    │   ├─> world_nether
    │   └─> world_the_end
    ├─> AI_Research (airesearch:25570) [Docker Container]
    │   ├─> world_ai (анархия + защищенные зоны)
    │   ├─> world_ai_nether (защита 50x50)
    │   └─> world_ai_the_end (полная анархия)
    └─> Survival+ (survivalplus:25572) [Coming Soon]

PostgreSQL (postgres:5432) [Docker Container]
    └─> Shared database для LuckPerms, AuthMe и веб-сайта
```

## Быстрый старт

### 1. Установить Docker

**Windows:**
1. Скачать Docker Desktop: https://www.docker.com/products/docker-desktop
2. Установить и запустить Docker Desktop
3. Убедиться что Docker Compose включен

**Linux:**
```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# Добавить пользователя в группу docker
sudo usermod -aG docker $USER
newgrp docker
```

### 2. Скачать недостающие файлы

**Paper 1.21.1:**
```
https://papermc.io/downloads/paper
```
Сохранить как `paper.jar` в `survival/` и `ai_research/`

**Velocity 3.4.0+:**
```
https://papermc.io/downloads/velocity
```
Сохранить как `velocity.jar` в `velocity/`

### 3. Настроить проброс портов на роутере

**ВАЖНО:** Перед запуском сервера настройте проброс портов!

Следуйте инструкции: **[ROUTER_SETUP.md](ROUTER_SETUP.md)**

Кратко:
- Порт: **25570** (TCP и UDP)
- Внутренний IP: **192.168.0.246**
- Внешний IP: **188.242.12.214**

### 4. Проверить файл .env

Проверьте что файл `.env` содержит правильные настройки:
```bash
cat .env
```

### 5. Запустить серверы

```bash
docker-compose up -d
```

Проверить статус контейнеров:
```bash
docker-compose ps
```

Все сервисы должны быть в статусе `Up`.

Подождать **60 секунд** для полной инициализации.

## Первоначальная настройка

После первого запуска необходимо выполнить команды настройки.

### Подключение к консолям серверов

**Survival:**
```bash
docker attach minecraft_survival
```

**AI_Research:**
```bash
docker attach minecraft_airesearch
```

**Velocity:**
```bash
docker attach minecraft_velocity
```

**Отключиться от консоли (без остановки сервера):**
Нажмите `Ctrl+P`, затем `Ctrl+Q`

### Survival консоль

```bash
# Создать void мир для авторизации
mv create void_auth NORMAL -g VoidGenerator
mv modify set generator void_auth VoidGenerator
mvtp void_auth
```

В игре:
1. Построить платформу 10x10 на Y=100
2. Окружить барьерами

Затем в консоли:
```bash
# Защита платформы авторизации
rg define auth_platform -5 95 -5 5 105 5
rg flag auth_platform passthrough deny
rg flag auth_platform pvp deny
rg flag auth_platform block-break deny
rg flag auth_platform block-place deny
rg flag auth_platform mob-spawning deny

# Вернуться в основной мир
mvtp world
tp 0 150 0
```

Построить lobby платформу 10x10 на Y=150, окружить барьерами.

```bash
# Защита lobby_spawn
rg define lobby_spawn -5 145 -5 5 155 5
rg flag lobby_spawn passthrough deny
rg flag lobby_spawn pvp deny
rg flag lobby_spawn block-break deny
rg flag lobby_spawn block-place deny
rg flag lobby_spawn mob-spawning deny
rg flag lobby_spawn entry allow
rg flag lobby_spawn exit allow

# Установка спавна
setworldspawn 0 150 0
essentials:setspawn
```

### AI_Research консоль

```bash
# Защита спавна 500x500
rg define spawn -250 0 -250 250 320 250
rg flag spawn pvp deny
rg flag spawn block-break deny
rg flag spawn block-place deny
rg flag spawn tnt deny
rg flag spawn creeper-explosion deny
rg flag spawn wither-damage deny
rg flag spawn ghast-fireball deny
rg flag spawn entry allow
rg flag spawn exit allow

# Тестовый полигон 500x500
rg define test_polygon_1 1000 64 1000 1500 120 1500
rg flag test_polygon_1 pvp deny
rg flag test_polygon_1 block-break deny
rg flag test_polygon_1 block-place deny
rg addmember test_polygon_1 g:ai_research

setworldspawn 0 65 0
```

### Настройка LuckPerms

Подключиться к Velocity консоли или любому серверу с LuckPerms:

```bash
# Создание групп
lp creategroup new
lp creategroup helper
lp creategroup starter
lp creategroup vip
lp creategroup premium
lp creategroup elite
lp creategroup legend
lp creategroup ai_research
lp creategroup ai_person
lp creategroup ai_father

# Весовые значения
lp group new setweight 1
lp group helper setweight 2
lp group starter setweight 3
lp group vip setweight 4
lp group premium setweight 5
lp group elite setweight 6
lp group legend setweight 7
lp group ai_research setweight 100
lp group ai_person setweight 50
lp group ai_father setweight 200

# Права для AI групп
lp group ai_research permission set velocity.command.server true
lp group ai_research permission set essentials.tp true
lp group ai_research permission set worldguard.region.bypass.* true

lp group ai_person permission set authme.bypass.register true
lp group ai_person permission set authme.bypass.login true
lp group ai_person meta set velocity.default-server ai_research

lp group ai_father parent add ai_research
lp group ai_father permission set * true

# Права донатных групп (примеры)
lp group vip permission set essentials.sethome.multiple.3 true
lp group premium permission set essentials.sethome.multiple.5 true
lp group elite permission set essentials.sethome.multiple.10 true
lp group legend permission set essentials.sethome.multiple.unlimited true
```

## Проверка MVP

### Тест 1: Обычный игрок
1. Подключиться к `26.151.146.93:25577`
2. Должен попасть в `void_auth` мир
3. `/register password password`
4. Телепорт на `lobby_spawn` (0,150,0) в `world`
5. `/rtp` - случайная телепортация в survival мир

### Тест 2: AI_Person
1. Создать тестового игрока: `lp user TestBot parent set ai_person`
2. Подключиться к `26.151.146.93:25577`
3. Должен попасть напрямую на AI_Research сервер
4. Авторизация не требуется

### Тест 3: Переключение серверов
1. Игрок с группой `ai_research` на Survival
2. `/server ai_research` - телепорт на AI сервер
3. Обычный игрок без прав - команда недоступна

### Тест 4: Защищенные зоны
1. AI_Research: попытка сломать блок в регионе spawn - запрещено
2. За пределами регионов - полная анархия
3. Survival: `lobby_spawn` защищен

## Структура проекта

```
minecraft-project/
├── Plugins_raw/              # Исходники плагинов
├── mysql/
│   └── init.sql             # SQL инициализация
├── velocity/
│   ├── velocity.jar         # Скачать вручную
│   ├── velocity.toml
│   └── plugins/
│       ├── LuckPerms-Velocity-5.5.18.jar
│       └── luckperms/config.yml
├── survival/
│   ├── paper.jar            # Скачать вручную
│   ├── server.properties
│   ├── spigot.yml
│   ├── bukkit.yml
│   ├── paper-world-defaults.yml
│   ├── eula.txt
│   └── plugins/
│       ├── LuckPerms-Bukkit-5.5.17.jar
│       ├── Vault.jar
│       ├── EssentialsX-2.22.0-dev+42-9985dbd.jar
│       ├── EssentialsXSpawn-2.22.0-dev+42-9985dbd.jar
│       ├── worldguard-bukkit-7.0.14-dist.jar
│       ├── worldedit-bukkit-7.3.17.jar
│       ├── multiverse-core-5.3.3.jar
│       └── configs/
├── lobby/
│   └── plugins/
│       ├── LuckPerms-Bukkit-5.5.17.jar
│       ├── AuthMe-5.6.0-legacy.jar (авторизация для всех серверов)
│       ├── worldguard-bukkit-7.0.14-dist.jar
│       ├── worldedit-bukkit-7.3.17.jar
│       └── configs/
├── ai_research/
│   ├── paper.jar            # Скачать вручную
│   ├── server.properties
│   ├── spigot.yml
│   ├── eula.txt
│   └── plugins/
│       ├── LuckPerms-Bukkit-5.5.17.jar
│       ├── worldguard-bukkit-7.0.14-dist.jar
│       ├── worldedit-bukkit-7.3.17.jar
│       ├── EssentialsX-2.22.0-dev+42-9985dbd.jar
│       └── configs/
├── start-all.bat            # Windows launcher
├── start-all.sh             # Linux launcher
└── README.md
```

## Группы пользователей

### Донатные группы (иерархия)
- `new` → `helper` → `starter` → `vip` → `premium` → `elite` → `legend`

### Специальные группы
- `ai_research` - исследователи AI (доступ к `/server`, bypass регионов)
- `ai_person` - AI-боты (bypass авторизации, автовход на AI_Research)
- `ai_father` - администраторы AI (полные права)

## Логика входа

**Обычный игрок:**
1. Вход через Velocity → `void_auth`
2. AuthMe регистрация/вход
3. Телепорт на `lobby_spawn` (0,150,0) в `world`
4. `/rtp` для телепортации в мир

**AI_Person:**
1. Вход через Velocity → напрямую `AI_Research`
2. Без авторизации
3. Спавн на координатах 0,65,0 в `world_ai`

## Поддержка

**Детальная документация:** `Plan.txt`

**Ссылки:**
- Paper: https://papermc.io/downloads/paper
- Velocity: https://papermc.io/downloads/velocity
- LuckPerms: https://luckperms.net/
- EssentialsX: https://essentialsx.net/
- WorldGuard: https://enginehub.org/worldguard
- WorldEdit: https://enginehub.org/worldedit
- Multiverse-Core: https://github.com/Multiverse/Multiverse-Core
- AuthMe: https://github.com/AuthMe/AuthMeReloaded

## Docker команды управления

### Основные команды

```bash
# Запустить все сервисы
docker-compose up -d

# Остановить все сервисы
docker-compose down

# Перезапустить конкретный сервис
docker-compose restart survival
docker-compose restart airesearch
docker-compose restart velocity
docker-compose restart mysql

# Просмотр статуса контейнеров
docker-compose ps

# Просмотр логов
docker-compose logs -f survival        # Логи Survival (в реальном времени)
docker-compose logs -f airesearch      # Логи AI_Research
docker-compose logs -f velocity        # Логи Velocity
docker-compose logs --tail=100 survival  # Последние 100 строк

# Подключение к консоли сервера
docker attach minecraft_survival
docker attach minecraft_airesearch
docker attach minecraft_velocity

# Отключение от консоли (без остановки)
# Нажать: Ctrl+P, затем Ctrl+Q

# Выполнить команду в контейнере
docker exec minecraft_survival rcon-cli "say Hello"

# Остановить сервер через консоль
docker attach minecraft_survival
# Ввести: stop
```

### Управление данными

```bash
# Резервное копирование миров
docker cp minecraft_survival:/server/world ./backup/survival-world-$(date +%Y%m%d)
docker cp minecraft_airesearch:/server/world_ai ./backup/ai-world-$(date +%Y%m%d)

# Резервное копирование базы данных
docker exec minecraft_mysql mysqldump -u mcserver -pStrongPass123! minecraft_luckperms > backup/db-$(date +%Y%m%d).sql

# Очистить неиспользуемые Docker образы и контейнеры
docker system prune -a
```

### Мониторинг ресурсов

```bash
# Использование ресурсов контейнерами
docker stats

# Использование дискового пространства
docker system df
```

## Важные замечания

⚠️ **Paper и Velocity jar-файлы НЕ включены в проект и должны быть скачаны вручную**

⚠️ **Изменить пароль БД в production** в файлах:
- `.env` (MYSQL_PASSWORD)
- `velocity/plugins/luckperms/config.yml`
- `survival/plugins/LuckPerms/config.yml`
- `survival/plugins/AuthMe/config.yml`
- `ai_research/plugins/LuckPerms/config.yml`

⚠️ **Online-mode=false** - сервер работает в оффлайн-режиме (без проверки лицензий Mojang)

⚠️ **Порты:**
- `80` - HTTP (Caddy - редирект на HTTPS)
- `443` - HTTPS (Caddy - веб-сайт с SSL)
- `8080` - HTTP альтернативный (опционально)
- `25565` - Velocity (внешний доступ, стандартный порт Minecraft)
- `25566` - Query (мониторинг серверов)
- `25570` - AI_Research (прямой доступ для ботов)
- `25571` - Survival (внутри Docker сети)
- `25569` - Lobby (внутри Docker сети)
- `25572` - Survival+ (внутри Docker сети, заглушка)
- `3000` - Backend API (внутри Docker сети, через Caddy)
- `5432` - PostgreSQL (внутри Docker сети)

⚠️ **HTTPS настройка:** Для работы веб-сайта с HTTPS нужен домен и SSL сертификат
- См. краткое руководство: [QUICK_START_HTTPS.md](QUICK_START_HTTPS.md)
- Или детальное руководство: [HTTPS_SETUP.md](HTTPS_SETUP.md)
- Caddy автоматически получит SSL сертификат от Let's Encrypt
- Стоимость: ~140₽/год за домен (.ru на reg.ru)

⚠️ **Проброс портов на роутере ОБЯЗАТЕЛЕН!**
- Minecraft: порт 25565
- Веб-сайт: порты 80, 443 (для HTTPS)
- См. [ROUTER_SETUP.md](ROUTER_SETUP.md) или [HTTPS_SETUP.md](HTTPS_SETUP.md)

⚠️ **Статичный IP:** Убедитесь что локальный IP сервера (192.168.0.246) не меняется

⚠️ **Docker Desktop:** На Windows должен быть запущен перед использованием docker-compose

⚠️ **Подключение:**
- Minecraft: `nettyan.ddns.net:25565` (или купленный домен)
- Веб-сайт (HTTP): `http://localhost` или `http://ваш_ip`
- Веб-сайт (HTTPS): `https://ваш_домен.ru` (после настройки SSL)
