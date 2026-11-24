-- PostGIS eklentisini aktif et
CREATE EXTENSION IF NOT EXISTS postgis;

-- 1. Kullanıcılar Tablosu (Gönüllü, İşletme ve Yönetici rolleri)
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(120) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) CHECK (role IN ('volunteer', 'business', 'admin')) DEFAULT 'volunteer',
    paws_balance INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Besleme Noktaları Tablosu (CBS / Konum Tabanlı)
CREATE TABLE feeding_points (
    id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    location GEOMETRY(Point, 4326) NOT NULL,
    animal_density VARCHAR(20) CHECK (animal_density IN ('low', 'medium', 'high')) DEFAULT 'medium',
    lambda_coeff DOUBLE PRECISION DEFAULT 0.15,
    last_fed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT TRUE
);

-- Mekansal sorguları hızlandırmak için GIST indeksi
CREATE INDEX idx_feeding_points_location ON feeding_points USING GIST (location);

-- 3. Doğrulanmış Besleme Kayıtları Tablosu
CREATE TABLE feeding_logs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    point_id INTEGER REFERENCES feeding_points(id) ON DELETE CASCADE,
    photo_url TEXT NOT NULL,
    user_location GEOMETRY(Point, 4326) NOT NULL,
    distance_meters DOUBLE PRECISION NOT NULL,
    food_amount VARCHAR(20) CHECK (food_amount IN ('low', 'medium', 'full')),
    water_refilled BOOLEAN DEFAULT FALSE,
    exif_timestamp TIMESTAMP NOT NULL,
    status VARCHAR(20) CHECK (status IN ('approved', 'pending_review', 'rejected')) DEFAULT 'approved',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. QR Kodlu Ödül ve Kupon Tablosu
CREATE TABLE reward_coupons (
    id SERIAL PRIMARY KEY,
    business_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(120) NOT NULL,
    paws_cost INTEGER NOT NULL,
    qr_token UUID UNIQUE NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    is_used BOOLEAN DEFAULT FALSE
);
