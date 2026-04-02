# FitMirror - 虚拟试穿 AI 穿搭助手

一款帮助用户在电商购物前预览搭配效果的应用。

## 功能特性

- 📸 **形象管理** - 上传全身照创建个人形象
- 👗 **服装管理** - 导入电商截图，智能裁剪服装
- ✨ **虚拟试穿** - 图层叠加预览搭配效果
- 🤖 **AI 点评** - 多维度评分，专业搭配建议
- ☁️ **云端同步** - 数据安全备份，多设备同步
- 🌙 **深色模式** - 护眼主题切换

## 技术栈

| 层级 | 技术 |
|------|------|
| 客户端 | Flutter 3.x + Riverpod + Hive |
| 后端 | Spring Boot 3.x + MySQL + JWT |
| AI | DeepSeek / OpenAI API |

## 快速开始

### 环境要求

- Flutter SDK 3.x
- Java 17+
- MySQL 8.0+
- Maven 3.8+

### 1. 启动后端

```bash
# Windows
start.bat

# Linux/Mac
chmod +x start.sh
./start.sh
```

或手动启动：

```bash
# 创建数据库
mysql -u root -p -e "CREATE DATABASE fitmirror"

# 启动后端
cd backend
./mvnw spring-boot:run
```

### 2. 启动客户端

```bash
cd fitmirror
flutter pub get
flutter run
```

## 项目结构

```
iFit/
├── fitmirror/                # Flutter 客户端
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/           # 数据模型
│   │   ├── providers/        # 状态管理
│   │   ├── services/         # 服务层
│   │   ├── screens/          # 页面
│   │   ├── widgets/          # 组件
│   │   └── utils/            # 工具
│   └── pubspec.yaml
│
├── backend/                  # Spring Boot 后端
│   ├── src/main/java/com/fitmirror/
│   │   ├── config/           # 配置
│   │   ├── controller/       # 控制器
│   │   ├── service/          # 服务
│   │   ├── repository/       # 数据访问
│   │   ├── entity/           # 实体
│   │   ├── dto/              # 数据传输
│   │   └── security/         # 安全认证
│   └── pom.xml
│
├── PRD/                      # 产品文档
└── docs/                     # 开发文档
```

## API 接口

| 接口 | 方法 | 说明 |
|------|------|------|
| /api/auth/register | POST | 用户注册 |
| /api/auth/login | POST | 用户登录 |
| /api/user/info | GET | 获取用户信息 |
| /api/ai/comment | POST | AI 点评 |
| /api/sync/upload | POST | 上传数据 |
| /api/sync/download | GET | 下载数据 |
| /api/files/upload | POST | 上传文件 |
| /api/health | GET | 健康检查 |

## 配置说明

### 后端配置 (application.yml)

```yaml
# 数据库
spring.datasource.url: jdbc:mysql://localhost:3306/fitmirror
spring.datasource.username: root
spring.datasource.password: 123456

# AI 提供商
ai.provider: deepseek  # deepseek / openai

# AI API Key
ai.deepseek.api-key: ${DEEPSEEK_API_KEY}
```

### 客户端配置

```dart
// lib/services/api_service.dart
baseUrl: 'http://localhost:8080/api'
```

## 开发进度

- [x] PRD 文档
- [x] 技术架构设计
- [x] Flutter 客户端核心功能
- [x] Spring Boot 后端 API
- [x] AI 点评集成
- [x] 用户认证系统
- [x] 数据同步功能
- [ ] 文件云存储 (OSS)
- [ ] 订阅付费系统
- [ ] iOS 版本

## License

MIT License
