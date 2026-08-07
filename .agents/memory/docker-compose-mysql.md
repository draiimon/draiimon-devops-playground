---
name: Docker Compose MySQL source alignment
description: The cloned FastAPI source uses MySQL through PyMySQL, so Compose must use MySQL and clean stale database containers before recreation.
---

The database service must match the cloned application's `mysql+pymysql` connection string. When changing an existing Compose project from PostgreSQL to MySQL, remove stale containers before recreating them because legacy `docker-compose` can fail with a `ContainerConfig` error while reusing an old container.

**Why:** The first Compose recreation attempted to reuse a PostgreSQL container and failed; a clean recreation produced healthy API, MySQL, and UI services.

**How to apply:** Check the cloned application's database driver before writing Compose. Use the matching image, credentials, health check, and named volume, then remove old service containers before `docker-compose up -d`.