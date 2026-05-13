package com.tongji;

import com.tongji.Benchmark.RedisMemoryBenchmark;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
//import javax.annotation.Resource;

@SpringBootTest
public class RedisMemoryTest {

    @Autowired
    private RedisMemoryBenchmark benchmarkService;

    @Test
    public void runMemoryTest() {
        // 直接调用我们写好的基准测试方法
        benchmarkService.runBenchmark();
    }
}