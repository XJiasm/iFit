@echo off
chcp 65001 >nul
echo =========================================
echo    FitMirror APK 打包脚本
echo =========================================
echo.

:: 检查 Flutter
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Flutter 未安装！
    echo.
    echo 请按以下步骤安装 Flutter:
    echo.
    echo 1. 下载 Flutter SDK:
    echo    https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip
    echo.
    echo 2. 解压到 C:\flutter
    echo.
    echo 3. 添加到系统环境变量 PATH:
    echo    C:\flutter\bin
    echo.
    echo 4. 重启命令行窗口，运行: flutter doctor
    echo.
    echo 5. 安装 Android Studio 并配置 Android SDK
    echo.
    pause
    exit /b 1
)

:: 进入项目目录
cd fitmirror

:: 清理并获取依赖
echo [1/3] 获取依赖...
flutter clean
flutter pub get

:: 构建 APK
echo [2/3] 构建 APK (release)...
flutter build apk --release

if %errorlevel% equ 0 (
    echo.
    echo [3/3] 构建成功！
    echo.
    echo APK 文件位置:
    echo %cd%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    explorer build\app\outputs\flutter-apk
) else (
    echo.
    echo [错误] 构建失败，请检查错误信息
)

cd ..
pause
