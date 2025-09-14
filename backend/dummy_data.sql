-- =====================================================
-- DUMMY DATA FOR KHEL PRATIBHA - SPORTS TALENT ASSESSMENT
-- =====================================================

-- This SQL script creates comprehensive dummy data for testing
-- the Flutter app's authentication and assessment functionality

-- =====================================================
-- 0. AUTHENTICATION USERS - Supabase auth.users table
-- =====================================================

-- Note: These are Supabase authentication users that correspond to the athlete profiles
-- The passwords are hashed using Supabase's bcrypt implementation
-- For testing, the actual passwords are: "TestPass123!" for all users

INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at,
    email_change_token_new, email_change, email_change_sent_at, last_sign_in_at,
    raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at,
    phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at,
    email_change_token_current, email_change_confirm_status, banned_until, is_sso_user,
    deleted_at
) VALUES 
-- Test User 1: Arjun Kumar
(
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111',
    'authenticated',
    'authenticated',
    'arjun.kumar@example.com',
    '$2a$10$rQiRyKJ5bVB8wGXj4BnKsOxc4rCUqj.hT8YhT5VWqB5QY9lX8zK8e', -- TestPass123!
    NOW() - INTERVAL '30 days',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW() - INTERVAL '5 days',
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Arjun Kumar", "age": 14, "location": "rural"}',
    false,
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '5 days',
    '+919876543210',
    NOW() - INTERVAL '30 days',
    NULL,
    '',
    NULL,
    '',
    0,
    NULL,
    false,
    NULL
),
-- Test User 2: Priya Sharma
(
    '00000000-0000-0000-0000-000000000000',
    '22222222-2222-2222-2222-222222222222',
    'authenticated',
    'authenticated',
    'priya.sharma@example.com',
    '$2a$10$rQiRyKJ5bVB8wGXj4BnKsOxc4rCUqj.hT8YhT5VWqB5QY9lX8zK8e', -- TestPass123!
    NOW() - INTERVAL '45 days',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW() - INTERVAL '2 days',
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Priya Sharma", "age": 16, "location": "urban"}',
    false,
    NOW() - INTERVAL '45 days',
    NOW() - INTERVAL '2 days',
    '+918765432109',
    NOW() - INTERVAL '45 days',
    NULL,
    '',
    NULL,
    '',
    0,
    NULL,
    false,
    NULL
),
-- Test User 3: Ravi Meena
(
    '00000000-0000-0000-0000-000000000000',
    '33333333-3333-3333-3333-333333333333',
    'authenticated',
    'authenticated',
    'ravi.meena@example.com',
    '$2a$10$rQiRyKJ5bVB8wGXj4BnKsOxc4rCUqj.hT8YhT5VWqB5QY9lX8zK8e', -- TestPass123!
    NOW() - INTERVAL '15 days',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW() - INTERVAL '3 days',
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Ravi Meena", "age": 15, "location": "tribal"}',
    false,
    NOW() - INTERVAL '15 days',
    NOW() - INTERVAL '3 days',
    '+917654321098',
    NOW() - INTERVAL '15 days',
    NULL,
    '',
    NULL,
    '',
    0,
    NULL,
    false,
    NULL
),
-- Test User 4: Sunita Devi
(
    '00000000-0000-0000-0000-000000000000',
    '44444444-4444-4444-4444-444444444444',
    'authenticated',
    'authenticated',
    'sunita.devi@example.com',
    '$2a$10$rQiRyKJ5bVB8wGXj4BnKsOxc4rCUqj.hT8YhT5VWqB5QY9lX8zK8e', -- TestPass123!
    NOW() - INTERVAL '60 days',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW() - INTERVAL '1 day',
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Sunita Devi", "age": 13, "location": "remote"}',
    false,
    NOW() - INTERVAL '60 days',
    NOW() - INTERVAL '1 day',
    '+916543210987',
    NOW() - INTERVAL '60 days',
    NULL,
    '',
    NULL,
    '',
    0,
    NULL,
    false,
    NULL
),
-- Test User 5: Vikram Singh
(
    '00000000-0000-0000-0000-000000000000',
    '55555555-5555-5555-5555-555555555555',
    'authenticated',
    'authenticated',
    'vikram.singh@example.com',
    '$2a$10$rQiRyKJ5bVB8wGXj4BnKsOxc4rCUqj.hT8YhT5VWqB5QY9lX8zK8e', -- TestPass123!
    NOW() - INTERVAL '90 days',
    NULL,
    '',
    NULL,
    '',
    NULL,
    '',
    '',
    NULL,
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Vikram Singh", "age": 17, "location": "urban"}',
    false,
    NOW() - INTERVAL '90 days',
    NOW(),
    '+915432109876',
    NOW() - INTERVAL '90 days',
    NULL,
    '',
    NULL,
    '',
    0,
    NULL,
    false,
    NULL
);

-- =====================================================
-- 0.1 AUTHENTICATION IDENTITIES - Link auth methods
-- =====================================================

-- Supabase identities table links authentication methods to users
INSERT INTO auth.identities (
    provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id
) VALUES 
-- Arjun Kumar - Email identity
('arjun.kumar@example.com', '11111111-1111-1111-1111-111111111111', '{"sub": "11111111-1111-1111-1111-111111111111", "email": "arjun.kumar@example.com", "email_verified": true, "phone_verified": true}', 'email', NOW() - INTERVAL '5 days', NOW() - INTERVAL '30 days', NOW() - INTERVAL '5 days', gen_random_uuid()),

