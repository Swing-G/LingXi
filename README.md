<p align="center">
  <a href="https://github.com/Swing-G/LingXi">
    <picture>
      <!-- TODO: 替换为实际 Logo 图片 -->
      <source srcset="assets/zhiguang-logo.png">
      <img src="assets/zhiguang-logo.png" alt="ZhiGuang — 开发者知识共享平台" width="200">
    </picture>
  </a>
</p>

<p align="center">
  <strong>灵析 ZhiGuang — 开发者知识共享平台</strong><br/>
  <sub>知文创作 × 全文检索 × RAG 智能问答 × 社交互动 × 高并发计数</sub>
</p>

<p align="center">
  <img alt="Java" src="https://img.shields.io/badge/Java-21-blue?style=flat-square&logo=java" />
  <img alt="Spring Boot" src="https://img.shields.io/badge/Spring%20Boot-3.2.4-green?style=flat-square&logo=springboot" />
  <img alt="React" src="https://img.shields.io/badge/React-18-61DAFB?style=flat-square&logo=react" />
  <img alt="TypeScript" src="https://img.shields.io/badge/TypeScript-5-3178C6?style=flat-square&logo=typescript" />
  <img alt="MySQL" src="https://img.shields.io/badge/MySQL-8.0-4479A1?style=flat-square&logo=mysql" />
  <img alt="Elasticsearch" src="https://img.shields.io/badge/Elasticsearch-9.2.1-FEC514?style=flat-square&logo=elasticsearch" />
  <img alt="Kafka" src="https://img.shields.io/badge/Kafka-4.1-231F20?style=flat-square&logo=apachekafka" />
  <img alt="Redis" src="https://img.shields.io/badge/Redis-8.4-DC382D?style=flat-square&logo=redis" />
  <a href="./LICENSE"><img alt="License" src="https://img.shields.io/badge/license-MIT-4a9b8f?style=flat-square" /></a>
</p>

---

## 项目简介

**灵析（ZhiGuang）** 是一个面向开发者的知识共享平台，提供从内容创作、发布、检索到 AI 智能问答的完整闭环体验。用户可以撰写技术文章（知文），通过全文检索发现优质内容，借助 RAG（检索增强生成）对单篇文章进行深度问答，同时支持点赞、收藏、关注等社交互动。

系统采用前后端分离架构，后端基于 Spring Boot 3.2.4 + Java 21，前端使用 React 18 + TypeScript + Vite。在数据一致性、高并发计数、异步事件处理等核心场景上，运用了 Outbox 发件箱模式、Canal + Kafka 消息管道、Redis 位图计数器等企业级架构方案。

> 代码仓库：https://github.com/Swing-G/LingXi

---

## 目录

