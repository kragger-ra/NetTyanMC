-- ============================================
-- PostgreSQL Init Script for AgiCraft Server
-- ============================================

-- Database 'minecraft_server' is automatically created by POSTGRES_DB env var
-- This script runs after database creation
-- Use UTF8 encoding
SET client_encoding = 'UTF8';

-- ============================================
-- LUCKPERMS TABLES (Standard schema from LuckPerms docs)
-- ============================================

CREATE TABLE IF NOT EXISTS luckperms_players (
    uuid VARCHAR(36) PRIMARY KEY,
    username VARCHAR(16) NOT NULL,
    primary_group VARCHAR(36) NOT NULL
);

CREATE TABLE IF NOT EXISTS luckperms_user_permissions (
    id SERIAL PRIMARY KEY,
    uuid VARCHAR(36) NOT NULL,
    permission VARCHAR(200) NOT NULL,
    value BOOLEAN NOT NULL,
    server VARCHAR(36) DEFAULT 'global',
    world VARCHAR(64) DEFAULT 'global',
    expiry BIGINT DEFAULT 0,
    contexts VARCHAR(200) DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS luckperms_group_permissions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(36) NOT NULL,
    permission VARCHAR(200) NOT NULL,
    value BOOLEAN NOT NULL,
    server VARCHAR(36) DEFAULT 'global',
    world VARCHAR(64) DEFAULT 'global',
    expiry BIGINT DEFAULT 0,
    contexts VARCHAR(200) DEFAULT '{}'
);

CREATE TABLE IF NOT EXISTS luckperms_groups (
    name VARCHAR(36) PRIMARY KEY,
    parent VARCHAR(36),
    weight INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS luckperms_actions (
    id SERIAL PRIMARY KEY,
    time BIGINT NOT NULL,
    actor_uuid VARCHAR(36) NOT NULL,
    actor_name VARCHAR(100) NOT NULL,
    type VARCHAR(1) NOT NULL,
    acted_uuid VARCHAR(36),
    acted_name VARCHAR(36) NOT NULL,
    action VARCHAR(300) NOT NULL
);

CREATE TABLE IF NOT EXISTS luckperms_tracks (
    name VARCHAR(36) PRIMARY KEY,
    groups TEXT NOT NULL
);

-- Indexes for LuckPerms
CREATE INDEX IF NOT EXISTS luckperms_user_permissions_uuid ON luckperms_user_permissions(uuid);
CREATE INDEX IF NOT EXISTS luckperms_group_permissions_name ON luckperms_group_permissions(name);

-- ============================================
-- AUTHME TABLES (for Survival server authentication)
-- ============================================

CREATE TABLE IF NOT EXISTS authme (
    id SERIAL PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    realname VARCHAR(255) NOT NULL,
    password VARCHAR(255) NOT NULL,
    ip VARCHAR(40) DEFAULT '127.0.0.1',
    lastlogin BIGINT DEFAULT 0,
    x DOUBLE PRECISION DEFAULT 0,
    y DOUBLE PRECISION DEFAULT 0,
    z DOUBLE PRECISION DEFAULT 0,
    world VARCHAR(255) DEFAULT 'world',
    regdate BIGINT DEFAULT 0,
    regip VARCHAR(40),
    yaw REAL DEFAULT 0,
    pitch REAL DEFAULT 0,
    email VARCHAR(255),
    isLogged SMALLINT DEFAULT 0,
    hasSession SMALLINT DEFAULT 0
);

-- ============================================
-- WEB SITE TABLES (for website and bot management)
-- ============================================

-- Users table for website
CREATE TABLE IF NOT EXISTS web_users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(16) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    minecraft_nickname VARCHAR(16) UNIQUE,
    minecraft_uuid VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP
);

