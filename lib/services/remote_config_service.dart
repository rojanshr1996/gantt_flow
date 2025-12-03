import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class MinAppVersionModel {
  final String iosRecommendedMinVersion;
  final String iosRequiredMinVersion;
  final String androidRecommendedMinVersion;
  final String androidRequiredMinVersion;

  const MinAppVersionModel({
    required this.iosRecommendedMinVersion,
    required this.iosRequiredMinVersion,
    required this.androidRecommendedMinVersion,
    required this.androidRequiredMinVersion,
  });

  factory MinAppVersionModel.fromJson(Map<String, dynamic> json) {
    return MinAppVersionModel(
      iosRecommendedMinVersion: json['iosRecommendedMinVersion'] ?? '1.0.0+1',
      iosRequiredMinVersion: json['iosRequiredMinVersion'] ?? '1.0.0+1',
      androidRecommendedMinVersion:
          json['androidRecommendedMinVersion'] ?? '1.0.0+1',
      androidRequiredMinVersion: json['androidRequiredMinVersion'] ?? '1.0.0+1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'iosRecommendedMinVersion': iosRecommendedMinVersion,
      'iosRequiredMinVersion': iosRequiredMinVersion,
      'androidRecommendedMinVersion': androidRecommendedMinVersion,
      'androidRequiredMinVersion': androidRequiredMinVersion,
    };
  }
}

class RemoteConfigService {
  final remoteConfig = FirebaseRemoteConfig.instance;

  static Future<void> initialize() async {
    final remoteConfig = FirebaseRemoteConfig.instance;

    try {
      const minAppVersion = MinAppVersionModel(
        iosRecommendedMinVersion: '1.0.0+1',
        iosRequiredMinVersion: '1.0.0+1',
        androidRecommendedMinVersion: '1.0.0+1',
        androidRequiredMinVersion: '1.0.0+1',
      );

      await remoteConfig.setDefaults({
        'isAppUnderMaintenance': false,
        'appMinimumVersion': json.encode(minAppVersion.toJson()),
      });

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Fetch the values from Firebase Remote Config
      await remoteConfig.fetchAndActivate();

      // Optional: listen for and activate changes to the Firebase Remote Config values
      remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();
      });
    } catch (e) {
      debugPrint('Remote config exception: $e');
    }
  }

  bool getIsAppUnderMaintenance() {
    return remoteConfig.getBool('isAppUnderMaintenance');
  }

  MinAppVersionModel getAppMinimumVersion() {
    final appMinVersion = remoteConfig.getString('appMinimumVersion');
    try {
      return MinAppVersionModel.fromJson(json.decode(appMinVersion));
    } catch (e) {
      debugPrint('Error parsing app minimum version: $e');
      return const MinAppVersionModel(
        iosRecommendedMinVersion: '1.0.0+1',
        iosRequiredMinVersion: '1.0.0+1',
        androidRecommendedMinVersion: '1.0.0+1',
        androidRequiredMinVersion: '1.0.0+1',
      );
    }
  }
}

class AppPackageInfo {
  String version = '1.0.0+1';
  String versionWithoutBuild = '1.0.0';

  Future<void> initialize() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      version = '${packageInfo.version}+${packageInfo.buildNumber}';
      versionWithoutBuild = packageInfo.version;
    } catch (e) {
      debugPrint('Package info exception: $e');
    }
  }
}