- [一、系统总览](#一系统总览)
- [二、核心功能详解](#二核心功能详解)
  - [2.1 用户认证体系](#21-用户认证体系)
  - [2.2 知文创作与发布](#22-知文创作与发布)
  - [2.3 全文检索](#23-全文检索)
  - [2.4 RAG 智能问答](#24-rag-智能问答)
  - [2.5 AI 摘要生成](#25-ai-摘要生成)
  - [2.6 社交互动（点赞/收藏/关注）](#26-社交互动点赞收藏关注)
  - [2.7 用户画像与个人主页](#27-用户画像与个人主页)
- [三、底层架构设计](#三底层架构设计)
  - [3.1 Outbox 发件箱模式（Canal → Kafka）](#31-outbox-发件箱模式canal--kafka)
  - [3.2 高并发计数系统](#32-高并发计数系统)
  - [3.3 LLM 分布式排队限流](#33-llm-分布式排队限流)
  - [3.4 多级缓存体系](#34-多级缓存体系)
- [四、技术栈](#四技术栈)
- [五、快速启动](#五快速启动)
- [六、项目结构](#六项目结构)
- [七、部署指南](#七部署指南)
- [八、许可证](#八许可证)

---

## 一、系统总览

灵析平台围绕"内容创作 → 检索发现 → AI 增强阅读 → 社交互动"这条主线，构建了一个完整的开发者知识社区。

| 使用场景 | 功能入口 | 核心能力 |
|---------|---------|---------|
| **内容发现** | 首页 `/` | Feed 信息流、热门知文推荐、分类浏览 |
| **内容创作** | 创作页 `/create` | Markdown 编辑器、OGS 直传、草稿管理、AI 摘要生成 |
| **全文检索** | 搜索页 `/search` | 关键词检索、标签过滤、搜索联想（Completion Suggester）、游标分页 |
| **深度阅读** | 详情页 `/post/:id` | Markdown 渲染、RAG 智能问答、点赞收藏 |
| **个人主页** | 个人页 `/profile` | 用户信息、知文列表、关注/粉丝管理 |
| **账号管理** | 登录 `/login`、注册 `/register` | 手机号注册、验证码登录、密码找回、JWT 鉴权 |

<!-- 截图占位：首页 Feed 流全貌 -->
> 📸 **截图占位** — 首页知识流展示

<!-- 截图占位：知文详情页 + RAG 问答面板 -->
> 📸 **截图占位** — 知文详情页，展示 Markdown 渲染内容与右侧 RAG 问答面板

<!-- 截图占位：搜索页 + 搜索联想下拉 -->
> 📸 **截图占位** — 全文检索页面，展示搜索联想与结果列表

---

## 二、核心功能详解

### 2.1 用户认证体系

**路径**：`/login`、`/register`

完整的用户注册、登录、鉴权体系，基于 Spring Security + OAuth2 Resource Server 实现无状态 JWT 认证。

| 能力 | 说明 |
|------|------|
| **注册** | 手机号 + 验证码注册，密码要求至少 8 位含字母和数字，BCrypt 强度 12 |
| **登录** | 手机号 + 密码登录 / 手机号 + 验证码登录（双通道） |
| **验证码** | Redis 存储，6 位数字，5 分钟有效期，最多 5 次尝试，60s 发送间隔，每日上限 10 次 |
| **JWT Token** | RS256 非对称加密，Access Token 15 分钟，Refresh Token 7 天，Redis 白名单管理 |
| **Token 刷新** | 无感刷新（前端 AuthContext 自动 60s 检查），过期自动续期 |
| **密码重置** | 验证码校验 → 新密码设置 |
| **登录审计** | `login_logs` 表记录每次登录的 IP、设备、时间 |

<!-- 截图占位：登录页 + 注册页 -->
> 📸 **截图占位** — 登录页与注册页双栏展示

**安全配置亮点**：
- 关闭 CSRF（纯 API，JWT 无会话）
- 无状态 Session（`SessionCreationPolicy.STATELESS`）
- 公开接口白名单（Feed、详情、搜索、RAG 问答等允许匿名访问）
- 其余接口强制 JWT 校验

---

### 2.2 知文创作与发布

**路径**：`/create`

支持从草稿到发布的完整内容生命周期管理。

| 能力 | 说明 |
|------|------|
| **草稿创建** | `POST /drafts` → 生成 Snowflake ID，状态为 `draft` |
| **OGS 直传** | 前端通过预签名 URL 直接将 Markdown 文件上传至阿里云 OSS，不经过后端中转 |
| **内容确认** | `POST /{id}/content/confirm` → 写入 OSS 元数据 |
| **元信息编辑** | `PATCH /{id}` → 修改标题、标签、可见性等 |
| **发布** | `POST /{id}/publish` → 状态变更为 `published`，写入 Outbox 事件 → 触发 ES 索引 |
| **可见性控制** | 支持公开/私有/好友可见等多种可见性级别 |
| **置顶管理** | 支持将知文设为置顶 |

**发布触发链路**：
```
[用户发布] → [know_posts 状态变更] → [Outbox 写入] → [Canal 监听 binlog]
→ [Kafka canal-outbox] → [SearchIndexService] → [Elasticsearch 索引更新]
```

<!-- 截图占位：创作页面 — Markdown 编辑器 + 元信息编辑面板 -->
> 📸 **截图占位** — 创作页，左侧 Markdown 编辑区 + 右侧标题/标签/封面配置面板

---

### 2.3 全文检索

**路径**：`/search`

基于 Elasticsearch 9.2.1 构建的高性能全文检索系统。

| 能力 | 说明 |
|------|------|
| **关键词检索** | 对知文标题、正文、标签进行多字段匹配 |
| **标签过滤** | 支持以 CSV 格式传入多个标签进行精确过滤 |
| **搜索联想** | Elasticsearch Completion Suggester，输入前缀即实时返回建议 |
| **游标分页** | 基于 `search_after` 的深度分页（Base64URL 编码游标），避免 `from+size` 性能问题 |
| **增量索引** | Canal Outbox 消费者增量同步，发布即索引 |
| **历史回填** | 启动时检测 ES 索引，为空则自动全量回填 |
| **内容编码兼容** | 自动检测 UTF-8 / GB18030 编码，从 OSS 拉取正文时正确解码 |

**索引名**：`zhiguang_content_index`（独立于 RAG 向量索引 `zhiguang-ai-index`）

**搜索 API**：
```
GET /api/v1/search?q=Spring Boot&size=10&tags=java,后端&after=<cursor>
GET /api/v1/search/suggest?prefix=Spr&size=5
```

<!-- 截图占位：搜索结果页 + 联想下拉 -->
> 📸 **截图占位** — 搜索联想下拉框 + 搜索结果卡片列表

---

### 2.4 RAG 智能问答

**路径**：`/post/:id` → 右侧问答面板

这是平台的亮点功能之一。用户阅读知文时，可以直接对文章内容进行提问，系统通过 RAG（检索增强生成）技术，在文章上下文中检索相关片段，然后由 LLM 生成精准回答。

**技术流程**：
```
[用户提问] → [OpenAI Embedding 向量化]
→ [ES 向量相似度检索（过滤 postId）]
→ [取 Top-K 相关片段作为上下文]
→ [DeepSeek Chat 生成回答]
→ [SSE 流式返回（逐字输出）]
```

| 能力 | 说明 |
|------|------|
| **向量嵌入** | OpenAI `text-embedding-v4`，1536 维向量，存储于 ES 向量索引 `zhiguang-ai-index` |
| **语义检索** | ES `similaritySearch` 向量检索 + `postId` 过滤，确保只检索目标文章 |
| **流式输出** | WebFlux + SSE（Server-Sent Events），逐字推送回答内容 |
| **分布式限流** | LLM 调用经过排队系统，防止 API 超限（429） |
| **索引自动化** | 首次问答时自动触发索引构建（`ensureIndexed`），用户无感知 |
| **手动重建** | 提供 `POST /{id}/rag/reindex` 和 `POST /{id}/search/reindex` 接口 |
| **错误容错** | 优雅处理 429（限流）、Timeout、401/402（认证/余额）、编码异常 |

**RAG 问答 API**：
```
GET /api/v1/knowposts/{id}/qa/stream?question=...&topK=5&maxTokens=1024
```

<!-- 截图占位：RAG 问答面板 — 提问输入框 + 流式回答 + 引用片段 -->
> 📸 **截图占位** — 知文详情页右侧 RAG 问答面板，展示提问 → 检索过程 → 流式回答

---

### 2.5 AI 摘要生成

借助 DeepSeek 大模型，自动为知文生成描述摘要，降低创作门槛。

| 能力 | 说明 |
|------|------|
| **摘要建议** | 前端输入正文后，请求 AI 生成摘要建议 |
| **模型** | DeepSeek Chat（`deepseek-chat`），通过 Spring AI `ChatClient` 调用 |

**流程**：
```
[前端提交正文] → [POST /api/v1/knowposts/description/suggest]
→ [DeepSeek ChatClient] → [返回摘要建议文本]
```

---

### 2.6 社交互动（点赞/收藏/关注）

平台提供完整的社交互动能力，采用 **Redis 位图 + Kafka 异步聚合** 的高并发计数架构。

#### 点赞 & 收藏

| 能力 | 说明 |
|------|------|
| **点赞/取消点赞** | `POST /api/v1/action/like` / `unlike` — 幂等操作，重复操作无副作用 |
| **收藏/取消收藏** | `POST /api/v1/action/fav` / `unfav` — 同样幂等 |
| **用户状态位图** | Redis Bitmap（`bf:{etype}:{eid}`）记录每个用户对每个实体的操作状态 |
| **计数存储** | Redis SDS（Structured Data Storage）键 `cnt:{schema}:{etype}:{eid}` |
| **异步聚合** | 操作事件 → Kafka → 聚合消费者 → Redis Hash 累加 → Lua 脚本定时刷入 SDS |
| **批量查询** | `GET /api/v1/counters/{etype}/{eid}` 返回多指标计数 + 当前用户状态 |

**计数聚合流程**：
```
[API: like/fav] → [CounterService: 位图检查 + Kafka 事件]
→ [Kafka Topic: counter-events]
→ [CounterAggregationConsumer: Redis Hash 聚合桶]
→ [@Scheduled(1s) flush(): Lua 脚本原子性折叠增量到 SDS]
```

<!-- 截图占位：知文卡片上的点赞/收藏按钮 + 计数展示 -->
> 📸 **截图占位** — 知文卡片底部 LikeFavBar 组件，展示点赞数/收藏数及当前用户操作状态

#### 关注 & 粉丝

| 能力 | 说明 |
|------|------|
| **关注/取消关注** | `POST /api/v1/relations/follow/{userId}` / `unfollow` |
| **粉丝列表** | `GET /api/v1/relations/followers?userId=...` |
| **关注列表** | `GET /api/v1/relations/following?userId=...` |
| **关注统计** | 关注数 / 粉丝数实时查询 |

**关注数据流（Outbox 模式）**：
```
[MySQL: following/follower 写入] → [Outbox 表写入]
→ [Canal binlog 监听] → [CanalKafkaBridge]
→ [Kafka: canal-outbox] → [RelationEventProcessor]
→ [Redis ZSet 缓存 + 用户计数更新]
```

<!-- 截图占位：个人主页的关注/粉丝面板 + 关注按钮 -->
> 📸 **截图占位** — 个人主页展示关注数/粉丝数，用户卡片上的 FollowButton

---

### 2.7 用户画像与个人主页

**路径**：`/profile`、`/profile/edit`

| 能力 | 说明 |
|------|------|
| **个人主页** | 展示用户信息（昵称、简介、标签、学校/公司）+ 发布的知文列表 |
| **资料编辑** | 修改昵称、个人简介、标签、教育/工作信息等 |
| **头像上传** | 支持本地上传 → Alibaba OSS 存储 |
| **OSS 直传** | 头像通过预签名 PUT URL 直接从浏览器上传至 OSS |

<!-- 截图占位：个人主页 + 编辑资料页 -->
> 📸 **截图占位** — 个人主页展示用户信息卡片 + 知文列表；编辑资料页的表单

---

## 三、底层架构设计

### 3.1 Outbox 发件箱模式（Canal → Kafka）

解决**数据库写入与异步操作（搜索索引、关系缓存）的数据一致性问题**。

```
                    ┌──────────┐
  [业务操作] ──────→│  MySQL   │
                    │ ┌──────┐ │
                    │ │业务表│ │  同一个本地事务
                    │ ├──────┤ │
                    │ │Outbox│ │
                    │ └──────┘ │
                    └────┬─────┘
                         │ binlog 实时监听
                    ┌────▼─────┐
                    │  Canal   │  CanalKafkaBridge (SmartLifecycle)
                    └────┬─────┘
                         │ 转发到 Kafka
                    ┌────▼─────┐
                    │  Kafka   │  Topic: canal-outbox
                    └──┬───┬──┘
                       │   │
              ┌────────┘   └────────┐
              ▼                      ▼
   ┌──────────────────┐  ┌──────────────────┐
   │ Relation Consumer│  │ Search Consumer  │
   │ (关注/粉丝同步)   │  │ (ES 索引同步)    │
   └──────────────────┘  └──────────────────┘
```

| 组件 | 职责 |
|------|------|
| **CanalKafkaBridge** | 实现 `SmartLifecycle`，在 Spring 启动时连接 Canal，异步消费 binlog，提取 Outbox 表变更 → 投递到 Kafka |
| **RelationEventProcessor** | 消费 `canal-outbox` → 解析 follow/fan 事件 → 写入 Redis ZSet（关系缓存）+ 更新用户计数 |
| **CanalOutboxConsumerSearch** | 消费 `canal-outbox` → 调用 `SearchIndexService` → Elasticsearch 文档的 upsert/soft-delete |
| **SearchIndexInitializer** | 启动检测：ES 索引为空 → 自动从 MySQL 全量回填所有已发布知文 |

**可靠性保证**：
- Canal 批次确认位点（`ack`），确保至少一次投递
- 仅转发 INSERT/UPDATE 的 `payload` 字段，过滤无关事件
- 解析失败 / 非关心类型不提交位点，保证消息不丢失

---

### 3.2 高并发计数系统

针对点赞、收藏这类高频操作场景，设计了一套**写操作轻量化 + 异步聚合**的计数系统。

**核心数据结构（Redis）**：

| 键模式 | 类型 | 用途 |
|--------|------|------|
| `cnt:{schema}:{etype}:{eid}` | SDS | 最终计数存储（likeCount、favCount 等） |
| `bf:{etype}:{eid}` | Bitmap | 用户操作状态（第 N 位 = 用户 N 是否已操作） |
| `agg:{schema}:{etype}:{eid}` | Hash | 增量聚合桶（field=指标名，value=增量） |

**写路径**：
```
[API 点赞] → [CounterService.like()]
  ├── [Redis Bitmap SETBIT]  ← 原子性判断 + 标记
  └── [Kafka 发送 CounterEvent]  ← 异步通知（轻量）
```

**聚合路径**：
```
[Kafka CounterEvents] → [CounterAggregationConsumer]
  └── [Redis Hash HINCRBY]  ← 聚合桶累加（批量）

[@Scheduled 每秒] → [Lua 脚本 flush]
  └── [HGETALL 聚合桶] → [SDS 原子折叠] → [DEL 聚合桶]
```

**查询路径**：
```
[API 查询计数] → [CounterService.getCounts()]
  ├── [SDS 读最终计数]
  └── [Bitmap GETBIT 查用户状态]
```

**设计亮点**：
- **幂等性**：Bitmap + Lua 脚本保证重复操作无副作用
- **原子性**：Lua 脚本在 Redis 服务端原子执行，避免并发竞态
- **读写分离**：写入走 Kafka 异步路径，读取直接访问 Redis SDS
- **批量查询**：`getCountsBatch` 支持一次查询多个实体的多个指标
- **用户计数**：`UserCounterService` 独立管理用户的获赞数、粉丝数等

> **Benchmark 参考**：`RedisMemoryBenchmark` 可对位图 + SDS 方案进行内存占用评估。

<!-- 截图占位：计数系统架构图 — Bitmap + SDS + Kafka 聚合流程 -->
> 📸 **截图占位** — 计数系统数据流架构图

---

### 3.3 LLM 分布式排队限流

RAG 问答依赖 DeepSeek API，受限于 API 并发限制。系统实现了**基于 Redis 的分布式排队限流**机制。

| 组件 | 说明 |
|------|------|
| **LlmQueueService** | 核心排队逻辑：`tryAcquire` → 排队等待 → `streamQueue` 推送位置更新 → 获取槽位 → `release` |
| **LlmQueueController** | SSE 端点 `GET /api/v1/llm/queue/{requestId}/status`，客户端可订阅排队状态 |

**排队流程**：
```
[用户提问] → [RagQueryService.streamAnswerFlux()]
  ├── tryAcquire() → 立即获取? → 直接流式回答
  ├── tryAcquire() → 队列已满? → 返回 "系统繁忙"
  └── tryAcquire() → 排队中 → SSE 推送位置更新
      ├── event: queued   {"position": 5}
      ├── event: position {"position": 3, "totalWaiting": 8}
      ├── event: position {"position": 1, "totalWaiting": 6}
      ├── event: ready    {}  ← 获取槽位
      └── 流式回答 → release()
```

**容错处理**：
- 排队超时 → `event: timeout` → 提示重试
- 429（限流）→ 提示"请求过于频繁，请稍等几秒再试"
- 401/402 → 分别提示认证失败/余额不足
- 超时 → 提示"回答生成超时，请简化问题后重试"

---

### 3.4 多级缓存体系

| 缓存层 | 技术 | 用途 | 特性 |
|--------|------|------|------|
| **L2 本地缓存** | Caffeine | Feed 列表、知文详情、热 key 缓存 | LRU + TTL，极低延迟 |
| **L1 远程缓存** | Redis | 用户会话、验证码、计数、关系 ZSet | 分布式共享，持久化 |
| **热 Key 检测** | `HotKeyDetector` | 基于 Caffeine 频率统计自动识别热点 | 可配置阈值，防止缓存击穿 |
| **缓存失效** | `FeedCacheInvalidationListener` | 发布/编辑知文时自动失效相关 Feed 缓存 | 保证缓存一致性 |

---

## 四、技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| **语言** | Java | 21 |
| **后端框架** | Spring Boot | 3.2.4 |
| **安全** | Spring Security + OAuth2 Resource Server | — |
| **ORM** | MyBatis + MyBatis Spring Boot Starter | 3.0.3 |
| **主数据库** | MySQL | 8.0.44 |
| **缓存** | Redis + Redisson（分布式锁/限流） | 8.4.0 / 3.52.0 |
| **本地缓存** | Caffeine | 3.1.8 |
| **搜索引擎** | Elasticsearch（全文 + 向量） | 9.2.1 |
| **消息队列** | Apache Kafka（KRaft） | 4.1.1 |
| **数据同步** | Alibaba Canal | 1.1.8 |
| **AI / LLM** | Spring AI + DeepSeek Chat + OpenAI Embeddings | 1.0.3 |
| **对象存储** | Alibaba OSS | 3.17.3 |
| **前端** | React + TypeScript + Vite | 18 / 5 / 5 |
| **前端路由** | React Router | v6 |
| **样式方案** | CSS Modules + CSS Custom Properties | — |
| **ID 生成** | Snowflake 算法（自研） | — |
| **邮件** | Spring Boot Starter Mail | — |

---

## 五、快速启动

### 环境要求

- **JDK** 21+
- **Maven** 3.6+
- **Node.js** 18+
- **Docker** & Docker Compose

### 1. 启动中间件

```bash
# 进入项目根目录
cd zhiguang

# 启动 MySQL / Redis / Elasticsearch / Kafka / Canal
docker compose up -d

# 等待所有容器健康检查通过
docker compose ps
```

### 2. 初始化数据库

```sql
-- 连接 MySQL
mysql -h localhost -u root -pMySql@123456

-- 创建数据库
CREATE DATABASE IF NOT EXISTS zhiguang DEFAULT CHARACTER SET utf8mb4;

-- 导入表结构（如有 schema.sql）
SOURCE db/schema.sql;
```

### 3. 配置后端

编辑 `zhiguang_be-main-new/src/main/resources/application.yml`：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/zhiguang
    username: root
    password: MySql@123456
  data:
    redis:
      host: localhost
      port: 6379
  elasticsearch:
    uris: http://localhost:9200
    username: elastic
    password: Elastic@9210

# DeepSeek API Key
spring:
  ai:
    deepseek:
      api-key: ${DEEPSEEK_API_KEY}
    openai:
      api-key: ${OPENAI_API_KEY}
```

### 4. 启动后端

```bash
cd zhiguang_be-main-new

# 编译
./mvnw clean compile

# 启动
./mvnw spring-boot:run

# 或者打包运行
./mvnw clean package -DskipTests
java -jar target/zhiguang-1.0-SNAPSHOT.jar
```

后端启动后访问：`http://localhost:8080`

### 5. 启动前端

```bash
cd zhiguang_fe-main-\ yuanban

# 安装依赖
npm install

# 启动开发服务器（代理 /api → localhost:8080）
npm run dev
```

前端启动后访问：`http://localhost:5173`

### 6. 验证

1. 浏览器打开 `http://localhost:5173`
2. 首页应正常显示知文列表（首次可能为空）
3. 注册账号 → 登录 → 创建知文 → 发布
4. 搜索页验证全文检索
5. 进入知文详情页 → 右侧 RAG 问答面板提问

---

## 六、项目结构

```
zhiguang/
├── zhiguang_be-main-new/                    # 后端 Spring Boot 项目
│   ├── pom.xml                              # Maven 配置
│   └── src/main/java/com/tongji/
│       ├── ZhiGuangApplication.java         # 应用入口
│       ├── auth/                            # 🔐 认证模块
│       │   ├── api/AuthController.java      # 注册/登录/Token/密码重置 API
│       │   ├── config/
│       │   │   ├── SecurityConfig.java      # Spring Security 配置
│       │   │   └── AuthProperties.java      # 认证配置属性
│       │   ├── token/
│       │   │   ├── JwtService.java          # JWT RS256 生成/验证
│       │   │   └── RedisRefreshTokenStore   # Redis Token 白名单
│       │   ├── verification/                # 验证码生成/校验/发送
│       │   └── audit/                       # 登录审计日志
│       ├── knowpost/                        # 📝 知文模块
│       │   ├── api/
│       │   │   ├── KnowPostController.java  # 知文 CRUD + 发布
│       │   │   ├── KnowPostRagController.java # RAG 问答 + 索引管理
│       │   │   └── KnowPostAiController.java  # AI 摘要生成
│       │   ├── service/                     # 知文服务 + Feed 服务
│       │   ├── model/                       # 实体 / FeedRow / DetailRow
│       │   └── id/SnowflakeIdGenerator.java # Snowflake ID 生成
│       ├── counter/                         # 🔢 计数模块
│       │   ├── api/                         # 点赞/收藏 API + 计数查询 API
│       │   ├── service/CounterService.java  # 位图操作 + Kafka 事件
│       │   ├── event/                       # CounterEventProducer / Consumer
│       │   └── schema/                      # CounterKeys / BitmapShard / SDS
│       ├── relation/                        # 👥 关系模块
│       │   ├── api/RelationController.java  # 关注/取关/列表 API
│       │   ├── service/                     # 关系服务
│       │   ├── outbox/
│       │   │   ├── CanalKafkaBridge.java    # Canal → Kafka 桥接器
│       │   │   ├── CanalOutboxConsumer.java # 关系事件消费者
│       │   │   └── OutboxMapper.java        # Outbox 表操作
│       │   ├── processor/
│       │   │   └── RelationEventProcessor.java # 关系事件 → Redis 同步
│       │   └── event/                       # 关系事件定义
│       ├── search/                          # 🔍 搜索模块
│       │   ├── api/SearchController.java    # 搜索/联想 API
│       │   ├── service/                     # 搜索服务 + ES 查询
│       │   ├── index/
│       │   │   ├── SearchIndexService.java  # ES 索引增量更新
│       │   │   └── SearchIndexInitializer   # 启动时全量回填
│       │   └── outbox/                      # 搜索消费者
│       ├── llm/                             # 🤖 AI 模块
│       │   ├── LlmConfig.java               # ChatClient Bean 配置
│       │   ├── service/                     # 摘要生成服务
│       │   ├── rag/
│       │   │   ├── RagQueryService.java     # RAG 问答（排队 + 检索 + 流式）
│       │   │   └── RagIndexService.java     # 向量索引构建
│       │   └── queue/
│       │       ├── LlmQueueService.java     # 分布式排队限流
│       │       └── LlmQueueController.java  # 排队状态 SSE
│       ├── profile/                         # 👤 用户画像模块
│       ├── storage/                         # ☁️ OSS 存储模块
│       ├── cache/                           # 📦 缓存模块
│       │   ├── config/CacheConfig.java      # Caffeine 缓存配置
│       │   └── hotkey/HotKeyDetector.java   # 热 Key 检测器
│       ├── user/                            # 用户领域实体
│       ├── common/                          # 公共模块
│       │   ├── exception/                   # BusinessException + ErrorCode
│       │   └── web/GlobalExceptionHandler   # 全局异常处理
│       └── config/                          # ES/Redisson/ThreadPool 配置
│   └── src/main/resources/
│       ├── application.yml                  # 应用配置（git-ignored）
│       ├── mapper/                          # MyBatis XML Mapper
│       ├── lua/                             # Redis Lua 脚本
│       └── keys/                            # JWT 公私钥
│
├── zhiguang_fe-main- yuanban/               # 前端 React 项目
│   ├── src/
│   │   ├── pages/                           # 页面组件（Home/Search/Create/Profile/Login...）
│   │   ├── components/
│   │   │   ├── cards/CourseCard.tsx          # 知文卡片组件
│   │   │   ├── common/                       # 通用组件（SearchBar/Tag/Select/Avatar/LikeFavBar...）
│   │   │   ├── icons/                        # SVG 图标组件
│   │   │   └── layout/                       # AppLayout + Sidebar + MainHeader
│   │   ├── context/AuthContext.tsx           # JWT 认证上下文（自动刷新）
│   │   ├── services/                         # API 服务层（apiClient/auth/knowpost/search/profile/relation）
│   │   ├── features/auth/                    # 登录状态指示器
│   │   ├── theme/                            # 设计 Token（颜色/圆角/阴影/布局）
│   │   ├── types/                            # TypeScript 类型定义
│   │   ├── App.tsx                           # 路由定义
│   │   ├── main.tsx                          # 入口
│   │   └── index.css                         # CSS 自定义属性 + 全局样式
│   └── vite.config.ts                        # Vite 配置（API 代理）
│
├── docker-compose.yml                        # 中间件编排
├── deploy.sh                                 # 一键部署脚本
├── DEPLOY.md                                 # 部署指南
├── es-config/elasticsearch.yml               # ES 配置
├── canal-conf/
│   ├── canal.properties                      # Canal 配置
│   └── instance.properties                   # Canal 实例配置
└── docs/                                     # 文档
```

---

## 七、部署指南

项目提供完整的一键部署方案，详细步骤见 [DEPLOY.md](./DEPLOY.md)。

### 快速部署流程

```bash
# 1. 修改 deploy.sh 中的服务器 IP 和 API Key
vim deploy.sh

# 2. 执行部署
chmod +x deploy.sh
./deploy.sh
```

脚本自动完成：
1. 上传代码到服务器
2. 安装 Docker（如未装）
3. 启动 MySQL / Redis / Elasticsearch / Kafka / Canal
4. 配置 ES 密码 + 安装 IK 分词器
5. 导入数据库 + 创建 Canal 用户
6. 构建 Spring Boot 后端并启动
7. 安装 Nginx + 部署前端静态文件

### 服务器目录结构

```
/opt/zhiguang/
├── docker-compose.yml       # 中间件编排
├── application.yml          # 后端配置
├── app.jar                  # Spring Boot
├── app.log                  # 运行日志
├── es-config/
├── canal-conf/
├── data/                    # 数据持久化
│   ├── mysql/
│   ├── redis/
│   ├── es/
│   └── kafka/
└── /var/www/zhiguang/       # 前端静态文件
```

---

## 八、许可证

本项目基于 [MIT License](./LICENSE) 开源。

---

## 联系方式

- 代码仓库：https://github.com/Swing-G/LingXi
