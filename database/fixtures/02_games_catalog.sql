-- Database Fixtures: 02_games_catalog.sql
-- Seed Canonical Games, Platforms, Regions, and Servers

-- Game 1: Ethereal Odyssey (Fantasy MMORPG)
INSERT INTO games (id, slug, name, publisher_name, developer_name, official_site, status) VALUES
('c0000000-0000-0000-0000-000000000001', 'ethereal-odyssey', 'Ethereal Odyssey Online', 'Aether Interactive Inc.', 'Studio Horizon', 'https://ethereal-odyssey.example.com', 'ACTIVE')
ON CONFLICT (slug) DO NOTHING;

-- Game 2: Galactic Warzone (Sci-Fi Shooter & Economy)
INSERT INTO games (id, slug, name, publisher_name, developer_name, official_site, status) VALUES
('c0000000-0000-0000-0000-000000000002', 'galactic-warzone', 'Galactic Warzone Arena', 'Nova Prime Games', 'Nova Prime Studios', 'https://galactic-warzone.example.com', 'ACTIVE')
ON CONFLICT (slug) DO NOTHING;

-- Game 3: Mythic Realms (Cross-Platform ARPG)
INSERT INTO games (id, slug, name, publisher_name, developer_name, official_site, status) VALUES
('c0000000-0000-0000-0000-000000000003', 'mythic-realms', 'Mythic Realms Chronicles', 'Mythic Works Ltd.', 'Seven Seas Studios', 'https://mythicrealms.example.com', 'ACTIVE')
ON CONFLICT (slug) DO NOTHING;

-- Platforms for Ethereal Odyssey
INSERT INTO game_platforms (id, game_id, platform_code, status) VALUES
('d0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'PC', 'ACTIVE'),
('d0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'CONSOLE', 'ACTIVE')
ON CONFLICT (game_id, platform_code) DO NOTHING;

-- Platforms for Galactic Warzone
INSERT INTO game_platforms (id, game_id, platform_code, status) VALUES
('d0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000002', 'PC', 'ACTIVE')
ON CONFLICT (game_id, platform_code) DO NOTHING;

-- Platforms for Mythic Realms
INSERT INTO game_platforms (id, game_id, platform_code, status) VALUES
('d0000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000003', 'CROSS_PLATFORM', 'ACTIVE')
ON CONFLICT (game_id, platform_code) DO NOTHING;

-- Regions
INSERT INTO game_regions (id, game_id, region_code, display_name, status) VALUES
('e0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'NA', 'North America', 'ACTIVE'),
('e0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'EU', 'Europe', 'ACTIVE'),
('e0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'ASIA', 'Asia Pacific', 'ACTIVE')
ON CONFLICT (game_id, region_code) DO NOTHING;

-- Servers for Ethereal Odyssey
INSERT INTO game_servers (id, game_id, game_region_id, server_code, name, status) VALUES
('f0000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000001', 'NA-ALTAIR', 'Altair Prime', 'ACTIVE'),
('f0000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000002', 'EU-VEGA', 'Vega Vanguard', 'ACTIVE'),
('f0000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'e0000000-0000-0000-0000-000000000003', 'ASIA-SIRIUS', 'Sirius Horizon', 'ACTIVE')
ON CONFLICT (game_id, game_region_id, server_code) DO NOTHING;

-- Product Types for Ethereal Odyssey
INSERT INTO game_product_types (id, game_id, product_type, status) VALUES
('10000000-0000-0000-0000-000000000001', 'c0000000-0000-0000-0000-000000000001', 'GAME_ITEM', 'ACTIVE'),
('10000000-0000-0000-0000-000000000002', 'c0000000-0000-0000-0000-000000000001', 'GAME_CURRENCY', 'REVIEW_REQUIRED'),
('10000000-0000-0000-0000-000000000003', 'c0000000-0000-0000-0000-000000000001', 'GAME_ACCOUNT', 'INACTIVE'),
('10000000-0000-0000-0000-000000000004', 'c0000000-0000-0000-0000-000000000001', 'OFFICIAL_GIFT_CODE', 'ACTIVE')
ON CONFLICT (game_id, product_type) DO NOTHING;