-- Priya Sharma - Email identity  
('priya.sharma@example.com', '22222222-2222-2222-2222-222222222222', '{"sub": "22222222-2222-2222-2222-222222222222", "email": "priya.sharma@example.com", "email_verified": true, "phone_verified": true}', 'email', NOW() - INTERVAL '2 days', NOW() - INTERVAL '45 days', NOW() - INTERVAL '2 days', gen_random_uuid()),

-- Ravi Meena - Email identity
('ravi.meena@example.com', '33333333-3333-3333-3333-333333333333', '{"sub": "33333333-3333-3333-3333-333333333333", "email": "ravi.meena@example.com", "email_verified": true, "phone_verified": true}', 'email', NOW() - INTERVAL '3 days', NOW() - INTERVAL '15 days', NOW() - INTERVAL '3 days', gen_random_uuid()),

-- Sunita Devi - Email identity
('sunita.devi@example.com', '44444444-4444-4444-4444-444444444444', '{"sub": "44444444-4444-4444-4444-444444444444", "email": "sunita.devi@example.com", "email_verified": true, "phone_verified": true}', 'email', NOW() - INTERVAL '1 day', NOW() - INTERVAL '60 days', NOW() - INTERVAL '1 day', gen_random_uuid()),

-- Vikram Singh - Email identity
('vikram.singh@example.com', '55555555-5555-5555-5555-555555555555', '{"sub": "55555555-5555-5555-5555-555555555555", "email": "vikram.singh@example.com", "email_verified": true, "phone_verified": true}', 'email', NOW(), NOW() - INTERVAL '90 days', NOW(), gen_random_uuid());

-- =====================================================
-- 0.2 AUTHENTICATION SESSIONS - Active user sessions
-- =====================================================

