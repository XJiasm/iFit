# FitMirror APK 打包脚本
# 使用方法：右键 -> 使用 PowerShell 运行

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  FitMirror APK 打包脚本" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ProjectDir = "C:\Users\Buding\.local\bin\iFit\fitmirror"

# 检查 Flutter 是否安装
$flutterCmd = Get-Command flutter -ErrorAction SilentlyContinue
if (-not $flutterCmd) {
    # 尝试从固定路径加载
    $flutterBat = "C:\tools\flutter\bin\flutter.bat"
    if (Test-Path $flutterBat) {
        $env:Path = "C:\tools\flutter\bin;" + $env:Path
    } else {
        Write-Host "[错误] 未找到 Flutter，请先运行 install-env.ps1 安装环境" -ForegroundColor Red
        Read-Host "按回车键退出"
        exit 1
    }
}

# 检查项目目录
if (-not (Test-Path $ProjectDir)) {
    Write-Host "[错误] 项目目录不存在: $ProjectDir" -ForegroundColor Red
    Read-Host "按回车键退出"
    exit 1
}

Set-Location $ProjectDir

# Step 1: 检查环境
Write-Host "[Step 1/4] 检查 Flutter 环境..." -ForegroundColor Yellow
flutter doctor --no-color 2>&1 | Select-String -Pattern "Flutter|Android|Java|\[✓\]|\[✗\]|\[!\]" | ForEach-Object {
    if ($_ -match "\[✗\]") {
        Write-Host "  $_" -ForegroundColor Red
    } elseif ($_ -match "\[!\]") {
        Write-Host "  $_" -ForegroundColor Yellow
    } else {
        Write-Host "  $_" -ForegroundColor Green
    }
}

# Step 2: 获取依赖
Write-Host ""
Write-Host "[Step 2/4] 获取项目依赖..." -ForegroundColor Yellow
flutter pub get 2>&1 | Out-Null
Write-Host "  -> 完成" -ForegroundColor Green

# Step 3: 打包 APK
Write-Host ""
Write-Host "[Step 3/4] 打包 Release APK..." -ForegroundColor Yellow
Write-Host "  -> 这可能需要几分钟，请耐心等待..." -ForegroundColor Cyan

$buildOutput = flutter build apk --release 2>&1
$buildExitCode = $LASTEXITCODE

if ($buildExitCode -eq 0) {
    Write-Host "  -> 打包成功！" -ForegroundColor Green
} else {
    Write-Host "  -> 打包失败！" -ForegroundColor Red
    Write-Host $buildOutput
    Read-Host "按回车键退出"
    exit 1
}

# Step 4: 显示结果
Write-Host ""
Write-Host "[Step 4/4] 构建结果" -ForegroundColor Yellow

$apkPath = "$ProjectDir\build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length / 1MB
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  APK 打包成功！" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "文件位置: $apkPath" -ForegroundColor Cyan
    Write-Host "文件大小: $([math]::Round($apkSize, 2)) MB" -ForegroundColor Cyan
    Write-Host ""

    # 打开输出目录
    $openFolder = Read-Host "是否打开 APK 所在文件夹？(y/n)"
    if ($openFolder -eq 'y' -or $openFolder -eq 'Y') {
        explorer.exe (Split-Path $apkPath -Parent)
    }
} else {
    Write-Host "[错误] APK 文件未找到: $apkPath" -ForegroundColor Red
}

Write-Host ""
Read-Host "按回车键退出"
