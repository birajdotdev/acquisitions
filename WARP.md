# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Node.js Express API for an acquisitions platform featuring user authentication. The project uses modern JavaScript (ES modules), Drizzle ORM with PostgreSQL (Neon database), and follows a structured MVC architecture pattern.

## Commands

### Development
```bash
# Start development server with hot reload
npm run dev

# Start production server
npm start
```

### Code Quality
```bash
# Run ESLint
npm run lint

# Auto-fix ESLint issues
npm run lint:fix

# Format code with Prettier
npm run format

# Check formatting without changing files
npm run format:check
```

### Database Operations
```bash
# Generate new migration files
npm run db:generate

# Run pending migrations
npm run db:migrate

# Open Drizzle Studio (database GUI)
npm run db:studio
```

## Architecture

### Module System
The project uses Node.js ES modules with custom import maps defined in `package.json`:
- `#src/*` - Main source directory
- `#config/*` - Configuration files (database, logger)
- `#controllers/*` - Route handlers
- `#middleware/*` - Custom middleware
- `#models/*` - Database models (Drizzle schemas)
- `#routes/*` - Express routes
- `#services/*` - Business logic layer
- `#utils/*` - Utility functions
- `#validations/*` - Zod validation schemas

### Directory Structure
```
src/
├── app.js              # Express app configuration
├── index.js            # Entry point (loads dotenv + server)
├── server.js           # HTTP server startup
├── config/
│   ├── database.js     # Neon PostgreSQL connection
│   └── logger.js       # Winston logger setup
├── controllers/        # Request handlers
├── models/             # Drizzle ORM schemas
├── routes/             # Express route definitions
├── services/           # Business logic layer
├── utils/              # Utility functions
└── validations/        # Zod schemas
```

### Database Architecture
- **ORM**: Drizzle ORM with PostgreSQL
- **Database**: Neon (serverless PostgreSQL)
- **Migrations**: Located in `drizzle/` directory
- **Models**: Defined in `src/models/` using Drizzle's pgTable

### Authentication Flow
The auth system implements JWT-based authentication:
1. **Registration/Login**: Controllers validate input using Zod schemas
2. **Password Hashing**: bcrypt with salt rounds of 10
3. **JWT Tokens**: Signed with configurable secret, 1-day expiration
4. **Cookie Storage**: HTTP-only cookies with secure flags in production
5. **User Roles**: 'user' and 'admin' roles supported

### Logging Strategy
- **Logger**: Winston with JSON formatting
- **Levels**: Configurable via LOG_LEVEL environment variable
- **Outputs**: Console (development), files (error.lg, combined.log)
- **Integration**: HTTP requests logged via Morgan

## Environment Setup

Required environment variables:
- `DATABASE_URL` - Neon PostgreSQL connection string
- `JWT_SECRET` - JWT signing secret (defaults to development key)
- `LOG_LEVEL` - Winston log level (defaults to 'info')
- `NODE_ENV` - Environment (affects cookie security, console logging)
- `PORT` - Server port (defaults to 3000)

## Development Notes

### Code Style
- **ESLint Configuration**: Extends @eslint/js recommended
- **Formatting**: Prettier with single quotes, 2-space indentation
- **Module Format**: ES modules exclusively (type: "module")
- **Error Handling**: Centralized via Express error handlers

### API Endpoints
Current endpoints:
- `GET /` - Health check with logging
- `GET /health` - Structured health status
- `GET /api` - API status message
- `POST /api/auth/sign-up` - User registration (implemented)
- `POST /api/auth/sign-in` - User login (routes defined, controller partial)
- `POST /api/auth/sign-out` - User logout (routes defined, controller implemented)

### Database Schema
Current schema includes `users` table with:
- Primary key (serial)
- Name, email (unique), password (hashed)
- Role-based access (user/admin)
- Timestamps (created_at, updated_at)

### Testing Strategy
- Test configuration present in ESLint for `tests/**/*.js`
- Jest globals configured but no test framework currently installed
- Consider adding test scripts when implementing tests

## Development Workflow

1. **New Features**: Follow MVC pattern - create/update routes, controllers, services, and models
2. **Database Changes**: Generate migrations with `npm run db:generate`, then migrate with `npm run db:migrate`
3. **API Development**: Add validation schemas first, then implement controllers and services
4. **Code Quality**: Run linting and formatting before commits
5. **Authentication**: Use existing JWT/cookie utilities for protected routes