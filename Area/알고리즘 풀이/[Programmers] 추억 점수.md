# [Programmers] 추억 점수

태그: HashMap, Level 1, PS
Date: September 9, 2023 2:26 PM
공개 여부: 공개
설명: 추억점수 풀이
카테고리: 알고리즘

![Untitled](Untitled%2049.png)

```java
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class Programmers {
    public int[] solution(String[] name, int[] yearning, String[][] photo) {
        Map<String, Integer> map = new HashMap<>();
        int photoSize = photo.length;
        int[] result = new int[photoSize];
        int resultIndex = 0;

        for (int i = 0; i < name.length; i++) {
            map.put(name[i], yearning[i]);
        }

        int sum = 0;
        for (int i = 0; i < photoSize; i++) {
            for (int j = 0; j < photo[i].length; j++) {
                Integer value = map.get(photo[i][j]);
                if (Objects.nonNull(value)) sum += value;
            }

            result[resultIndex++] = sum;
            sum = 0;
        }

        return result;
    }

}
```

[](https://school.programmers.co.kr/learn/courses/30/lessons/176963)

단순한 배열 계산 문제이며 특정 배열 값의 요소를 찾기 위해 `HashMap` 을 이용하였습니다.