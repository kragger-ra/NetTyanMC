# Survival+ Mode - Хардкорное выживание с прогрессией

Режим выживания с 5 мирами прогрессии, кастомной генерацией и анти-гринд механиками.

---

## Концепция

5 миров с увеличивающейся сложностью и прогрессией через материалы:

1. **Clean World** - чистый мир БЕЗ руд, только для строительства баз
2. **Basic World** - 3x базовые руды (уголь, железо, медь, редстоун, лазурит)
3. **Danger World** - только редкие руды (золото, алмазы, изумруды) + tier 2 материалы
4. **Cursed World** - ancient debris + tier 3 материалы (nether-подобный)
5. **Chaos World** - все руды + легендарные материалы, swiss cheese структура

---

## Прогрессия

### Уровни доступа
- Clean: доступен всем с 1 уровня
- Basic: уровень 5
- Danger: уровень 20
- Cursed: уровень 40
- Chaos: уровень 60 + активная сессия (2ч работы, 30мин cooldown)

### Система смерти
- **Clean**: респавн без потерь
- **Basic**: дроп инвентаря на месте смерти
- **Danger**: дроп инвентаря, часть предметов уничтожается
- **Cursed**: весь инвентарь уничтожается
- **Chaos**: полный вайп персонажа (уровень, статы, инвентарь)

### Материалы
- **Tier 0**: vanilla ресурсы (дерево, камень)
- **Tier 1**: базовые руды из Basic World
- **Tier 2**: mythril, obsidian shard из Danger World
- **Tier 3**: chaos steel из Cursed World
- **Tier 4**: chaos crystal из Chaos World (легендарные предметы)

---

## Требуемые плагины

### Обязательные
```
1. Multiverse-Core - управление мирами
2. OreControl - контроль генерации руд
3. EpicWorldGenerator (или Terra/Iris) - кастомная генерация Chaos мира
4. LuckPerms - права доступа к мирам по уровню
5. ItemsAdder - кастомные материалы (mythril, chaos crystal, etc)
6. MythicMobs - кастомные мобы
```

### Рекомендуемые
```
7. AureliumSkills или SkillAPI - система скиллов без RPG классов
8. CustomStructures - процедурные данжи
9. WorldGuard + WorldEdit - защита spawn зон
10. PlaceholderAPI - для интеграций
11. Vault - экономика (опционально)
```

---

## Установка

### 1. Скачать плагины
Загрузите jar файлы в `/data/plugins/` контейнера survivalplus:

```bash
# Примонтировать временную папку для загрузки
docker exec -it minecraft_survivalplus bash

# Скачать плагины через wget или curl
cd /data/plugins
wget https://url-to-multiverse-core.jar
wget https://url-to-orecontrol.jar
# ... и т.д.
```

### 2. Применить конфиги
Конфиги из `survival_plus/config/` автоматически синхронизируются в `/data/` при старте контейнера через `COPY_CONFIG_DEST`.

### 3. Перезапустить сервер
```bash
docker-compose restart survivalplus
```

### 4. Создать миры
Первый запуск создаст миры через Multiverse-Core:
```
/mv create sp_clean NORMAL
/mv create sp_basic NORMAL
/mv create sp_danger NORMAL
/mv create sp_cursed NORMAL
/mv create sp_chaos NORMAL -g EpicWorldGenerator:Chaos
```

---

## Chaos World - Особенности

### Структура "Swiss Cheese"
- 30-40% пустоты (void)
- Floating islands на разных высотах:
  - Y 10-80: крупные острова (30-100 блоков)
  - Y 80-160: средние острова (20-60 блоков)
  - Y 160-240: мелкие острова (10-40 блоков)

### Смешанные биомы
Один остров может содержать несколько биомов:
- Plains, Desert, Savanna (vanilla)
- Crimson Forest, Warped Forest (nether)
- Basalt Deltas, Soul Sand Valley (nether)

### Эффекты
- Частицы ash (как в Basalt Deltas)
- Случайные блоки хаоса (crying obsidian, ancient debris, glowstone)
- Void карманы внутри островов
- Ambient звуки Nether

### Session система
- Сессия: 2 часа активного времени
- Cooldown: 30 минут после окончания
- Logout в Chaos = смерть
- Entry limit: максимум 10 игроков одновременно

