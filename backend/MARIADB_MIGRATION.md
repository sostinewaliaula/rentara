# MariaDB Migration Summary

The Rentara backend has been successfully migrated from PostgreSQL to MariaDB/MySQL.

## Changes Made

### 1. Prisma Schema (`prisma/schema.prisma`)
- Changed `provider` from `"postgresql"` to `"mysql"`
- All models remain compatible with MySQL/MariaDB

### 2. Docker Compose (`docker-compose.yml`)
- Replaced `postgres` service with `mariadb` service
- Updated image to `mariadb:10.11`
- Changed environment variables:
  - `POSTGRES_*` → `MYSQL_*`
  - Port changed from `5432` to `3306`
- Updated healthcheck command
- Updated volume name from `postgres_data` to `mariadb_data`

### 3. Environment Configuration (`.env.example`)
- Updated `DATABASE_URL` format:
  - From: `postgresql://user:pass@host:5432/db?schema=public`
  - To: `mysql://user:pass@host:3306/db`
- Removed `?schema=public` (not needed for MySQL)
- Updated variable names from `POSTGRES_*` to `MYSQL_*`

### 4. Documentation Updates
- Updated `README.md` - Technology stack and setup instructions
- Updated `SETUP.md` - Database setup instructions
- Updated `backend/README.md` - Prerequisites and setup

## Important Notes for MySQL/MariaDB

### Connection String Format
```
mysql://username:password@host:port/database
```

### Differences from PostgreSQL
1. **No Schema Parameter**: MySQL doesn't use schemas like PostgreSQL. The `?schema=public` parameter is not needed.
2. **Port**: Default port is `3306` instead of `5432`
3. **Case Sensitivity**: Table and column names are case-sensitive based on the operating system (Windows is case-insensitive, Linux is case-sensitive)

### Prisma Migrations
When running migrations for the first time with MariaDB:

```bash
# Generate Prisma Client for MySQL
npx prisma generate

# Create initial migration
npx prisma migrate dev --name init

# Or if starting fresh
npx prisma migrate reset
```

### Database Setup Commands

**Using Docker:**
```bash
docker-compose up -d mariadb
```

**Local MariaDB/MySQL:**
```bash
mysql -u root -p
CREATE DATABASE rentara;
CREATE USER 'rentara'@'localhost' IDENTIFIED BY 'rentara123';
GRANT ALL PRIVILEGES ON rentara.* TO 'rentara'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

## Testing the Migration

1. **Verify Database Connection:**
   ```bash
   npx prisma db pull
   ```

2. **Run Migrations:**
   ```bash
   npx prisma migrate dev
   ```

3. **Seed Database:**
   ```bash
   npm run prisma:seed
   ```

4. **Start Server:**
   ```bash
   npm run dev
   ```

## Troubleshooting

### Connection Issues
- Verify MariaDB is running: `mysqladmin ping -h localhost`
- Check connection string in `.env`
- Ensure database and user exist
- Verify firewall settings (port 3306)

### Migration Issues
- If you have existing PostgreSQL migrations, you'll need to start fresh:
  ```bash
  rm -rf prisma/migrations
  npx prisma migrate dev --name init
  ```

### Prisma Client Issues
- Regenerate Prisma Client after schema changes:
  ```bash
  npx prisma generate
  ```

## Next Steps

1. Update your `.env` file with MariaDB connection details
2. Run `npx prisma generate` to regenerate the Prisma Client
3. Run `npx prisma migrate dev` to create the database schema
4. Run `npm run prisma:seed` to populate with sample data
5. Start the server and test all endpoints

All functionality remains the same - only the database backend has changed!