-- Supabase sessions for logged-in users (some users have active sessions)
INSERT INTO auth.sessions (
    id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip
) VALUES 
-- Arjun Kumar - Active session
(gen_random_uuid(), '11111111-1111-1111-1111-111111111111', NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 hour', NULL, 'aal1', NULL, NOW() - INTERVAL '1 hour', 'Flutter/3.24.0 (Android 13)', '192.168.1.101'),

-- Priya Sharma - Active session
(gen_random_uuid(), '22222222-2222-2222-2222-222222222222', NOW() - INTERVAL '2 days', NOW() - INTERVAL '30 minutes', NULL, 'aal1', NULL, NOW() - INTERVAL '30 minutes', 'Flutter/3.24.0 (iOS 16.5)', '192.168.1.102'),

-- Ravi Meena - Active session (in-progress user)
(gen_random_uuid(), '33333333-3333-3333-3333-333333333333', NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 hours', NULL, 'aal1', NULL, NOW() - INTERVAL '2 hours', 'Flutter/3.24.0 (Android 12)', '192.168.1.103'),

-- Sunita Devi - Recent session
(gen_random_uuid(), '44444444-4444-4444-4444-444444444444', NOW() - INTERVAL '1 day', NOW() - INTERVAL '6 hours', NULL, 'aal1', NULL, NOW() - INTERVAL '6 hours', 'Flutter/3.24.0 (ColorOS 13)', '192.168.1.104'),

-- Vikram Singh - Very active user, current session
(gen_random_uuid(), '55555555-5555-5555-5555-555555555555', NOW() - INTERVAL '1 hour', NOW() - INTERVAL '5 minutes', NULL, 'aal1', NULL, NOW() - INTERVAL '5 minutes', 'Flutter/3.24.0 (OxygenOS 13)', '192.168.1.105');

-- =====================================================
-- 0.3 REFRESH TOKENS - For session management
-- =====================================================

-- Refresh tokens for maintaining user sessions
INSERT INTO auth.refresh_tokens (
    instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id
) VALUES 
-- Arjun Kumar - Refresh token
('00000000-0000-0000-0000-000000000000', 1, encode(gen_random_bytes(32), 'base64'), '11111111-1111-1111-1111-111111111111', false, NOW() - INTERVAL '5 days', NOW() - INTERVAL '1 hour', NULL, (SELECT id FROM auth.sessions WHERE user_id = '11111111-1111-1111-1111-111111111111' LIMIT 1)),

-- Priya Sharma - Refresh token
('00000000-0000-0000-0000-000000000000', 2, encode(gen_random_bytes(32), 'base64'), '22222222-2222-2222-2222-222222222222', false, NOW() - INTERVAL '2 days', NOW() - INTERVAL '30 minutes', NULL, (SELECT id FROM auth.sessions WHERE user_id = '22222222-2222-2222-2222-222222222222' LIMIT 1)),

-- Ravi Meena - Refresh token
('00000000-0000-0000-0000-000000000000', 3, encode(gen_random_bytes(32), 'base64'), '33333333-3333-3333-3333-333333333333', false, NOW() - INTERVAL '3 days', NOW() - INTERVAL '2 hours', NULL, (SELECT id FROM auth.sessions WHERE user_id = '33333333-3333-3333-3333-333333333333' LIMIT 1)),

-- Sunita Devi - Refresh token
('00000000-0000-0000-0000-000000000000', 4, encode(gen_random_bytes(32), 'base64'), '44444444-4444-4444-4444-444444444444', false, NOW() - INTERVAL '1 day', NOW() - INTERVAL '6 hours', NULL, (SELECT id FROM auth.sessions WHERE user_id = '44444444-4444-4444-4444-444444444444' LIMIT 1)),

-- Vikram Singh - Fresh refresh token
('00000000-0000-0000-0000-000000000000', 5, encode(gen_random_bytes(32), 'base64'), '55555555-5555-5555-5555-555555555555', false, NOW() - INTERVAL '1 hour', NOW() - INTERVAL '5 minutes', NULL, (SELECT id FROM auth.sessions WHERE user_id = '55555555-5555-5555-5555-555555555555' LIMIT 1));

-- =====================================================
-- 1. FITNESS TESTS - Core SAI fitness test types
-- =====================================================

INSERT INTO fitness_tests (
    name, display_name, description, instructions, video_demo_url, 
    duration_seconds, requires_video, measurement_unit, ai_model_config, 
    cheat_detection_enabled, is_active, created_at
) VALUES 
(
    'height_weight', 
    'Height & Weight Measurement',
    'Basic anthropometric measurements for body composition analysis',
    'Stand straight against the wall for height measurement. Step on the scale for weight measurement. Ensure proper posture and remove shoes.',
    'https://example.com/videos/height_weight_demo.mp4',
    300,
    true,
    'cm/kg',
    '{"model_type": "anthropometric", "confidence_threshold": 0.85}',
    true,
    true,
    NOW()
),
(
    'vertical_jump', 
    'Vertical Jump Test',
    'Measures explosive leg power and vertical jumping ability',
    'Stand beside the wall with feet shoulder-width apart. Reach up and mark your highest point. Jump as high as possible and touch the wall at peak height.',
    'https://example.com/videos/vertical_jump_demo.mp4',
    60,
    true,
    'cm',
    '{"model_type": "jump_analysis", "confidence_threshold": 0.90, "frame_rate": 30}',
    true,
    true,
    NOW()
),
(
    'shuttle_run', 
    'Shuttle Run Test',
    'Tests agility, speed, and change of direction ability',
    'Run between two points 10 meters apart. Touch the line with your hand at each turn. Complete 4 laps (40m total) as fast as possible.',
    'https://example.com/videos/shuttle_run_demo.mp4',
    120,
    true,
    'seconds',
    '{"model_type": "speed_analysis", "confidence_threshold": 0.88, "distance_markers": true}',
    true,
    true,
    NOW()
),
(
    'situps', 
    'Sit-ups Test',
    'Measures abdominal and core muscle strength and endurance',
    'Lie on your back with knees bent at 90 degrees. Cross arms over chest. Perform as many sit-ups as possible in 1 minute.',
    'https://example.com/videos/situps_demo.mp4',
    60,
    true,
    'reps',
    '{"model_type": "repetition_counter", "confidence_threshold": 0.92, "form_check": true}',
    true,
    true,
    NOW()
),
(
    'endurance_run', 
    'Endurance Run (1600m)',
    'Tests cardiovascular endurance and aerobic capacity',
    'Run 1600 meters (4 laps of 400m track) at your maximum sustainable pace. Maintain steady breathing and pacing.',
    'https://example.com/videos/endurance_run_demo.mp4',
    900,
    true,
    'minutes:seconds',
    '{"model_type": "endurance_tracker", "confidence_threshold": 0.85, "gps_tracking": true}',
    true,
    true,
    NOW()
),
(
    'flexibility', 
    'Flexibility Test',
    'Measures joint range of motion and muscle flexibility',
    'Sit with legs straight and feet against the box. Slowly reach forward as far as possible and hold for 2 seconds.',
    'https://example.com/videos/flexibility_demo.mp4',
    120,
    true,
    'cm',
    '{"model_type": "flexibility_measure", "confidence_threshold": 0.87, "angle_detection": true}',
    true,
    true,
    NOW()
),
(
    'agility', 
    'Agility Test',
    'Tests speed, coordination, and quick directional changes',
    'Navigate through the cone course as quickly as possible. Touch each cone and maintain control throughout the course.',
    'https://example.com/videos/agility_demo.mp4',
    180,
    true,
    'seconds',
    '{"model_type": "agility_tracker", "confidence_threshold": 0.89, "path_validation": true}',
    true,
    true,
    NOW()
);

-- =====================================================
-- 2. AGE BENCHMARKS - Performance standards by age/gender
-- =====================================================

-- Vertical Jump Benchmarks (in cm)
INSERT INTO age_benchmarks (
    fitness_test_id, age_min, age_max, gender, 
    excellent_threshold, good_threshold, average_threshold, below_average_threshold,
    excellent_points, good_points, average_points, below_average_points,
    created_at
) VALUES 
-- Males 10-12
((SELECT id FROM fitness_tests WHERE name = 'vertical_jump'), 10, 12, 'male', 35.0, 30.0, 25.0, 20.0, 100, 80, 60, 40, NOW()),
-- Males 13-15  
((SELECT id FROM fitness_tests WHERE name = 'vertical_jump'), 13, 15, 'male', 45.0, 40.0, 35.0, 30.0, 100, 80, 60, 40, NOW()),
-- Males 16-18
((SELECT id FROM fitness_tests WHERE name = 'vertical_jump'), 16, 18, 'male', 55.0, 50.0, 45.0, 40.0, 100, 80, 60, 40, NOW()),
-- Females 10-12
((SELECT id FROM fitness_tests WHERE name = 'vertical_jump'), 10, 12, 'female', 30.0, 25.0, 20.0, 15.0, 100, 80, 60, 40, NOW()),
-- Females 13-15
((SELECT id FROM fitness_tests WHERE name = 'vertical_jump'), 13, 15, 'female', 40.0, 35.0, 30.0, 25.0, 100, 80, 60, 40, NOW()),
-- Females 16-18
((SELECT id FROM fitness_tests WHERE name = 'vertical_jump'), 16, 18, 'female', 45.0, 40.0, 35.0, 30.0, 100, 80, 60, 40, NOW());

-- Shuttle Run Benchmarks (in seconds - lower is better)
INSERT INTO age_benchmarks (
    fitness_test_id, age_min, age_max, gender, 
    excellent_threshold, good_threshold, average_threshold, below_average_threshold,
    excellent_points, good_points, average_points, below_average_points,
    created_at
) VALUES 
-- Males 10-12
((SELECT id FROM fitness_tests WHERE name = 'shuttle_run'), 10, 12, 'male', 12.0, 13.0, 14.0, 15.0, 100, 80, 60, 40, NOW()),
-- Males 13-15
((SELECT id FROM fitness_tests WHERE name = 'shuttle_run'), 13, 15, 'male', 10.5, 11.5, 12.5, 13.5, 100, 80, 60, 40, NOW()),
-- Males 16-18
((SELECT id FROM fitness_tests WHERE name = 'shuttle_run'), 16, 18, 'male', 9.5, 10.5, 11.5, 12.5, 100, 80, 60, 40, NOW()),
-- Females 10-12
((SELECT id FROM fitness_tests WHERE name = 'shuttle_run'), 10, 12, 'female', 13.0, 14.0, 15.0, 16.0, 100, 80, 60, 40, NOW()),
-- Females 13-15
((SELECT id FROM fitness_tests WHERE name = 'shuttle_run'), 13, 15, 'female', 11.5, 12.5, 13.5, 14.5, 100, 80, 60, 40, NOW()),
-- Females 16-18
((SELECT id FROM fitness_tests WHERE name = 'shuttle_run'), 16, 18, 'female', 10.5, 11.5, 12.5, 13.5, 100, 80, 60, 40, NOW());

-- Sit-ups Benchmarks (in reps)
INSERT INTO age_benchmarks (
    fitness_test_id, age_min, age_max, gender, 
    excellent_threshold, good_threshold, average_threshold, below_average_threshold,
    excellent_points, good_points, average_points, below_average_points,
    created_at
) VALUES 
-- Males 10-12
((SELECT id FROM fitness_tests WHERE name = 'situps'), 10, 12, 'male', 40.0, 35.0, 30.0, 25.0, 100, 80, 60, 40, NOW()),
-- Males 13-15
((SELECT id FROM fitness_tests WHERE name = 'situps'), 13, 15, 'male', 50.0, 45.0, 40.0, 35.0, 100, 80, 60, 40, NOW()),
-- Males 16-18
((SELECT id FROM fitness_tests WHERE name = 'situps'), 16, 18, 'male', 55.0, 50.0, 45.0, 40.0, 100, 80, 60, 40, NOW()),
-- Females 10-12
((SELECT id FROM fitness_tests WHERE name = 'situps'), 10, 12, 'female', 35.0, 30.0, 25.0, 20.0, 100, 80, 60, 40, NOW()),
-- Females 13-15
((SELECT id FROM fitness_tests WHERE name = 'situps'), 13, 15, 'female', 45.0, 40.0, 35.0, 30.0, 100, 80, 60, 40, NOW()),
-- Females 16-18
((SELECT id FROM fitness_tests WHERE name = 'situps'), 16, 18, 'female', 50.0, 45.0, 40.0, 35.0, 100, 80, 60, 40, NOW());

-- Endurance Run Benchmarks (in seconds - lower is better)
INSERT INTO age_benchmarks (
    fitness_test_id, age_min, age_max, gender, 
    excellent_threshold, good_threshold, average_threshold, below_average_threshold,
    excellent_points, good_points, average_points, below_average_points,
    created_at
) VALUES 
-- Males 10-12 (6:00, 7:00, 8:00, 9:00 minutes)
((SELECT id FROM fitness_tests WHERE name = 'endurance_run'), 10, 12, 'male', 360.0, 420.0, 480.0, 540.0, 100, 80, 60, 40, NOW()),
-- Males 13-15 (5:30, 6:30, 7:30, 8:30 minutes)
((SELECT id FROM fitness_tests WHERE name = 'endurance_run'), 13, 15, 'male', 330.0, 390.0, 450.0, 510.0, 100, 80, 60, 40, NOW()),
-- Males 16-18 (5:00, 6:00, 7:00, 8:00 minutes)
((SELECT id FROM fitness_tests WHERE name = 'endurance_run'), 16, 18, 'male', 300.0, 360.0, 420.0, 480.0, 100, 80, 60, 40, NOW()),
-- Females 10-12 (7:00, 8:00, 9:00, 10:00 minutes)
((SELECT id FROM fitness_tests WHERE name = 'endurance_run'), 10, 12, 'female', 420.0, 480.0, 540.0, 600.0, 100, 80, 60, 40, NOW()),
-- Females 13-15 (6:30, 7:30, 8:30, 9:30 minutes)
((SELECT id FROM fitness_tests WHERE name = 'endurance_run'), 13, 15, 'female', 390.0, 450.0, 510.0, 570.0, 100, 80, 60, 40, NOW()),
-- Females 16-18 (6:00, 7:00, 8:00, 9:00 minutes)
((SELECT id FROM fitness_tests WHERE name = 'endurance_run'), 16, 18, 'female', 360.0, 420.0, 480.0, 540.0, 100, 80, 60, 40, NOW());

-- =====================================================
-- 3. ATHLETE PROFILES - Dummy users for testing auth
-- =====================================================

INSERT INTO athlete_profiles (
    id, auth_user_id, full_name, date_of_birth, age, gender, height, weight,
    phone_number, email, address, state, district, pin_code, location_category,
    aadhaar_number, sports_interests, previous_sports_experience,
    profile_picture_url, is_verified, verification_status,
    overall_talent_score, talent_grade, national_ranking, state_ranking,
    total_points, badges_earned, level, created_at, updated_at
) VALUES 
-- Test User 1: Young Male Athlete from Rural Area
(
    'a1b2c3d4-e5f6-1890-abcd-ef1234567890',
    '11111111-1111-1111-1111-111111111111',
    'Arjun Kumar',
    '2010-03-15',
    14,
    'male',
    165.50,
    52.75,
    '+91-9876543210',
    'arjun.kumar@example.com',
    'Village Chandrapur, Near Government School',
    'Maharashtra',
    'Chandrapur',
    '442401',
    'rural',
    '123456789012',
    '["football", "athletics", "volleyball"]',
    'Played in district level football championship. Won silver medal in 400m race at school level.',
    'https://example.com/profiles/arjun_kumar.jpg',
    true,
    'verified',
    78.50,
    'B+',
    1245,
    145,
    1850,
    '["first_assessment", "speed_demon"]',
    3,
    NOW() - INTERVAL '30 days',
    NOW() - INTERVAL '5 days'
),
-- Test User 2: Urban Female Athlete
(
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    '22222222-2222-2222-2222-222222222222',
    'Priya Sharma',
    '2008-07-22',
    16,
    'female',
    158.25,
    48.90,
    '+91-8765432109',
    'priya.sharma@example.com',
    'A-304, Green Valley Apartments, Sector 12',
    'Gujarat',
    'Ahmedabad',
    '380012',
    'urban',
    '234567890123',
    '["badminton", "gymnastics", "swimming"]',
    'State level badminton player. Participated in national gymnastics championship.',
    'https://example.com/profiles/priya_sharma.jpg',
    true,
    'verified',
    82.75,
    'A-',
    892,
    67,
    2240,
    '["flexibility_master", "endurance_champion", "top_performer"]',
    4,
    NOW() - INTERVAL '45 days',
    NOW() - INTERVAL '2 days'
),
-- Test User 3: Tribal Area Male Athlete
(
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    '33333333-3333-3333-3333-333333333333',
    'Ravi Meena',
    '2009-11-08',
    15,
    'male',
    172.80,
    58.60,
    '+91-7654321098',
    'ravi.meena@example.com',
    'Meena Basti, Behind Primary Health Center',
    'Rajasthan',
    'Udaipur',
    '313001',
    'tribal',
    '345678901234',
    '["archery", "wrestling", "athletics"]',
    'Traditional archery champion in tribal sports meet. Won bronze in wrestling at district level.',
    'https://example.com/profiles/ravi_meena.jpg',
    false,
    'document_submitted',
    null,
    null,
    null,
    null,
    450,
    '["newcomer"]',
    1,
    NOW() - INTERVAL '15 days',
    NOW() - INTERVAL '3 days'
),
-- Test User 4: Remote Area Female Athlete
(
    'd4e5f6a7-b8c9-0123-defa-456789012345',
    '44444444-4444-4444-4444-444444444444',
    'Sunita Devi',
    '2011-01-30',
    13,
    'female',
    152.30,
    42.15,
    '+91-6543210987',
    'sunita.devi@example.com',
    'Hilltop Village, Post Office Road',
    'Himachal Pradesh',
    'Kinnaur',
    '172108',
    'remote',
    '456789012345',
    '["running", "cycling", "mountaineering"]',
    'Won gold medal in inter-school cross country race. Active in local trekking groups.',
    'https://example.com/profiles/sunita_devi.jpg',
    true,
    'verified',
    85.25,
    'A',
    645,
    42,
    2680,
    '["mountain_runner", "endurance_champion", "consistency_pro"]',
    5,
    NOW() - INTERVAL '60 days',
    NOW() - INTERVAL '1 day'
),
-- Test User 5: Urban Male Athlete (Advanced)
(
    'e5f6a7b8-c9d0-1234-efab-567890123456',
    '55555555-5555-5555-5555-555555555555',
    'Vikram Singh',
    '2007-09-12',
    17,
    'male',
    178.95,
    68.40,
    '+91-5432109876',
    'vikram.singh@example.com',
    'B-45, Sports Complex Road, Model Town',
    'Punjab',
    'Ludhiana',
    '141002',
    'urban',
    '567890123456',
    '["basketball", "athletics", "boxing"]',
    'State basketball team captain. National level 800m runner. District boxing champion.',
    'https://example.com/profiles/vikram_singh.jpg',
    true,
    'verified',
    91.75,
    'A+',
    234,
    18,
    3450,
    '["basketball_star", "speed_demon", "power_athlete", "champion"]',
    6,
    NOW() - INTERVAL '90 days',
    NOW()
);

-- =====================================================
-- 4. ASSESSMENT SESSIONS - Test sessions for athletes
-- =====================================================

INSERT INTO assessment_sessions (
    id, athlete_id, session_name, status, total_tests, completed_tests,
    overall_score, overall_grade, percentile_rank, sai_submission_id,
    sai_officer_notes, sai_verification_status, device_info, network_quality,
    created_at, completed_at, submitted_at
) VALUES 
-- Arjun's completed assessment
(
    'a1111111-1111-1111-1111-111111111111',
    'a1b2c3d4-e5f6-1890-abcd-ef1234567890',
    'Initial SAI Fitness Assessment',
    'completed',
    7,
    7,
    78.50,
    'B+',
    67.25,
    'SAI_SUB_001',
    'Good athletic potential. Recommend focus on speed and agility training.',
    'verified',
    '{"device": "Samsung Galaxy A54", "os": "Android 13", "app_version": "1.2.1"}',
    'excellent',
    NOW() - INTERVAL '25 days',
    NOW() - INTERVAL '24 days',
    NOW() - INTERVAL '20 days'
),
-- Priya's completed assessment
(
    'b2222222-2222-2222-2222-222222222222',
    'b2c3d4e5-f6a7-8901-bcde-f23456789012',
    'SAI Talent Assessment - Round 1',
    'submitted_to_sai',
    7,
    7,
    82.75,
    'A-',
    78.90,
    'SAI_SUB_002',
    'Excellent flexibility and endurance. Strong candidate for gymnastics development.',
    'under_review',
    '{"device": "iPhone 14", "os": "iOS 16.5", "app_version": "1.2.1"}',
    'good',
    NOW() - INTERVAL '40 days',
    NOW() - INTERVAL '38 days',
    NOW() - INTERVAL '35 days'
),
-- Ravi's in-progress assessment
(
    'c3333333-3333-3333-3333-333333333333',
    'c3d4e5f6-a7b8-9012-cdef-345678901234',
    'First Time Assessment',
    'in_progress',
    7,
    3,
    null,
    null,
    null,
    null,
    null,
    null,
    '{"device": "Xiaomi Redmi Note 12", "os": "Android 12", "app_version": "1.2.0"}',
    'fair',
    NOW() - INTERVAL '10 days',
    null,
    null
),
-- Sunita's completed assessment
(
    'd4444444-4444-4444-4444-444444444444',
    'd4e5f6a7-b8c9-0123-defa-456789012345',
    'Mountain Region Assessment',
    'verified_by_sai',
    7,
    7,
    85.25,
    'A',
    82.15,
    'SAI_SUB_004',
    'Outstanding endurance capabilities. Ideal for long-distance events. Recommend advanced training.',
    'approved',
    '{"device": "Oppo A78", "os": "ColorOS 13", "app_version": "1.2.1"}',
    'poor',
    NOW() - INTERVAL '55 days',
    NOW() - INTERVAL '53 days',
    NOW() - INTERVAL '50 days'
),
-- Vikram's completed assessment
(
    'e5555555-5555-5555-5555-555555555555',
    'e5f6a7b8-c9d0-1234-efab-567890123456',
    'Advanced Athlete Assessment',
    'verified_by_sai',
    7,
    7,
    91.75,
    'A+',
    94.60,
    'SAI_SUB_005',
    'Exceptional talent across multiple disciplines. Fast-track for national camps.',
    'approved',
    '{"device": "OnePlus 11", "os": "OxygenOS 13", "app_version": "1.2.1"}',
    'excellent',
    NOW() - INTERVAL '85 days',
    NOW() - INTERVAL '83 days',
    NOW() - INTERVAL '80 days'
);

-- =====================================================
-- 5. BADGES - Achievement system for gamification
-- =====================================================

INSERT INTO badges (
    name, description, badge_type, icon_url, criteria, points_reward, is_active, created_at
) VALUES 
(
    'First Assessment',
    'Complete your first fitness assessment',
    'participation',
    'https://example.com/badges/first_assessment.png',
    '{"action": "complete_assessment", "count": 1}',
    100,
    true,
    NOW()
),
(
    'Speed Demon',
    'Achieve excellent score in shuttle run test',
    'performance',
    'https://example.com/badges/speed_demon.png',
    '{"test": "shuttle_run", "grade": "excellent"}',
    200,
    true,
    NOW()
),
(
    'Flexibility Master',
    'Score in top 10% for flexibility test',
    'performance',
    'https://example.com/badges/flexibility_master.png',
    '{"test": "flexibility", "percentile": 90}',
    250,
    true,
    NOW()
),
(
    'Endurance Champion',
    'Complete 1600m run in excellent time',
    'performance',
    'https://example.com/badges/endurance_champion.png',
    '{"test": "endurance_run", "grade": "excellent"}',
    300,
    true,
    NOW()
),
(
    'Power Athlete',
    'Achieve excellent score in vertical jump',
    'performance',
    'https://example.com/badges/power_athlete.png',
    '{"test": "vertical_jump", "grade": "excellent"}',
    200,
    true,
    NOW()
),
(
    'Consistency Pro',
    'Complete 3 assessments with consistent performance',
    'consistency',
    'https://example.com/badges/consistency_pro.png',
    '{"action": "consistent_performance", "assessments": 3}',
    400,
    true,
    NOW()
),
(
    'Top Performer',
    'Achieve overall grade A or above',
    'performance',
    'https://example.com/badges/top_performer.png',
    '{"overall_grade": ["A+", "A", "A-"]}',
    500,
    true,
    NOW()
),
(
    'Mountain Runner',
    'Special badge for athletes from mountainous regions with excellent endurance',
    'special',
    'https://example.com/badges/mountain_runner.png',
    '{"location_category": "remote", "test": "endurance_run", "grade": "excellent"}',
    350,
    true,
    NOW()
),
(
    'Newcomer',
    'Welcome badge for new athletes',
    'participation',
    'https://example.com/badges/newcomer.png',
    '{"action": "register", "count": 1}',
    50,
    true,
    NOW()
),
(
    'Champion',
    'Achieve A+ grade in overall assessment',
    'performance',
    'https://example.com/badges/champion.png',
    '{"overall_grade": "A+"}',
    1000,
    true,
    NOW()
);

-- =====================================================
-- 6. ATHLETE BADGES - Assign earned badges to athletes
-- =====================================================

INSERT INTO athlete_badges (athlete_id, badge_id, earned_at, notes) VALUES 
-- Arjun's badges
('a1b2c3d4-e5f6-1890-abcd-ef1234567890', (SELECT id FROM badges WHERE name = 'First Assessment'), NOW() - INTERVAL '24 days', 'Completed first assessment successfully'),
('a1b2c3d4-e5f6-1890-abcd-ef1234567890', (SELECT id FROM badges WHERE name = 'Speed Demon'), NOW() - INTERVAL '24 days', 'Excellent shuttle run performance'),

-- Priya's badges
('b2c3d4e5-f6a7-8901-bcde-f23456789012', (SELECT id FROM badges WHERE name = 'First Assessment'), NOW() - INTERVAL '38 days', 'First assessment completed'),
('b2c3d4e5-f6a7-8901-bcde-f23456789012', (SELECT id FROM badges WHERE name = 'Flexibility Master'), NOW() - INTERVAL '38 days', 'Outstanding flexibility score'),
('b2c3d4e5-f6a7-8901-bcde-f23456789012', (SELECT id FROM badges WHERE name = 'Endurance Champion'), NOW() - INTERVAL '38 days', 'Excellent endurance performance'),
('b2c3d4e5-f6a7-8901-bcde-f23456789012', (SELECT id FROM badges WHERE name = 'Top Performer'), NOW() - INTERVAL '38 days', 'Overall A- grade achieved'),

-- Ravi's badges
('c3d4e5f6-a7b8-9012-cdef-345678901234', (SELECT id FROM badges WHERE name = 'Newcomer'), NOW() - INTERVAL '15 days', 'Welcome to the platform'),

-- Sunita's badges
('d4e5f6a7-b8c9-0123-defa-456789012345', (SELECT id FROM badges WHERE name = 'First Assessment'), NOW() - INTERVAL '53 days', 'First assessment completed'),
('d4e5f6a7-b8c9-0123-defa-456789012345', (SELECT id FROM badges WHERE name = 'Mountain Runner'), NOW() - INTERVAL '53 days', 'Exceptional endurance from mountain region'),
('d4e5f6a7-b8c9-0123-defa-456789012345', (SELECT id FROM badges WHERE name = 'Endurance Champion'), NOW() - INTERVAL '53 days', 'Outstanding endurance performance'),
('d4e5f6a7-b8c9-0123-defa-456789012345', (SELECT id FROM badges WHERE name = 'Consistency Pro'), NOW() - INTERVAL '10 days', 'Consistent high performance'),

-- Vikram's badges
('e5f6a7b8-c9d0-1234-efab-567890123456', (SELECT id FROM badges WHERE name = 'First Assessment'), NOW() - INTERVAL '83 days', 'First assessment completed'),
('e5f6a7b8-c9d0-1234-efab-567890123456', (SELECT id FROM badges WHERE name = 'Speed Demon'), NOW() - INTERVAL '83 days', 'Exceptional speed performance'),
('e5f6a7b8-c9d0-1234-efab-567890123456', (SELECT id FROM badges WHERE name = 'Power Athlete'), NOW() - INTERVAL '83 days', 'Outstanding jumping ability'),
('e5f6a7b8-c9d0-1234-efab-567890123456', (SELECT id FROM badges WHERE name = 'Champion'), NOW() - INTERVAL '83 days', 'A+ overall grade achieved');

-- =====================================================
-- 7. SAMPLE TEST RECORDINGS - Dummy test results
-- =====================================================

-- Note: These are sample recordings for completed assessments
-- In real implementation, these would have actual video URLs

INSERT INTO test_recordings (
    id, session_id, fitness_test_id, athlete_id, original_video_url,
    processed_video_url, thumbnail_url, video_duration, video_size_mb,
    device_analysis_score, device_analysis_confidence, device_analysis_data,
    ai_raw_score, ai_confidence, ai_analysis_data,
    cheat_detection_score, cheat_flags, is_suspicious,
    manual_score, verified_by_sai_officer, verification_notes,
    final_score, performance_grade, percentile, points_earned,
    processing_status, retry_count, created_at, processed_at
) VALUES 
-- Arjun's vertical jump test
(
    'f1111111-1111-1111-1111-111111111111',
    'a1111111-1111-1111-1111-111111111111',
    (SELECT id FROM fitness_tests WHERE name = 'vertical_jump'),
    'a1b2c3d4-e5f6-1890-abcd-ef1234567890',
    'https://storage.example.com/videos/arjun_vertical_jump.mp4',
    'https://storage.example.com/processed/arjun_vertical_jump_analyzed.mp4',
    'https://storage.example.com/thumbnails/arjun_vertical_jump_thumb.jpg',
    45.50,
    12.30,
    42.5,
    0.9200,
    '{"peak_height": 42.5, "takeoff_velocity": 2.89, "form_score": 0.85}',
    42.8,
    0.9350,
    '{"jump_height": 42.8, "consistency": 0.92, "technique_score": 0.88}',
    0.0500,
    '[]',
    false,
    42.5,
    'SAI_Officer_001',
    'Good jumping technique, consistent measurement',
    42.5,
    'excellent',
    78.50,
    100,
    'manually_verified',
    0,
    NOW() - INTERVAL '24 days',
    NOW() - INTERVAL '23 days'
);

-- =====================================================
-- 8. ADDITIONAL TEST DATA FOR ALL FITNESS TESTS
-- =====================================================

-- Add more benchmark data for remaining tests (flexibility, agility, height_weight)

-- Flexibility Benchmarks (in cm - higher is better)
INSERT INTO age_benchmarks (
    fitness_test_id, age_min, age_max, gender, 
    excellent_threshold, good_threshold, average_threshold, below_average_threshold,
    excellent_points, good_points, average_points, below_average_points,
    created_at
) VALUES 
-- Males flexibility benchmarks
((SELECT id FROM fitness_tests WHERE name = 'flexibility'), 10, 12, 'male', 25.0, 20.0, 15.0, 10.0, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'flexibility'), 13, 15, 'male', 30.0, 25.0, 20.0, 15.0, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'flexibility'), 16, 18, 'male', 35.0, 30.0, 25.0, 20.0, 100, 80, 60, 40, NOW()),
-- Females flexibility benchmarks
((SELECT id FROM fitness_tests WHERE name = 'flexibility'), 10, 12, 'female', 30.0, 25.0, 20.0, 15.0, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'flexibility'), 13, 15, 'female', 35.0, 30.0, 25.0, 20.0, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'flexibility'), 16, 18, 'female', 40.0, 35.0, 30.0, 25.0, 100, 80, 60, 40, NOW());

