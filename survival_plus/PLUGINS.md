# Survival+ Required Plugins

Список необходимых плагинов для Survival+ сервера.

---

## Обязательные плагины

### 1. Multiverse-Core
**Версия:** 4.3.12+ (Paper 1.21.1)
**Скачать:** https://dev.bukkit.org/projects/multiverse-core
**Зависимости:** Нет
**Назначение:** Управление 5 мирами (sp_clean, sp_basic, sp_danger, sp_cursed, sp_chaos)

```bash
cd /data/plugins
wget https://ci.onarandombox.com/job/Multiverse-Core/lastSuccessfulBuild/artifact/target/multiverse-core-4.3.12.jar
```

---

### 2. OreControl
**Версия:** 2.0.0+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/orecontrol.8891/
**Зависимости:** Нет
**Назначение:** Контроль генерации руд в каждом мире

**Premium плагин** - требует покупку на SpigotMC ($10)

Альтернатива (бесплатно): **OreRegenerator** - https://www.spigotmc.org/resources/oreregenerator.2851/

---

### 3. EpicWorldGenerator
**Версия:** 9.0.0+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/epicworldgenerator.8067/
**Зависимости:** Нет
**Назначение:** Генерация Chaos мира (swiss cheese структура)

**Premium плагин** - требует покупку на SpigotMC ($25)

**Бесплатные альтернативы:**
- **Terra:** https://github.com/PolyhedralDev/Terra (требует свои конфиги)
- **Iris:** https://www.spigotmc.org/resources/iris-world-gen.84586/ (более простой)

Для тестирования можно использовать vanilla End-like generation:
```yaml
# В Multiverse-Core worlds.yml
sp_chaos:
  generator: 'THE_END'
  environment: THE_END
```

---

### 4. LuckPerms
**Версия:** 5.4.137+ (Paper 1.21.1)
**Скачать:** https://luckperms.net/download
**Зависимости:** Нет (но нужен PostgreSQL для shared permissions)
**Назначение:** Управление правами доступа к мирам по уровням

```bash
cd /data/plugins
wget https://download.luckperms.net/1553/bukkit/loader/LuckPerms-Bukkit-5.4.137.jar
```

**Конфигурация для PostgreSQL:**
```yaml
# config.yml
storage-method: postgresql
data:
  address: postgres:5432
  database: minecraft_server
  username: mcserver
  password: ${POSTGRES_PASSWORD}
```

---

### 5. ItemsAdder
**Версия:** 3.6.3+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/itemsadder.73355/
**Зависимости:** Нет
**Назначение:** Кастомные материалы (mythril, chaos crystal, obsidian shard, etc)

**Premium плагин** - требует покупку на SpigotMC ($20)

**Бесплатная альтернатива:**
- **Oraxen:** https://www.spigotmc.org/resources/oraxen.72448/ (частично бесплатно)
- **MMOItems:** https://www.spigotmc.org/resources/mmoitems.39267/ (бесплатно, но менее гибкий)

---

### 6. MythicMobs
**Версия:** 5.6.1+ (Paper 1.21.1)
**Скачать:** https://mythiccraft.io/downloads
**Зависимости:** Нет
**Назначение:** Кастомные мобы для каждого мира

**Premium версия** - $35 на mythiccraft.io
**Free версия:** https://www.spigotmc.org/resources/mythicmobs.5702/ (ограниченный функционал)

```bash
cd /data/plugins
# Free версия:
wget https://ci.lumine.io/job/MythicMobs/lastSuccessfulBuild/artifact/build/MythicMobs-5.6.1-FREE.jar
```

---

## Рекомендуемые плагины

### 7. AureliumSkills
**Версия:** 2.1.7+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/aurelium-skills.81069/
**Зависимости:** PlaceholderAPI
**Назначение:** Skill tree без традиционных RPG классов

**Бесплатный!**

```bash
cd /data/plugins
wget https://github.com/Archy-X/AureliumSkills/releases/download/2.1.7/AureliumSkills-2.1.7.jar
```

**Альтернатива:** SkillAPI - https://www.spigotmc.org/resources/skillapi.4532/

---

### 8. CustomStructures
**Версия:** 3.0.0+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/custom-structures.38249/
**Зависимости:** Нет
**Назначение:** Процедурные данжи на островах

**Бесплатный!**

---

### 9. WorldGuard + WorldEdit
**WorldGuard версия:** 7.0.10+ (Paper 1.21.1)
**Скачать:** https://dev.bukkit.org/projects/worldguard
**WorldEdit версия:** 7.3.6+ (Paper 1.21.1)
**Скачать:** https://dev.bukkit.org/projects/worldedit

```bash
cd /data/plugins
wget https://dev.bukkit.org/projects/worldedit/files/latest
wget https://dev.bukkit.org/projects/worldguard/files/latest
```

**Назначение:** Защита spawn зон, регионы

---

### 10. PlaceholderAPI
**Версия:** 2.11.6+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/placeholderapi.6245/

