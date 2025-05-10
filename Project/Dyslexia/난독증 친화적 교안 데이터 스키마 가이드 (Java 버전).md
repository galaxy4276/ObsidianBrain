
이 문서는 난독증이 있는 학생들을 위한 교육 자료를 구조화하기 위한 Java 기반 데이터 스키마를 정의합니다. 노션 스타일의 블록 기반 구조를 차용하여 설계되었습니다.

## 패키지 구조

## 기본 열거형(Enum) 정의

```java
package com.dyslexiaapp.model.enums;

/**
 * 교안 컨텐츠의 블록 유형을 정의하는 열거형
 */
public enum BlockType {
    HEADING_1,
    HEADING_2,
    HEADING_3,
    PARAGRAPH,
    BULLETED_LIST,
    NUMBERED_LIST,
    CALLOUT,
    DIVIDER,
    IMAGE,
    VIDEO,
    AUDIO,
    TABLE,
    CODE,
    TOGGLE,
    
    // 난독증 특화 블록 유형
    CONCEPT_VISUALIZATION,
    TERM_DEFINITION,
    SIMPLIFIED_TEXT,
    STEP_BY_STEP
}
```

## 기본 블록 추상화

모든 컨텐츠 요소의 공통 구조를 정의합니다.

java

```java
package com.dyslexiaapp.model.block.base;

import com.dyslexiaapp.model.enums.BlockType;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 모든 콘텐츠 블록의 기본 추상 클래스
 */
public abstract class Block {
    private String id;                   // 블록 고유 식별자
    private BlockType type;              // 블록 유형
    private LocalDateTime createdAt;     // 생성 시간
    private LocalDateTime updatedAt;     // 수정 시간
    private boolean hasChildren;         // 하위 블록 포함 여부
    private List<Block> children;        // 하위 블록 목록 (있는 경우)
    
    // Getter/Setter 메서드
    // ...
}
```

## 텍스트 관련 클래스

java

```java
package com.dyslexiaapp.model.block.text;

/**
 * 텍스트 서식 및 주석을 위한 클래스
 */
public class RichText {
    private String plainText;
    private TextAnnotation annotations;
    private String href;        // 링크 URL (있는 경우)
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 텍스트 서식 설정을 위한 클래스
 */
public class TextAnnotation {
    private boolean bold;
    private boolean italic;
    private boolean underline;
    private String color;
    private boolean highlight;
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 난독증 친화적 텍스트 설정을 위한 클래스
 */
public class DyslexiaTextSettings {
    private String fontFamily;     // OpenDyslexic 등 특수 글꼴
    private Integer fontSize;      // 확대된 글꼴 크기
    private Float lineSpacing;     // 줄 간격 (1.5, 2.0 등)
    private Float letterSpacing;   // 글자 간격
    private Float wordSpacing;     // 단어 간격
    private String alignment;      // 텍스트 정렬
    private String textColor;      // 텍스트 색상
    private String backgroundColor; // 배경색
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 텍스트 기반 블록의 기본 추상 클래스
 */
public abstract class TextBlock extends Block {
    private List<RichText> content;
    private DyslexiaTextSettings dyslexiaSettings;
    
    // Getter/Setter 메서드
    // ...
}
```

## 텍스트 블록 구현 클래스

java

```java
package com.dyslexiaapp.model.block.text;

import com.dyslexiaapp.model.enums.BlockType;

/**
 * 제목 블록 클래스
 */
public class HeadingBlock extends TextBlock {
    private boolean isKeyConcept;  // 핵심 개념 여부
    
    public HeadingBlock() {
        // BlockType은 생성자에서 설정하거나 별도 메서드로 처리
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 문단 블록 클래스
 */
public class ParagraphBlock extends TextBlock {
    private Integer complexityLevel;  // 텍스트 복잡성 수준 (1-5)
    
    public ParagraphBlock() {
        setType(BlockType.PARAGRAPH);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 글머리 기호 목록 블록 클래스
 */
public class BulletedListBlock extends TextBlock {
    
    public BulletedListBlock() {
        setType(BlockType.BULLETED_LIST);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 번호 매기기 목록 블록 클래스
 */
public class NumberedListBlock extends TextBlock {
    private int number;  // 목록 번호
    
    public NumberedListBlock() {
        setType(BlockType.NUMBERED_LIST);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 토글(접기/펼치기) 블록 클래스
 */
public class ToggleBlock extends TextBlock {
    private boolean isOpen;  // 기본 표시 상태
    
    public ToggleBlock() {
        setType(BlockType.TOGGLE);
    }
    
    // Getter/Setter 메서드
    // ...
}
```

