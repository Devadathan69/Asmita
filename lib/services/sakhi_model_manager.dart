import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network_privacy_service.dart';

enum SakhiModelTier {
  light,
  better,
}

class SakhiModelInfo {
  const SakhiModelInfo({
    required this.tier,
    required this.displayName,
    required this.fileName,
    required this.downloadUrl,
    required this.approximateSizeMb,
    required this.minRamGb,
  });

  final SakhiModelTier tier;
  final String displayName;
  final String fileName;
  final String downloadUrl;
  final int approximateSizeMb;
  final int minRamGb;

  String get subtitle => switch (tier) {
        SakhiModelTier.light => 'Best for most phones',
        SakhiModelTier.better => 'Better replies, needs a newer phone',
      };
}

class SakhiDownloadProgress {
  const SakhiDownloadProgress({
    required this.progress,
    required this.downloadedMb,
    required this.totalMb,
    required this.status,
  });

  final double progress;
  final double downloadedMb;
  final double? totalMb;
  final String status;
}

class SakhiModelManager {
  SakhiModelManager({
    NetworkPrivacyService network = const NetworkPrivacyService(),
  }) : _network = network;

  static const qwenLightUrl = 'PASTE_QWEN_0_5B_Q4_GGUF_DIRECT_URL_HERE';
  static const qwenBetterUrl = 'PASTE_QWEN_1_5B_Q4_GGUF_DIRECT_URL_HERE';

  static const _selectedModelPathKey = 'sakhi_selected_model_path';
  static const _selectedModelTierKey = 'sakhi_selected_model_tier';
  static const minimumUsableModelMb = 100;

  final NetworkPrivacyService _network;

  static const models = [
    SakhiModelInfo(
      tier: SakhiModelTier.light,
      displayName: 'Light Offline AI',
      fileName: 'qwen2_5_0_5b_instruct_q4.gguf',
      downloadUrl: qwenLightUrl,
      approximateSizeMb: 420,
      minRamGb: 3,
    ),
    SakhiModelInfo(
      tier: SakhiModelTier.better,
      displayName: 'Better Offline AI',
      fileName: 'qwen2_5_1_5b_instruct_q4.gguf',
      downloadUrl: qwenBetterUrl,
      approximateSizeMb: 1100,
      minRamGb: 6,
    ),
  ];

  SakhiModelInfo infoForTier(SakhiModelTier tier) {
    return models.firstWhere((model) => model.tier == tier);
  }

  Future<Directory> modelDirectory() async {
    final documents = await getApplicationDocumentsDirectory();
    final dir = Directory('${documents.path}/models/sakhi');
    await dir.create(recursive: true);
    return dir;
  }

  Future<File> modelFileFor(SakhiModelTier tier) async {
    final dir = await modelDirectory();
    return File('${dir.path}/${infoForTier(tier).fileName}');
  }

  Future<File?> selectedModelFile() async {
    final prefs = await SharedPreferences.getInstance();
    final selectedPath = prefs.getString(_selectedModelPathKey);
    if (selectedPath != null) {
      final selected = File(selectedPath);
      if (await _isUsable(selected)) {
        await _logModel(selected, selectedPath);
        return selected;
      }
    }

    for (final info in models) {
      final file = await modelFileFor(info.tier);
      if (await _isUsable(file)) {
        await _saveSelection(info.tier, file.path);
        await _logModel(file, file.path);
        return file;
      }
    }
    _log('exists false');
    return null;
  }

  Future<SakhiModelInfo?> selectedModelInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final tierName = prefs.getString(_selectedModelTierKey);
    if (tierName == null) return null;
    for (final info in models) {
      if (info.tier.name == tierName) return info;
    }
    return null;
  }

  Future<bool> hasUsableModel() async => await selectedModelFile() != null;

  Future<void> selectModel(SakhiModelTier tier) async {
    final file = await modelFileFor(tier);
    if (!await _isUsable(file)) {
      throw const SakhiModelException(
        "Sakhi's offline AI model is not downloaded yet. Please download it first.",
      );
    }
    await _saveSelection(tier, file.path);
  }

  Future<void> downloadModel(
    SakhiModelTier tier, {
    required void Function(SakhiDownloadProgress progress) onProgress,
    bool Function()? shouldCancel,
  }) async {
    final info = infoForTier(tier);
    if (!_isConfiguredUrl(info.downloadUrl)) {
      throw const SakhiModelException(
        'Offline model download link is not configured yet.',
      );
    }

    final destination = await modelFileFor(tier);
    final temp = File('${destination.path}.download');
    if (await temp.exists()) await temp.delete();

    onProgress(SakhiDownloadProgress(
      progress: 0,
      downloadedMb: 0,
      totalMb: info.approximateSizeMb.toDouble(),
      status: 'Starting download',
    ));

    try {
      await _network.downloadFile(
        info.downloadUrl,
        temp,
        shouldCancel: shouldCancel,
        onProgress: (progress) {
          onProgress(SakhiDownloadProgress(
            progress: progress,
            downloadedMb: info.approximateSizeMb * progress,
            totalMb: info.approximateSizeMb.toDouble(),
            status: 'Downloading',
          ));
        },
        onBytesProgress: (received, total) {
          final totalMb =
              total == null ? null : total / (1024 * 1024).toDouble();
          onProgress(SakhiDownloadProgress(
            progress: total == null || total <= 0
                ? 0
                : (received / total).clamp(0, 1).toDouble(),
            downloadedMb: received / (1024 * 1024).toDouble(),
            totalMb: totalMb,
            status: 'Downloading',
          ));
        },
      );
      if (shouldCancel?.call() == true) {
        throw const SakhiModelException('Download cancelled');
      }
      final sizeMb = await _sizeMb(temp);
      if (sizeMb < minimumUsableModelMb) {
        await temp.delete();
        throw const SakhiModelException(
          'Downloaded model file is too small. Please check the download link.',
        );
      }
      if (await destination.exists()) await destination.delete();
      await temp.rename(destination.path);
      await _saveSelection(tier, destination.path);
      await _logModel(destination, destination.path);
      onProgress(SakhiDownloadProgress(
        progress: 1,
        downloadedMb: sizeMb,
        totalMb: sizeMb,
        status: 'Ready',
      ));
    } catch (_) {
      if (await temp.exists()) await temp.delete();
      rethrow;
    }
  }

  Future<void> _saveSelection(SakhiModelTier tier, String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_selectedModelPathKey, path);
    await prefs.setString(_selectedModelTierKey, tier.name);
    _log('selected model ${infoForTier(tier).displayName}');
  }

  Future<bool> _isUsable(File file) async {
    if (!await file.exists()) return false;
    return await _sizeMb(file) >= minimumUsableModelMb;
  }

  Future<double> _sizeMb(File file) async {
    if (!await file.exists()) return 0;
    return await file.length() / (1024 * 1024).toDouble();
  }

  Future<void> _logModel(File file, String path) async {
    final exists = await file.exists();
    _log('model path $path');
    _log('exists $exists');
    if (exists)
      _log('file size MB ${(await _sizeMb(file)).toStringAsFixed(2)}');
  }

  bool _isConfiguredUrl(String url) {
    return url.startsWith('http') && !url.contains('PASTE_');
  }

  void _log(String message) {
    if (kDebugMode) debugPrint('[SakhiModel] $message');
  }
}

class SakhiModelException implements Exception {
  const SakhiModelException(this.message);
  final String message;

  @override
  String toString() => message;
}
