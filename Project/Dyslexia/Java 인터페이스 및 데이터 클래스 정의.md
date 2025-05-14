
## 1. 메인 결과 클래스

### WordAnalysisResult.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WordAnalysisResult {
    
    @JsonProperty("originalSentence")
    private String originalSentence;
    
    @JsonProperty("analysis")
    private SentenceAnalysis analysis;
    
    @JsonProperty("words")
    private List<DifficultWord> words;
    
    @JsonProperty("learningPath")
    private LearningPath learningPath;
}
```

## 2. 문장 분석 클래스

### SentenceAnalysis.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class SentenceAnalysis {
    
    @JsonProperty("totalWords")
    private Integer totalWords;
    
    @JsonProperty("difficultWords")
    private Integer difficultWords;
    
    @JsonProperty("averageDifficulty")
    private String averageDifficulty;
}
```

## 3. 어려운 단어 클래스

### DifficultWord.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class DifficultWord {
    
    @JsonProperty("word")
    private String word;
    
    @JsonProperty("position")
    private WordPosition position;
    
    @JsonProperty("meaning")
    private WordMeaning meaning;
    
    @JsonProperty("difficulty")
    private WordDifficulty difficulty;
    
    @JsonProperty("phonetics")
    private PhoneticAnalysis phonetics;
    
    @JsonProperty("learning")
    private LearningInfo learning;
}
```

## 4. 단어 위치 클래스

### WordPosition.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WordPosition {
    
    @JsonProperty("startIndex")
    private Integer startIndex;
    
    @JsonProperty("endIndex")
    private Integer endIndex;
}
```

## 5. 단어 의미 클래스

### WordMeaning.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WordMeaning {
    
    @JsonProperty("definition")
    private String definition;
    
    @JsonProperty("simplifiedDefinition")
    private String simplifiedDefinition;
    
    @JsonProperty("examples")
    private List<String> examples;
}
```

## 6. 단어 난이도 클래스

### WordDifficulty.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WordDifficulty {
    
    @JsonProperty("level")
    private String level;
    
    @JsonProperty("reason")
    private String reason;
    
    @JsonProperty("gradeLevel")
    private Integer gradeLevel;
}
```

## 7. 음성학 분석 클래스

### PhoneticAnalysis.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PhoneticAnalysis {
    
    @JsonProperty("syllables")
    private List<Syllable> syllables;
    
    @JsonProperty("writingSteps")
    private List<WritingStep> writingSteps;
}
```

## 8. 음절 클래스

### Syllable.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Syllable {
    
    @JsonProperty("syllable")
    private String syllable;
    
    @JsonProperty("initial")
    private String initial;
    
    @JsonProperty("medial")
    private String medial;
    
    @JsonProperty("final")
    private String finalConsonant;
    
    @JsonProperty("pronunciation")
    private String pronunciation;
}
```

## 9. 쓰기 단계 클래스

### WritingStep.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class WritingStep {
    
    @JsonProperty("step")
    private Integer step;
    
    @JsonProperty("type")
    private String type;
    
    @JsonProperty("symbol")
    private String symbol;
    
    @JsonProperty("tips")
    private String tips;
}
```

## 10. 학습 정보 클래스

### LearningInfo.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LearningInfo {
    
    @JsonProperty("estimatedTime")
    private Integer estimatedTime;
    
    @JsonProperty("recommendedRepetitions")
    private Integer recommendedRepetitions;
    
    @JsonProperty("similarWords")
    private List<String> similarWords;
}
```

## 11. 학습 경로 클래스

### LearningPath.java

```java
package com.dyslexiaapp.model.wordanalysis;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class LearningPath {
    
    @JsonProperty("totalSteps")
    private Integer totalSteps;
    
    @JsonProperty("estimatedDuration")
    private Integer estimatedDuration;
    
    @JsonProperty("difficulty")
    private String difficulty;
    
    @JsonProperty("prerequisites")
    private List<String> prerequisites;
}
```

## 12. 서비스 인터페이스