## 미디어 블록 클래스

java

```java
package com.dyslexiaapp.model.block.media;

import com.dyslexiaapp.model.block.base.Block;
import com.dyslexiaapp.model.enums.BlockType;

/**
 * 구분선 블록 클래스
 */
public class DividerBlock extends Block {
    
    public DividerBlock() {
        setType(BlockType.DIVIDER);
    }
}

/**
 * 이미지 블록 클래스
 */
public class ImageBlock extends Block {
    private String url;
    private String caption;
    private String altText;  // 접근성을 위한 대체 텍스트
    private Dimensions dimensions;
    
    public ImageBlock() {
        setType(BlockType.IMAGE);
    }
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 이미지 크기 정보를 위한 내부 클래스
     */
    public static class Dimensions {
        private int width;
        private int height;
        
        // Getter/Setter 메서드
        // ...
    }
}

/**
 * 표 블록 클래스
 */
public class TableBlock extends Block {
    private boolean hasHeader;
    private int rows;
    private int columns;
    private List<List<TableCell>> cells;  // 2차원 배열로 셀 데이터 저장
    
    public TableBlock() {
        setType(BlockType.TABLE);
    }
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 표 셀 데이터를 위한 내부 클래스
     */
    public static class TableCell {
        private List<RichText> content;
        private boolean isHeader;
        
        // Getter/Setter 메서드
        // ...
    }
}
```

## 난독증 친화적 특수 블록

java

```java
package com.dyslexiaapp.model.block.specialized;

import com.dyslexiaapp.model.block.base.Block;
import com.dyslexiaapp.model.enums.BlockType;
import com.dyslexiaapp.model.enums.VisualizationType;
import java.util.List;

/**
 * 개념 시각화 블록 클래스
 */
public class ConceptVisualizationBlock extends Block {
    private String conceptName;           // 시각화할 개념명
    private VisualizationType visualizationType;
    private String imageUrl;
    private String description;           // 시각 자료 설명
    private String relatedTextId;         // 연관된 텍스트 블록 ID
    
    public ConceptVisualizationBlock() {
        setType(BlockType.CONCEPT_VISUALIZATION);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 시각화 유형 열거형
 */
package com.dyslexiaapp.model.enums;

public enum VisualizationType {
    DIAGRAM,
    INFOGRAPHIC,
    FLOWCHART,
    COMPARISON
}

/**
 * 용어 정의 블록 클래스
 */
public class TermDefinitionBlock extends Block {
    private String term;                  // 원본 용어
    private String simplifiedDefinition;  // 단순화된 정의
    private List<String> examples;        // 예시
    private String visualHintUrl;         // 시각적 힌트 이미지
    
    public TermDefinitionBlock() {
        setType(BlockType.TERM_DEFINITION);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 단순화된 텍스트 블록 클래스
 */
public class SimplifiedTextBlock extends Block {
    private String originalText;         // 원본 텍스트
    private String simplifiedText;       // 단순화된 텍스트
    private int complexityReduction;     // 복잡성 감소 수준 (1-5)
    
    public SimplifiedTextBlock() {
        setType(BlockType.SIMPLIFIED_TEXT);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 단계별 지시 블록 클래스
 */
public class StepByStepBlock extends Block {
    private String title;
    private List<Step> steps;
    
    public StepByStepBlock() {
        setType(BlockType.STEP_BY_STEP);
    }
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 단계 정보를 위한 내부 클래스
     */
    public static class Step {
        private int stepNumber;
        private String instruction;
        private String imageUrl;
        private boolean isCurrent;      // 현재 진행 중인 단계 표시
        
        // Getter/Setter 메서드
        // ...
    }
}
```