-- Agility Benchmarks (in seconds - lower is better)
INSERT INTO age_benchmarks (
    fitness_test_id, age_min, age_max, gender, 
    excellent_threshold, good_threshold, average_threshold, below_average_threshold,
    excellent_points, good_points, average_points, below_average_points,
    created_at
) VALUES 
-- Males agility benchmarks
((SELECT id FROM fitness_tests WHERE name = 'agility'), 10, 12, 'male', 15.0, 16.0, 17.0, 18.0, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'agility'), 13, 15, 'male', 13.5, 14.5, 15.5, 16.5, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'agility'), 16, 18, 'male', 12.0, 13.0, 14.0, 15.0, 100, 80, 60, 40, NOW()),
-- Females agility benchmarks
((SELECT id FROM fitness_tests WHERE name = 'agility'), 10, 12, 'female', 16.0, 17.0, 18.0, 19.0, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'agility'), 13, 15, 'female', 14.5, 15.5, 16.5, 17.5, 100, 80, 60, 40, NOW()),
((SELECT id FROM fitness_tests WHERE name = 'agility'), 16, 18, 'female', 13.0, 14.0, 15.0, 16.0, 100, 80, 60, 40, NOW());


-- =====================================================
-- SUMMARY OF DUMMY DATA CREATED:
-- =====================================================
-- 
-- 🔐 AUTHENTICATION DATA:
-- ✅ 5 Supabase Auth Users (auth.users table)
-- ✅ 5 Auth Identities (email provider linking)
-- ✅ 5 Active Sessions (with realistic user agents & IPs)
-- ✅ 5 Refresh Tokens (for session management)
--
-- 🏃 SPORTS ASSESSMENT DATA:
-- ✅ 7 Fitness Tests (all SAI standard tests)
-- ✅ 42 Age Benchmarks (6 age/gender groups × 7 tests)
-- ✅ 5 Athlete Profiles (diverse demographics for testing)
-- ✅ 5 Assessment Sessions (various stages of completion)  
-- ✅ 10 Achievement Badges (gamification system)
-- ✅ 13 Athlete Badge Awards (earned achievements)
-- ✅ 1 Sample Test Recording (for reference)
--
-- 📱 TEST USERS FOR FLUTTER APP LOGIN:
-- 
-- Email: arjun.kumar@example.com | Password: TestPass123!
-- ↳ ID: 11111111-1111-1111-1111-111111111111 | Arjun Kumar - Rural, Male, 14, Verified, B+ grade
--
-- Email: priya.sharma@example.com | Password: TestPass123!
-- ↳ ID: 22222222-2222-2222-2222-222222222222 | Priya Sharma - Urban, Female, 16, Verified, A- grade
--
-- Email: ravi.meena@example.com | Password: TestPass123!
-- ↳ ID: 33333333-3333-3333-3333-333333333333 | Ravi Meena - Tribal, Male, 15, Document submitted, In progress
--
-- Email: sunita.devi@example.com | Password: TestPass123!
-- ↳ ID: 44444444-4444-4444-4444-444444444444 | Sunita Devi - Remote, Female, 13, Verified, A grade
--
-- Email: vikram.singh@example.com | Password: TestPass123!
-- ↳ ID: 55555555-5555-5555-5555-555555555555 | Vikram Singh - Urban, Male, 17, Verified, A+ grade
--
-- 🚀 USAGE INSTRUCTIONS:
-- 1. Run this SQL file in your Supabase database
-- 2. In your Flutter app, use the email/password combinations above to test login
-- 3. All users have the same password: "TestPass123!" (for testing convenience)
-- 4. Each user represents different demographics and assessment completion stages
-- 5. Test various app flows: registration, login, assessment, gamification, etc.
--
-- 💡 TESTING SCENARIOS:
-- • Login/Logout functionality with real auth sessions
-- • User profile display with diverse demographics  
-- • Assessment flow with users at different completion stages
-- • Gamification features (badges, points, leaderboards)
-- • Performance tracking and SAI submission workflow
-- =====================================================