### WordAnalysisService.java

```java
package com.dyslexiaapp.service;

import com.dyslexiaapp.model.wordanalysis.WordAnalysisResult;

public interface WordAnalysisService {
    
    /**
     * 문장을 분석하여 어려운 어휘를 추출하고 음소 분해를 수행합니다.
     * @param sentence 분석할 문장
     * @return 분석 결과
     */
    WordAnalysisResult analyzeSentence(String sentence);
    
    /**
     * 특정 단어의 음소 분해를 수행합니다.
     * @param word 분석할 단어
     * @return 음소 분해 결과
     */
    PhoneticAnalysis analyzeWordPhonetics(String word);
    
    /**
     * 분석 결과를 캐시에서 조회합니다.
     * @param sentence 문장
     * @return 캐시된 분석 결과 (없으면 null)
     */
    WordAnalysisResult getCachedAnalysis(String sentence);
}
```

### OpenAIService.java

```java
package com.dyslexiaapp.service;

public interface OpenAIService {
    
    /**
     * OpenAI API를 사용하여 문장을 분석합니다.
     * @param sentence 분석할 문장
     * @param prompt 사용할 프롬프트
     * @return OpenAI API 응답
     */
    String callOpenAI(String sentence, String prompt);
    
    /**
     * JSON 문자열을 WordAnalysisResult 객체로 파싱합니다.
     * @param jsonResponse OpenAI API의 JSON 응답
     * @return 파싱된 분석 결과
     */
    WordAnalysisResult parseResponse(String jsonResponse);
}
```

## 13. 요청/응답 DTO

### AnalysisRequest.java

```java
package com.dyslexiaapp.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AnalysisRequest {
    
    private String sentence;
    private Integer targetGradeLevel = 3;
    private Boolean includePhonetics = true;
}
```

### AnalysisResponse.java

```java
package com.dyslexiaapp.dto;

import com.dyslexiaapp.model.wordanalysis.WordAnalysisResult;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AnalysisResponse {
    
    private boolean success;
    private String message;
    private WordAnalysisResult data;
    private long processingTimeMs;
}
```
## 15. JSON 원본 예시
### OpenAI API 응답 JSON 샘플

```json
{
  "originalSentence": "사람은 감각을 쓰면 지식을 얻고, 안 쓰면 모르게 돼요.",
  "analysis": {
    "totalWords": 8,
    "difficultWords": 2,
    "averageDifficulty": "medium"
  },
  "words": [
    {
      "word": "감각",
      "position": {
        "startIndex": 3,
        "endIndex": 5
      },
      "meaning": {
        "definition": "몸으로 느끼고 알아차리는 능력",
        "simplifiedDefinition": "보고, 듣고, 만지면서 알아차리는 것",
        "examples": ["눈으로 보는 것도 감각이에요"]
      },
      "difficulty": {
        "level": "medium",
        "reason": "추상적 개념어",
        "gradeLevel": 4
      },
      "phonetics": {
        "syllables": [
          {
            "syllable": "감",
            "initial": "ㄱ",
            "medial": "ㅏ",
            "final": "ㅁ",
            "pronunciation": "/gam/"
          },
          {
            "syllable": "각",
            "initial": "ㄱ",
            "medial": "ㅏ",
            "final": "ㄱ",
            "pronunciation": "/gak/"
          }
        ],
        "writingSteps": [
          {
            "step": 1,
            "type": "consonant",
            "symbol": "ㄱ",
            "tips": "위에서 아래로, 왼쪽에서 오른쪽으로"
          },
          {
            "step": 2,
            "type": "vowel",
            "symbol": "ㅏ",
            "tips": "세로선 먼저, 가로선 나중에"
          },
          {
            "step": 3,
            "type": "final",
            "symbol": "ㅁ",
            "tips": "네모난 모양으로 정확하게"
          }
        ]
      },
      "learning": {
        "estimatedTime": 300,
        "recommendedRepetitions": 5,
        "similarWords": ["감정", "감사"]
      }
    }
  ],
  "learningPath": {
    "totalSteps": 15,
    "estimatedDuration": 900,
    "difficulty": "medium",
    "prerequisites": ["기본 자음/모음 읽기"]
  }
}
```

