-- ============================================================================
-- GOVSERVE / PAFMS SUPABASE COMPLETE MIGRATION & SEED SCRIPT
-- Execute this script in your Supabase Project SQL Editor:
-- Dashboard -> SQL Editor -> New Query -> Paste & Run
-- ============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. USERS TABLE
CREATE TABLE IF NOT EXISTS public.users (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL,
  password VARCHAR(100) NOT NULL,
  pin VARCHAR(6) DEFAULT '123456',
  last_otp_at TIMESTAMP WITH TIME ZONE,
  role VARCHAR(50) NOT NULL DEFAULT 'Citizen',
  department VARCHAR(100) DEFAULT 'General Public',
  phone VARCHAR(50),
  avatar VARCHAR(255),
  status VARCHAR(50) DEFAULT 'Active',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 2. FACILITIES & PARKS TABLE (Per Facility / Park Custom Time Slot Controls)
CREATE TABLE IF NOT EXISTS public.facilities (
  id SERIAL PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  category VARCHAR(50) NOT NULL,
  capacity INT DEFAULT 50,
  hourly_rate NUMERIC(10, 2) DEFAULT 0,
  morning_start VARCHAR(20) DEFAULT '08:00 AM',
  morning_end VARCHAR(20) DEFAULT '12:00 PM',
  morning_enabled BOOLEAN DEFAULT true,
  afternoon_start VARCHAR(20) DEFAULT '01:00 PM',
  afternoon_end VARCHAR(20) DEFAULT '05:00 PM',
  afternoon_enabled BOOLEAN DEFAULT true,
  wholeday_enabled BOOLEAN DEFAULT true,
  location VARCHAR(255) NOT NULL,
  amenities TEXT DEFAULT 'Sound System, Aircon, Chairs, Stage',
  status VARCHAR(50) DEFAULT 'Available',
  image_url TEXT,
  image_url_2 TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Ensure columns exist if table was already created
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS morning_start VARCHAR(20) DEFAULT '08:00 AM';
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS morning_end VARCHAR(20) DEFAULT '12:00 PM';
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS morning_enabled BOOLEAN DEFAULT true;
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS afternoon_start VARCHAR(20) DEFAULT '01:00 PM';
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS afternoon_end VARCHAR(20) DEFAULT '05:00 PM';
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS afternoon_enabled BOOLEAN DEFAULT true;
ALTER TABLE public.facilities ADD COLUMN IF NOT EXISTS wholeday_enabled BOOLEAN DEFAULT true;

-- 3. FACILITY RESERVATIONS TABLE
CREATE TABLE IF NOT EXISTS public.facility_reservations (
  id SERIAL PRIMARY KEY,
  reference_no VARCHAR(50) UNIQUE NOT NULL,
  facility_id INT REFERENCES public.facilities(id) ON DELETE SET NULL,
  citizen_id INT,
  applicant_name VARCHAR(100) NOT NULL,
  applicant_email VARCHAR(100) NOT NULL,
  citizen_email VARCHAR(100),
  applicant_phone VARCHAR(50) NOT NULL,
  purpose VARCHAR(200) NOT NULL,
  event_date DATE NOT NULL,
  start_time VARCHAR(20) NOT NULL,
  end_time VARCHAR(20) NOT NULL,
  attendees INT DEFAULT 20,
  special_equipment TEXT,
  fee_amount NUMERIC(10, 2) DEFAULT 0,
  hours NUMERIC(5, 2) DEFAULT 0,
  status VARCHAR(50) DEFAULT 'Pending Review',
  remarks TEXT,
  payment_method VARCHAR(50),
  paid_at TIMESTAMP WITH TIME ZONE,
  payment_due_date DATE,
  activity_type VARCHAR(100),
  sponsorship_photo_url TEXT,
  event_name VARCHAR(200),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. CEMETERY PLOTS TABLE (Columbarium Wall Grid & Lawn Lots)
CREATE TABLE IF NOT EXISTS public.cemetery_plots (
  id SERIAL PRIMARY KEY,
  cemetery_name VARCHAR(150) DEFAULT 'Barangay 178 Municipal Cemetery',
  plot_code VARCHAR(50) UNIQUE NOT NULL,
  section VARCHAR(50) NOT NULL,
  block_no VARCHAR(20) NOT NULL,
  lot_no VARCHAR(20) NOT NULL,
  row_no INT,
  col_no INT,
  plot_type VARCHAR(50) DEFAULT 'Columbarium Niche',
  status VARCHAR(50) DEFAULT 'Available',
  price NUMERIC(10, 2) DEFAULT 15000.00,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. BURIAL RECORDS TABLE
CREATE TABLE IF NOT EXISTS public.burial_records (
  id SERIAL PRIMARY KEY,
  reference_no VARCHAR(50) UNIQUE NOT NULL,
  deceased_name VARCHAR(100) NOT NULL,
  date_of_birth DATE,
  date_of_death DATE NOT NULL,
  burial_date DATE NOT NULL,
  plot_id INT REFERENCES public.cemetery_plots(id) ON DELETE SET NULL,
  plot_code VARCHAR(50),
  section VARCHAR(50),
  cemetery_name VARCHAR(150) DEFAULT 'Barangay 178 Municipal Cemetery',
  contact_person VARCHAR(100) NOT NULL,
  contact_phone VARCHAR(50) NOT NULL,
  applicant_email VARCHAR(100),
  citizen_email VARCHAR(100),
  citizen_id INT,
  cause_of_death VARCHAR(200),
  deceased_address VARCHAR(255),
  attending_physician VARCHAR(150),
  applicant_relationship VARCHAR(100),
  applicant_address VARCHAR(255),
  burial_time VARCHAR(20),
  fee_amount NUMERIC(10, 2) DEFAULT 0,
  status VARCHAR(50) DEFAULT 'Approved',
  permit_no VARCHAR(50) UNIQUE,
  remarks TEXT,
  payment_method VARCHAR(50),
  paid_at TIMESTAMP WITH TIME ZONE,
  payment_due_date DATE,
  death_certificate_url TEXT,
  valid_id_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. UTILITY REQUESTS TABLE
CREATE TABLE IF NOT EXISTS public.utility_requests (
  id SERIAL PRIMARY KEY,
  ticket_no VARCHAR(50) UNIQUE NOT NULL,
  citizen_name VARCHAR(100) NOT NULL,
  citizen_email VARCHAR(100),
  citizen_id INT,
  citizen_phone VARCHAR(50) NOT NULL,
  service_type VARCHAR(100) NOT NULL,
  location VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  photo_url TEXT,
  affected_households VARCHAR(100),
  urgency VARCHAR(20) DEFAULT 'Normal',
  ai_priority_score INT DEFAULT 60,
  status VARCHAR(50) DEFAULT 'Pending',
  assigned_team VARCHAR(100),
  resolution_notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  resolved_at TIMESTAMP WITH TIME ZONE
);

-- 7. ASSETS INVENTORY TABLE
CREATE TABLE IF NOT EXISTS public.assets (
  id SERIAL PRIMARY KEY,
  asset_tag VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(150) NOT NULL,
  category VARCHAR(100) NOT NULL,
  serial_no VARCHAR(100),
  purchase_date DATE,
  purchase_cost NUMERIC(15, 2) DEFAULT 0,
  current_condition VARCHAR(50) DEFAULT 'Operational',
  assigned_department VARCHAR(100) NOT NULL,
  last_maintenance_date DATE,
  next_maintenance_due DATE,
  ai_maintenance_alert TEXT,
  specs TEXT,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. SYSTEM ACTIVITY LOGS TABLE
CREATE TABLE IF NOT EXISTS public.activity_logs (
  id SERIAL PRIMARY KEY,
  user_name VARCHAR(100) NOT NULL,
  action VARCHAR(100) NOT NULL,
  module VARCHAR(50) NOT NULL,
  details TEXT,
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_users_email ON public.users(email);
CREATE INDEX IF NOT EXISTS idx_facilities_category ON public.facilities(category);
CREATE INDEX IF NOT EXISTS idx_reservations_status ON public.facility_reservations(status);
CREATE INDEX IF NOT EXISTS idx_reservations_citizen_email ON public.facility_reservations(citizen_email);
CREATE INDEX IF NOT EXISTS idx_plots_code ON public.cemetery_plots(plot_code);
CREATE INDEX IF NOT EXISTS idx_plots_status ON public.cemetery_plots(status);
CREATE INDEX IF NOT EXISTS idx_burials_ref ON public.burial_records(reference_no);
CREATE INDEX IF NOT EXISTS idx_utilities_ticket ON public.utility_requests(ticket_no);
CREATE INDEX IF NOT EXISTS idx_assets_tag ON public.assets(asset_tag);

-- ============================================================================
-- PERMISSIONS & ROW LEVEL SECURITY (RLS)
-- Grant access to anon & authenticated roles for client-side API interaction
-- ============================================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL TABLES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated, service_role;
GRANT ALL ON ALL ROUTINES IN SCHEMA public TO anon, authenticated, service_role;

ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO anon, authenticated, service_role;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO anon, authenticated, service_role;

-- Disable RLS on tables so the anon client can read/write directly
ALTER TABLE public.users DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.facilities DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.facility_reservations DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.cemetery_plots DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.burial_records DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.utility_requests DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.assets DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_logs DISABLE ROW LEVEL SECURITY;

-- ============================================================================
-- INITIAL SEED DATA
-- ============================================================================

-- Super Admin Users
INSERT INTO public.users (name, email, password, pin, role, department, avatar) 
VALUES ('Atty. Elena Ramos', 'admin@govserve.gov.ph', 'admin123', '123456', 'Super Admin', 'Municipal Executive Office', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80')
ON CONFLICT (email) DO UPDATE SET password = EXCLUDED.password, pin = EXCLUDED.pin, role = EXCLUDED.role;

INSERT INTO public.users (name, email, password, pin, role, department, phone, avatar) 
VALUES ('Municipal Administrator', 'wahtah173@gmail.com', 'Admin1234567!', '123456', 'Super Admin', 'Municipal Executive Office', '+63 917 000 0000', 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80')
ON CONFLICT (email) DO UPDATE SET password = EXCLUDED.password, pin = EXCLUDED.pin, role = EXCLUDED.role;

-- Demo Citizen User
INSERT INTO public.users (name, email, password, pin, role, department, phone, avatar) 
VALUES ('Juan M. Dela Cruz', 'juan.delacruz@citizen.gov.ph', 'citizen123', '123456', 'Citizen', 'Resident / Brgy. 178', '+63 917 123 4567', 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=150&auto=format&fit=crop&q=80')
ON CONFLICT (email) DO UPDATE SET password = EXCLUDED.password, pin = EXCLUDED.pin, role = EXCLUDED.role;

-- Facilities & Parks (Per-facility morning and afternoon slot schedules)
INSERT INTO public.facilities (name, category, capacity, hourly_rate, morning_start, morning_end, morning_enabled, afternoon_start, afternoon_end, afternoon_enabled, wholeday_enabled, location, amenities, status, image_url) 
VALUES
('Barangay 178 Multi-Purpose Civic Center', 'Government Facility', 350, 500.00, '08:00 AM', '12:00 PM', true, '01:00 PM', '05:00 PM', true, true, 'Civic Complex, Mindanao Ave.', 'Central Aircon, Full PA Sound System, Stage, 300 Chairs, Generator Backup', 'Available', 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=500&auto=format&fit=crop&q=80'),
('Camarin Green Urban Recreation Park', 'Park & Recreation', 500, 0.00, '06:00 AM', '11:00 AM', true, '01:00 PM', '06:00 PM', true, true, 'Camarin Road Sector 3', 'Jogging Trail, Children Playground, Gazebo, Covered Picnic Sheds, Solar Lights', 'Available', 'https://images.unsplash.com/photo-1519331379826-f10be5486c6f?w=500&auto=format&fit=crop&q=80'),
('Purok 7 Community Amphitheater & Plaza', 'Park & Recreation', 400, 250.00, '07:00 AM', '12:00 PM', true, '02:00 PM', '07:00 PM', true, true, 'Purok 7 Hillsview', 'Open-Air Stage, Tiered Seating, Ambient Garden Lighting, Perimeter Fence', 'Available', 'https://images.unsplash.com/photo-1506157786151-b8491531f063?w=500&auto=format&fit=crop&q=80')
ON CONFLICT DO NOTHING;

-- Columbarium Niches (9 Rows x 10 Columns = 90 Niches in Columbarium Wall Alpha)
DO $$
BEGIN
  FOR r IN 1..9 LOOP
    FOR c IN 1..10 LOOP
      DECLARE
        row_str VARCHAR(10) := CASE WHEN r < 10 THEN 'R0' || r ELSE 'R' || r END;
        col_str VARCHAR(10) := CASE WHEN c < 10 THEN 'C0' || c ELSE 'C' || c END;
        p_code VARCHAR(50) := 'COL-' || row_str || '-' || col_str;
        p_status VARCHAR(50) := 'Available';
      BEGIN
        IF (r = 1 AND c = 2) OR (r = 2 AND c = 5) OR (r = 3 AND c = 8) OR (r = 5 AND c = 6) OR (r = 7 AND c = 9) OR (r = 9 AND c IN (1, 2, 3)) THEN
          p_status := 'Occupied';
        ELSIF (r = 1 AND c = 4) OR (r = 4 AND c = 7) OR (r = 6 AND c = 3) OR (r = 9 AND c = 4) THEN
          p_status := 'Reserved';
        END IF;

        INSERT INTO public.cemetery_plots (cemetery_name, plot_code, section, block_no, lot_no, row_no, col_no, plot_type, status, price)
        VALUES ('Barangay 178 Municipal Cemetery', p_code, 'Columbarium Wall Alpha', 'Row ' || r, 'Vault ' || c, r, c, 'Columbarium Niche', p_status, 18000.00)
        ON CONFLICT (plot_code) DO NOTHING;
      END;
    END LOOP;
  END LOOP;
END $$;

-- Lawn Lots & Mausoleums
DO $$
BEGIN
  FOR i IN 1..10 LOOP
    DECLARE
      p_code VARCHAR(50) := 'SEC-A-B01-L' || (CASE WHEN i < 10 THEN '0' || i ELSE '' || i END);
      p_status VARCHAR(50) := CASE WHEN i <= 3 THEN 'Occupied' WHEN i = 4 THEN 'Reserved' ELSE 'Available' END;
    BEGIN
      INSERT INTO public.cemetery_plots (cemetery_name, plot_code, section, block_no, lot_no, plot_type, status, price)
      VALUES ('Barangay 178 Municipal Cemetery', p_code, 'Section A - St. Peter Lawn', 'Block 1', 'Lot ' || i, 'Lawn Lot', p_status, 25000.00)
      ON CONFLICT (plot_code) DO NOTHING;
    END;
  END LOOP;
END $$;

-- Initial Burial Records
INSERT INTO public.burial_records (reference_no, deceased_name, date_of_birth, date_of_death, burial_date, plot_id, contact_person, contact_phone, status, permit_no, applicant_email, citizen_email)
VALUES
('BUR-2026-081', 'Severino M. Dela Cruz', '1948-03-12', '2026-08-15', '2026-08-20', 1, 'Maria Dela Cruz (Daughter)', '+63 917 222 8891', 'Completed', 'BP-2026-0089', 'maria.delacruz@citizen.gov.ph', 'maria.delacruz@citizen.gov.ph'),
('BUR-2026-082', 'Florencia T. Bautista', '1955-09-24', '2026-08-18', '2026-08-24', 2, 'Ricardo Bautista (Husband)', '+63 919 333 7712', 'Completed', 'BP-2026-0090', 'ricardo.b@gmail.com', 'ricardo.b@gmail.com'),
('BUR-2026-083', 'Hon. Benjamin G. Ramos', '1940-11-05', '2026-08-21', CURRENT_DATE + INTERVAL '2 day', 5, 'Consuelo Ramos (Wife)', '+63 922 444 1109', 'Approved', 'BP-2026-0091', 'consuelo.ramos@gmail.com', 'consuelo.ramos@gmail.com')
ON CONFLICT (reference_no) DO NOTHING;

-- Initial Municipal Assets
INSERT INTO public.assets (asset_tag, name, category, serial_no, purchase_date, purchase_cost, current_condition, assigned_department, last_maintenance_date, next_maintenance_due, ai_maintenance_alert, specs, image_url)
VALUES
('AST-2026-001', 'Isuzu 5,000L Rapid Water Response Tanker', 'Heavy Equipment', 'ISZ-WT-88219', '2024-02-15', 3200000, 'Operational', 'Disaster Risk Reduction & Management (DRRMO)', '2026-01-10', '2026-09-15', 'Optimal condition - next periodic oil change due in September.', 'High-pressure water cannon, 5000L tank, 4x4 off-road chassis, dual fire hose connectors', 'https://images.unsplash.com/photo-1596720426673-e4e14290f0cc?w=600&auto=format&fit=crop&q=80'),
('AST-2026-002', 'Caterpillar 45kVA Civic Standby Diesel Generator', 'Water Pump & Generator', 'CAT-GEN-9901', '2023-08-20', 850000, 'Operational', 'Barangay 178 Civic Center', '2026-02-05', '2026-10-01', 'Battery backup level normal. Ready for typhoon emergency standby.', '45kVA 3-Phase Silent Type, Automatic Transfer Switch (ATS), 120L fuel reservoir', 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=600&auto=format&fit=crop&q=80'),
('AST-2026-003', 'Komatsu PC30 Hydraulic Mini Backhoe Excavator', 'Heavy Equipment', 'KOM-EXC-4402', '2023-11-10', 2450000, 'Operational', 'Municipal Engineering & Drainage Maintenance', '2026-02-14', '2026-08-30', 'Hydraulic pressure nominal. Regularly used for canal dredging.', '0.12 m3 bucket, rubber crawler tracks for street work, 3.2m digging depth', 'https://images.unsplash.com/photo-1579487785973-74d2ca7abdd5?w=600&auto=format&fit=crop&q=80'),
('AST-2026-004', 'Toyota HiAce Type-II Emergency Rescue Ambulance', 'Service Vehicle', 'TOY-AMB-7718', '2024-05-12', 2100000, 'Operational', 'Municipal Health Office (MHO) & Emergency EMS', '2026-02-18', '2026-11-20', 'Defibrillator and oxygen tank certified inspection passed.', 'Stretcher system, portable ECG monitor, trauma kit, siren & LED beacon bar', 'https://images.unsplash.com/photo-1587745416684-47953f16f02f?w=600&auto=format&fit=crop&q=80')
ON CONFLICT (asset_tag) DO NOTHING;

-- Initial Utility Request
INSERT INTO public.utility_requests (ticket_no, citizen_name, citizen_email, citizen_phone, service_type, location, description, affected_households, urgency, ai_priority_score, status, assigned_team, resolution_notes)
VALUES
('UTL-2026-001', 'Juan M. Dela Cruz', 'juan.delacruz@citizen.gov.ph', '+63 917 123 4567', 'Drainage Declogging', 'Zone 2, Main Drainage Culvert', 'Heavy blockage causing backflow during high tide and rain.', '6 - 15 Households (Entire Street / Alley)', 'Urgent', 85, 'In Progress', 'Barangay Drainage Team Alpha', 'Crew Alpha dispatched with suction tanker')
ON CONFLICT (ticket_no) DO NOTHING;

-- Initial Facility Reservation
INSERT INTO public.facility_reservations (reference_no, facility_id, applicant_name, applicant_email, citizen_email, applicant_phone, purpose, event_date, start_time, end_time, attendees, status, remarks)
VALUES
('RES-2026-001', 1, 'Juan M. Dela Cruz', 'juan.delacruz@citizen.gov.ph', 'juan.delacruz@citizen.gov.ph', '+63 917 123 4567', 'Barangay Community Sports League Opening Assembly', '2026-09-05', '08:00 AM', '12:00 PM', 150, 'Approved', 'Approved by Executive Committee & Facilities Bureau')
ON CONFLICT (reference_no) DO NOTHING;
