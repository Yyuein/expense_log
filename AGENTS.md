# 项目概览

- **项目说明**：Flutter 个人记账应用，支持新增、编辑、删除支出，按月份汇总并绘制柱状图。Web、iOS、Android 分别在本地保存账目；目前没有跨设备同步。
- **技术栈**：Dart 3.6、Flutter、Provider、Drift/SQLite、`fl_chart`、`intl`。入口是 `lib/main.dart`，界面在 `lib/pages/`，模型在 `lib/models/`，数据库代码在 `lib/database/`。

# 开发命令

- **安装依赖**：`flutter pub get`
- **生成 Drift 代码**：`dart run build_runner build`
- **运行**：`flutter run`
- **构建 Web**：`flutter build web`
- **测试**：`flutter test`
- **静态分析与 lint**：`flutter analyze`

仓库没有 `package.json`，不使用 npm 命令。`lib/database/app_database.g.dart` 是生成文件；修改表结构后重新运行 build_runner，不手工编辑生成内容。Web 运行需要 `web/sqlite3.wasm` 和 `web/drift_worker.dart.js`。当前 worker 来自 Drift 2.28.0，WASM 来自 sqlite3 2.7.5；升级时应先确认这两个文件与锁定的 Dart 包兼容，并实际在浏览器启动应用。

# 编码与风格规范

- **缩进**：Dart 使用 2 个空格，遵循 `analysis_options.yaml` 中启用的 `flutter_lints`。
- **命名**：类型使用 `UpperCamelCase`，变量和函数使用 `lowerCamelCase`，私有标识符以 `_` 开头，文件名使用 `lowercase_with_underscores.dart`。
- **架构**：界面通过 Provider 访问 `ExpenseDatabase`；Drift 表结构和平台连接放在数据层。Web 连接与原生连接分别实现，业务读写逻辑共用。
- **注释**：仅为不直观的业务规则和设计意图添加简洁中文注释。

# 测试与验证规则

- 新功能或修复应添加或更新对应测试，重点覆盖记账数据读写、月度汇总和界面交互。
- 提交代码前运行 `flutter test` 与 `flutter analyze`。修改 Web 存储时还需构建 Web，并在浏览器中验证重开页面后数据仍在；修改移动端存储时检查 Android 和 iOS 的持久化行为。
- 环境或既有问题阻止验证时，明确记录命令和错误，不声称验证通过。

# 禁止操作（安全）

- 不把 `.env` 内容、认证凭据、密钥或其他秘密写入源代码、测试或文档。
- 未获明确指示，不删除或覆盖用户本地账目，不执行破坏性数据库迁移或影响生产环境的操作。旧版 Isar 数据不在本阶段迁移，也不主动清理其文件。
