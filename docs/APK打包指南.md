# FitMirror APK 打包指南

## 一、环境准备

### 1. 安装 Flutter SDK

**方式一：直接下载（推荐）**

1. 下载地址：https://docs.flutter.dev/get-started/install/windows
2. 直接下载链接：https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.16.0-stable.zip
3. 解压到 `C:\flutter`

**方式二：使用 Git**

```bash
git clone https://github.com/flutter/flutter.git -b stable C:\flutter
```

### 2. 配置环境变量

1. 打开「系统属性」→「高级」→「环境变量」
2. 在「系统变量」中找到 `Path`，点击「编辑」
3. 添加：`C:\flutter\bin`
4. 确定保存，重启命令行窗口

### 3. 安装 Android Studio

1. 下载：https://developer.android.com/studio
2. 安装后打开，进入 `More Actions` → `SDK Manager`
3. 安装 Android SDK (API 33 或更高)
4. 勾选 `Android SDK Command-line Tools`

### 4. 验证环境

```bash
flutter doctor
```

确保以下项目都是 ✓：
- Flutter SDK
- Android toolchain
- Visual Studio (可选，用于 Windows 桌面应用)

---

## 二、打包 APK

### 方式一：使用脚本

双击运行 `build-apk.bat`

### 方式二：手动打包

```bash
# 进入项目目录
cd fitmirror

# 清理项目
flutter clean

# 获取依赖
flutter pub get

# 构建 APK (release 版本)
flutter build apk --release

# 构建完成后，APK 位于：
# build/app/outputs/flutter-apk/app-release.apk
```

### 方式三：构建分架构 APK（更小体积）

```bash
# 构建分架构 APK
flutter build apk --split-per-abi --release

# 会生成三个 APK：
# app-armeabi-v7a-release.apk  (~15MB)
# app-arm64-v8a-release.apk    (~18MB)
# app-x86_64-release.apk       (~18MB)
```

---

## 三、签名配置（正式发布需要）

### 1. 生成签名密钥

```bash
keytool -genkey -v -keystore fitmirror.jks -keyalg RSA -keysize 2048 -validity 10000 -alias fitmirror
```

### 2. 创建 key.properties

在 `fitmirror/android/` 目录下创建 `key.properties`：

```properties
storePassword=你的密码
keyPassword=你的密码
keyAlias=fitmirror
storeFile=../fitmirror.jks
```

### 3. 配置 build.gradle

编辑 `fitmirror/android/app/build.gradle`：

```gradle
android {
    ...
    signingConfigs {
        release {
            keyAlias 'fitmirror'
            keyPassword '你的密码'
            storeFile file('../fitmirror.jks')
            storePassword '你的密码'
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 四、常见问题

### Q1: `flutter doctor` 报错 Android licenses 未接受

```bash
flutter doctor --android-licenses
```
一路按 `y` 接受所有许可。

### Q2: 构建报错 `Could not resolve all files`

检查网络，或配置国内镜像。编辑 `fitmirror/android/build.gradle`：

```gradle
allprojects {
    repositories {
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        google()
        mavenCentral()
    }
}
```

### Q3: Gradle 下载太慢

修改 `fitmirror/android/gradle/wrapper/gradle-wrapper.properties`，使用国内镜像：

```properties
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-7.5-all.zip
```

---

## 五、安装测试

```bash
# 连接手机（开启 USB 调试）
adb devices

# 安装 APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

或直接将 APK 文件传输到手机安装。
