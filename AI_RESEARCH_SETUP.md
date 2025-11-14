# Настройка защиты AI Research сервера

## Команды WorldGuard для настройки защищенных зон

**ВАЖНО:** Выполнять команды в консоли AI_Research сервера после первого запуска.

### 1. Защита спавна в Обычном мире (world_ai)

Уже настроена защита 500x500 блоков. Проверить:

```bash
/rg info spawn
```

### 2. Защита спавна в Нижнем мире (world_ai_nether) - 50x50 блоков

**Телепортация в Нижний мир:**
```bash
/mv tp world_ai_nether
```

**Определить координаты спавна:**
```bash
/spawnpoint
# Предположим, спавн на координатах (0, 64, 0)
```

**Создать регион 50x50 вокруг спавна:**
```bash
# Регион от -25, 0, -25 до 25, 128, 25
/rg define nether_spawn -25 0 -25 25 128 25
```

**Установить флаги защиты:**
```bash
/rg flag nether_spawn pvp deny
/rg flag nether_spawn block-break deny
/rg flag nether_spawn block-place deny
/rg flag nether_spawn tnt deny
/rg flag nether_spawn creeper-explosion deny
/rg flag nether_spawn wither-damage deny
/rg flag nether_spawn ghast-fireball deny
/rg flag nether_spawn entry allow
/rg flag nether_spawn exit allow
```

**Установить приоритет:**
```bash
/rg priority nether_spawn 10
```

### 3. Край (world_ai_the_end) - Без защиты

**Полная анархия в Краю. Ничего не делаем.**

### 4. Проверка настроек

**Список регионов:**
```bash
/rg list
```

**Информация о регионе:**
```bash
/rg info nether_spawn
```

### 5. Дополнительная информация

**Границы защищенных зон:**

- **Обычный мир (world_ai):**
  - Регион `spawn`: 500x500 блоков (от -250 до 250)

- **Нижний мир (world_ai_nether):**
  - Регион `nether_spawn`: 50x50 блоков (от -25 до 25)

- **Край (world_ai_the_end):**
  - Без защиты (полная анархия)

**Кто может обходить защиту:**
- Группа `ai_research` имеет право `worldguard.region.bypass.*`
- Группа `netfather` имеет все права

### 6. Тестирование

**Тест 1: Обычный игрок в Нижнем мире**
1. Телепортировать игрока в nether_spawn регион
2. Попытаться сломать блок → должно быть запрещено
3. Выйти за пределы 50x50 → блоки ломаются (анархия)

**Тест 2: Игрок с группой ai_research**
1. Может ломать блоки даже в защищенных зонах
2. Использовать `/server ai_research` для переключения

**Тест 3: Край**
1. Телепортировать игрока в Край
2. Блоки ломаются везде (полная анархия)

---

## Быстрая настройка (копипаст)

Подключиться к консоли AI_Research сервера:

```bash
docker attach minecraft_airesearch
```

Скопировать и выполнить:

```bash
mv tp world_ai_nether
rg define nether_spawn -25 0 -25 25 128 25
rg flag nether_spawn pvp deny
rg flag nether_spawn block-break deny
rg flag nether_spawn block-place deny
rg flag nether_spawn tnt deny
rg flag nether_spawn creeper-explosion deny
rg flag nether_spawn wither-damage deny
rg flag nether_spawn ghast-fireball deny
rg flag nether_spawn entry allow
rg flag nether_spawn exit allow
rg priority nether_spawn 10
rg info nether_spawn
```

Отключиться от консоли без остановки сервера: **Ctrl+P, затем Ctrl+Q**

---

## Готово!

Защита Нижнего мира настроена. Край остается без защиты для полной анархии.
