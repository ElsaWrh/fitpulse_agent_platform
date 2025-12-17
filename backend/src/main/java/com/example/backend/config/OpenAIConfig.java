package com.example.backend.config;

import com.theokanning.openai.service.OpenAiService;
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.time.Duration;

/**
 * OpenAI 配置类
 */
@Configuration
@ConfigurationProperties(prefix = "openai")
@Data
public class OpenAIConfig {

    private String apiKey;
    private String baseUrl;
    private String model;
    private Integer maxTokens;
    private Double temperature;

    @Bean
    public OpenAiService openAiService() {
        return new OpenAiService(apiKey, Duration.ofSeconds(60));
    }
}
