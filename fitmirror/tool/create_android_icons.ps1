Add-Type -AssemblyName System.Drawing

$basePath = "C:\Users\Buding\.local\bin\iFit\fitmirror\assets\images\app_icon.png"
$androidResPath = "C:\Users\Buding\.local\bin\iFit\fitmirror\android\app\src\main\res"

# Load source image
$sourceImage = [System.Drawing.Image]::FromFile($basePath)

# Android mipmap sizes
$sizes = @{
    "mipmap-mdpi"    = 48
    "mipmap-hdpi"    = 72
    "mipmap-xhdpi"   = 96
    "mipmap-xxhdpi"  = 144
    "mipmap-xxxhdpi" = 192
}

foreach ($folder in $sizes.Keys) {
    $targetSize = $sizes[$folder]
    $destPath = "$androidResPath\$folder"

    # Create directory if not exists
    if (-not (Test-Path $destPath)) {
        New-Item -ItemType Directory -Force -Path $destPath | Out-Null
    }

    # Create resized bitmap
    $resized = New-Object System.Drawing.Bitmap($targetSize, $targetSize)
    $graphics = [System.Drawing.Graphics]::FromImage($resized)
    $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.DrawImage($sourceImage, 0, 0, $targetSize, $targetSize)

    # Save
    $resized.Save("$destPath\ic_launcher.png", [System.Drawing.Imaging.ImageFormat]::Png)
    $resized.Save("$destPath\ic_launcher_round.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $graphics.Dispose()
    $resized.Dispose()

    Write-Host "Created $folder\ic_launcher.png ($targetSize x $targetSize)" -ForegroundColor Green
}

# Create adaptive icon background (solid red)
$adaptiveBgPath = "$androidResPath\mipmap-anydpi-v26"
if (-not (Test-Path $adaptiveBgPath)) {
    New-Item -ItemType Directory -Force -Path $adaptiveBgPath | Out-Null
}

# Create ic_launcher_background.xml
$bgXml = @"
<?xml version="1.0" encoding="utf-8"?>
<shape xmlns:android="http://schemas.android.com/apk/res/android">
    <solid android:color="#E53935"/>
</shape>
"@
$bgXml | Out-File -FilePath "$androidResPath\drawable\ic_launcher_background.xml" -Encoding UTF8

# Create ic_launcher_foreground.xml
$fgXml = @"
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@drawable/ic_launcher_background"/>
    <foreground android:drawable="@drawable/ic_launcher_foreground"/>
</adaptive-icon>
"@

# Create foreground drawable (white dress icon)
$fgDrawablePath = "$androidResPath\drawable"
if (-not (Test-Path $fgDrawablePath)) {
    New-Item -ItemType Directory -Force -Path $fgDrawablePath | Out-Null
}

# Create 108dp foreground image
$fgSize = 432  # 108dp at xxxhdpi
$fgBitmap = New-Object System.Drawing.Bitmap($fgSize, $fgSize)
$fgGraphics = [System.Drawing.Graphics]::FromImage($fgBitmap)
$fgGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

# Draw scaled elements from source
$fgGraphics.DrawImage($sourceImage, 0, 0, $fgSize, $fgSize)

$fgBitmap.Save("$fgDrawablePath\ic_launcher_foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)

$fgBitmap.Dispose()
$fgGraphics.Dispose()
$sourceImage.Dispose()

Write-Host ""
Write-Host "All launcher icons created successfully!" -ForegroundColor Cyan
