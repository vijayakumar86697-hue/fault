# capture_screenshots.ps1
$tempDir = "d:\temp_screenshots"
$outputDir = "d:\New folder\rendered_screenshots"
$artifactDir = "C:\Users\acer\.gemini\antigravity-ide\brain\f5169bf9-3c96-4d50-bbaa-48fe5527b485\rendered_screenshots"

if (-not (Test-Path $outputDir)) { New-Item -ItemType Directory -Force -Path $outputDir | Out-Null }
if (-not (Test-Path $artifactDir)) { New-Item -ItemType Directory -Force -Path $artifactDir | Out-Null }

$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$htmlFiles = Get-ChildItem -Path $tempDir -Filter "*.html"

foreach ($f in $htmlFiles) {
    $name = $f.BaseName
    $tempPng = "$tempDir\$name.png"
    $outPng = "$outputDir\$name.png"
    $artPng = "$artifactDir\$name.png"
    $fileUrl = "file:///" + $f.FullName.Replace('\', '/')
    
    Write-Host "Rendering $name..."
    $argList = @(
        "--headless",
        "--disable-gpu",
        "--window-size=1280,800",
        "--user-data-dir=d:\temp_chrome",
        "--screenshot=$tempPng",
        $fileUrl
    )
    
    Start-Process -FilePath $chrome -ArgumentList $argList -Wait
    
    if (Test-Path $tempPng) {
        Copy-Item -Path $tempPng -Destination $outPng -Force
        Copy-Item -Path $tempPng -Destination $artPng -Force
        Write-Host "SUCCESS: Saved $name.png ($((Get-Item $tempPng).Length) bytes)"
    } else {
        Write-Host "FAILED: $name"
    }
}

Write-Host "BATCH_RENDERING_COMPLETE"
