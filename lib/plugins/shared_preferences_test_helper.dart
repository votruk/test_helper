import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import 'path_platform_fake.dart';

class SharedPreferencesTestHelper {
  late SharedPreferencesStorePlatform store;
  late InMemorySharedPreferencesStore testData;
  late PathProviderPlatform pathProvider;

  /// Should be called inside setUp method before tests started
  /// Don't forget to call TestWidgetsFlutterBinding.ensureInitialized();
  void setUp() {
    pathProvider = createPlatformDependantFakePathProvider();
    testData = InMemorySharedPreferencesStore.empty();

    PathProviderPlatform.instance = pathProvider;

    const MethodChannel('plugins.flutter.io/shared_preferences_macos')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getAll') {
        return await testData.getAll();
      }
      if (methodCall.method == 'remove') {
        final String key = (methodCall.arguments['key'] as String?)!;
        return await testData.remove(key);
      }
      if (methodCall.method == 'clear') {
        return await testData.clear();
      }
      final RegExp setterRegExp = RegExp(r'set(.*)');
      final Match? match = setterRegExp.matchAsPrefix(methodCall.method);
      if (match?.groupCount == 1) {
        final String valueType = match!.group(1)!;
        final String key = (methodCall.arguments['key'] as String?)!;
        final Object value = (methodCall.arguments['value'] as Object?)!;
        return await testData.setValue(valueType, key, value);
      }
      fail('Unexpected method call: ${methodCall.method}');
    });
  }

  void tearDown() {
    store.clear();
  }

  SharedPreferencesStorePlatform createStore() {
    store = SharedPreferencesStorePlatform.instance;
    return store;
  }

  Future<String> getFilePath() async {
    final String? directory = await pathProvider.getApplicationSupportPath();
    return path.join(directory!, 'shared_preferences.json');
  }

  Future<void> writeTestFile(String value) async {
    File(await getFilePath())
      ..createSync(recursive: true)
      ..writeAsStringSync(value);
  }

  Future<String> readTestFile() async {
    return File(await getFilePath()).readAsStringSync();
  }

  static String prefixedKey(String key) {
    return 'flutter.$key';
  }
}