```bash
cd /data/plugins
wget https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/2.11.6/PlaceholderAPI-2.11.6.jar
```

**Назначение:** Интеграция плагинов, плейсхолдеры для чата/скорборда

---

### 11. Vault
**Версия:** 1.7.3+ (Paper 1.21.1)
**Скачать:** https://www.spigotmc.org/resources/vault.34315/

```bash
cd /data/plugins
wget https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar
```

**Назначение:** Экономика (опционально для Survival+)

---

## Дополнительные плагины для реализации механик

### Session Manager (кастомный плагин)
**Назначение:** Управление сессиями в Chaos World (2ч активно, 30мин cooldown)

**Требует разработку** - можно использовать Skript или написать на Java/Kotlin.

**Альтернатива со Skript:**
```yaml
# Установить Skript
cd /data/plugins
wget https://github.com/SkriptLang/Skript/releases/download/2.9.0/Skript-2.9.0.jar
```

Затем создать скрипт в `/data/plugins/Skript/scripts/chaos_session.sk`

---

### Daily XP Cap (кастомный плагин)
**Назначение:** Ограничение XP до 2000/день (100%), после 20%

**Skript решение:**
```sk
on exp change:
    if player's world is "sp_chaos" or "sp_cursed":
        set {xp.today.%player%} to {xp.today.%player%} + event.getExperience()
        if {xp.today.%player%} > 2000:
            set event.setExperience(event.getExperience() * 0.2)
```

---

### Death Penalties (кастомный плагин)
**Назначение:** Разная система смерти в каждом мире

**Альтернатива:** Death Chest + custom Skript для вайпа

---

## Установка всех плагинов

### Скрипт для автоматической установки (бесплатные)

```bash
#!/bin/bash
# install_plugins.sh

PLUGINS_DIR="/data/plugins"
cd $PLUGINS_DIR

# Multiverse-Core
wget -O Multiverse-Core.jar https://ci.onarandombox.com/job/Multiverse-Core/lastSuccessfulBuild/artifact/target/multiverse-core-4.3.12.jar

# LuckPerms
wget -O LuckPerms.jar https://download.luckperms.net/1553/bukkit/loader/LuckPerms-Bukkit-5.4.137.jar

# PlaceholderAPI
wget -O PlaceholderAPI.jar https://github.com/PlaceholderAPI/PlaceholderAPI/releases/download/2.11.6/PlaceholderAPI-2.11.6.jar

# AureliumSkills
wget -O AureliumSkills.jar https://github.com/Archy-X/AureliumSkills/releases/download/2.1.7/AureliumSkills-2.1.7.jar

# MythicMobs Free
wget -O MythicMobs.jar https://ci.lumine.io/job/MythicMobs/lastSuccessfulBuild/artifact/build/MythicMobs-5.6.1-FREE.jar

# WorldEdit
wget -O WorldEdit.jar https://dev.bukkit.org/projects/worldedit/files/latest

# WorldGuard
wget -O WorldGuard.jar https://dev.bukkit.org/projects/worldguard/files/latest

# Vault
wget -O Vault.jar https://github.com/MilkBowl/Vault/releases/download/1.7.3/Vault.jar

# Skript (для кастомных механик)
wget -O Skript.jar https://github.com/SkriptLang/Skript/releases/download/2.9.0/Skript-2.9.0.jar

echo "Бесплатные плагины установлены!"
echo ""
echo "ТРЕБУЮТ РУЧНОЙ ПОКУПКИ И УСТАНОВКИ:"
echo "- OreControl ($10) - https://www.spigotmc.org/resources/orecontrol.8891/"
echo "- EpicWorldGenerator ($25) - https://www.spigotmc.org/resources/epicworldgenerator.8067/"
echo "- ItemsAdder ($20) - https://www.spigotmc.org/resources/itemsadder.73355/"
echo ""
echo "Альтернативы бесплатные:"
echo "- OreControl -> OreRegenerator (бесплатно)"
echo "- EpicWorldGenerator -> Terra/Iris (бесплатно)"
echo "- ItemsAdder -> MMOItems/Oraxen (бесплатно)"
```

Запуск:
```bash
docker exec -it minecraft_survivalplus bash
chmod +x /config/install_plugins.sh
/config/install_plugins.sh
```

---

## Минимальная конфигурация (без premium плагинов)

Если нужен полностью **бесплатный** Survival+:

1. **Multiverse-Core** - миры
2. **OreRegenerator** вместо OreControl - руды
3. **Iris** вместо EpicWorldGenerator - Chaos мир
4. **MMOItems** вместо ItemsAdder - кастомные предметы
5. **MythicMobs Free** - кастомные мобы (ограничено)
6. **AureliumSkills** - skill tree
7. **Skript** - кастомные механики (sessions, XP cap, death penalties)

**Общая стоимость:** $0

---

**Итого стоимость (premium):** ~$70-90
**Итого стоимость (бесплатно):** $0

**Рекомендация:** Начать с бесплатных альтернатив, потом купить premium при необходимости.