## 페이지 구조

java

```java
package com.dyslexiaapp.model.page;

import com.dyslexiaapp.model.block.base.Block;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 전체 페이지 구조를 표현하는 클래스
 */
public class Page {
    private String id;
    private String title;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private PageMetadata metadata;
    private GlobalDyslexiaSettings globalDyslexiaSettings;
    private List<Block> blocks;          // 페이지 콘텐츠 블록
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 페이지 메타데이터를 위한 내부 클래스
     */
    public static class PageMetadata {
        private String originalPdf;       // 원본 PDF 소스
        private String subject;           // 과목
        private String gradeLevel;        // 학년
        private Integer readingLevel;     // 읽기 난이도 (1-10)
        private String author;            // 작성자/변환자
        
        // Getter/Setter 메서드
        // ...
    }
    
    /**
     * 전역 난독증 설정을 위한 내부 클래스
     */
    public static class GlobalDyslexiaSettings {
        private String defaultFont;       // 기본 폰트
        private int defaultFontSize;      // 기본 폰트 크기
        private float defaultLineSpacing; // 기본 줄 간격
        private ColorScheme colorScheme;  // 색상 테마
        private boolean highlightCurrentLine; // 현재 줄 강조 표시
        
        // Getter/Setter 메서드
        // ...
    }
    
    /**
     * 색상 테마 열거형
     */
    public enum ColorScheme {
        LIGHT,
        DARK,
        SEPIA,
        CUSTOM
    }
}
```

## 사용 예시 (JSON 형식)

아래는 이 스키마를 사용한 JSON 형식의 페이지 예시입니다:

json

```json
{
  "id": "page_123456",
  "title": "생태계와 환경",
  "createdAt": "2025-05-10T12:00:00Z",
  "updatedAt": "2025-05-11T09:30:00Z",
  "metadata": {
    "originalPdf": "3학년_과학_2단원.pdf",
    "subject": "과학",
    "gradeLevel": "3",
    "readingLevel": 3,
    "author": "최은기"
  },
  "globalDyslexiaSettings": {
    "defaultFont": "OpenDyslexic",
    "defaultFontSize": 16,
    "defaultLineSpacing": 1.5,
    "colorScheme": "LIGHT",
    "highlightCurrentLine": true
  },
  "blocks": [
    {
      "id": "heading_001",
      "type": "HEADING_1",
      "createdAt": "2025-05-10T12:05:00Z",
      "updatedAt": "2025-05-10T12:05:00Z",
      "hasChildren": false,
      "content": [
        {
          "plainText": "생태계란 무엇일까요?",
          "annotations": {
            "bold": true,
            "color": "#2D7FF9"
          }
        }
      ],
      "isKeyConcept": true,
      "dyslexiaSettings": {
        "fontSize": 24,
        "lineSpacing": 1.8
      }
    },
    
    {
      "id": "concept_viz_001",
      "type": "CONCEPT_VISUALIZATION",
      "createdAt": "2025-05-10T12:10:00Z",
      "updatedAt": "2025-05-10T12:10:00Z",
      "hasChildren": false,
      "conceptName": "생태계",
      "visualizationType": "DIAGRAM",
      "imageUrl": "https://example.com/images/ecosystem.png",
      "description": "생태계는 생물과 환경이 서로 영향을 주고받는 관계입니다.",
      "relatedTextId": "paragraph_001"
    }
  ]
}
```

## 구현 시 고려사항

1. **직렬화/역직렬화**: Jackson 또는 Gson 라이브러리를 사용하여 Java 객체와 JSON 간 변환
2. **유효성 검증**: Bean Validation API(JSR-380)를 활용한 데이터 유효성 검증
3. **확장성**: 새로운 블록 유형 추가 시 Block 추상 클래스 상속 및 BlockType enum 확장
4. **저장소**: MongoDB 또는 PostgreSQL(JSONB 타입)을 사용한 문서 저장 고려
5. **버전 관리**: 교안 수정 이력 관리를 위한 버전 관리 메커니즘 구현 검토

