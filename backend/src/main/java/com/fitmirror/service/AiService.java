package com.fitmirror.service;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import com.fitmirror.dto.AiCommentRequest;
import com.fitmirror.dto.AiCommentResponse;
import lombok.extern.slf4j.Slf4j;
import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.TimeUnit;

@Slf4j
@Service
public class AiService {

    @Value("${ai.provider}")
    private String provider;

    @Value("${ai.deepseek.api-key}")
    private String deepseekApiKey;

    @Value("${ai.deepseek.base-url}")
    private String deepseekBaseUrl;

    @Value("${ai.openai.api-key}")
    private String openaiApiKey;

    @Value("${ai.openai.base-url}")
    private String openaiBaseUrl;

    private final OkHttpClient httpClient = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(60, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();

    public AiCommentResponse getComment(AiCommentRequest request) {
        String prompt = buildPrompt(request);
        String response = callAiApi(prompt);
        return parseResponse(response);
    }

    private String buildPrompt(AiCommentRequest request) {
        StringBuilder prompt = new StringBuilder();
        prompt.append("你是一位专业的时尚穿搭顾问。请对以下服装进行专业点评，并以JSON格式返回结果。\n\n");
        prompt.append("服装信息：\n");
        prompt.append("- 类型：").append(getTypeName(request.getClothType())).append("\n");
        prompt.append("- 颜色：").append(request.getClothColor()).append("\n");
        if (request.getOccasion() != null) {
            prompt.append("- 目标场合：").append(request.getOccasion()).append("\n");
        }
        if (request.getUserStyle() != null) {
            prompt.append("- 用户风格偏好：").append(request.getUserStyle()).append("\n");
        }

        prompt.append("\n请从以下维度进行点评（JSON格式）：\n");
        prompt.append("{\n");
        prompt.append("  \"score\": 0-100的综合评分,\n");
        prompt.append("  \"summary\": \"一句话总结\",\n");
        prompt.append("  \"color\": {\n");
        prompt.append("    \"score\": 0-100的颜色匹配分,\n");
        prompt.append("    \"comment\": \"颜色点评\",\n");
        prompt.append("    \"suitableSkinTones\": [\"适合的肤色列表\"]\n");
        prompt.append("  },\n");
        prompt.append("  \"style\": {\n");
        prompt.append("    \"score\": 0-100的风格契合分,\n");
        prompt.append("    \"comment\": \"风格点评\",\n");
        prompt.append("    \"tags\": [\"风格标签\"]\n");
        prompt.append("  },\n");
        prompt.append("  \"occasions\": [\"适合的场合列表\"],\n");
        prompt.append("  \"suggestions\": [\"搭配建议\"],\n");
        prompt.append("  \"conclusion\": \"购买建议\"\n");
        prompt.append("}\n\n");
        prompt.append("请只返回JSON，不要有其他内容。");

        return prompt.toString();
    }

    private String callAiApi(String prompt) {
        try {
            switch (provider.toLowerCase()) {
                case "deepseek":
                    return callDeepSeekApi(prompt);
                case "openai":
                    return callOpenAiApi(prompt);
                default:
                    return callDeepSeekApi(prompt);
            }
        } catch (Exception e) {
            log.error("AI API调用失败", e);
            return getDefaultResponse();
        }
    }

    private String callDeepSeekApi(String prompt) throws IOException {
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", "deepseek-chat");
        requestBody.put("messages", new JSONArray()
                .fluentAdd(new JSONObject()
                        .fluentPut("role", "user")
                        .fluentPut("content", prompt)));
        requestBody.put("temperature", 0.7);
        requestBody.put("max_tokens", 1000);

        Request request = new Request.Builder()
                .url(deepseekBaseUrl + "/chat/completions")
                .addHeader("Authorization", "Bearer " + deepseekApiKey)
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(requestBody.toJSONString(), MediaType.parse("application/json")))
                .build();

        try (Response response = httpClient.newCall(request).execute()) {
            if (response.isSuccessful() && response.body() != null) {
                String responseBody = response.body().string();
                JSONObject json = JSON.parseObject(responseBody);
                return json.getJSONArray("choices")
                        .getJSONObject(0)
                        .getJSONObject("message")
                        .getString("content");
            }
        }
        return getDefaultResponse();
    }

