"""
Supabase Authentication Middleware for Django
Validates Supabase JWT tokens and sets request.user_id
"""

import jwt
import requests
import json
from django.http import JsonResponse
from django.conf import settings
from django.utils.deprecation import MiddlewareMixin
from functools import wraps


class SupabaseAuthMiddleware(MiddlewareMixin):
    """
    Middleware to handle Supabase JWT authentication
    """
    
    def __init__(self, get_response):
        self.get_response = get_response
        # Cache for Supabase JWT secrets
        self._jwt_secret = None
        super().__init__(get_response)
    
    def process_request(self, request):
        """
        Process incoming requests to validate Supabase JWT tokens
        """
        # Skip authentication for certain paths
        skip_paths = [
            '/admin/',
            '/health/',
            '/api/docs/',
            '/api/v1/device/optimize/',
            '/api/auth/profile-sync/',
            '/api/auth/profile/',
            '/static/',
            '/media/',
        ]
        
        # Skip authentication for specific paths
        if any(request.path.startswith(path) for path in skip_paths):
            return None
        
        # Get authorization header
        auth_header = request.META.get('HTTP_AUTHORIZATION')
        
        if not auth_header or not auth_header.startswith('Bearer '):
            # For GET requests to some endpoints, allow without auth
            if request.method == 'GET' and '/api/v1/' in request.path:
                request.user_id = None
                request.user_email = None
                request.is_authenticated = False
                return None
            
            return JsonResponse({
                'error': 'Authentication required',
                'message': 'Please provide a valid Supabase JWT token'
            }, status=401)
        
        # Extract token
        token = auth_header.split(' ')[1]
        
        try:
            # Decode and validate JWT token
            user_data = self.validate_supabase_token(token)
            
            if user_data:
                # Set user information on request
                request.user_id = user_data.get('sub')  # Supabase user ID
                request.user_email = user_data.get('email')
                request.user_role = user_data.get('role', 'authenticated')
                request.is_authenticated = True
                request.token_data = user_data
                return None
            else:
                return JsonResponse({
                    'error': 'Invalid token',
                    'message': 'The provided JWT token is invalid or expired'
                }, status=401)
                
        except jwt.ExpiredSignatureError:
            return JsonResponse({
                'error': 'Token expired',
                'message': 'The JWT token has expired. Please login again.'
            }, status=401)
        except jwt.InvalidTokenError:
            return JsonResponse({
                'error': 'Invalid token',
                'message': 'The provided JWT token is malformed or invalid'
            }, status=401)
        except Exception as e:
            return JsonResponse({
                'error': 'Authentication error',
                'message': f'Error validating token: {str(e)}'
            }, status=401)
    
    def validate_supabase_token(self, token):
        """
        Validate Supabase JWT token
        """
        try:
            # For development, you can skip verification
            # In production, you should verify with Supabase's public key
            if getattr(settings, 'SUPABASE_SKIP_JWT_VERIFICATION', False):
                # Decode without verification (DEVELOPMENT ONLY)
                decoded = jwt.decode(token, options={"verify_signature": False})
                return decoded
            
            # Production: Verify with Supabase JWT secret
            supabase_jwt_secret = getattr(settings, 'SUPABASE_JWT_SECRET', None)
            if not supabase_jwt_secret:
                raise Exception("SUPABASE_JWT_SECRET not configured in settings")
            
            decoded = jwt.decode(
                token, 
                supabase_jwt_secret, 
                algorithms=['HS256'],
                audience='authenticated'
            )
            return decoded
            
        except Exception as e:
            print(f"JWT validation error: {e}")
            return None


def supabase_auth_required(view_func):
    """
    Decorator to require Supabase authentication for views
    """
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not getattr(request, 'is_authenticated', False):
            return JsonResponse({
                'error': 'Authentication required',
                'message': 'This endpoint requires authentication'
            }, status=401)
        return view_func(request, *args, **kwargs)
    return wrapper


def get_current_user_profile(request):
    """
    Helper function to get the current user's athlete profile
    """
    if not getattr(request, 'is_authenticated', False):
        return None
    
    from .models import AthleteProfile
    try:
        return AthleteProfile.objects.get(auth_user_id=request.user_id)
    except AthleteProfile.DoesNotExist:
        return None


class SupabaseUser:
    """
    Simple user class to replace Django User for Supabase authentication
    """
    def __init__(self, user_id, email, role='authenticated'):
        self.id = user_id
        self.email = email
        self.role = role
        self.is_authenticated = True
    
    def __str__(self):
        return f"SupabaseUser({self.email})"