## 16. Jackson을 통한 JSON 파싱
### JSON 파싱 유틸리티 클래스

```java
package com.dyslexiaapp.util;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.dyslexiaapp.model.wordanalysis.WordAnalysisResult;
import com.dyslexiaapp.exception.JsonParsingException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

@Component
@Slf4j
public class JsonParsingUtil {
    
    private final ObjectMapper objectMapper;
    
    public JsonParsingUtil() {
        this.objectMapper = new ObjectMapper();
        // 알 수 없는 속성 무시 (OpenAI가 추가 필드를 보낼 경우 대비)
        this.objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
        // null 값 무시
        this.objectMapper.configure(DeserializationFeature.FAIL_ON_NULL_FOR_PRIMITIVES, false);
    }
    
    /**
     * JSON 문자열을 WordAnalysisResult 객체로 파싱
     * @param jsonString OpenAI API에서 반환된 JSON 문자열
     * @return 파싱된 WordAnalysisResult 객체
     * @throws JsonParsingException 파싱 실패 시
     */
    public WordAnalysisResult parseWordAnalysisResult(String jsonString) {
        try {
            log.debug("JSON 파싱 시작: {}", jsonString);
            WordAnalysisResult result = objectMapper.readValue(jsonString, WordAnalysisResult.class);
            log.debug("JSON 파싱 완료. 발견된 어려운 단어 수: {}", 
                result.getWords() != null ? result.getWords().size() : 0);
            return result;
        } catch (JsonProcessingException e) {
            log.error("JSON 파싱 실패. JSON: {}", jsonString, e);
            throw new JsonParsingException("WordAnalysisResult 파싱 실패: " + e.getMessage(), e);
        }
    }
    
    /**
     * WordAnalysisResult 객체를 JSON 문자열로 변환
     * @param result 변환할 객체
     * @return JSON 문자열
     * @throws JsonParsingException 변환 실패 시
     */
    public String toJson(WordAnalysisResult result) {
        try {
            return objectMapper.writeValueAsString(result);
        } catch (JsonProcessingException e) {
            log.error("JSON 변환 실패", e);
            throw new JsonParsingException("JSON 변환 실패: " + e.getMessage(), e);
        }
    }
    
    /**
     * JSON 유효성 검증
     * @param jsonString 검증할 JSON 문자열
     * @return 유효한 JSON이면 true, 아니면 false
     */
    public boolean isValidJson(String jsonString) {
        try {
            objectMapper.readTree(jsonString);
            return true;
        } catch (JsonProcessingException e) {
            log.warn("유효하지 않은 JSON: {}", jsonString);
            return false;
        }
    }
}
```

### 서비스 구현 예시