    private String callOpenAiApi(String prompt) throws IOException {
        JSONObject requestBody = new JSONObject();
        requestBody.put("model", "gpt-3.5-turbo");
        requestBody.put("messages", new JSONArray()
                .fluentAdd(new JSONObject()
                        .fluentPut("role", "user")
                        .fluentPut("content", prompt)));
        requestBody.put("temperature", 0.7);
        requestBody.put("max_tokens", 1000);

        Request request = new Request.Builder()
                .url(openaiBaseUrl + "/chat/completions")
                .addHeader("Authorization", "Bearer " + openaiApiKey)
                .addHeader("Content-Type", "application/json")
                .post(RequestBody.create(requestBody.toJSONString(), MediaType.parse("application/json")))
                .build();

        try (Response response = httpClient.newCall(request).execute()) {
            if (response.isSuccessful() && response.body() != null) {
                String responseBody = response.body().string();
                JSONObject json = JSON.parseObject(responseBody);
                return json.getJSONArray("choices")
                        .getJSONObject(0)
                        .getJSONObject("message")
                        .getString("content");
            }
        }
        return getDefaultResponse();
    }

    private AiCommentResponse parseResponse(String response) {
        try {
            // 提取JSON部分
            String jsonStr = response;
            if (response.contains("```json")) {
                jsonStr = response.substring(response.indexOf("{"), response.lastIndexOf("}") + 1);
            } else if (response.contains("{")) {
                jsonStr = response.substring(response.indexOf("{"), response.lastIndexOf("}") + 1);
            }

            JSONObject json = JSON.parseObject(jsonStr);

            return AiCommentResponse.builder()
                    .score(json.getIntValue("score"))
                    .summary(json.getString("summary"))
                    .color(parseColorAnalysis(json.getJSONObject("color")))
                    .style(parseStyleAnalysis(json.getJSONObject("style")))
                    .occasions(json.getJSONArray("occasions").toJavaList(String.class))
                    .suggestions(json.getJSONArray("suggestions").toJavaList(String.class))
                    .conclusion(json.getString("conclusion"))
                    .build();
        } catch (Exception e) {
            log.error("解析AI响应失败", e);
            return getDefaultCommentResponse();
        }
    }

    private AiCommentResponse.ColorAnalysis parseColorAnalysis(JSONObject json) {
        if (json == null) return AiCommentResponse.ColorAnalysis.builder().score(80).comment("颜色搭配和谐").build();
        return AiCommentResponse.ColorAnalysis.builder()
                .score(json.getIntValue("score"))
                .comment(json.getString("comment"))
                .suitableSkinTones(json.getJSONArray("suitableSkinTones") != null
                        ? json.getJSONArray("suitableSkinTones").toJavaList(String.class)
                        : List.of("大多数肤色"))
                .build();
    }

    private AiCommentResponse.StyleAnalysis parseStyleAnalysis(JSONObject json) {
        if (json == null) return AiCommentResponse.StyleAnalysis.builder().score(80).comment("风格百搭").build();
        return AiCommentResponse.StyleAnalysis.builder()
                .score(json.getIntValue("score"))
                .comment(json.getString("comment"))
                .tags(json.getJSONArray("tags") != null
                        ? json.getJSONArray("tags").toJavaList(String.class)
                        : List.of("简约"))
                .build();
    }

    private String getDefaultResponse() {
        return "{\"score\":85,\"summary\":\"这件服装整体风格不错，适合日常穿着\",\"color\":{\"score\":80,\"comment\":\"颜色百搭，适合大多数肤色\",\"suitableSkinTones\":[\"暖黄皮\",\"冷白皮\"]},\"style\":{\"score\":85,\"comment\":\"简约大方，易于搭配\",\"tags\":[\"简约\",\"休闲\",\"百搭\"]},\"occasions\":[\"日常\",\"通勤\",\"约会\"],\"suggestions\":[\"可搭配浅色下装\",\"适合配简约首饰\"],\"conclusion\":\"推荐购买，百搭实用\"}";
    }

    private AiCommentResponse getDefaultCommentResponse() {
        return AiCommentResponse.builder()
                .score(85)
                .summary("这件服装整体风格不错，适合日常穿着")
                .color(AiCommentResponse.ColorAnalysis.builder()
                        .score(80)
                        .comment("颜色百搭，适合大多数肤色")
                        .suitableSkinTones(List.of("暖黄皮", "冷白皮"))
                        .build())
                .style(AiCommentResponse.StyleAnalysis.builder()
                        .score(85)
                        .comment("简约大方，易于搭配")
                        .tags(List.of("简约", "休闲", "百搭"))
                        .build())
                .occasions(List.of("日常", "通勤", "约会"))
                .suggestions(List.of("可搭配浅色下装", "适合配简约首饰"))
                .conclusion("推荐购买，百搭实用")
                .build();
    }

    private String getTypeName(String type) {
        if (type == null) return "服装";
        switch (type.toLowerCase()) {
            case "top": return "上衣";
            case "pants": return "裤子";
            case "skirt": return "裙子";
            case "dress": return "连衣裙";
            case "jacket": return "外套";
            case "shoes": return "鞋子";
            case "bag": return "包包";
            case "accessory": return "配饰";
            default: return type;
        }
    }
}
