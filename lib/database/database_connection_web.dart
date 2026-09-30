import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';

Future<QueryExecutor> openDatabase() async {
  final result = await WasmDatabase.open(
    databaseName: 'expense_log',
    sqlite3Uri: Uri.parse('sqlite3.wasm'),
    driftWorkerUri: Uri.parse('drift_worker.dart.js'),
  );

  // 这两种模式无法保证账目在关闭浏览器或同时打开多个标签后仍然安全。
  if (result.chosenImplementation == WasmStorageImplementation.inMemory ||
      result.chosenImplementation ==
          WasmStorageImplementation.unsafeIndexedDb) {
    await result.resolvedExecutor.close();
    throw UnsupportedError(
      '当前浏览器无法可靠保存账目。请使用普通浏览窗口并允许网站存储，或更换浏览器。',
    );
  }

  return result.resolvedExecutor;
}