```java
package com.dyslexiaapp.service.impl;

import com.dyslexiaapp.service.OpenAIService;
import com.dyslexiaapp.service.WordAnalysisService;
import com.dyslexiaapp.model.wordanalysis.WordAnalysisResult;
import com.dyslexiaapp.util.JsonParsingUtil;
import com.dyslexiaapp.exception.JsonParsingException;
import com.dyslexiaapp.exception.OpenAIServiceException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Service
@Slf4j
@RequiredArgsConstructor
public class WordAnalysisServiceImpl implements WordAnalysisService {
    
    private final OpenAIService openAIService;
    private final JsonParsingUtil jsonParsingUtil;
    
    @Override
    public WordAnalysisResult analyzeSentence(String sentence) {
        try {
            log.info("문장 분석 시작: {}", sentence);
            
            // 1. 프롬프트 생성
            String prompt = buildAnalysisPrompt(sentence);
            
            // 2. OpenAI API 호출
            String jsonResponse = openAIService.callOpenAI(sentence, prompt);
            log.debug("OpenAI 응답 받음: {}", jsonResponse);
            
            // 3. JSON 유효성 검증
            if (!jsonParsingUtil.isValidJson(jsonResponse)) {
                throw new JsonParsingException("유효하지 않은 JSON 응답: " + jsonResponse);
            }
            
            // 4. JSON 파싱
            WordAnalysisResult result = jsonParsingUtil.parseWordAnalysisResult(jsonResponse);
            
            log.info("문장 분석 완료. 어려운 단어 {}개 발견", 
                result.getWords() != null ? result.getWords().size() : 0);
            
            return result;
            
        } catch (OpenAIServiceException e) {
            log.error("OpenAI 서비스 오류", e);
            throw e;
        } catch (JsonParsingException e) {
            log.error("JSON 파싱 오류", e);
            throw e;
        } catch (Exception e) {
            log.error("문장 분석 중 예상치 못한 오류", e);
            throw new RuntimeException("문장 분석 실패", e);
        }
    }
    
    private String buildAnalysisPrompt(String sentence) {
        return String.format("""
            다음 문장에서 9-13세 난독증 학생이 어려워할 수 있는 어휘를 추출하고 분석해주세요:
            
            문장: "%s"
            
            JSON 형식으로 응답해주세요:
            """, sentence);
    }
}
```

### 단위 테스트 예시

```java
package com.dyslexiaapp.util;

import com.dyslexiaapp.model.wordanalysis.WordAnalysisResult;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.springframework.boot.test.context.SpringBootTest;

import static org.assertj.core.api.Assertions.*;

@SpringBootTest
class JsonParsingUtilTest {
    
    private JsonParsingUtil jsonParsingUtil;
    
    @BeforeEach
    void setUp() {
        jsonParsingUtil = new JsonParsingUtil();
    }
    
    @Test
    void 유효한_JSON_파싱_테스트() {
        // Given
        String validJson = """
            {
              "originalSentence": "사람은 감각을 쓰면 지식을 얻고, 안 쓰면 모르게 돼요.",
              "analysis": {
                "totalWords": 8,
                "difficultWords": 2,
                "averageDifficulty": "medium"
              },
              "words": [
                {
                  "word": "감각",
                  "position": {
                    "startIndex": 3,
                    "endIndex": 5
                  },
                  "meaning": {
                    "definition": "몸으로 느끼고 알아차리는 능력",
                    "simplifiedDefinition": "보고, 듣고, 만지면서 알아차리는 것",
                    "examples": ["눈으로 보는 것도 감각이에요"]
                  }
                }
              ]
            }
            """;
        
        // When
        WordAnalysisResult result = jsonParsingUtil.parseWordAnalysisResult(validJson);
        
        // Then
        assertThat(result).isNotNull();
        assertThat(result.getOriginalSentence()).isEqualTo("사람은 감각을 쓰면 지식을 얻고, 안 쓰면 모르게 돼요.");
        assertThat(result.getAnalysis().getTotalWords()).isEqualTo(8);
        assertThat(result.getWords()).hasSize(1);
        assertThat(result.getWords().get(0).getWord()).isEqualTo("감각");
    }
    
    @Test
    void 유효하지_않은_JSON_파싱_실패_테스트() {
        // Given
        String invalidJson = "{ invalid json }";
        
        // When & Then
        assertThatThrownBy(() -> jsonParsingUtil.parseWordAnalysisResult(invalidJson))
            .isInstanceOf(JsonParsingException.class);
    }
}
```

## 17. 예외 처리 인터페이스

### CustomException.java

```java
package com.dyslexiaapp.exception;

public class WordAnalysisException extends RuntimeException {
    public WordAnalysisException(String message);
    public WordAnalysisException(String message, Throwable cause);
}

public class OpenAIServiceException extends RuntimeException {
    public OpenAIServiceException(String message);
    public OpenAIServiceException(String message, Throwable cause);
}

public class JsonParsingException extends RuntimeException {
    public JsonParsingException(String message);
    public JsonParsingException(String message, Throwable cause);
}
```