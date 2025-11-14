# Настройка Lobby сервера

## 1. Скачать плагины

**Необходимые плагины (положить в `lobby/plugins/`):**

1. **Paper 1.21.1** → `lobby/paper.jar`
   - https://papermc.io/downloads/paper

2. **LuckPerms** (уже настроен конфиг)
   - https://luckperms.net/download
   - `lobby/plugins/LuckPerms-Bukkit-5.5.17.jar`

3. **WorldGuard**
   - https://enginehub.org/worldguard
   - `lobby/plugins/WorldGuard-Bukkit-7.0.14.jar`

4. **WorldEdit**
   - https://enginehub.org/worldedit
   - `lobby/plugins/WorldEdit-Bukkit-7.3.17.jar`

5. **DecentHolograms**
   - https://www.spigotmc.org/resources/decentholograms.96927/
   - `lobby/plugins/DecentHolograms-X.X.X.jar`

6. **FancyNpcs**
   - https://www.spigotmc.org/resources/fancy-npcs.107636/
   - `lobby/plugins/FancyNpcs-X.X.X.jar`

7. **TAB**
   - https://www.mc-market.org/resources/20631/
   - `lobby/plugins/TAB-X.X.X.jar`

8. **EssentialsX** (базовые команды)
   - https://essentialsx.net/downloads.html
   - `lobby/plugins/EssentialsX-2.22.0-dev+42-9985dbd.jar`

---

## 2. Первый запуск сервера

```bash
docker-compose up -d lobby
docker logs -f minecraft_lobby
```

Дождаться загрузки (60 секунд).

---

## 3. Построить lobby платформу

**Подключиться к консоли:**
```bash
docker attach minecraft_lobby
```

**В игре:**
1. Подключиться к серверу
2. Телепортироваться на Y=100: `/tp @s 0 100 0`
3. Построить платформу 20x20 из камня/кварца
4. Окружить барьерами: `/give @s minecraft:barrier 64`
5. Построить красивый spawn с декорациями

**Установить спавн:**
```bash
/setworldspawn 0 100 0
/spawn
```

---

## 4. Защитить весь мир WorldGuard

**Создать глобальный регион:**
```bash
/rg define lobby_world
/rg flag lobby_world pvp deny
/rg flag lobby_world block-break deny
/rg flag lobby_world block-place deny
/rg flag lobby_world mob-spawning deny
/rg flag lobby_world damage-animals deny
/rg flag lobby_world entity-interact deny
/rg flag lobby_world use deny
/rg flag lobby_world vehicle-destroy deny
/rg flag lobby_world hunger-deplete deny
/rg flag lobby_world fall-damage deny
/rg flag lobby_world entry allow
/rg flag lobby_world exit allow
/rg priority lobby_world 1
```

**Создать регион платформы:**
```bash
/rg define spawn_platform -10 95 -10 10 105 10
/rg flag spawn_platform passthrough deny
/rg priority spawn_platform 10
```

---

## 5. Настроить NPC для телепортации

**С помощью FancyNpcs:**

**Создать NPC "Survival":**
```bash
/npc create Survival
/npc skin Survival steve
/npc pos 5 100 0
/npc look 5 100 0
/npc interact add command player server survival
/npc display name &a&lSurvival
```

**Создать NPC "AI Research":**
```bash
/npc create AI_Research
/npc skin AI_Research alex
/npc pos -5 100 0
/npc look -5 100 0
/npc interact add command player server ai_research
/npc display name &3&lAI Research
/npc permission add server.ai_research.access
```

**Создать NPC "Survival+" (неактивный):**
```bash
/npc create Survival_Plus
/npc skin Survival_Plus notch
/npc pos 0 100 5
/npc look 0 100 5
/npc display name &7&lSurvival+ &c(Скоро)
/npc interact add message &cСервер Survival+ еще в разработке!
```

---

## 6. Настроить голограммы DecentHolograms

**Голограмма над NPC "Survival":**
```bash
/holo create survival_info 5 102 0
/holo addline survival_info &a&lSurvival
/holo addline survival_info &7Классическое выживание
/holo addline survival_info &7Онлайн: &f{PAPI: %server_online_survival%}
/holo addline survival_info &eНажми ПКМ для входа
```

**Голограмма над NPC "AI Research":**
```bash
/holo create ai_info -5 102 0
/holo addline ai_info &3&lAI Research
/holo addline ai_info &7Тестовый сервер для ИИ
/holo addline ai_info &7Онлайн: &f{PAPI: %server_online_ai_research%}
/holo addline ai_info &7Требуется права: &aai_research
```

**Голограмма над NPC "Survival+":**
```bash
/holo create sp_info 0 102 5
/holo addline sp_info &6&lSurvival+
/holo addline sp_info &7Расширенный режим
/holo addline sp_info &c&lСкоро...
```

**Центральная голограмма (приветствие):**
```bash
/holo create welcome 0 105 0
/holo addline welcome &6&l✦ AgiCraft ✦
/holo addline welcome &7Добро пожаловать!
/holo addline welcome &fВыбери сервер ниже
/holo addline welcome &7
/holo addline welcome &7Онлайн: &f{PAPI: %server_online_total%}/100
```

---

## 7. Настроить TAB (опционально)

**Файл: `lobby/plugins/TAB/config.yml`**

```yaml
header:
  - '&6&l✦ AgiCraft ✦'
  - '&7Лобби'
  - ''

footer:
  - ''
  - '&7Онлайн: &f%server_online_total%/100'
  - '&7Пинг: &f%player_ping%ms'
  - '&7Discord: &bdiscord.gg/agicraft'

tablist-name-format: '%luckperms_prefix%%player%'
```

---

## 8. Плагин PlaceholderAPI (для голограмм)

**Установить PlaceholderAPI:**
```bash
# Скачать: https://www.spigotmc.org/resources/placeholderapi.6245/
# Положить в lobby/plugins/PlaceholderAPI.jar
```

**Установить расширения:**
```bash
/papi ecloud download Server
/papi ecloud download Player
/papi reload
```

---

## 9. Тестирование

1. **Подключиться к серверу:** `nettyan.ddns.net:25565`
2. **Должен попасть в лобби**
3. **Проверить NPC:**
   - ПКМ на "Survival" → телепорт на Survival
   - ПКМ на "AI Research" → телепорт (если есть права)
4. **Проверить голограммы:** показывают онлайн
5. **Проверить защиту:** блоки не ломаются

---

## 10. Настройка ai_person для прямого входа

**Чтобы ai_person заходили напрямую на AI Research (минуя лобби):**

В LuckPerms:
```bash
/lp group ai_person meta set velocity.default-server ai_research
```

---

## Готово!

Лобби настроен и готов к работе.

**Команды для игроков:**
- `/server survival` - переключение на Survival
- `/server ai_research` - переключение на AI Research (если есть права)
- `/server lobby` - вернуться в лобби

**Команды администратора:**
- `docker attach minecraft_lobby` - консоль лобби
- `docker logs -f minecraft_lobby` - логи
- `Ctrl+P, Ctrl+Q` - отключиться от консоли

