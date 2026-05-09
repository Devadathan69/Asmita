import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../services/sakhi_model_manager.dart';
import '../../../theme/app_colors.dart';
import '../../../widgets/common/asmita_button.dart';
import '../../../widgets/common/asmita_logo_mark.dart';
import '../../../widgets/common/gradient_background.dart';
import '../../../widgets/common/privacy_badge.dart';

class ModelLoadingIndicator extends StatefulWidget {
  const ModelLoadingIndicator({
    super.key,
    required this.onDownload,
    required this.onComplete,
  });

  final Future<void> Function(
    SakhiModelTier tier, {
    required void Function(SakhiDownloadProgress progress) onProgress,
    bool Function()? shouldCancel,
  }) onDownload;
  final VoidCallback onComplete;

  @override
  State<ModelLoadingIndicator> createState() => _ModelLoadingIndicatorState();
}

class _ModelLoadingIndicatorState extends State<ModelLoadingIndicator> {
  SakhiDownloadProgress? progress;
  SakhiModelTier? activeTier;
  bool downloading = false;
  bool success = false;
  bool cancelRequested = false;
  String? error;

  @override
  Widget build(BuildContext context) {
    final progressValue = progress?.progress ?? 0;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 26),
                const Center(child: AsmitaLogoMark(size: 104)),
                const SizedBox(height: 18),
                const Center(
                  child: PrivacyBadge(label: 'One-time setup', internet: true),
                ),
                const SizedBox(height: 22),
                Text(
                  success ? 'Sakhi is ready' : 'Download Sakhi Offline AI',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  success
                      ? 'Model loaded successfully. Sakhi will now run privately on this device.'
                      : 'Sakhi can chat offline after a one-time model download. Your conversations stay only on this phone.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                if (downloading || success) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: success ? 1 : progressValue,
                      minHeight: 14,
                      backgroundColor: AppColors.primaryPale,
                      color: success ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    success ? '100% complete' : _progressText(progress),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress?.status ?? 'Preparing',
                    textAlign: TextAlign.center,
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 14),
                  Text(
                    error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ],
                const SizedBox(height: 24),
                if (success)
                  AsmitaButton(
                    label: 'Start chatting',
                    icon: Icons.check_circle_rounded,
                    onPressed: widget.onComplete,
                  )
                else if (downloading)
                  OutlinedButton.icon(
                    onPressed: () => setState(() => cancelRequested = true),
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Cancel download'),
                  )
                else ...[
                  _ModelChoiceCard(
                    info: SakhiModelManager.models.firstWhere(
                        (model) => model.tier == SakhiModelTier.light),
                    onPressed: () => _download(SakhiModelTier.light),
                  ),
                  const SizedBox(height: 12),
                  _ModelChoiceCard(
                    info: SakhiModelManager.models.firstWhere(
                        (model) => model.tier == SakhiModelTier.better),
                    warning: 'Needs newer phone and more storage.',
                    onPressed: () => _download(SakhiModelTier.better),
                  ),
                ],
              ],
            ).animate().fadeIn(duration: 420.ms).slideY(begin: .04),
          ),
        ),
      ),
    );
  }

  Future<void> _download(SakhiModelTier tier) async {
    setState(() {
      downloading = true;
      success = false;
      cancelRequested = false;
      activeTier = tier;
      error = null;
      progress = null;
    });
    try {
      await widget.onDownload(
        tier,
        shouldCancel: () => cancelRequested,
        onProgress: (value) {
          if (!mounted) return;
          setState(() => progress = value);
        },
      );
      if (!mounted) return;
      setState(() {
        progress = const SakhiDownloadProgress(
          progress: 1,
          downloadedMb: 0,
          totalMb: null,
          status: 'Ready',
        );
        success = true;
        downloading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        downloading = false;
        error = '$e';
      });
    }
  }

  String _progressText(SakhiDownloadProgress? value) {
    if (value == null) return '0%';
    final percent = (value.progress * 100).round();
    final total = value.totalMb;
    if (total == null || total <= 0) {
      return '$percent% - ${value.downloadedMb.toStringAsFixed(1)} MB';
    }
    return '$percent% - ${value.downloadedMb.toStringAsFixed(1)} / ${total.toStringAsFixed(1)} MB';
  }
}

class _ModelChoiceCard extends StatelessWidget {
  const _ModelChoiceCard({
    required this.info,
    required this.onPressed,
    this.warning,
  });

  final SakhiModelInfo info;
  final VoidCallback onPressed;
  final String? warning;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: .94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primary.withValues(alpha: .14)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryPale,
                  foregroundColor: AppColors.primary,
                  child: Icon(
                    info.tier == SakhiModelTier.light
                        ? Icons.bolt_rounded
                        : Icons.auto_awesome_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        info.displayName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(info.subtitle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '~${info.approximateSizeMb} MB • ${info.minRamGb} GB RAM recommended',
            ),
            if (warning != null) ...[
              const SizedBox(height: 6),
              Text(
                warning!,
                style: const TextStyle(color: AppColors.warning),
              ),
            ],
            const SizedBox(height: 12),
            AsmitaButton(
              label: info.tier == SakhiModelTier.light
                  ? 'Download Light Model'
                  : 'Download Better Model',
              icon: Icons.download_rounded,
              onPressed: onPressed,
            ),
          ],
        ),
      ),
    );
  }
}
