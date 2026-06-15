/*
 Navicat Premium Dump SQL

 Source Server         : mysql8.0
 Source Server Type    : MySQL
 Source Server Version : 80044 (8.0.44)
 Source Host           : localhost:3306
 Source Schema         : zhiguang

 Target Server Type    : MySQL
 Target Server Version : 80044 (8.0.44)
 File Encoding         : 65001

 Date: 15/06/2026 23:01:45
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for follower
-- ----------------------------
DROP TABLE IF EXISTS `follower`;
CREATE TABLE `follower`  (
  `id` bigint UNSIGNED NOT NULL,
  `to_user_id` bigint UNSIGNED NOT NULL,
  `from_user_id` bigint UNSIGNED NOT NULL,
  `rel_status` tinyint NOT NULL DEFAULT 1,
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_to_from`(`to_user_id` ASC, `from_user_id` ASC) USING BTREE,
  INDEX `idx_to_created`(`to_user_id` ASC, `created_at` ASC, `from_user_id` ASC, `rel_status` ASC) USING BTREE,
  INDEX `idx_from`(`from_user_id` ASC, `to_user_id` ASC, `rel_status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of follower
-- ----------------------------
INSERT INTO `follower` VALUES (906623186739537996, 1, 4, 1, '2026-03-06 22:10:37.049', '2026-03-06 22:10:37.049');
INSERT INTO `follower` VALUES (1175089801092263742, 2, 4, 1, '2026-03-06 22:10:50.141', '2026-03-06 22:10:50.141');
INSERT INTO `follower` VALUES (1730613668042333784, 3, 4, 1, '2026-03-06 22:10:59.222', '2026-03-06 22:10:59.222');
INSERT INTO `follower` VALUES (5947043361684682660, 1, 3, 1, '2026-02-10 21:28:36.737', '2026-02-10 21:32:05.824');

-- ----------------------------
-- Table structure for following
-- ----------------------------
DROP TABLE IF EXISTS `following`;
CREATE TABLE `following`  (
  `id` bigint UNSIGNED NOT NULL,
  `from_user_id` bigint UNSIGNED NOT NULL,
  `to_user_id` bigint UNSIGNED NOT NULL,
  `rel_status` tinyint NOT NULL DEFAULT 1,
  `created_at` datetime(3) NOT NULL,
  `updated_at` datetime(3) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_from_to`(`from_user_id` ASC, `to_user_id` ASC) USING BTREE,
  INDEX `idx_from_created`(`from_user_id` ASC, `created_at` ASC, `to_user_id` ASC, `rel_status` ASC) USING BTREE,
  INDEX `idx_to`(`to_user_id` ASC, `from_user_id` ASC, `rel_status` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of following
-- ----------------------------
INSERT INTO `following` VALUES (469630953033625590, 5, 1, 1, '2026-05-12 21:00:10.607', '2026-05-13 12:26:02.416');
INSERT INTO `following` VALUES (906623186739537996, 4, 1, 1, '2026-03-06 22:10:35.799', '2026-03-06 22:10:35.799');
INSERT INTO `following` VALUES (1175089801092263742, 4, 2, 1, '2026-03-06 22:10:49.549', '2026-03-06 22:10:49.549');
INSERT INTO `following` VALUES (1730613668042333784, 4, 3, 1, '2026-03-06 22:10:58.165', '2026-03-06 22:10:58.165');
INSERT INTO `following` VALUES (2713408904467963929, 9, 1, 1, '2026-06-13 13:20:51.089', '2026-06-13 13:20:51.089');
INSERT INTO `following` VALUES (5947043361684682660, 3, 1, 1, '2026-02-10 21:28:35.975', '2026-02-10 21:32:05.006');

-- ----------------------------
-- Table structure for know_posts
-- ----------------------------
DROP TABLE IF EXISTS `know_posts`;
CREATE TABLE `know_posts`  (
  `id` bigint UNSIGNED NOT NULL,
  `tag_id` bigint UNSIGNED NULL DEFAULT NULL COMMENT '主分类/内容分类ID',
  `tags` json NULL COMMENT '标签名数组，例如 [\"java\",\"编程\"]',
  `title` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `description` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '摘要/描述，最多50字',
  `content_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '正文存储于OSS的访问URL或签名URL',
  `content_object_key` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS对象Key',
  `content_etag` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT 'OSS ETag（用于校验）',
  `content_size` bigint UNSIGNED NULL DEFAULT NULL COMMENT '正文字节大小',
  `content_sha256` char(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL COMMENT '正文SHA-256哈希（hex）',
  `creator_id` bigint UNSIGNED NOT NULL,
  `is_top` tinyint(1) NOT NULL DEFAULT 0,
  `type` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'image_text',
  `visible` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'public',
  `img_urls` json NULL COMMENT '图片URL数组或对象数组',
  `video_url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL COMMENT '视频URL（一期不使用）',
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'draft',
  `create_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `update_time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `publish_time` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_know_posts_creator_ct`(`creator_id` ASC, `create_time` ASC) USING BTREE,
  INDEX `ix_know_posts_status_ct`(`status` ASC, `create_time` ASC) USING BTREE,
  INDEX `ix_know_posts_tag_ct`(`tag_id` ASC, `create_time` ASC) USING BTREE,
  INDEX `ix_know_posts_top_ct`(`is_top` ASC, `create_time` ASC) USING BTREE,
  INDEX `ix_know_posts_creator_status_pub`(`creator_id` ASC, `status` ASC, `publish_time` ASC) USING BTREE,
  CONSTRAINT `fk_know_posts_creator` FOREIGN KEY (`creator_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of know_posts
-- ----------------------------
INSERT INTO `know_posts` VALUES (271193723654770688, NULL, NULL, '111', '11', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271193723654770688/content.md', 'posts/271193723654770688/content.md', '\"698D51A19D8A121CE581499D7B701668\"', 3, 'f6e0a1e2ac41945a9aa7ff8a8aaa0cebc12a3bcc981a929ad5cf810a090e11ae', 1, 0, 'image_text', 'private', NULL, NULL, 'published', '2026-01-18 08:27:02', '2026-02-04 20:58:20', '2026-01-18 16:27:04');
INSERT INTO `know_posts` VALUES (271193962159673344, NULL, NULL, '111111', '11111', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271193962159673344/content.md', 'posts/271193962159673344/content.md', '\"B59C67BF196A4758191E42F76670CEBA\"', 4, '0ffe1abd1a08215353c233d6e009613e95eec4253832a761af28ff37ac5a150c', 1, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271193962159673344/images/20260118/f0665e3c.jpg\"]', NULL, 'published', '2026-01-18 08:27:59', '2026-05-13 11:32:25', '2026-01-18 16:28:10');
INSERT INTO `know_posts` VALUES (271195855791460352, NULL, NULL, '222', '解耦与访问发货的关联探讨', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271195855791460352/content.md', 'posts/271195855791460352/content.md', '\"C070A9CA2C8FDF34F9280EBAE4D5EF19\"', 40, '68dcfcf507d2eed1074b1844485090722690043f996323248aabd54ec84cf982', 1, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271195855791460352/images/20260118/eaa4a013.png\"]', NULL, 'published', '2026-01-18 08:35:31', '2026-02-04 20:58:17', '2026-01-18 16:35:39');
INSERT INTO `know_posts` VALUES (271221151143956480, NULL, NULL, '333', '数字串4324234234234234234', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271221151143956480/content.md', 'posts/271221151143956480/content.md', '\"F21F0BE6939212C67FA21371373FA01E\"', 19, '5b1dff8ad5da368cddfc41888cd8a4a0164d25177f23a9295b907421eefde006', 1, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271221151143956480/images/20260118/e02d24b7.png\"]', NULL, 'published', '2026-01-18 10:16:01', '2026-02-04 20:58:15', '2026-01-18 18:16:10');
INSERT INTO `know_posts` VALUES (271833688331915264, NULL, '[\"administrator\"]', '我是一个测试', '精简ES镜像无网络工具属正常,优先用外部命令验证网络,容器内临时安装工具不影响服务', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271833688331915264/content.md', 'posts/271833688331915264/content.md', '\"5FE6FEE58BBEB5E37D79020037BEE4C1\"', 494, '16663aa40583f4290725cbe8fc2649cb2c0a11aa42d4dd56bd6b598eafa58c37', 1, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/271833688331915264/images/20260120/0f767eff.jpg\"]', NULL, 'published', '2026-01-20 02:50:02', '2026-06-13 17:21:11', '2026-01-20 10:50:27');
INSERT INTO `know_posts` VALUES (277401450882142208, NULL, '[\"1221\"]', 'test1', '神秘数字串引人探索', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/277401450882142208/content.md', 'posts/277401450882142208/content.md', '\"C1FAC60EB7538ED0CEB6406E5AB1C202\"', 22, 'bb450a3c64ecfb7a95193d97d4a336642e2e4fbfa00c60a60d7a99bca316815d', 2, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/277401450882142208/images/20260204/db6c3b15.jpg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/277401450882142208/images/20260204/0ec66c93.jpg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/277401450882142208/images/20260204/250cfc5c.jpg\"]', NULL, 'published', '2026-02-04 11:34:20', '2026-05-13 11:32:27', '2026-02-04 19:34:47');
INSERT INTO `know_posts` VALUES (279604408931717120, NULL, NULL, 'test1', NULL, 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/279604408931717120/content.md', 'posts/279604408931717120/content.md', '\"69CEC910651BEFD6CC67AF6AC1447B1D\"', 3327, 'ef135913c93b694878e2d38b77147203cfb27f68db0422e644bf09cd0d2a9c19', 3, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/279604408931717120/images/20260210/e06de3a5.jpg\"]', NULL, 'published', '2026-02-10 13:28:06', '2026-05-13 11:32:27', '2026-02-10 21:28:23');
INSERT INTO `know_posts` VALUES (284613927906709504, NULL, NULL, '133', NULL, 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/284613927906709504/content.md', 'posts/284613927906709504/content.md', '\"979F9554FCB3ED87521529E62B3C6250\"', 15, '7d62dbce7ae71fe8aba28876a42583efa039c83b10328363ceb46e41da4e86b3', 1, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/284613927906709504/images/20260224/a3b21691.webp\"]', NULL, 'published', '2026-02-24 09:14:08', '2026-05-13 11:32:28', '2026-02-24 17:14:14');
INSERT INTO `know_posts` VALUES (288311355407208448, NULL, NULL, 'MySQL', NULL, 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/288311355407208448/content.md', 'posts/288311355407208448/content.md', '\"14498B83DD1667A0C78F4FDAF5AFBF4B\"', 5, '942e7cbef3a365ebbd8b8fecb2eb5a2499e5d9fee43206b905387f462b1352ef', 4, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/288311355407208448/images/20260306/51780473.jpeg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/288311355407208448/images/20260306/62030dd8.jpeg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/288311355407208448/images/20260306/ae760c44.png\"]', NULL, 'published', '2026-03-06 14:06:24', '2026-05-13 11:32:28', '2026-03-06 22:06:43');
INSERT INTO `know_posts` VALUES (288311779124187136, NULL, NULL, 'Redis', NULL, 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/288311779124187136/content.md', 'posts/288311779124187136/content.md', '\"86A1B907D54BF7010394BF316E183E67\"', 5, '34fb46c847bb9df96e5205a39d382f648a6e8dce1e014cd85b4ca6a88d88ed03', 4, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/288311779124187136/images/20260306/06e9137c.png\"]', NULL, 'published', '2026-03-06 14:08:05', '2026-05-13 11:32:29', '2026-03-06 22:08:12');
INSERT INTO `know_posts` VALUES (312592592003010560, NULL, '[\"test\", \"admin\"]', 'test', '这是一个测试的正文内容', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/content.md', 'posts/312592592003010560/content.md', '\"CFCA700B9E09CF664F3AE80733274D9F\"', 18, '9f7ac1e7609c31d81d8c3c255798766abe77f3bf94489e94604be901ce2a855c', 5, 0, 'image_text', 'private', '[\"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/images/20260512/98c853be.jpg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/images/20260512/4af4f36c.jpeg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/images/20260512/436c3417.jpg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/images/20260512/fdea5ed7.jpg\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/images/20260512/742e6ace.png\", \"http://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312592592003010560/images/20260512/9606e320.jpg\"]', NULL, 'published', '2026-05-12 14:11:22', '2026-05-13 11:32:30', '2026-05-12 22:11:53');
INSERT INTO `know_posts` VALUES (312785737584087040, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, 0, 'image_text', 'private', NULL, NULL, 'draft', '2026-05-13 02:58:51', '2026-05-13 11:32:30', NULL);
INSERT INTO `know_posts` VALUES (312786148915286016, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'private', NULL, NULL, 'draft', '2026-05-13 03:00:29', '2026-05-13 11:32:31', NULL);
INSERT INTO `know_posts` VALUES (312786295376187392, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 7, 0, 'image_text', 'private', NULL, NULL, 'draft', '2026-05-13 03:01:04', '2026-05-13 11:32:31', NULL);
INSERT INTO `know_posts` VALUES (312792127631396864, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'private', NULL, NULL, 'draft', '2026-05-13 03:24:15', '2026-05-13 11:32:32', NULL);
INSERT INTO `know_posts` VALUES (312793763833581568, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'private', NULL, NULL, 'draft', '2026-05-13 03:30:45', '2026-05-13 11:32:37', NULL);
INSERT INTO `know_posts` VALUES (312794591613030400, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:34:02', '2026-05-13 03:34:02', NULL);
INSERT INTO `know_posts` VALUES (312796444799143936, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:41:24', '2026-05-13 03:41:24', NULL);
INSERT INTO `know_posts` VALUES (312797114482692096, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:44:04', '2026-05-13 03:44:04', NULL);
INSERT INTO `know_posts` VALUES (312798119249186816, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:48:03', '2026-05-13 03:48:03', NULL);
INSERT INTO `know_posts` VALUES (312799185516761088, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:52:17', '2026-05-13 03:52:17', NULL);
INSERT INTO `know_posts` VALUES (312799469865406464, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:53:25', '2026-05-13 03:53:25', NULL);
INSERT INTO `know_posts` VALUES (312799571967348736, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:53:49', '2026-05-13 03:53:49', NULL);
INSERT INTO `know_posts` VALUES (312800338086334464, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 5, 0, 'image_text', 'public', NULL, NULL, 'draft', '2026-05-13 03:56:52', '2026-05-13 03:56:52', NULL);
INSERT INTO `know_posts` VALUES (312806951027347456, NULL, '[\"数据库\", \"迁移\"]', '如何进行数据库的迁移', '学会数据库迁移技巧,轻松迁移数据并保障安全', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312806951027347456/content.md', 'posts/312806951027347456/content.md', '\"6A0F95D44E455565A63C4741DE09B242\"', 30, 'd5953f2623f89fbcd880f687df22ccdf0f4363553b11abd92a14c017994f53fc', 5, 0, 'image_text', 'private', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312806951027347456/images/20260513/eddc40fd.jpg\"]', NULL, 'published', '2026-05-13 04:23:09', '2026-06-13 17:20:23', '2026-05-13 12:23:32');
INSERT INTO `know_posts` VALUES (312850171799146496, NULL, NULL, 'wiwiiwi', '一篇充满感叹与情绪的简短文字', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312850171799146496/content.md', 'posts/312850171799146496/content.md', '\"7E87634953378CB7C6CE8ECC94974470\"', 60, '085c32ac876b90a76e74822251b4a09e2f45536702e4b0e88133ab7e646928bf', 8, 0, 'image_text', 'private', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/312850171799146496/images/20260513/6b6d00e6.png\"]', NULL, 'published', '2026-05-13 07:14:53', '2026-06-13 17:20:12', '2026-05-13 15:15:41');
INSERT INTO `know_posts` VALUES (313156166559600640, NULL, NULL, '程序员牛肉的面试项目', '程序员牛肉的面试项目', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/content.md', 'posts/313156166559600640/content.md', '\"3CF877B142D6269B3506E119F494732B\"', 15, '9e2e56b5f7c54db296977f40991834dc20a2101db2c70b90d7e7cf2cbaeeea4e', 5, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/7f35e5cd.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/d529d253.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/32da6d6b.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/e89140b4.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/ff3cacb0.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/ee079952.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/313156166559600640/images/20260514/843f1cdf.jpg\"]', NULL, 'published', '2026-05-14 03:30:48', '2026-06-13 12:50:58', '2026-05-14 11:31:27');
INSERT INTO `know_posts` VALUES (324017769920204800, NULL, '[\"人工智能\", \"GPT\", \"DeepSeek\"]', 'GPT-6与DeepSeek V4巅峰对决：AI行业迎来全新变革', 'OpenAI押注AGI终极一战,GPT-6搭载Symphony架构,实现全模态与双系统推理革命', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324017769920204800/content.md', 'posts/324017769920204800/content.md', '\"5D24784E7853B0B9CE5CA8C991405969\"', 2282, 'a1d44ce47b2e7dd382c6ed5bc0009d6e89fd41a5c6db3710142254c9e74b9c2b', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324017769920204800/images/20260613/95e74a60.jpg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324017769920204800/images/20260613/5278c268.png\"]', NULL, 'published', '2026-06-13 02:50:56', '2026-06-13 10:52:26', '2026-06-13 10:52:26');
INSERT INTO `know_posts` VALUES (324018848250597376, NULL, '[\"OpenClaw\", \"龙虾智能体\", \"AI安全\"]', '龙虾智能体不是玩具！国家安全部提醒：这3个防护步骤必做', '龙虾”AI助手可自主执行任务,但存在主机被控、数据泄露等风险,需谨慎使用', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324018848250597376/content.md', 'posts/324018848250597376/content.md', '\"D5FFCA9A64F51A301EEFFBCB666D3E4F\"', 8295, 'f2317f42629b4aba3155c00ef3869a97be0f1efbeccc5fc142d62b3c3d70f6da', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324018848250597376/images/20260613/ba97e4e0.jpeg\"]', NULL, 'published', '2026-06-13 02:55:13', '2026-06-13 10:58:15', '2026-06-13 10:58:15');
INSERT INTO `know_posts` VALUES (324020258153304064, NULL, '[\"Java\", \"CAS原理\", \"Java面试\"]', '【面试专栏｜Java并发编程】CAS 核心原理，优缺点，ABA问题与解决方案', 'CAS无锁并发核心:比较并交换,依赖CPU原子指令,解决ABA问题用版本号或AtomicStampe', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324020258153304064/content.md', 'posts/324020258153304064/content.md', '\"8AAB3C094221017B0DA709757BCFF5D6\"', 9811, '76d7030322833ef738bb261ac3396f16cd7e9a686338c366681d495de92432da', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324020258153304064/images/20260613/0d94af40.jpeg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324020258153304064/images/20260613/2f564e4c.jpeg\"]', NULL, 'published', '2026-06-13 03:00:50', '2026-06-13 11:02:45', '2026-06-13 11:02:45');
INSERT INTO `know_posts` VALUES (324020950167326720, NULL, '[\"OpenClaw\", \"AI Agent\", \"自主智能体\"]', '从玩具到超越 Linux 的开源奇迹：2026 年爆火的 OpenClaw 究竟是什么？', 'OpenClaw:7x24小时自主智能体,开启一人企业时代,你的数字管家', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324020950167326720/content.md', 'posts/324020950167326720/content.md', '\"5E0B713007F5CB25FC96F83288B6F3B6\"', 5679, '6a04644ee79f1615aaa31bc305bce73ac76c22144a5b7ef09847dfdf5ee23126', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324020950167326720/images/20260613/ee967d5e.jpeg\"]', NULL, 'published', '2026-06-13 03:03:35', '2026-06-13 11:04:37', '2026-06-13 11:04:37');
INSERT INTO `know_posts` VALUES (324112287772315648, NULL, '[\"JVM\", \"Java引用类型\", \"JVM内存管理\"]', '【面试专栏｜JVM虚拟机】JVM内存优化必看：软引用、弱引用的正确用法，避免内存泄漏踩坑', '透彻讲解Java四种引用:强引用、软引用、弱引用、虚引用,及GC回收策略与适用场景', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324112287772315648/content.md', 'posts/324112287772315648/content.md', '\"4672F36EA724CE14AAA9EC5C2BD2738A\"', 4063, 'd968d5850d632406999f87306ef05e28f91ee6e14028a90f778cfa606fd0ed59', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324112287772315648/images/20260613/ca028f4a.jpeg\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324112287772315648/images/20260613/eeb898cc.jpeg\"]', NULL, 'published', '2026-06-13 09:06:31', '2026-06-13 17:07:50', '2026-06-13 17:07:50');
INSERT INTO `know_posts` VALUES (324112937180598272, NULL, '[\"一致性Hash\", \"Java面试\", \"分布式缓存\"]', '一致性HASH详解+Java面试算法实现', '一致性哈希核心:哈希环映射节点与key,增减节点仅影响局部,避免哈希雪崩', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324112937180598272/content.md', 'posts/324112937180598272/content.md', '\"43FC7BB98FFD51A5D5F000B4230D80AD\"', 2941, '6f5bd8b4bbfb1d61a30fb7d4696beaac459d3470a7eed931eb1a650e0ea78ab3', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324112937180598272/images/20260613/2b7ba433.webp\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324112937180598272/images/20260613/8f126f75.jpeg\"]', NULL, 'published', '2026-06-13 09:09:06', '2026-06-13 17:10:33', '2026-06-13 17:10:33');
INSERT INTO `know_posts` VALUES (324114290690887680, NULL, '[\"MCP\", \"模型上下文协议\", \"Agent\"]', '【MCP模型上下文协议】AI Agent的通用“USB-C接口”，打通大模型与真实世界的标准化桥梁', 'AI Agent工具调用“碎片化噩梦”?MCP协议,统一大模型交互的“USB-C”标准来了', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324114290690887680/content.md', 'posts/324114290690887680/content.md', '\"C012F47BB5B8DC491BDFD9A12808115F\"', 14005, 'f50e9716a7ea8a7010ffd75a7af17270feb41ef134339a5493e527830f42918b', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324114290690887680/images/20260613/afb7c958.png\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324114290690887680/images/20260613/4fe387d9.png\", \"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324114290690887680/images/20260613/d67495a7.png\"]', NULL, 'published', '2026-06-13 09:14:29', '2026-06-13 17:16:13', '2026-06-13 17:16:13');
INSERT INTO `know_posts` VALUES (324115145393573888, NULL, '[\"AI Agent\", \"LLM\", \"Agentic AI\"]', '【AI Agent】从大模型“对话工具”到自主智能体的进化之路', 'AI Agent让大模型从“对话工具”进化为能感知、会思考、可执行的自主智能体', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324115145393573888/content.md', 'posts/324115145393573888/content.md', '\"9AE4A6BD676197C18D0FC17860D7945D\"', 17672, '183e56df6a6cc9beed656ca2773010011b73aeb62d463775c05bf6aee49abf01', 1, 0, 'image_text', 'public', '[\"https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/posts/324115145393573888/images/20260613/604e1ebc.png\"]', NULL, 'published', '2026-06-13 09:17:52', '2026-06-13 17:18:50', '2026-06-13 17:18:50');

-- ----------------------------
-- Table structure for login_logs
-- ----------------------------
DROP TABLE IF EXISTS `login_logs`;
CREATE TABLE `login_logs`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` bigint UNSIGNED NULL DEFAULT NULL,
  `identifier` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `channel` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `status` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_login_logs_user_created_at`(`user_id` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 43 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of login_logs
-- ----------------------------
INSERT INTO `login_logs` VALUES (1, 1, '13864424165', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'SUCCESS', '2026-01-18 08:26:51');
INSERT INTO `login_logs` VALUES (2, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'SUCCESS', '2026-01-20 02:49:43');
INSERT INTO `login_logs` VALUES (3, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36', 'SUCCESS', '2026-01-22 13:45:31');
INSERT INTO `login_logs` VALUES (4, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-02-04 11:29:14');
INSERT INTO `login_logs` VALUES (5, 2, '15634293321', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0', 'SUCCESS', '2026-02-04 11:33:29');
INSERT INTO `login_logs` VALUES (6, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-02-10 05:09:50');
INSERT INTO `login_logs` VALUES (7, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-02-10 08:14:50');
INSERT INTO `login_logs` VALUES (8, 3, '13666666666', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-02-10 13:27:36');
INSERT INTO `login_logs` VALUES (9, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-02-24 09:14:03');
INSERT INTO `login_logs` VALUES (10, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-03-06 10:00:10');
INSERT INTO `login_logs` VALUES (11, 4, '14344433333', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/145.0.0.0 Safari/537.36', 'SUCCESS', '2026-03-06 14:05:49');
INSERT INTO `login_logs` VALUES (12, 1, '13864424165', 'CODE', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'SUCCESS', '2026-04-30 02:29:56');
INSERT INTO `login_logs` VALUES (13, 5, '15634293322', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-12 12:21:59');
INSERT INTO `login_logs` VALUES (14, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'FAILED', '2026-05-12 12:57:12');
INSERT INTO `login_logs` VALUES (15, 5, '15634293322', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-12 12:57:33');
INSERT INTO `login_logs` VALUES (16, 5, '15634293322', 'PASSWORD', '2408:8417:d00:8bbe:88dc:5fff:fea6:efc6', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', 'SUCCESS', '2026-05-12 14:05:56');
INSERT INTO `login_logs` VALUES (17, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'FAILED', '2026-05-12 14:10:39');
INSERT INTO `login_logs` VALUES (18, 5, '15634293322', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-12 14:10:54');
INSERT INTO `login_logs` VALUES (19, 6, '15634293323', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-12 14:13:22');
INSERT INTO `login_logs` VALUES (20, 7, '13864424161', 'REGISTER', '2408:8418:e00:93cf:d03f:10ff:fe25:b2c6', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', 'SUCCESS', '2026-05-13 02:58:24');
INSERT INTO `login_logs` VALUES (21, 5, '15634293322', 'PASSWORD', '134.195.101.195', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-13 03:00:23');
INSERT INTO `login_logs` VALUES (22, 5, '15634293322', 'PASSWORD', '43.135.136.162', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-13 03:29:14');
INSERT INTO `login_logs` VALUES (23, 5, '15634293322', 'PASSWORD', '2602:feda:f30f:6099:f11e:2a9e:9ce4:324b', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36 Edg/148.0.0.0', 'SUCCESS', '2026-05-13 03:41:18');
INSERT INTO `login_logs` VALUES (24, 5, '15634293322', 'PASSWORD', '10.210.69.90', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-13 03:52:13');
INSERT INTO `login_logs` VALUES (25, 5, '15634293322', 'PASSWORD', '2408:8418:e00:93cf:d03f:10ff:fe25:b2c6', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-13 03:53:15');
INSERT INTO `login_logs` VALUES (26, 5, '15634293322', 'PASSWORD', '2408:8418:e00:93cf:d03f:10ff:fe25:b2c6', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-13 04:22:32');
INSERT INTO `login_logs` VALUES (27, 5, '15634293322', 'PASSWORD', '10.210.69.90', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36', 'SUCCESS', '2026-05-13 06:06:46');
INSERT INTO `login_logs` VALUES (28, 8, '15249717970', 'REGISTER', '240e:446:905:9707:1080:2f6f:2a0f:5336', 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.3.1 Safari/605.1.15', 'SUCCESS', '2026-05-13 07:14:02');
INSERT INTO `login_logs` VALUES (29, 5, '15634293322', 'PASSWORD', '112.224.157.96', 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/147.0.0.0 Mobile Safari/537.36', 'SUCCESS', '2026-05-14 03:30:41');
INSERT INTO `login_logs` VALUES (30, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'FAILED', '2026-06-11 13:15:22');
INSERT INTO `login_logs` VALUES (31, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-11 13:15:31');
INSERT INTO `login_logs` VALUES (32, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 02:37:16');
INSERT INTO `login_logs` VALUES (33, 9, '15636525645', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 04:11:38');
INSERT INTO `login_logs` VALUES (34, 9, '15636525645', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 04:16:02');
INSERT INTO `login_logs` VALUES (35, 9, '15636525645', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 05:00:58');
INSERT INTO `login_logs` VALUES (36, 9, '15636525645', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 05:02:25');
INSERT INTO `login_logs` VALUES (37, 9, '15636525645', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 05:20:41');
INSERT INTO `login_logs` VALUES (38, 9, '15636525645', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 05:21:13');
INSERT INTO `login_logs` VALUES (39, 10, '15844489569', 'REGISTER', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 05:22:06');
INSERT INTO `login_logs` VALUES (40, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 05:22:42');
INSERT INTO `login_logs` VALUES (41, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 09:06:23');
INSERT INTO `login_logs` VALUES (42, 1, '13864424165', 'PASSWORD', '0:0:0:0:0:0:0:1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/149.0.0.0 Safari/537.36', 'SUCCESS', '2026-06-13 13:28:16');

-- ----------------------------
-- Table structure for outbox
-- ----------------------------
DROP TABLE IF EXISTS `outbox`;
CREATE TABLE `outbox`  (
  `id` bigint UNSIGNED NOT NULL,
  `aggregate_type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `aggregate_id` bigint UNSIGNED NULL DEFAULT NULL,
  `type` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` json NOT NULL,
  `created_at` timestamp(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ix_outbox_agg`(`aggregate_type` ASC, `aggregate_id` ASC) USING BTREE,
  INDEX `ix_outbox_ct`(`created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of outbox
-- ----------------------------
INSERT INTO `outbox` VALUES (1, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 21:35:05.821');
INSERT INTO `outbox` VALUES (2, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 21:44:18.201');
INSERT INTO `outbox` VALUES (3, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 21:47:27.143');
INSERT INTO `outbox` VALUES (4, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 21:49:58.355');
INSERT INTO `outbox` VALUES (5, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 21:51:52.192');
INSERT INTO `outbox` VALUES (6, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:08:41.112');
INSERT INTO `outbox` VALUES (7, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:22:23.324');
INSERT INTO `outbox` VALUES (8, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:25:23.875');
INSERT INTO `outbox` VALUES (9, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:27:57.090');
INSERT INTO `outbox` VALUES (10, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:29:02.652');
INSERT INTO `outbox` VALUES (11, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:30:16.672');
INSERT INTO `outbox` VALUES (12, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:31:12.348');
INSERT INTO `outbox` VALUES (13, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:32:15.380');
INSERT INTO `outbox` VALUES (14, 'User', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:35:19.901');
INSERT INTO `outbox` VALUES (17, 'User111', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-17 22:42:49.748');
INSERT INTO `outbox` VALUES (31, 'following', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-22 17:33:19.735');
INSERT INTO `outbox` VALUES (32, 'following', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-22 17:38:01.745');
INSERT INTO `outbox` VALUES (33, 'following', 1, 'FollowCreated', '{\"toUserId\": 2, \"fromUserId\": 1}', '2026-01-22 17:46:57.613');
INSERT INTO `outbox` VALUES (1265665691776749080, 'following', NULL, 'FollowCanceled', '{\"id\": null, \"type\": \"FollowCanceled\", \"toUserId\": 1, \"fromUserId\": 5}', '2026-05-13 12:25:59.825');
INSERT INTO `outbox` VALUES (2531610154573032288, 'following', 7965232560775056297, 'FollowCreated', '{\"id\": 7965232560775056297, \"type\": \"FollowCreated\", \"toUserId\": 1, \"fromUserId\": 5}', '2026-05-13 12:26:02.424');
INSERT INTO `outbox` VALUES (2729812385558258622, 'following', 469630953033625590, 'FollowCreated', '{\"id\": 469630953033625590, \"type\": \"FollowCreated\", \"toUserId\": 1, \"fromUserId\": 5}', '2026-05-12 21:00:10.615');
INSERT INTO `outbox` VALUES (4068340916676159472, 'following', 1175089801092263742, 'FollowCreated', '{\"id\": 1175089801092263742, \"type\": \"FollowCreated\", \"toUserId\": 2, \"fromUserId\": 4}', '2026-03-06 22:10:49.553');
INSERT INTO `outbox` VALUES (4327142446591773909, 'following', NULL, 'FollowCanceled', '{\"id\": null, \"type\": \"FollowCanceled\", \"toUserId\": 1, \"fromUserId\": 3}', '2026-02-10 21:31:36.128');
INSERT INTO `outbox` VALUES (5158834241847807252, 'following', 4882417906507573388, 'FollowCreated', '{\"id\": 4882417906507573388, \"type\": \"FollowCreated\", \"toUserId\": 1, \"fromUserId\": 3}', '2026-02-10 21:32:05.014');
INSERT INTO `outbox` VALUES (5225341003169844174, 'following', 5947043361684682660, 'FollowCreated', '{\"id\": 5947043361684682660, \"type\": \"FollowCreated\", \"toUserId\": 1, \"fromUserId\": 3}', '2026-02-10 21:28:35.982');
INSERT INTO `outbox` VALUES (6408901291956282938, 'following', 906623186739537996, 'FollowCreated', '{\"id\": 906623186739537996, \"type\": \"FollowCreated\", \"toUserId\": 1, \"fromUserId\": 4}', '2026-03-06 22:10:35.810');
INSERT INTO `outbox` VALUES (7677340465015144059, 'following', 1730613668042333784, 'FollowCreated', '{\"id\": 1730613668042333784, \"type\": \"FollowCreated\", \"toUserId\": 3, \"fromUserId\": 4}', '2026-03-06 22:10:58.168');
INSERT INTO `outbox` VALUES (8457058338651177014, 'following', 2713408904467963929, 'FollowCreated', '{\"id\": 2713408904467963929, \"type\": \"FollowCreated\", \"toUserId\": 1, \"fromUserId\": 9}', '2026-06-13 13:20:51.098');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
  `phone` varchar(32) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `password_hash` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `nickname` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `avatar` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `bio` varchar(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `zg_id` varchar(64) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `gender` varchar(16) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `birthday` date NULL DEFAULT NULL,
  `school` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tags_json` json NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_users_phone`(`phone` ASC) USING BTREE,
  UNIQUE INDEX `uk_users_email`(`email` ASC) USING BTREE,
  UNIQUE INDEX `uk_users_zg_id`(`zg_id` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 11 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES (1, '13864424165', NULL, '$2a$12$wFY/DDwbBcWHs7jrvhPPHe7QGp1E2rJ/OjcnX1b76HsJ6XcNdmPcq', 'YF', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/avatars/1-1781185616396.jpg', NULL, NULL, NULL, NULL, NULL, '[]', '2026-01-18 08:26:51', '2026-06-11 21:46:56');
INSERT INTO `users` VALUES (2, '15634293321', NULL, '$2a$12$KZpl9QuWl2EyORcsnqI22.flK6eZdIscMRDBN1w.w.ABaHuktKqXO', '知光用户a20cc5ae', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-02-04 11:33:29', '2026-02-04 11:33:29');
INSERT INTO `users` VALUES (3, '13666666666', NULL, '$2a$12$ihEGWZ8Jnt2jYwgrTMtRRustj84HHmbYajY.myJTR0l2DohStrdGW', 'test1', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-02-10 13:27:36', '2026-02-10 21:27:52');
INSERT INTO `users` VALUES (4, '14344433333', NULL, '$2a$12$4CoCFCzrSUk7uGXVlErxru4aSdI3Ql3QgfN3oktmhXu3C0BnqsmaC', '菲菲', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-03-06 14:05:49', '2026-03-06 22:06:06');
INSERT INTO `users` VALUES (5, '15634293322', NULL, '$2a$12$oxfbMgAnqz5cCAiTHHe7GusjKs8xbbMmP5Vo2xWjYF.LVWZE1ZTZO', 'YF', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/avatars/5-1778646289400.png', NULL, NULL, 'MALE', NULL, NULL, '[]', '2026-05-12 12:21:59', '2026-05-13 14:08:29');
INSERT INTO `users` VALUES (6, '15634293323', NULL, '$2a$12$mCH2RIODOxBbVEZ8htIuIOE6UZbRLqOwEe4MZN7Dq/7dErTjZQzGG', '知光用户5df42ea9', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-05-12 14:13:22', '2026-05-12 14:13:22');
INSERT INTO `users` VALUES (7, '13864424161', NULL, '$2a$12$65FLEtjs2g0TfndNPXFihOxSrPf4mFWijxwvoP9Lj0E15RvyZdNuu', '知光用户6a7dac6e', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-05-13 02:58:24', '2026-05-13 02:58:24');
INSERT INTO `users` VALUES (8, '15249717970', NULL, '$2a$12$dUFw3Gwd6yE8cX5kgJwHKe0gV5sk80Xn.GDkKVKIikdq2oMkjo8QW', '温温', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-05-13 07:14:02', '2026-06-13 13:03:35');
INSERT INTO `users` VALUES (9, '15636525645', NULL, '$2a$12$j4kNDNT2U8rhS9is52FtnuCf3M4nmsak/5ruj5km2cKvitfvLcqEm', '予枫001', 'https://zhiguangapp-3.oss-cn-beijing.aliyuncs.com/avatars/9-1781324182629.jpg', NULL, NULL, NULL, NULL, NULL, '[]', '2026-06-13 04:11:37', '2026-06-13 13:03:00');
INSERT INTO `users` VALUES (10, '15844489569', NULL, '$2a$12$PrAONg1rm6G1RinrQmd5i.U6qADa9TP42zko7mYOVhpT198bGW8qW', '灵析用户2f11c9fd', 'https://static.zhiguang.cn/default-avatar.png', NULL, NULL, NULL, NULL, NULL, '[]', '2026-06-13 05:22:06', '2026-06-13 05:22:06');

SET FOREIGN_KEY_CHECKS = 1;
