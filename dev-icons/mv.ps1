# C:\Users\deveu\MyHeart\dev-icons 폴더의 모든 하위 폴더에서 SVG 파일을 찾아 상위 폴더로 이동하는 스크립트

$baseDir = "C:\Users\deveu\MyHeart\dev-icons"
$subdirs = Get-ChildItem -Path $baseDir -Directory

# 이동된 파일 수와 오류 수를 추적하기 위한 카운터
$movedFiles = 0
$errorCount = 0

foreach ($dir in $subdirs) {
    # 각 하위 폴더에서 SVG 파일 찾기
    $svgFiles = Get-ChildItem -Path $dir.FullName -Filter "*.svg"
    
    foreach ($file in $svgFiles) {
        # 새 파일 이름 생성 (폴더이름-파일이름.svg)
        $newFileName = "{0}-{1}" -f $dir.Name, $file.Name
        $destination = Join-Path -Path $baseDir -ChildPath $newFileName
        
        try {
            # 파일 이동 (복사 후 원본 유지)
            Copy-Item -Path $file.FullName -Destination $destination -Force
            $movedFiles++
            Write-Host "이동 완료: $($file.FullName) -> $destination" -ForegroundColor Green
        } catch {
            $errorCount++
            Write-Host "오류 발생: $($file.FullName) 파일 이동 중 오류 - $_" -ForegroundColor Red
        }
    }
}

Write-Host "`n작업 완료!" -ForegroundColor Cyan
Write-Host "총 $movedFiles 개의 SVG 파일을 이동했습니다." -ForegroundColor Cyan
if ($errorCount -gt 0) {
    Write-Host "$errorCount 개의 오류가 발생했습니다." -ForegroundColor Yellow
}