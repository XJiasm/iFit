# FitMirror APK Build Environment Installer
# Run with PowerShell (Admin recommended)

param([switch]$SkipSdkInstall)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FitMirror Environment Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Directories
$FlutterDir = "C:\tools\flutter"
$AndroidDir = "C:\Android"
$ToolsDir = "C:\tools"

# Step 1: Create directories
Write-Host "[Step 1/6] Creating directories..." -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
New-Item -ItemType Directory -Force -Path $AndroidDir | Out-Null
Write-Host "  -> Done" -ForegroundColor Green

# Step 2: Download Flutter SDK
Write-Host "[Step 2/6] Checking Flutter SDK..." -ForegroundColor Yellow
if (Test-Path "$FlutterDir\bin\flutter.bat") {
    Write-Host "  -> Flutter exists, skipping" -ForegroundColor Green
} else {
    Write-Host "  -> Downloading Flutter SDK (~1GB)..." -ForegroundColor Cyan
    $flutterUrl = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.0-stable.zip"
    $flutterZip = "$ToolsDir\flutter.zip"

    try {
        $ProgressPreference = "SilentlyContinue"
        Invoke-WebRequest -Uri $flutterUrl -OutFile $flutterZip -UseBasicParsing
        Write-Host "  -> Extracting Flutter SDK..." -ForegroundColor Cyan
        Expand-Archive -Path $flutterZip -DestinationPath $ToolsDir -Force
        Remove-Item $flutterZip -Force
        Write-Host "  -> Flutter SDK installed" -ForegroundColor Green
    } catch {
        Write-Host "  -> Error: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 3: Download Android Command Line Tools
Write-Host "[Step 3/6] Checking Android Command Line Tools..." -ForegroundColor Yellow
$cmdlineToolsPath = "$AndroidDir\cmdline-tools\latest\bin\sdkmanager.bat"
if (Test-Path $cmdlineToolsPath) {
    Write-Host "  -> Android tools exist, skipping" -ForegroundColor Green
} else {
    Write-Host "  -> Downloading Android Command Line Tools..." -ForegroundColor Cyan
    $cmdlineUrl = "https://dl.google.com/android/repository/commandlinetools-win-11076708_latest.zip"
    $cmdlineZip = "$ToolsDir\cmdline-tools.zip"

    try {
        Invoke-WebRequest -Uri $cmdlineUrl -OutFile $cmdlineZip -UseBasicParsing
        Write-Host "  -> Extracting..." -ForegroundColor Cyan
        Expand-Archive -Path $cmdlineZip -DestinationPath "$AndroidDir\cmdline-tools-temp" -Force
        New-Item -ItemType Directory -Force -Path "$AndroidDir\cmdline-tools\latest" | Out-Null
        Get-ChildItem "$AndroidDir\cmdline-tools-temp\cmdline-tools" | Move-Item -Destination "$AndroidDir\cmdline-tools\latest" -Force
        Remove-Item "$AndroidDir\cmdline-tools-temp" -Recurse -Force
        Remove-Item $cmdlineZip -Force
        Write-Host "  -> Android Command Line Tools installed" -ForegroundColor Green
    } catch {
        Write-Host "  -> Error: $_" -ForegroundColor Red
        exit 1
    }
}

# Step 4: Set environment variables
Write-Host "[Step 4/6] Configuring environment variables..." -ForegroundColor Yellow
$flutterBin = "$FlutterDir\bin"
$androidCmdBin = "$AndroidDir\cmdline-tools\latest\bin"
$androidPlatformBin = "$AndroidDir\platform-tools"

$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")
$pathsToAdd = @($flutterBin, $androidCmdBin, $androidPlatformBin)
$updated = $false

foreach ($p in $pathsToAdd) {
    if ($currentPath -notlike "*$p*") {
        $currentPath = "$currentPath;$p"
        $updated = $true
    }
}

if ($updated) {
    [Environment]::SetEnvironmentVariable("Path", $currentPath, "User")
    Write-Host "  -> PATH updated" -ForegroundColor Green
} else {
    Write-Host "  -> PATH already configured" -ForegroundColor Green
}

[Environment]::SetEnvironmentVariable("ANDROID_HOME", $AndroidDir, "User")
$env:ANDROID_HOME = $AndroidDir
$env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [Environment]::GetEnvironmentVariable("Path", "User")
Write-Host "  -> ANDROID_HOME set" -ForegroundColor Green

# Step 5: Install Android SDK components
if (-not $SkipSdkInstall) {
    Write-Host "[Step 5/6] Installing Android SDK components..." -ForegroundColor Yellow

    $yesFile = "$ToolsDir\yes.txt"
    "y`ny`ny`ny`ny`ny`ny`ny`ny`ny`n" | Out-File -FilePath $yesFile -Encoding ASCII

    Write-Host "  -> Accepting licenses..." -ForegroundColor Cyan
    cmd /c "$yesFile | $cmdlineToolsPath --licenses" 2>&1 | Out-Null

    Write-Host "  -> Installing platform-tools, platform-34, build-tools-34..." -ForegroundColor Cyan
    cmd /c "$yesFile | $cmdlineToolsPath `"platform-tools`" `"platforms;android-34`" `"build-tools;34.0.0`"" 2>&1 | Out-Null

    Remove-Item $yesFile -Force -ErrorAction SilentlyContinue
    Write-Host "  -> Android SDK components installed" -ForegroundColor Green
}

# Step 6: Verify
Write-Host "[Step 6/6] Verifying installation..." -ForegroundColor Yellow
$env:Path = "$flutterBin;" + $env:Path
Write-Host ""
Write-Host "Flutter version:" -ForegroundColor Cyan
& "$flutterBin\flutter.bat" --version 2>&1 | Select-String -Pattern "Flutter|Dart"

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Close this PowerShell window" -ForegroundColor White
Write-Host "  2. Open a new PowerShell window" -ForegroundColor White
Write-Host "  3. Run: flutter doctor" -ForegroundColor White
Write-Host "  4. cd C:\Users\Buding\.local\bin\iFit\fitmirror" -ForegroundColor White
Write-Host "  5. flutter pub get" -ForegroundColor White
Write-Host "  6. flutter build apk --release" -ForegroundColor White
