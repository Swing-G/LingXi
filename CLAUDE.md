# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

ZhiGuang (知光/灵析) — a knowledge-sharing platform for developers. Two projects in this repo:

1. **zhiguang_be-main-new** — Backend: Spring Boot 3.2.4, Java 21, MySQL 8.0, MyBatis, Redis, Elasticsearch, Kafka, Canal, Alibaba OSS. Provides user auth, content posting (知文/KnowPost), social relations (follow/fan), counters (likes/favs), full-text search, RAG-based AI Q&A, and user profiles.
2. **zhiguang_fe-main- yuanban** — Frontend: React 18 + TypeScript + Vite 5, CSS Modules, React Router v6. No UI framework — custom warm/dark design system with CSS custom properties.

## Build & Run

```bash
# Build
./mvnw clean compile

# Run (requires MySQL, Redis, Elasticsearch, Kafka, Canal — see application.yml)
./mvnw spring-boot:run

# Run tests (3 test files exist)
./mvnw test
./mvnw test -Dtest=JwtServiceTest

# Package
./mvnw clean package -DskipTests
```

Main class: `com.tongji.ZhiGuangApplication`

## Architecture

The codebase is organized by domain under `com.tongji`:

### Module Map

| Module | Package | Responsibility |
|--------|---------|----------------|
| **auth** | `com.tongji.auth` | Registration, login (password + verification code), JWT token issuance/refresh/revocation (RS256), password reset, RBAC via Spring Security OAuth2 Resource Server |
| **knowpost** | `com.tongji.knowpost` | CRUD for knowledege posts (drafts → publish), feed queries (public/mine) with Caffeine L2 caching, Snowflake IDs |
| **counter** | `com.tongji.counter` | Like/fav counts stored as Redis bitmaps + SDS (Structured Data Storage). Actions produce Kafka events → aggregation consumer flushes to Redis via Lua scripts |
| **relation** | `com.tongji.relation` | Follow/fan relationships via Outbox pattern: MySQL write → Canal binlog subscription → Kafka → event processor → Redis ZSet caches + user counter updates |
| **search** | `com.tongji.search` | Elasticsearch full-text search + suggest. Indexing via Canal outbox consumer + historical backfill on startup |
| **profile** | `com.tongji.profile` | User profile update (nickname, bio, tags, school, etc.) + avatar upload to OSS |
| **storage** | `com.tongji.storage` | Alibaba OSS upload (avatar) + presigned PUT URL generation for direct client upload |
| **llm** | `com.tongji.llm` | AI description generation (DeepSeek via Spring AI ChatClient) + RAG index/query (OpenAI embeddings → Elasticsearch vector store) |
| **cache** | `com.tongji.cache` | Caffeine L2 caches for feed/detail pages + hot key detection |
| **user** | `com.tongji.user` | User domain entity, mapper, and basic CRUD service |
| **common** | `com.tongji.common` | `BusinessException`/`ErrorCode` enum, `GlobalExceptionHandler` (`@RestControllerAdvice`), `OutboxMessageUtil` |

### Data Flow: Outbox Pattern (Canal → Kafka)

```
[MySQL outbox table] --binlog--> [Canal] --CanalKafkaBridge--> [Kafka: canal-outbox]
                                                                       |
  ┌────────────────────────────────────────────────────────────────────┘
  ├── CanalOutboxConsumer (groupId: relation-outbox-consumer) → RelationEventProcessor → follow/fan tables + Redis ZSet + user counters
  └── CanalOutboxConsumerSearch (groupId: search-index-consumer) → SearchIndexService → Elasticsearch upsert/soft-delete
```

Canal bridge (`CanalKafkaBridge`) implements `SmartLifecycle` — starts/connects on Spring startup, runs on `taskExecutor` thread pool.

### Data Flow: Counter System

```
[API: like/fav] → CounterService → CounterEventProducer → Kafka: counter-events
                                                               |
                                                    CounterAggregationConsumer
                                                    (Redis Hash agg buckets)
                                                               |
                                                    @Scheduled(fixedDelay=1s) flush()
                                                    (Lua script folds deltas into SDS)
```

Redis counter keys follow schema: `cnt:{schema}:{etype}:{eid}` (SDS), `agg:{schema}:{etype}:{eid}` (Hash aggregation bucket). User-state bitmaps use `bf:{etype}:{eid}`.

### Auth Flow

- **JWT**: RS256 asymmetric keys at `src/main/resources/keys/{private,public}.pem`. Access tokens (15min) + refresh tokens (7 days) with whitelist in Redis (`RedisRefreshTokenStore`).
- **Verification codes**: Redis-backed (`RedisVerificationCodeStore`), 6-digit, 5-minute TTL, max 5 attempts, 60s send interval, daily limit 10. `LoggingCodeSender` logs to console (production would use SMS/email).
- **Password**: BCrypt strength 12, min 8 chars, must include letters + digits.
- **Security config** (`SecurityConfig`): Stateless sessions, public endpoints for auth + feed/detail/RAG QA, all others require valid JWT. CORS allows all origins (marked TODO).

### KnowPost Content Lifecycle

1. `POST /drafts` → creates row with status=draft, Snowflake ID
2. Direct OSS upload via presigned URL (`StorageController`)
3. `POST /{id}/content/confirm` → writes OSS metadata to row
4. `PATCH /{id}` → update title/tags/visibility/etc
5. `POST /{id}/publish` → status → published, writes outbox event → triggers ES re-index

### Search Index

- Index name: `zhiguang_content_index` (distinct from Spring AI vector index `zhiguang-ai-index`)
- Uses Elasticsearch Java API Client (`co.elastic.clients`), not Spring Data ES
- Backfill on startup if index empty; incremental via Canal outbox consumer
- Content body auto-detects charset (UTF-8/GB18030 fallback) when fetching from OSS

