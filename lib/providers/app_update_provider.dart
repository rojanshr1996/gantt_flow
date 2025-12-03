import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gantt_mobile/services/remote_config_service.dart';

class AppUpdateProvider extends ChangeNotifier {
  final RemoteConfigService _remoteConfigService;
  final AppPackageInfo _packageInfo;

  bool _isUpdateRequired = false;
  bool _isAppUnderMaintenance = false;

  bool get isUpdateRequired => _isUpdateRequired;
  bool get isAppUnderMaintenance => _isAppUnderMaintenance;

  AppUpdateProvider(this._remoteConfigService, this._packageInfo);

  Future<void> checkForUpdate() async {
    try {
      _isAppUnderMaintenance = _remoteConfigService.getIsAppUnderMaintenance();

      if (_isAppUnderMaintenance) {
        notifyListeners();
        return;
      }

      final minVersions = _remoteConfigService.getAppMinimumVersion();
      final currentVersion = _packageInfo.version;

      String requiredVersion;
      if (Platform.isAndroid) {
        requiredVersion = minVersions.androidRequiredMinVersion;
      } else if (Platform.isIOS) {
        requiredVersion = minVersions.iosRequiredMinVersion;
      } else {
        _isUpdateRequired = false;
        notifyListeners();
        return;
      }

      _isUpdateRequired = _isVersionLower(currentVersion, requiredVersion);
      notifyListeners();
    } catch (e) {
      debugPrint('Error checking for update: $e');
      _isUpdateRequired = false;
      notifyListeners();
    }
  }

  bool _isVersionLower(String current, String required) {
    try {
      // Parse version strings like "1.0.0+1"
      final currentParts = current.split('+');
      final requiredParts = required.split('+');

      final currentVersion = currentParts[0].split('.').map(int.parse).toList();
      final requiredVersion =
          requiredParts[0].split('.').map(int.parse).toList();

      // Compare major, minor, patch
      for (int i = 0; i < 3; i++) {
        if (currentVersion[i] < requiredVersion[i]) return true;
        if (currentVersion[i] > requiredVersion[i]) return false;
      }

      // If versions are equal, compare build numbers
      if (currentParts.length > 1 && requiredParts.length > 1) {
        final currentBuild = int.parse(currentParts[1]);
        final requiredBuild = int.parse(requiredParts[1]);
        return currentBuild < requiredBuild;
      }

      return false;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }
}
