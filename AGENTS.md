# AGENTS.md

<!-- INSFORGE:START -->
## InsForge backend

This project uses [InsForge](https://insforge.dev): an all-in-one, open-source Postgres-based backend (BaaS) that gives this app a database, authentication, file storage, edge functions, realtime, an AI model gateway, and payments through one platform.

- **Project:** **Civic campus** (API base `https://f3k6x5hq.ap-southeast.insforge.app`)
- **Skills:** these InsForge skills are installed for supported coding agents. Reach for them before implementing any InsForge feature instead of guessing the API:
  - `insforge`: app code with the `@insforge/sdk` client (database CRUD, auth, storage, edge functions, realtime, AI, email, and Stripe payments).
  - `insforge-cli`: backend and infrastructure via the `insforge` CLI (projects, SQL, migrations, RLS policies, storage buckets, functions, secrets, payment setup, schedules, deploys).
  - `insforge-debug`: diagnosing failures (SDK/HTTP errors, RLS denials, auth and OAuth issues) and running security or performance audits.
  - `insforge-integrations`: wiring external auth providers (Clerk, Auth0, WorkOS, Better Auth, etc.) for JWT-based RLS, or the OKX x402 payment facilitator.
  - `find-skills`: discovering additional skills on demand.
- **Credentials:** app code reads keys from `.env.local`; the CLI reads `.insforge/project.json`. Never hardcode or commit keys.

Key patterns:

- Database inserts take an array: `insert([{ ... }])`.
- Reference users with `auth.users(id)`; use `auth.uid()` in RLS policies.
- For storage uploads, persist both the returned `url` and `key`.

### Auth API endpoints (NOT Supabase compatible)

| Action | Endpoint | Method |
|--------|----------|--------|
| Sign in (mobile) | `POST /api/auth/sessions?client_type=mobile` | `{ email, password }` → `{ accessToken, refreshToken, user }` |
| Sign up (mobile) | `POST /api/auth/users?client_type=mobile` | `{ email, password, name }` → `{ accessToken, refreshToken, user }` |
| Sign out | `POST /api/auth/logout` | (no body) |
| Refresh (mobile) | `POST /api/auth/refresh?client_type=mobile` | `{ refreshToken }` → `{ accessToken, refreshToken, user }` |
| Get current user | `GET /api/auth/sessions/current` | `Authorization: Bearer {accessToken}` → `{ user }` |

### Edge Functions (4 deployed)

| Slug | Purpose | Auth | URL |
|------|---------|------|-----|
| `submit-report` | Submit a report (creates incident or links to existing) | User token required | `POST /functions/submit-report` |
| `check-duplicates` | Find duplicate incidents by location+category | User token required | `POST /functions/check-duplicates` |
| `reopen-request` | Request reopen of a resolved/closed incident | User token required | `POST /functions/reopen-request` |
| `dashboard-stats` | Admin dashboard stats + staff workload | Admin token required | `GET /functions/dashboard-stats` |

Edge functions are TypeScript/Deno, source in `functions/`. They consume `INSFORGE_BASE_URL`, `ANON_KEY` from secrets. All require user auth via `Authorization: Bearer {userToken}`.

### Flutter API Layer (`lib/api/`)

| Service | File | Endpoints |
|---------|------|-----------|
| `IncidentApi` | `lib/api/incident_api.dart` | list, getById, create, update, updateStatus, getHistory, getNotes, addNote |
| `ReportApi` | `lib/api/report_api.dart` | submit (edge fn), checkDuplicates (edge fn), confirm, getAttachments, getReports |
| `LocationApi` | `lib/api/location_api.dart` | getBuildings, getFloors, getAreas, getById, create, update, delete |
| `CategoryApi` | `lib/api/category_api.dart` | list, getById, create, update, delete |
| `UserApi` | `lib/api/user_api.dart` | list, getById, create, update, toggleActive |
| `NotificationApi` | `lib/api/notification_api.dart` | list, getUnreadCount, markRead, markAllRead |
| `StorageService` | `lib/api/storage_service.dart` | uploadPhoto, getPublicUrl, deletePhoto |

All services receive `ApiClient` via constructor injection and return `ApiResponse`. Use PostgREST query params (eq., in., ilike., order, limit, offset). Barrel export: `import 'package:civic_campus/api/api.dart'`.

### Known issues

- `dedup_score_candidates` PG function had a fix: subquery `where incident_id = c.id` → `where confirmations.incident_id = c.id` (RETURNS TABLE output param name shadowed column ref). Fix applied via `db query` and patched in migration file.
- Auth in Flutter uses `client_type=mobile` endpoints (not Supabase-compatible `/auth/v1/*` paths).
<!-- INSFORGE:END -->
