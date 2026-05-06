import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../providers/asha_screening_provider.dart';
import '../../widgets/common/asmita_button.dart';
import 'widgets/capture_guide_overlay.dart';

class AshaCameraScreen extends ConsumerStatefulWidget {
  const AshaCameraScreen({super.key, required this.step});

  final String step;

  @override
  ConsumerState<AshaCameraScreen> createState() => _AshaCameraScreenState();
}

class _AshaCameraScreenState extends ConsumerState<AshaCameraScreen> {
  CameraController? controller;
  String? capturedPath;
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant AshaCameraScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step != widget.step) {
      setState(() => capturedPath = null);
    }
  }

  Future<void> _setup() async {
    final permission = await Permission.camera.request();
    if (!permission.isGranted) {
      setState(() {
        error = 'Camera permission is needed for screening photos.';
        loading = false;
      });
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      setState(() {
        error = 'No camera available on this device.';
        loading = false;
      });
      return;
    }
    controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await controller!.initialize();
    if (mounted) setState(() => loading = false);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final step = widget.step;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: error != null
            ? _ErrorState(message: error!, onBack: () => context.pop())
            : loading || controller == null
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      Positioned.fill(
                        child: capturedPath == null
                            ? CameraPreview(controller!)
                            : Image.file(File(capturedPath!),
                                fit: BoxFit.cover),
                      ),
                      Positioned.fill(child: CaptureGuideOverlay(step: step)),
                      Positioned(
                        top: 8,
                        left: 8,
                        right: 8,
                        child: Row(
                          children: [
                            IconButton.filledTonal(
                              onPressed: () => _previous(context),
                              icon: const Icon(Icons.arrow_back),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              '${_stepNumber(step)} of 3 - ${_title(step)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(26),
                            ),
                          ),
                          child: capturedPath == null
                              ? Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _StepHint(step: step),
                                    const SizedBox(height: 14),
                                    GestureDetector(
                                      onTap: _capture,
                                      child: Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white70,
                                            width: 6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () =>
                                            setState(() => capturedPath = null),
                                        child: const Text('Retake'),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: AsmitaButton(
                                        label: 'Use this photo',
                                        icon: Icons.check,
                                        onPressed: _usePhoto,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Future<void> _capture() async {
    final file = await controller!.takePicture();
    final dir = await getTemporaryDirectory();
    final target = File(
      '${dir.path}/asmita_${widget.step}_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    await File(file.path).copy(target.path);
    setState(() => capturedPath = target.path);
  }

  void _usePhoto() {
    ref
        .read(ashaScreeningProvider.notifier)
        .setPhoto(widget.step, capturedPath!);
    context.go(switch (widget.step) {
      'neck' => '/asha/camera/knuckle',
      'knuckle' => '/asha/camera/face',
      _ => '/asha/measurements',
    });
  }

  void _previous(BuildContext context) {
    context.go(switch (widget.step) {
      'knuckle' => '/asha/camera/neck',
      'face' => '/asha/camera/knuckle',
      _ => '/asha/instructions',
    });
  }

  int _stepNumber(String step) => switch (step) {
        'neck' => 1,
        'knuckle' => 2,
        _ => 3,
      };

  String _title(String step) => switch (step) {
        'neck' => 'Neck Photo',
        'knuckle' => 'Knuckle Photo',
        _ => 'Face Photo',
      };
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onBack});
  final String message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: Colors.white, size: 48),
            const SizedBox(height: 12),
            Text(message, style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 20),
            AsmitaButton(label: 'Go Back', onPressed: onBack),
          ],
        ),
      ),
    );
  }
}

class _StepHint extends StatelessWidget {
  const _StepHint({required this.step});
  final String step;

  @override
  Widget build(BuildContext context) {
    final icon = switch (step) {
      'neck' => Icons.accessibility_new_rounded,
      'knuckle' => Icons.back_hand_rounded,
      _ => Icons.face_rounded,
    };
    final text = switch (step) {
      'neck' => 'Remove necklace. Keep the neck centered.',
      'knuckle' => 'Relax fingers. Keep knuckles inside the frame.',
      _ => 'Use daylight. Keep the face centered.',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
