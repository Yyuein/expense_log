# expense_log

Flutter 个人记账应用：记录、编辑、删除支出，并查看每月汇总和柱状图。

## 运行

项目使用 Dart 3.6 / Flutter 3.27，支持 Web、Android 和 iOS。每个平台分别在本地保存账目，目前没有跨设备同步。

```sh
flutter pub get
dart run build_runner build
flutter run -d chrome
```

Android 可使用 `flutter run -d <设备 ID>`，iOS 需要在 macOS 上使用 Xcode 和 Flutter 运行。运行 `flutter devices` 可查看设备 ID。

Web 端依赖仓库中的 `web/sqlite3.wasm` 和 `web/drift_worker.dart.js`。发布时需保留这两个文件，并确保服务器以 `application/wasm` 响应 WASM 文件。浏览器存储不可用或无法可靠支持多标签写入时，应用会显示错误，避免把临时账目误认为已保存。

## 验证

```sh
flutter test
flutter analyze
flutter build web
flutter build apk --debug
```

旧版 Isar 账目不会自动迁移到新版 SQLite 数据库；升级过程不会主动删除原有 Isar 文件。
 