---

## Анти-гринд механики

### Daily XP Cap
- До 2000 XP: 100% получение
- После 2000 XP: только 20% получение
- Сброс каждые 24 часа (00:00 UTC)

### Skill Tree
Прокачка навыков без традиционных RPG классов:
- Mining: эффективность добычи
- Combat: урон и защита
- Exploration: скорость, выносливость
- Crafting: шанс получить дополнительные предметы

### Престиж система
При достижении 100 уровня:
- Опция сброса до 1 уровня
- Получение престиж поинтов
- Разблокировка уникальных перков

---

## Конфигурация

### Multiverse миры
`survival_plus/config/plugins/Multiverse-Core/worlds.yml`
- Определяет параметры каждого мира
- PvP, difficulty, respawn world
- Spawn settings

### OreControl руды
`survival_plus/config/plugins/OreControl/config.yml`
- sp_clean: ВСЕ руды отключены
- sp_basic: 3x базовые руды (coal, iron, copper, redstone, lapis)
- sp_danger: 2x редкие руды (gold, diamond, emerald)
- sp_cursed: 3x ancient_debris, nether руды
- sp_chaos: все руды, маленькие жилы но часто

### EpicWorldGenerator
`survival_plus/config/plugins/EpicWorldGenerator/worlds/Chaos.yml`
- 3D Perlin noise для floating islands
- Void generation (threshold 0.35)
- Multi-layer island generation
- Chaos effects (particles, random blocks, void pockets)

---

## Команды

### Телепортация между мирами
```
/mvtp sp_clean - в Clean World
/mvtp sp_basic - в Basic World (требует уровень 5)
/mvtp sp_danger - в Danger World (требует уровень 20)
/mvtp sp_cursed - в Cursed World (требует уровень 40)
/mvtp sp_chaos - в Chaos World (требует уровень 60 + активную сессию)
```

### Chaos сессии
```
/chaos start - начать сессию в Chaos World
/chaos status - проверить статус сессии
/chaos leave - выйти из Chaos (= смерть)
```

### Прогресс
```
/progress - показать текущий уровень и доступные миры
/skills - открыть skill tree
/prestige - сброс до 1 уровня (доступно с 100 lvl)
```

---

## Troubleshooting

### Миры не создаются
- Проверить что Multiverse-Core установлен: `/plugins`
- Создать вручную: `/mv create <world> NORMAL`

### EWG не генерирует Chaos мир
- Требуется EWG Premium для полной поддержки
- Альтернативы: Terra, Iris (требуют свои конфиги)
- Fallback: использовать vanilla End generation для похожего эффекта

### Руды не работают
- Проверить OreControl загружен: `/plugins`
- Reload конфига: `/oc reload`
- OreControl работает только с новыми чанками (очистить старые миры)

### Плагины не подгружают конфиги
- Проверить что `SYNC_SKIP_NEWER_IN_DESTINATION: "true"` в docker-compose.yml
- Проверить права доступа: `docker exec minecraft_survivalplus ls -la /config`
- Ручная копия: `docker cp ./survival_plus/config/. minecraft_survivalplus:/data/`

---

## Production checklist

- [ ] Скачать и установить все обязательные плагины
- [ ] Создать 5 миров через Multiverse
- [ ] Проверить OreControl генерацию в каждом мире
- [ ] Настроить LuckPerms права доступа по уровням
- [ ] Добавить кастомные материалы через ItemsAdder
- [ ] Создать кастомных мобов через MythicMobs
- [ ] Настроить skill tree (AureliumSkills/SkillAPI)
- [ ] Реализовать session систему для Chaos World
- [ ] Настроить daily XP cap
- [ ] Протестировать систему смерти во всех мирах
- [ ] Создать spawn зоны и защитить через WorldGuard
- [ ] Добавить tutorial для новых игроков

---

## Порт и подключение

- **Внутренний порт:** 25565 (стандартный Minecraft)
- **Внешний порт:** 25573
- **Подключение:** `/server survivalplus` из Velocity proxy
- **Direct access:** `mc.nettyan.ru:25573` (для тестирования)

---

**Автор конфигурации:** Claude Code
**Дата:** 2025-11-21
**Статус:** Конфигурация готова, требуется установка плагинов
