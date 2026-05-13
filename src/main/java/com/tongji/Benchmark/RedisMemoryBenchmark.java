package com.tongji.test;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.RedisCallback;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;
//import javax.annotation.Resource;
import java.nio.ByteBuffer;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;

@Service
public class RedisMemoryBenchmark {

    @Autowired
    private StringRedisTemplate redis;

    private static final int USER_COUNT = 100000; // 模拟 10 万用户

    public void runBenchmark() {
        System.out.println("🚀 开始执行 Redis 内存开销对比基准测试 (Spring Boot 环境)...");
        System.out.println("模拟用户量: " + USER_COUNT + "\n");

        // ==========================================
        // 测试一：传统 Hash 结构
        // ==========================================
        flushDb();
        long startMemoryHash = getUsedMemory();

        for (int i = 0; i < USER_COUNT; i++) {
            Map<String, String> hash = new HashMap<>();
            hash.put("followCount", "100");
            hash.put("fanCount", "50");
            hash.put("workCount", "20");
            hash.put("likeCount", "999");
            hash.put("favCount", "12");

            // Hash 结构可以直接用 StringRedisTemplate 的高层 API
            redis.opsForHash().putAll("test:ucnt:hash:" + i, hash);
        }

        long endMemoryHash = getUsedMemory();
        long hashMemoryUsed = endMemoryHash - startMemoryHash;
        System.out.printf("🛑 传统 Hash 结构耗费内存: %.2f MB\n", hashMemoryUsed / (1024.0 * 1024.0));

        // ==========================================
        // 测试二：定制化二进制 Byte 结构 (核心魔法)
        // ==========================================
        flushDb();
        long startMemoryBin = getUsedMemory();

        for (int i = 0; i < USER_COUNT; i++) {
            // 5个计数值，每个 4 字节 int，总共严格分配 20 字节连续空间
            ByteBuffer buffer = ByteBuffer.allocate(20);
            buffer.putInt(100); // offset 0-3
            buffer.putInt(50);  // offset 4-7
            buffer.putInt(20);  // offset 8-11
            buffer.putInt(999); // offset 12-15
            buffer.putInt(12);  // offset 16-19

            final byte[] rawKey = ("test:ucnt:bin:" + i).getBytes(StandardCharsets.UTF_8);
            final byte[] rawValue = buffer.array();

            // 【面试加分项】绕过 StringRedisTemplate 的 UTF-8 序列化，直接操作底层连接存入纯二进制！
            redis.execute((RedisCallback<Void>) connection -> {
                connection.stringCommands().set(rawKey, rawValue);
                return null;
            });
        }

        long endMemoryBin = getUsedMemory();
        long binMemoryUsed = endMemoryBin - startMemoryBin;
        System.out.printf("✅ 定制 Binary 结构耗费内存: %.2f MB\n", binMemoryUsed / (1024.0 * 1024.0));

        // ==========================================
        // 结论计算
        // ==========================================
        double saveRatio = (double) (hashMemoryUsed - binMemoryUsed) / hashMemoryUsed * 100;
        System.out.println("\n🎉 测试完成！");
        System.out.printf("🔥 内存节省比例高达: %.2f%%\n", saveRatio);
    }

    /**
     * 获取 Redis 当前使用的内存量 (字节)
     */
    private long getUsedMemory() {
        // Spring Data Redis 提供了优雅的 serverCommands() 来获取 INFO
        return redis.execute((RedisCallback<Long>) connection -> {
            Properties info = connection.serverCommands().info("memory");
            if (info != null && info.getProperty("used_memory") != null) {
                return Long.parseLong(info.getProperty("used_memory"));
            }
            return 0L;
        });
    }

    /**
     * 清空当前 DB
     */
    private void flushDb() {
        redis.execute((RedisCallback<Void>) connection -> {
            connection.serverCommands().flushDb();
            return null;
        });
    }
}