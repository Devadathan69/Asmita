import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
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

  final Stream<double> Function() onDownload;
  final VoidCallback onComplete;

  @override
  State<ModelLoadingIndicator> createState() => _ModelLoadingIndicatorState();
}

class _ModelLoadingIndicatorState extends State<ModelLoadingIndicator> {
  double progress = 0;
  bool downloading = false;
  bool success = false;
  String? error;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: GradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: AsmitaLogoMark(size: 104)),
                  const SizedBox(height: 18),
                  const Center(
                    child: PrivacyBadge(
                      label: 'One-time setup',
                      internet: true,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    success
                        ? 'Sakhi is ready'
                        : 'Setting up Sakhi for the first time',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    success
                        ? 'Model loaded successfully. Sakhi will now run privately on this device.'
                        : 'Downloads Sakhi\'s on-device chat model once. After setup, Sakhi works offline for chat.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 26),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: downloading || success ? progress : 0,
                      minHeight: 14,
                      backgroundColor: AppColors.primaryPale,
                      color: success ? AppColors.success : AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    success ? '100% complete' : '${(progress * 100).round()}%',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
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
                  else
                    AsmitaButton(
                      label: downloading ? 'Setting up...' : 'Set up Sakhi',
                      icon: Icons.auto_awesome_rounded,
                      onPressed: downloading ? null : _download,
                    ),
                ],
              ).animate().fadeIn(duration: 420.ms).slideY(begin: .04),
            ),
          ),
        ),
      );

  Future<void> _download() async {
    setState(() {
      downloading = true;
      error = null;
      progress = 0;
    });
    try {
      await for (final value in widget.onDownload()) {
        if (!mounted) return;
        setState(() => progress = value);
      }
      if (!mounted) return;
      setState(() {
        progress = 1;
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
}
