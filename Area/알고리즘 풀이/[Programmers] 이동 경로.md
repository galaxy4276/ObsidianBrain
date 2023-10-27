![[Pasted image 20231026085120.png]]
```java
import java.util.StringTokenizer;

public class Programmers {

    public static void main(String[] args) {
        Programmers programmers = new Programmers();
        int[] solution = programmers.solution(new String[]{"OSO", "OOO", "OXO", "OOO"}, new String[]{"E 2", "S 3", "W 1"});
        System.out.println("[" + solution[0] + ", " + solution[1] + "]");
    }

    public int[] solution(String[] park, String[] routes) {
        int width = park[0].length();
        int height = park.length;
        char[][] map = new char[height][width];
        int[] pos = { 0, 0 };

        for (int i = 0; i < height; i++) {
            char[] ca = park[i].toCharArray();
            for (int j = 0; j < width; j++) {
                if (ca[j] == 'S') {
                    pos = new int[]{ i, j };
                }
                map[i][j] = ca[j];
            }
        }

        boolean pass = true;
        for (int i = 0; i < routes.length; i++) {
            int[] yxPos = getPos(routes[i]);
            int[] sum = { pos[0] + yxPos[0], pos[1] + yxPos[1] };
            System.out.print("sum: ");
            print(sum);
            if (sum[0] < 0 || sum[1] < 0 || sum[1] > width - 1 || sum[0] > height - 1) {
                continue;
            }

            int minY = Math.min(pos[0], sum[0]);
            int maxY = Math.max(pos[0], sum[0]);
            int minX = Math.min(pos[1], sum[1]);
            int maxX = Math.max(pos[1], sum[1]);

            for (int y = minY; y <= maxY; y++) {
                for (int x = minX; x <= maxX; x++) {
                    if (map[y][x] == 'X') {
                        pass = false;
                    }
                }

                if (map[y][maxX] == 'X') {
                    pass = false;
                }
            }

            if (pass) {
                pos = sum;
            }
            pass = true;
        }

        return pos;
    }

    public int[] getPos(String s) {
        StringTokenizer st = new StringTokenizer(s);
        String pos = st.nextToken();
        int value = Integer.parseInt(st.nextToken());
        switch (pos) {
            case "N" -> {
                return new int[] {-value, 0};
            }
            case "S" -> {
                return new int[] {value, 0};
            }
            case "W" -> {
                return new int[] {0, -value};
            }
            case "E" -> {
                return new int[] {0, value};
            }
            default -> {
                return new int[] {0,0};
            }
        }
    }

    public void print(int[] arr) {
        System.out.println("[" + arr[0] + ", " + arr[1] + "]");
    }

}
```

헥헥 2차원 배열에서 4방향 이동 경우의 수를 구하는 문제다.

자바로 푸니까 상당히 힘들었다..