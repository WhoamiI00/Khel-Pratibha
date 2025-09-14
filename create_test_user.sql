-- Simple test user creation for Supabase
-- Run this in your Supabase SQL Editor

-- Create a simple test user
INSERT INTO auth.users (
    instance_id, 
    id, 
    aud, 
    role, 
    email, 
    encrypted_password, 
    email_confirmed_at,
    raw_app_meta_data, 
    raw_user_meta_data, 
    created_at, 
    updated_at,
    confirmation_token,
    recovery_token,
    email_change_token_new,
    email_change
) VALUES (
    '00000000-0000-0000-0000-000000000000',
    '11111111-1111-1111-1111-111111111111',
    'authenticated',
    'authenticated', 
    'arjun.kumar@example.com',
    '$2a$10$rQiRyKJ5bVB8wGXj4BnKsOxc4rCUqj.hT8YhT5VWqB5QY9lX8zK8e', -- TestPass123!
    NOW(),
    '{"provider": "email", "providers": ["email"]}',
    '{"full_name": "Arjun Kumar"}',
    NOW(),
    NOW(),
    '',
    '',
    '',
    ''
);

-- Create identity for the user
INSERT INTO auth.identities (
    provider_id, 
    user_id, 
    identity_data, 
    provider, 
    last_sign_in_at, 
    created_at, 
    updated_at, 
    id
) VALUES (
    'arjun.kumar@example.com',
    '11111111-1111-1111-1111-111111111111',
    '{"sub": "11111111-1111-1111-1111-111111111111", "email": "arjun.kumar@example.com", "email_verified": true}',
    'email',
    NOW(),
    NOW(),
    NOW(),
    gen_random_uuid()
);

-- Create athlete profile (if your app needs it)
INSERT INTO athlete_profiles (
    id,
    auth_user_id,
    full_name,
    date_of_birth,
    age,
    gender,
    height,
    weight,
    phone_number,
    email,
    address,
    state,
    district,
    pin_code,
    location_category,
    aadhaar_number,
    sports_interests,
    is_verified,
    verification_status,
    total_points,
    badges_earned,
    level,
    created_at,
    updated_at
) VALUES (
    'a1b2c3d4-e5f6-1890-abcd-ef1234567890',
    '11111111-1111-1111-1111-111111111111',
    'Arjun Kumar',
    '2010-03-15',
    14,
    'male',
    165.5,
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
    true,
    'verified',
    1850,
    '["first_assessment", "speed_demon"]',
    3,
    NOW(),
    NOW()
);