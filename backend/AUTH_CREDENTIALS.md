# 🔐 Authentication Test Credentials - Khel Pratibha

## Quick Reference for Flutter App Testing

### Test User Accounts

All users have the same password: **`TestPass123!`**

| **Email** | **User ID** | **Name** | **Profile** |
|-----------|-------------|----------|-------------|
| `arjun.kumar@example.com` | `11111111-1111-1111-1111-111111111111` | Arjun Kumar | Rural, Male, 14, B+ grade |
| `priya.sharma@example.com` | `22222222-2222-2222-2222-222222222222` | Priya Sharma | Urban, Female, 16, A- grade |
| `ravi.meena@example.com` | `33333333-3333-3333-3333-333333333333` | Ravi Meena | Tribal, Male, 15, In-progress |
| `sunita.devi@example.com` | `44444444-4444-4444-4444-444444444444` | Sunita Devi | Remote, Female, 13, A grade |
| `vikram.singh@example.com` | `55555555-5555-5555-5555-555555555555` | Vikram Singh | Urban, Male, 17, A+ grade |

### Authentication Features Included

- ✅ **Supabase Auth Users** - Complete user records in `auth.users`
- ✅ **Email Authentication** - All users can log in via email/password
- ✅ **Phone Verification** - All users have verified phone numbers
- ✅ **Active Sessions** - Realistic session data with device info
- ✅ **Refresh Tokens** - For proper session management
- ✅ **User Metadata** - Profile info stored in auth metadata

### Usage in Flutter App

1. **Login Testing**: Use any email/password combination above
2. **Registration Flow**: Create new users (will need to handle in your app)
3. **Session Management**: Test logout/login, token refresh
4. **Profile Integration**: User data links to athlete profiles via `auth_user_id`

### Database Setup

```sql
-- Run the dummy_data.sql file in your Supabase database
-- It will populate both auth tables and your app tables
```

### Supabase Configuration

Make sure your Supabase project has:
- Email authentication enabled
- Phone authentication enabled (optional)
- Proper RLS policies for your tables
- CORS settings for your Flutter app domains

---
*Generated for Khel Pratibha - Sports Talent Assessment Platform*