-- AgiCoins balance table
CREATE TABLE IF NOT EXISTS web_agicoins_balance (
    user_id INTEGER PRIMARY KEY REFERENCES web_users(id) ON DELETE CASCADE,
    balance INTEGER DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- AgiCoins transactions history
CREATE TABLE IF NOT EXISTS web_agicoins_transactions (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES web_users(id) ON DELETE CASCADE,
    amount INTEGER NOT NULL,
    type VARCHAR(50) NOT NULL, -- purchase, vote, exchange, event, spend, reward
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Donate products (ranks, kits, upgrades, cosmetics)
CREATE TABLE IF NOT EXISTS web_donate_products (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price_agicoins INTEGER NOT NULL,
    price_rubles INTEGER DEFAULT 0, -- For direct purchases (AgiCoins packs)
    luckperms_group VARCHAR(50),
    duration_days INTEGER,
    product_type VARCHAR(20) NOT NULL, -- rank, kit, upgrade, cosmetic, agicoins
    metadata JSONB DEFAULT '{}'::jsonb,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Donations/purchases history
CREATE TABLE IF NOT EXISTS web_donations (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES web_users(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES web_donate_products(id),
    amount_agicoins INTEGER,
    amount_rubles INTEGER,
    status VARCHAR(20) DEFAULT 'pending', -- pending, completed, failed, refunded
    yookassa_payment_id VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP
);

-- News articles
CREATE TABLE IF NOT EXISTS web_news (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    author_id INTEGER REFERENCES web_users(id) ON DELETE SET NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_published BOOLEAN DEFAULT TRUE
);

-- Indexes for better performance
CREATE INDEX IF NOT EXISTS idx_web_agicoins_transactions_user ON web_agicoins_transactions(user_id);
CREATE INDEX IF NOT EXISTS idx_web_donations_user ON web_donations(user_id);
CREATE INDEX IF NOT EXISTS idx_web_donations_status ON web_donations(status);
CREATE INDEX IF NOT EXISTS idx_web_news_published ON web_news(is_published, created_at DESC);

-- ============================================
-- INITIAL DATA (for testing)
-- ============================================

-- Insert default donate products
INSERT INTO web_donate_products (name, description, price_agicoins, luckperms_group, duration_days, product_type) VALUES
('NEW (2 месяца)', 'Белый префикс, автосортировка, 4 дома, приоритет в очереди', 35, 'new', 60, 'rank'),
('NEW (6 месяцев)', 'Экономия 15₽ (-14%)', 90, 'new', 180, 'rank'),
('NEW (12 месяцев)', 'Экономия 45₽ (-21%)', 165, 'new', 365, 'rank'),
('HELPER (2 месяца)', 'Серый префикс, команда /hat, 5 домов, 2 профессии', 99, 'helper', 60, 'rank'),
('HELPER (6 месяцев)', 'Экономия 47₽ (-16%)', 250, 'helper', 180, 'rank'),
('HELPER (12 месяцев)', 'Экономия 124₽ (-21%)', 470, 'helper', 365, 'rank'),
('STARTER (2 месяца)', 'Зелёный префикс, смена ника, 6 домов, 4 лота на аукционе', 199, 'starter', 60, 'rank'),
('STARTER (6 месяцев)', 'Экономия 97₽ (-16%)', 500, 'starter', 180, 'rank'),
('STARTER (12 месяцев)', 'Экономия 244₽ (-20%)', 950, 'starter', 365, 'rank'),
('VIP (2 месяца)', 'Голубой префикс, полет в приватах, veinminer, 8 домов, 3 профессии', 399, 'vip', 60, 'rank'),
('VIP (6 месяцев)', 'Экономия 197₽ (-16%)', 1000, 'vip', 180, 'rank'),
('VIP (12 месяцев)', 'Экономия 494₽ (-21%)', 1900, 'vip', 365, 'rank'),
('PREMIUM (2 месяца)', 'Фиолетовый префикс, полет везде, ускоренный полет, 12 домов, 4 профессии', 799, 'premium', 60, 'rank'),
('PREMIUM (6 месяцев)', 'Экономия 397₽ (-17%)', 2000, 'premium', 180, 'rank'),
('PREMIUM (12 месяцев)', 'Экономия 994₽ (-21%)', 3800, 'premium', 365, 'rank'),
('ELITE (2 месяца)', 'Золотой префикс, макс скорость полета, /repair, WorldEdit, 18 домов', 1299, 'elite', 60, 'rank'),
('ELITE (6 месяцев)', 'Экономия 597₽ (-15%)', 3300, 'elite', 180, 'rank'),
('ELITE (12 месяцев)', 'Экономия 1594₽ (-20%)', 6200, 'elite', 365, 'rank'),
('LEGEND (2 месяца)', 'Красный жирный префикс, частицы, /god, 25 домов, эксклюзивные предметы', 1999, 'legend', 60, 'rank'),
('LEGEND (6 месяцев)', 'Экономия 997₽ (-17%)', 5000, 'legend', 180, 'rank'),
('LEGEND (12 месяцев)', 'Экономия 2494₽ (-21%)', 9500, 'legend', 365, 'rank')
ON CONFLICT DO NOTHING;

-- Insert AgiCoins purchase packages
INSERT INTO web_donate_products (name, description, price_agicoins, price_rubles, product_type) VALUES
('100 AgiCoins', '100₽ → 110 AgiCoins (+10% бонус)', 0, 100, 'agicoins'),
('500 AgiCoins', '500₽ → 575 AgiCoins (+15% бонус)', 0, 500, 'agicoins'),
('1000 AgiCoins', '1000₽ → 1200 AgiCoins (+20% бонус)', 0, 1000, 'agicoins'),
('2500 AgiCoins', '2500₽ → 3125 AgiCoins (+25% бонус)', 0, 2500, 'agicoins'),
('5000 AgiCoins', '5000₽ → 6500 AgiCoins (+30% бонус)', 0, 5000, 'agicoins')
ON CONFLICT DO NOTHING;

-- ============================================
-- FUNCTIONS AND TRIGGERS
-- ============================================

-- Function to automatically create AgiCoins balance for new users
CREATE OR REPLACE FUNCTION create_agicoins_balance()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO web_agicoins_balance (user_id, balance) VALUES (NEW.id, 0);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create AgiCoins balance when user is created
DROP TRIGGER IF EXISTS trigger_create_agicoins_balance ON web_users;
CREATE TRIGGER trigger_create_agicoins_balance
AFTER INSERT ON web_users
FOR EACH ROW
EXECUTE FUNCTION create_agicoins_balance();

-- Function to update balance timestamp
CREATE OR REPLACE FUNCTION update_agicoins_balance_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update timestamp on balance change
DROP TRIGGER IF EXISTS trigger_update_balance_timestamp ON web_agicoins_balance;
CREATE TRIGGER trigger_update_balance_timestamp
BEFORE UPDATE ON web_agicoins_balance
FOR EACH ROW
EXECUTE FUNCTION update_agicoins_balance_timestamp();

-- ============================================
-- COMPLETION MESSAGE
-- ============================================

DO $$
BEGIN
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'AgiCraft Database Initialized Successfully!';
    RAISE NOTICE '=============================================';
    RAISE NOTICE 'Tables created:';
    RAISE NOTICE '  - LuckPerms: 6 tables';
    RAISE NOTICE '  - AuthMe: 1 table';
    RAISE NOTICE '  - Website: 6 tables';
    RAISE NOTICE '  - Donate products: 26 initial products';
    RAISE NOTICE '=============================================';
END $$;
