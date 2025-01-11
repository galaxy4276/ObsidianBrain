#two-pointer #array #problem-solved


```python
from typing import List

class Solution:
    def merge(self, nums1: List[int], m: int, nums2: List[int], n: int) -> None:
        last = m + n - 1
        while m > 0 and n > 0:
            if nums1[m - 1] > nums2[n - 1]:
                nums1[last] = nums1[m - 1]
                m -= 1
            else:
                nums1[last] = nums2[n - 1]
                n -= 1
            last -= 1

        while n > 0:
            nums1[last] = nums2[n - 1]
            n, last = n - 1, last - 1
```

**1. 변수 설정**
• last: nums1의 가장 마지막 인덱스(m + n - 1)를 초기화.
• m, n: 각각 nums1과 nums2의 현재 탐색해야 할 유효한 마지막 인덱스를 나타냄.

**2. 병합 작업 (첫 번째 while 루프)**
• nums1과 nums2의 마지막 요소부터 비교:
• nums1[m - 1] > nums2[n - 1]일 경우:
• nums1[last]에 nums1[m - 1]을 복사하고, m과 last를 감소.
 그 외의 경우:
• nums1[last]에 nums2[n - 1]을 복사하고, n과 last를 감소.

**3. 남은 요소 처리 (두 번째 while 루프)**
nums2에 남은 요소가 있을 경우.
nums1의 남은 공간에 그대로 복사.

**4. 주의 사항**
• nums1의 앞부분(m > 0)은 이미 정렬되어 있으므로, nums2의 남은 요소만 처리하면 됨.
• nums2의 요소를 끝까지 모두 병합하면 작업이 완료
