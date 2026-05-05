import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/asha_screening_provider.dart';
import '../../providers/vision_provider.dart';
import '../../services/risk_engine.dart';
import '../../services/screening_storage_service.dart';
import '../../widgets/common/asmita_logo_mark.dart';

class AshaProcessingScreen extends ConsumerStatefulWidget {
  const AshaProcessingScreen({super.key});

  @override
  ConsumerState<AshaProcessingScreen> createState() =>
      _AshaProcessingScreenState();
}

class _AshaProcessingScreenState extends ConsumerState<AshaProcessingScreen> {
  final steps = [
    'Analysing neck skin...',
    'Analysing knuckles...',
    'Analysing facial features...',
    'Processing cycle data...',
    'Calculating risk score...',
    'Preparing report...',
  ];
  int done = 0;
  String? error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _process());
  }

  Future<void> _tick() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => done++);
  }

  Future<void> _process() async {
    final notifier = ref.read(ashaScreeningProvider.notifier);
    final state = ref.read(ashaScreeningProvider);
    try {
      notifier.setProcessing(true);
      final vision = ref.read(visionServiceProvider);
      await vision.loadModels();
      await _tick();
      final result = await vision.runScreening(
        neckImagePath: state.neckImagePath!,
        knuckleImagePath: state.knuckleImagePath!,
        faceImagePath: state.faceImagePath!,
      );
      notifier.applyVision(result);
      await _tick();
      await _tick();
      final updated = ref.read(ashaScreeningProvider);
      await _tick();
      final risk = RiskEngine().compute(
        anNeckScore: updated.anNeckScore,
        anKnuckle: updated.anKnuckle,
        anKnuckleConf: updated.anKnuckleConf,
        periorbital: updated.periorbital,
        periorbitalConf: updated.periorbitalConf,
        hirsutism: updated.hirsutism,
        hirsutismConf: updated.hirsutismConf,
        acneJawline: updated.acneJawline,
        menstrualScore: updated.menstrualScore,
        bmi: updated.bmi ?? 0,
        suddenOnset: updated.suddenOnset,
      );
      notifier.setResult(risk);
      await _tick();
      await ScreeningStorageService().saveScreening(
        risk,
        ref.read(ashaScreeningProvider),
      );
      for (final path in [
        state.neckImagePath,
        state.knuckleImagePath,
        state.faceImagePath
      ]) {
        if (path != null) {
          try {
            await File(path).delete();
          } catch (_) {}
        }
      }
      await _tick();
      if (mounted) context.go('/asha/result');
    } catch (e) {
      notifier.setError('$e');
      if (mounted) setState(() => error = '$e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6B21A8), Color(0xFFDB2777)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AsmitaLogoMark(size: 96),
                  const SizedBox(height: 20),
                  if (error != null)
                    Text(error!, style: const TextStyle(color: Colors.white))
                  else
                    for (var i = 0; i < steps.length; i++)
                      ListTile(
                        leading: Icon(
                          i < done
                              ? Icons.check_circle
                              : Icons.hourglass_bottom,
                          color: Colors.white,
                        ),
                        title: Text(
                          steps[i],
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
