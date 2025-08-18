# Magic Link Authentication API Documentation

## Overview

This Rails API provides magic link authentication functionality. Users can authenticate using either:

1. A 6-digit code sent via email
2. A magic link sent via email

## Endpoints

### 1. Request Magic Link

**POST** `/api/v1/auth/request_magic_link`

Requests a magic link for authentication. If the user doesn't exist and first_name/last_name are provided, a new account will be created.

**Request Body:**

```json
{
  "email": "user@example.com",
  "first_name": "John", // Required for new users
  "last_name": "Doe" // Required for new users
}
```

**Response:**

```json
{
  "message": "Magic link sent successfully",
  "debug": {
    // Only in development
    "code": "123456",
    "magic_link": "http://localhost:3000/api/v1/auth/verify?token=..."
  }
}
```

### 2. Verify Code

**POST** `/api/v1/auth/verify_code`

Verifies the 6-digit authentication code.

**Request Body:**

```json
{
  "code": "123456"
}
```

**Response:**

```json
{
  "message": "Authentication successful",
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "full_name": "John Doe"
  }
}
```

### 3. Verify Magic Link

**GET** `/api/v1/auth/verify?token=TOKEN`

Verifies the magic link token.

**Query Parameters:**

- `token`: The magic link token

**Response:**

```json
{
  "message": "Authentication successful",
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "full_name": "John Doe"
  }
}
```

### 4. Get Current User

**GET** `/api/v1/auth/me`

Returns information about the currently authenticated user.

**Headers:**

```
Authorization: Bearer YOUR_JWT_TOKEN
```

**Response:**

```json
{
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe",
    "full_name": "John Doe"
  }
}
```

### 5. Logout

**DELETE** `/api/v1/auth/logout`

Logs out the current user (client-side token disposal required).

**Headers:**

```
Authorization: Bearer YOUR_JWT_TOKEN
```

**Response:**

```json
{
  "message": "Logged out successfully"
}
```

## Authentication Flow

### For New Users:

1. Send email, first_name, and last_name to `/api/v1/auth/request_magic_link`
2. User receives email with 6-digit code and magic link
3. User can either:
   - Enter the 6-digit code via `/api/v1/auth/verify_code`
   - Click the magic link which goes to `/api/v1/auth/verify?token=...`
4. Both methods return a JWT token for subsequent API calls

### For Existing Users:

1. Send only email to `/api/v1/auth/request_magic_link`
2. Same verification process as above

## Error Responses

All endpoints return error responses in this format:

```json
{
  "error": "Error message description"
}
```

Common HTTP status codes:

- `400`: Bad Request (missing required parameters)
- `401`: Unauthorized (invalid or missing token)
- `422`: Unprocessable Entity (validation errors, expired codes, etc.)

## Security Features

- Auth codes expire after 30 minutes
- Auth codes are single-use (marked as used after verification)
- JWT tokens include expiration timestamps
- Email addresses are case-insensitive and normalized
- Unique constraints on email, auth codes, and tokens

## Development Notes

In development mode, the email content is logged to the Rails console instead of being sent via email service. The API response includes debug information with the generated code and magic link for testing purposes.