이 스키마는 난독증이 있는 학생들을 위한 교육 자료 변환 및 표시를 위한 기본 구조를 제공합니다. 실제 구현 시에는 요구사항에 따라 수정 및 확장이 필요할 수 있습니다.

재시도

은

이 내용의 가이드를 마크다운으로 작업해줘.

편집

분석하고 마크다운 형식으로 문서 재구성 계획

5초

요청을 명확하게 이해해보겠습니다. 사용자는 내가 작성한 "난독증 친화적 교안 데이터 스키마 가이드 (Java 버전)"를 마크다운 형식으로 변환해달라는 것입니다. 현재 내 답변은 이미 마크다운 형식으로 작성되어 있지만, 코드 블록과 구조를 좀 더 마크다운에 최적화된 형태로 정리하라는 의미로 이해됩니다.

마크다운 형식으로 문서를 작성할 때 다음과 같은 특징을 고려해야 합니다:

1. 제목 계층 구조 (#, ##, ### 등)
2. 코드 블록 (```)
3. 리스트 (-, * 또는 1., 2. 등)
4. 강조 표시 (**, *, __)
5. 표(Tables)
6. 인용구 (>)

기존 내용을 이러한 마크다운 요소를 잘 활용해 재구성하겠습니다.

# 난독증 친화적 교안 데이터 스키마 가이드 (Java 버전)

이 문서는 난독증이 있는 학생들을 위한 교육 자료를 구조화하기 위한 Java 기반 데이터 스키마를 정의합니다. 노션 스타일의 블록 기반 구조를 차용하여 설계되었습니다.

## 목차

- [패키지 구조](#%ED%8C%A8%ED%82%A4%EC%A7%80-%EA%B5%AC%EC%A1%B0)
- [기본 열거형 정의](#%EA%B8%B0%EB%B3%B8-%EC%97%B4%EA%B1%B0%ED%98%95-%EC%A0%95%EC%9D%98)
- [기본 블록 추상화](#%EA%B8%B0%EB%B3%B8-%EB%B8%94%EB%A1%9D-%EC%B6%94%EC%83%81%ED%99%94)
- [텍스트 관련 클래스](#%ED%85%8D%EC%8A%A4%ED%8A%B8-%EA%B4%80%EB%A0%A8-%ED%81%B4%EB%9E%98%EC%8A%A4)
- [텍스트 블록 구현 클래스](#%ED%85%8D%EC%8A%A4%ED%8A%B8-%EB%B8%94%EB%A1%9D-%EA%B5%AC%ED%98%84-%ED%81%B4%EB%9E%98%EC%8A%A4)
- [미디어 블록 클래스](#%EB%AF%B8%EB%94%94%EC%96%B4-%EB%B8%94%EB%A1%9D-%ED%81%B4%EB%9E%98%EC%8A%A4)
- [난독증 친화적 특수 블록](#%EB%82%9C%EB%8F%85%EC%A6%9D-%EC%B9%9C%ED%99%94%EC%A0%81-%ED%8A%B9%EC%88%98-%EB%B8%94%EB%A1%9D)
- [페이지 구조](#%ED%8E%98%EC%9D%B4%EC%A7%80-%EA%B5%AC%EC%A1%B0)
- [사용 예시 (JSON 형식)](#%EC%82%AC%EC%9A%A9-%EC%98%88%EC%8B%9C-json-%ED%98%95%EC%8B%9D)
- [구현 시 고려사항](#%EA%B5%AC%ED%98%84-%EC%8B%9C-%EA%B3%A0%EB%A0%A4%EC%82%AC%ED%95%AD)

## 패키지 구조

```
com.dyslexiaapp
├── model
│   ├── block
│   │   ├── base
│   │   ├── text
│   │   ├── media
│   │   └── specialized
│   ├── page
│   └── enums
└── util
```

## 기본 열거형 정의

java

```java
package com.dyslexiaapp.model.enums;

/**
 * 교안 컨텐츠의 블록 유형을 정의하는 열거형
 */
public enum BlockType {
    HEADING_1,
    HEADING_2,
    HEADING_3,
    PARAGRAPH,
    BULLETED_LIST,
    NUMBERED_LIST,
    CALLOUT,
    DIVIDER,
    IMAGE,
    VIDEO,
    AUDIO,
    TABLE,
    CODE,
    TOGGLE,
    
    // 난독증 특화 블록 유형
    CONCEPT_VISUALIZATION,
    TERM_DEFINITION,
    SIMPLIFIED_TEXT,
    STEP_BY_STEP
}
```

## 기본 블록 추상화

모든 컨텐츠 요소의 공통 구조를 정의합니다.

java

```java
package com.dyslexiaapp.model.block.base;

import com.dyslexiaapp.model.enums.BlockType;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 모든 콘텐츠 블록의 기본 추상 클래스
 */
public abstract class Block {
    private String id;                   // 블록 고유 식별자
    private BlockType type;              // 블록 유형
    private LocalDateTime createdAt;     // 생성 시간
    private LocalDateTime updatedAt;     // 수정 시간
    private boolean hasChildren;         // 하위 블록 포함 여부
    private List<Block> children;        // 하위 블록 목록 (있는 경우)
    
    // Getter/Setter 메서드
    // ...
}
```

## 텍스트 관련 클래스

java

```java
package com.dyslexiaapp.model.block.text;

/**
 * 텍스트 서식 및 주석을 위한 클래스
 */
public class RichText {
    private String plainText;
    private TextAnnotation annotations;
    private String href;        // 링크 URL (있는 경우)
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 텍스트 서식 설정을 위한 클래스
 */
public class TextAnnotation {
    private boolean bold;
    private boolean italic;
    private boolean underline;
    private String color;
    private boolean highlight;
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 난독증 친화적 텍스트 설정을 위한 클래스
 */
public class DyslexiaTextSettings {
    private String fontFamily;     // OpenDyslexic 등 특수 글꼴
    private Integer fontSize;      // 확대된 글꼴 크기
    private Float lineSpacing;     // 줄 간격 (1.5, 2.0 등)
    private Float letterSpacing;   // 글자 간격
    private Float wordSpacing;     // 단어 간격
    private String alignment;      // 텍스트 정렬
    private String textColor;      // 텍스트 색상
    private String backgroundColor; // 배경색
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 텍스트 기반 블록의 기본 추상 클래스
 */
public abstract class TextBlock extends Block {
    private List<RichText> content;
    private DyslexiaTextSettings dyslexiaSettings;
    
    // Getter/Setter 메서드
    // ...
}
```

## 텍스트 블록 구현 클래스

java

```java
package com.dyslexiaapp.model.block.text;

import com.dyslexiaapp.model.enums.BlockType;

/**
 * 제목 블록 클래스
 */
public class HeadingBlock extends TextBlock {
    private boolean isKeyConcept;  // 핵심 개념 여부
    
    public HeadingBlock() {
        // BlockType은 생성자에서 설정하거나 별도 메서드로 처리
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 문단 블록 클래스
 */
public class ParagraphBlock extends TextBlock {
    private Integer complexityLevel;  // 텍스트 복잡성 수준 (1-5)
    
    public ParagraphBlock() {
        setType(BlockType.PARAGRAPH);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 글머리 기호 목록 블록 클래스
 */
public class BulletedListBlock extends TextBlock {
    
    public BulletedListBlock() {
        setType(BlockType.BULLETED_LIST);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 번호 매기기 목록 블록 클래스
 */
public class NumberedListBlock extends TextBlock {
    private int number;  // 목록 번호
    
    public NumberedListBlock() {
        setType(BlockType.NUMBERED_LIST);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 토글(접기/펼치기) 블록 클래스
 */
public class ToggleBlock extends TextBlock {
    private boolean isOpen;  // 기본 표시 상태
    
    public ToggleBlock() {
        setType(BlockType.TOGGLE);
    }
    
    // Getter/Setter 메서드
    // ...
}
```

## 미디어 블록 클래스

java

```java
package com.dyslexiaapp.model.block.media;

import com.dyslexiaapp.model.block.base.Block;
import com.dyslexiaapp.model.enums.BlockType;

/**
 * 구분선 블록 클래스
 */
public class DividerBlock extends Block {
    
    public DividerBlock() {
        setType(BlockType.DIVIDER);
    }
}

/**
 * 이미지 블록 클래스
 */
public class ImageBlock extends Block {
    private String url;
    private String caption;
    private String altText;  // 접근성을 위한 대체 텍스트
    private Dimensions dimensions;
    
    public ImageBlock() {
        setType(BlockType.IMAGE);
    }
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 이미지 크기 정보를 위한 내부 클래스
     */
    public static class Dimensions {
        private int width;
        private int height;
        
        // Getter/Setter 메서드
        // ...
    }
}

/**
 * 표 블록 클래스
 */
public class TableBlock extends Block {
    private boolean hasHeader;
    private int rows;
    private int columns;
    private List<List<TableCell>> cells;  // 2차원 배열로 셀 데이터 저장
    
    public TableBlock() {
        setType(BlockType.TABLE);
    }
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 표 셀 데이터를 위한 내부 클래스
     */
    public static class TableCell {
        private List<RichText> content;
        private boolean isHeader;
        
        // Getter/Setter 메서드
        // ...
    }
}
```

## 난독증 친화적 특수 블록

java

```java
package com.dyslexiaapp.model.block.specialized;

import com.dyslexiaapp.model.block.base.Block;
import com.dyslexiaapp.model.enums.BlockType;
import com.dyslexiaapp.model.enums.VisualizationType;
import java.util.List;

/**
 * 개념 시각화 블록 클래스
 */
public class ConceptVisualizationBlock extends Block {
    private String conceptName;           // 시각화할 개념명
    private VisualizationType visualizationType;
    private String imageUrl;
    private String description;           // 시각 자료 설명
    private String relatedTextId;         // 연관된 텍스트 블록 ID
    
    public ConceptVisualizationBlock() {
        setType(BlockType.CONCEPT_VISUALIZATION);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 시각화 유형 열거형
 */
package com.dyslexiaapp.model.enums;

public enum VisualizationType {
    DIAGRAM,
    INFOGRAPHIC,
    FLOWCHART,
    COMPARISON
}

/**
 * 용어 정의 블록 클래스
 */
public class TermDefinitionBlock extends Block {
    private String term;                  // 원본 용어
    private String simplifiedDefinition;  // 단순화된 정의
    private List<String> examples;        // 예시
    private String visualHintUrl;         // 시각적 힌트 이미지
    
    public TermDefinitionBlock() {
        setType(BlockType.TERM_DEFINITION);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 단순화된 텍스트 블록 클래스
 */
public class SimplifiedTextBlock extends Block {
    private String originalText;         // 원본 텍스트
    private String simplifiedText;       // 단순화된 텍스트
    private int complexityReduction;     // 복잡성 감소 수준 (1-5)
    
    public SimplifiedTextBlock() {
        setType(BlockType.SIMPLIFIED_TEXT);
    }
    
    // Getter/Setter 메서드
    // ...
}

/**
 * 단계별 지시 블록 클래스
 */
public class StepByStepBlock extends Block {
    private String title;
    private List<Step> steps;
    
    public StepByStepBlock() {
        setType(BlockType.STEP_BY_STEP);
    }
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 단계 정보를 위한 내부 클래스
     */
    public static class Step {
        private int stepNumber;
        private String instruction;
        private String imageUrl;
        private boolean isCurrent;      // 현재 진행 중인 단계 표시
        
        // Getter/Setter 메서드
        // ...
    }
}
```

## 페이지 구조

java

```java
package com.dyslexiaapp.model.page;

import com.dyslexiaapp.model.block.base.Block;
import java.time.LocalDateTime;
import java.util.List;

/**
 * 전체 페이지 구조를 표현하는 클래스
 */
public class Page {
    private String id;
    private String title;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private PageMetadata metadata;
    private GlobalDyslexiaSettings globalDyslexiaSettings;
    private List<Block> blocks;          // 페이지 콘텐츠 블록
    
    // Getter/Setter 메서드
    // ...
    
    /**
     * 페이지 메타데이터를 위한 내부 클래스
     */
    public static class PageMetadata {
        private String originalPdf;       // 원본 PDF 소스
        private String subject;           // 과목
        private String gradeLevel;        // 학년
        private Integer readingLevel;     // 읽기 난이도 (1-10)
        private String author;            // 작성자/변환자
        
        // Getter/Setter 메서드
        // ...
    }
    
    /**
     * 전역 난독증 설정을 위한 내부 클래스
     */
    public static class GlobalDyslexiaSettings {
        private String defaultFont;       // 기본 폰트
        private int defaultFontSize;      // 기본 폰트 크기
        private float defaultLineSpacing; // 기본 줄 간격
        private ColorScheme colorScheme;  // 색상 테마
        private boolean highlightCurrentLine; // 현재 줄 강조 표시
        
        // Getter/Setter 메서드
        // ...
    }
    
    /**
     * 색상 테마 열거형
     */
    public enum ColorScheme {
        LIGHT,
        DARK,
        SEPIA,
        CUSTOM
    }
}
```

## 사용 예시 (JSON 형식)

아래는 이 스키마를 사용한 JSON 형식의 페이지 예시입니다:

json

```json
{
  "id": "page_123456",
  "title": "생태계와 환경",
  "createdAt": "2025-05-10T12:00:00Z",
  "updatedAt": "2025-05-11T09:30:00Z",
  "metadata": {
    "originalPdf": "3학년_과학_2단원.pdf",
    "subject": "과학",
    "gradeLevel": "3",
    "readingLevel": 3,
    "author": "최은기"
  },
  "globalDyslexiaSettings": {
    "defaultFont": "OpenDyslexic",
    "defaultFontSize": 16,
    "defaultLineSpacing": 1.5,
    "colorScheme": "LIGHT",
    "highlightCurrentLine": true
  },
  "blocks": [
    {
      "id": "heading_001",
      "type": "HEADING_1",
      "createdAt": "2025-05-10T12:05:00Z",
      "updatedAt": "2025-05-10T12:05:00Z",
      "hasChildren": false,
      "content": [
        {
          "plainText": "생태계란 무엇일까요?",
          "annotations": {
            "bold": true,
            "color": "#2D7FF9"
          }
        }
      ],
      "isKeyConcept": true,
      "dyslexiaSettings": {
        "fontSize": 24,
        "lineSpacing": 1.8
      }
    },
    
    {
      "id": "concept_viz_001",
      "type": "CONCEPT_VISUALIZATION",
      "createdAt": "2025-05-10T12:10:00Z",
      "updatedAt": "2025-05-10T12:10:00Z",
      "hasChildren": false,
      "conceptName": "생태계",
      "visualizationType": "DIAGRAM",
      "imageUrl": "https://example.com/images/ecosystem.png",
      "description": "생태계는 생물과 환경이 서로 영향을 주고받는 관계입니다.",
      "relatedTextId": "paragraph_001"
    }
  ]
}
```

## 구현 시 고려사항

1. **직렬화/역직렬화**: Jackson 또는 Gson 라이브러리를 사용하여 Java 객체와 JSON 간 변환
2. **유효성 검증**: Bean Validation API(JSR-380)를 활용한 데이터 유효성 검증
3. **확장성**: 새로운 블록 유형 추가 시 Block 추상 클래스 상속 및 BlockType enum 확장
4. **저장소**: MongoDB 또는 PostgreSQL(JSONB 타입)을 사용한 문서 저장 고려
5. **버전 관리**: 교안 수정 이력 관리를 위한 버전 관리 메커니즘 구현 검토

이 스키마는 난독증이 있는 학생들을 위한 교육 자료 변환 및 표시를 위한 기본 구조를 제공합니다. 실제 구현 시에는 요구사항에 따라 수정 및 확장이 필요할 수 있습니다.