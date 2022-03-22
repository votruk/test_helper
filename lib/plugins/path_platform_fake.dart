import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_linux/path_provider_linux.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:path_provider_windows/path_provider_windows.dart';

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

PathProviderPlatform createPlatformDependantFakePathProvider() {
  if (Platform.isMacOS) {
    return FakePathProviderPlatform();
  } else if (Platform.isWindows) {
    return FakePathProviderWindows();
  } else if (Platform.isLinux) {
    return FakePathProviderLinux();
  }
  throw Exception(
      "Tests not supposed to run on OSes other than Windows, MacOS and Linux");
}

class FakePathProviderPlatform extends PathProviderPlatform
    with FakePathProviderPlatformMixin {}

class FakePathProviderWindows extends PathProviderPlatform
    with FakePathProviderPlatformMixin
    implements PathProviderWindows {
  @override
  late VersionInfoQuerier versionInfoQuerier;

  @override
  Future<String?> getApplicationSupportPath() async => r'C:\appsupport';

  @override
  Future<String> getPath(String folderID) async => '';
}

class FakePathProviderLinux extends PathProviderPlatform
    with FakePathProviderPlatformMixin
    implements PathProviderLinux {
  @override
  Future<String?> getApplicationSupportPath() async => r'/appsupport';
}

mixin FakePathProviderPlatformMixin on PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kLibraryPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kDownloadsPath;
  }
}
