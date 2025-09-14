#!/usr/bin/env python3
"""
Simple script to generate a test JWT token for testing Supabase middleware
"""

import jwt
import json
from datetime import datetime, timedelta

# Test payload (similar to what Supabase would send)
payload = {
    'sub': '550e8400-e29b-41d4-a716-446655440004',  # User ID
    'email': 'testnew5@example.com',
    'role': 'authenticated',
    'aud': 'authenticated',
    'exp': datetime.utcnow() + timedelta(hours=1),  # Expires in 1 hour
    'iat': datetime.utcnow(),
    'iss': 'supabase'
}

# Generate token without verification (for development testing)
token = jwt.encode(payload, 'your-secret-key', algorithm='HS256')

print("Test JWT Token:")
print(token)
print("\nPayload:")
print(json.dumps(payload, indent=2, default=str))
print("\nTo test the API, use this token in the Authorization header:")
print(f"Authorization: Bearer {token}")