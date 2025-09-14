#!/usr/bin/env python3
"""
Create Django User accounts that match our Supabase test data
Run this script to create Django users for testing authentication
"""

import os
import sys
import django
from datetime import datetime, date

# Add the project directory to Python path
sys.path.append('/path/to/your/project')

# Set up Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'sporty.settings')
django.setup()

from django.contrib.auth.models import User
from django.db import transaction
from sporty.models import AthleteProfile
import uuid

def create_test_users():
    """Create Django User accounts and AthleteProfile for testing"""
    
    test_users = [
        {
            'email': 'arjun.kumar@example.com',
            'password': 'TestPass123!',
            'full_name': 'Arjun Kumar',
            'date_of_birth': date(2010, 3, 15),
            'age': 14,
            'gender': 'male',
            'height': 165.50,
            'weight': 52.75,
            'phone_number': '+91-9876543210',
            'address': 'Village Chandrapur, Near Government School',
            'state': 'Maharashtra',
            'district': 'Chandrapur',
            'pincode': '442401',
            'location_category': 'rural',
            'aadhaar_number': '123456789012',
            'supabase_user_id': '11111111-1111-1111-1111-111111111111'
        },
        {
            'email': 'priya.sharma@example.com',
            'password': 'TestPass123!',
            'full_name': 'Priya Sharma',
            'date_of_birth': date(2008, 7, 22),
            'age': 16,
            'gender': 'female',
            'height': 158.25,
            'weight': 48.90,
            'phone_number': '+91-8765432109',
            'address': 'A-304, Green Valley Apartments, Sector 12',
            'state': 'Gujarat',
            'district': 'Ahmedabad',
            'pincode': '380012',
            'location_category': 'urban',
            'aadhaar_number': '234567890123',
            'supabase_user_id': '22222222-2222-2222-2222-222222222222'
        },
        {
            'email': 'ravi.meena@example.com',
            'password': 'TestPass123!',
            'full_name': 'Ravi Meena',
            'date_of_birth': date(2009, 11, 8),
            'age': 15,
            'gender': 'male',
            'height': 172.80,
            'weight': 58.60,
            'phone_number': '+91-7654321098',
            'address': 'Meena Basti, Behind Primary Health Center',
            'state': 'Rajasthan',
            'district': 'Udaipur',
            'pincode': '313001',
            'location_category': 'tribal',
            'aadhaar_number': '345678901234',
            'supabase_user_id': '33333333-3333-3333-3333-333333333333'
        },
        {
            'email': 'sunita.devi@example.com',
            'password': 'TestPass123!',
            'full_name': 'Sunita Devi',
            'date_of_birth': date(2011, 1, 30),
            'age': 13,
            'gender': 'female',
            'height': 152.30,
            'weight': 42.15,
            'phone_number': '+91-6543210987',
            'address': 'Hilltop Village, Post Office Road',
            'state': 'Himachal Pradesh',
            'district': 'Kinnaur',
            'pincode': '172108',
            'location_category': 'remote',
            'aadhaar_number': '456789012345',
            'supabase_user_id': '44444444-4444-4444-4444-444444444444'
        },
        {
            'email': 'vikram.singh@example.com',
            'password': 'TestPass123!',
            'full_name': 'Vikram Singh',
            'date_of_birth': date(2007, 9, 12),
            'age': 17,
            'gender': 'male',
            'height': 178.95,
            'weight': 68.40,
            'phone_number': '+91-5432109876',
            'address': 'B-45, Sports Complex Road, Model Town',
            'state': 'Punjab',
            'district': 'Ludhiana',
            'pincode': '141002',
            'location_category': 'urban',
            'aadhaar_number': '567890123456',
            'supabase_user_id': '55555555-5555-5555-5555-555555555555'
        }
    ]
    
    created_users = []
    
    for user_data in test_users:
        try:
            with transaction.atomic():
                # Check if user already exists
                if User.objects.filter(username=user_data['email']).exists():
                    print(f"❌ User {user_data['email']} already exists, skipping...")
                    continue
                
                # Create Django User
                user = User.objects.create_user(
                    username=user_data['email'],
                    email=user_data['email'],
                    password=user_data['password'],
                    first_name=user_data['full_name'].split(' ')[0],
                    last_name=' '.join(user_data['full_name'].split(' ')[1:])
                )
                
                # Check if AthleteProfile already exists
                if AthleteProfile.objects.filter(email=user_data['email']).exists():
                    print(f"❌ AthleteProfile for {user_data['email']} already exists, skipping...")
                    user.delete()  # Clean up the user we just created
                    continue
                
                # Create AthleteProfile
                athlete = AthleteProfile.objects.create(
                    auth_user_id=user_data['supabase_user_id'],  # Use Supabase UUID
                    full_name=user_data['full_name'],
                    date_of_birth=user_data['date_of_birth'],
                    age=user_data['age'],
                    gender=user_data['gender'],
                    height=user_data['height'],
                    weight=user_data['weight'],
                    phone_number=user_data['phone_number'],
                    email=user_data['email'],
                    address=user_data['address'],
                    state=user_data['state'],
                    district=user_data['district'],
                    pin_code=user_data['pincode'],
                    location_category=user_data['location_category'],
                    aadhaar_number=user_data['aadhaar_number'],
                    is_verified=True,
                    verification_status='verified'
                )
                
                created_users.append({
                    'django_user': user,
                    'athlete_profile': athlete,
                    'email': user_data['email']
                })
                
                print(f"✅ Created user: {user_data['email']} (Django ID: {user.id}, Athlete ID: {athlete.id})")
                
        except Exception as e:
            print(f"❌ Error creating user {user_data['email']}: {str(e)}")
    
    return created_users

def main():
    print("🚀 Creating Django test users for authentication...")
    print("=" * 60)
    
    created_users = create_test_users()
    
    print("=" * 60)
    print(f"✅ Successfully created {len(created_users)} test users!")
    print("\n📱 TEST CREDENTIALS FOR FLUTTER APP:")
    print("-" * 40)
    
    for user_info in created_users:
        print(f"Email: {user_info['email']}")
        print(f"Password: TestPass123!")
        print(f"Django User ID: {user_info['django_user'].id}")
        print(f"Athlete Profile ID: {user_info['athlete_profile'].id}")
        print("-" * 40)
    
    print("\n🔧 USAGE:")
    print("1. Use these credentials in your Flutter app login screen")
    print("2. The login endpoint is: POST /api/auth/login/")
    print("3. Send JSON: {'email': 'user@example.com', 'password': 'TestPass123!'}")
    print("4. You'll receive a token for authenticated requests")
    
    print("\n🎯 TESTING:")
    print("You can now test login with any of the above credentials!")

if __name__ == '__main__':
    main()