### LLM / AI

- **DeepSeek**: `spring-ai-starter-model-deepseek` via `deepseek-v4-flash` model, used for content description generation (via `ChatClient` bean)
- **OpenAI**: Embeddings only (`text-embedding-v4`, 1536 dims), stored in ES vector index (`zhiguang-ai-index`) for RAG
- RAG QA endpoint: `GET /api/v1/knowposts/{id}/qa/stream` (SSE streaming, public access)

## Database

- Schema: `db/schema.sql` — 5 tables: `users`, `login_logs`, `know_posts`, `outbox`, `following`, `follower`
- MyBatis XML mappers: `src/main/resources/mapper/*.xml`
- MyBatis config: `map-underscore-to-camel-case: true`
- Snowflake ID generation (`SnowflakeIdGenerator`) for `know_posts.id` and relationship IDs

## Configuration Notes

- `application.yml` is git-ignored (contains credentials). Template structure visible at `src/main/resources/application.yml`.
- Canal bridge enabled via `canal.enabled` property
- Counter rebuild feature (`counter.rebuild.enabled`) uses Redisson distributed lock
- Hot key detector: Caffeine-based with configurable thresholds (`cache.hotkey.*`)

## Common Exceptions

- Throw `BusinessException(ErrorCode.XYZ)` for expected errors — caught by `GlobalExceptionHandler` returning HTTP 400
- `ErrorCode` enum defines 12 error codes covering auth, validation, and server errors
- Unknown exceptions map to HTTP 500 with generic message

## Key Dependencies

Spring AI BOM 1.0.3, Elasticsearch Java Client 9.2.1, MyBatis Spring Boot Starter 3.0.3, Redisson 3.52.0, Caffeine 3.1.8, Alibaba Canal Client 1.1.8, Alibaba OSS SDK 3.17.3, MySQL Connector 9.5.0

---

## Frontend (zhiguang_fe-main- yuanban)

React 18 + TypeScript + Vite 5, CSS Modules, React Router v6. No UI framework — all styles are handcrafted with CSS custom properties and CSS Modules. The design language is warm/muted: cream surfaces (`#fffaf2`), dark charcoal text (`#211f1b`), warm accent (`#b65f35` / `#7f3e25`), patterned dot-grid background.

### Build & Run

```bash
cd zhiguang_fe-main-\ yuanban
npm install            # install dependencies
npm run dev            # dev server at localhost:5173, proxies /api → localhost:8080
npm run build          # type-check + production build
npm run lint           # tsc --noEmit
npm run preview        # preview production build
```

The Vite dev server proxies `/api` to `http://localhost:8080` (the Spring Boot backend).

### Route Map

| Route | Component | Description |
|-------|-----------|-------------|
| `/` | `HomePage` | Feed of published knowposts + hero panel |
| `/search` | `SearchPage` | Full-text search with prefix suggestions |
| `/create` | `CreatePage` | Create/publish a knowpost (draft → content upload → publish) |
| `/learn` | `LearningPage` | Bookmarked/saved content (placeholder) |
| `/profile` | `ProfilePage` | User profile + own knowposts |
| `/profile/edit` | `EditProfilePage` | Edit user profile |
| `/post/:id` | `CourseDetailPage` | Knowpost detail + Markdown rendering + RAG Q&A panel |
| `/login` | `LoginPage` | Phone + password login |
| `/register` | `RegisterPage` | Registration |

### Architecture

```
src/
├── components/
│   ├── cards/           CourseCard (knowpost card), LikeFavBar, ...
│   ├── common/          SearchBar, Tag, TagInput, Select, UserBadge, FollowButton, ...
│   ├── icons/           SVG icon components (HomeIcon, SearchIcon, CreateIcon, ...)
│   └── layout/          AppLayout (shell + sidebar), MainHeader (page header), Sidebar
├── context/             AuthContext (JWT token + user state, localStorage persistence)
├── features/auth/       AuthStatus (login button / user badge + logout)
├── pages/               One component per route + *.module.css
├── services/            apiClient (fetch wrapper), authService, knowpostService,
│                        searchService, profileService, relationService
├── theme/               Design tokens (colors, radii, shadows, layout)
├── types/               TypeScript interfaces (auth, content, knowpost, profile, relation, search)
├── App.tsx              Route definitions
├── main.tsx             Entry point (BrowserRouter + AuthProvider)
└── index.css            CSS custom properties (:root), global resets, .ghost-button, .app-shell
```

### Key Design Patterns

- **CSS custom properties** defined in `index.css` (`:root`): colors (`--color-*`), radii (`--radius-*`), shadows (`--shadow-*`), easing (`--ease-out`). Used everywhere via `var(--color-*)` — never hardcode colors.
- **CSS Modules** for component-scoped styles (`*.module.css`). Global utilities like `.ghost-button` and `.app-shell` are in `index.css`.
- **Auth flow**: `AuthContext` stores JWT tokens in localStorage (`zhiguang_auth_tokens`), auto-refreshes every 60s, persists user profile. `apiClient` auto-attaches `Authorization: Bearer <token>` from localStorage. All pages check `useAuth()` for user state.
- **Feed/card pattern**: HomePage, SearchPage, and ProfilePage all render `CourseCard` inside a CSS masonry layout (`.masonry` from `HomePage.module.css` — reused via import across pages).
- **Mock-free**: No mock data. All data comes from the backend API.
- **No external UI lib**: No Ant Design, MUI, Tailwind, etc. All styles are hand-written CSS Modules.
