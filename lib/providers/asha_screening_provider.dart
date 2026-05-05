import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/risk_engine.dart';
import '../services/vision_service.dart';

enum ScreeningStep {
  idle,
  neckCapture,
  knuckleCapture,
  faceCapture,
  measurements,
  menstrual,
  processing,
  result,
}

class ScreeningState {
  const ScreeningState({
    this.neckImagePath,
    this.knuckleImagePath,
    this.faceImagePath,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.menstrualText = '',
    this.menstrualScore = 0,
    this.menstrualFeatures = const MenstrualFeatures(),
    this.anNeckScore = 0,
    this.anKnuckle = false,
    this.anKnuckleConf = 0,
    this.periorbital = false,
    this.periorbitalConf = 0,
    this.hirsutism = false,
    this.hirsutismConf = 0,
    this.acneJawline = false,
    this.acneProbs = const [0, 0, 0],
    this.result,
    this.currentStep = ScreeningStep.idle,
    this.isProcessing = false,
    this.errorMessage,
    this.suddenOnset = false,
  });

  final String? neckImagePath;
  final String? knuckleImagePath;
  final String? faceImagePath;
  final double? heightCm;
  final double? weightKg;
  final double? bmi;
  final String menstrualText;
  final int menstrualScore;
  final MenstrualFeatures menstrualFeatures;
  final double anNeckScore;
  final bool anKnuckle;
  final double anKnuckleConf;
  final bool periorbital;
  final double periorbitalConf;
  final bool hirsutism;
  final double hirsutismConf;
  final bool acneJawline;
  final List<double> acneProbs;
  final RiskResult? result;
  final ScreeningStep currentStep;
  final bool isProcessing;
  final String? errorMessage;
  final bool suddenOnset;

  ScreeningState copyWith({
    String? neckImagePath,
    String? knuckleImagePath,
    String? faceImagePath,
    double? heightCm,
    double? weightKg,
    double? bmi,
    String? menstrualText,
    int? menstrualScore,
    MenstrualFeatures? menstrualFeatures,
    double? anNeckScore,
    bool? anKnuckle,
    double? anKnuckleConf,
    bool? periorbital,
    double? periorbitalConf,
    bool? hirsutism,
    double? hirsutismConf,
    bool? acneJawline,
    List<double>? acneProbs,
    RiskResult? result,
    ScreeningStep? currentStep,
    bool? isProcessing,
    String? errorMessage,
    bool? suddenOnset,
  }) {
    return ScreeningState(
      neckImagePath: neckImagePath ?? this.neckImagePath,
      knuckleImagePath: knuckleImagePath ?? this.knuckleImagePath,
      faceImagePath: faceImagePath ?? this.faceImagePath,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      menstrualText: menstrualText ?? this.menstrualText,
      menstrualScore: menstrualScore ?? this.menstrualScore,
      menstrualFeatures: menstrualFeatures ?? this.menstrualFeatures,
      anNeckScore: anNeckScore ?? this.anNeckScore,
      anKnuckle: anKnuckle ?? this.anKnuckle,
      anKnuckleConf: anKnuckleConf ?? this.anKnuckleConf,
      periorbital: periorbital ?? this.periorbital,
      periorbitalConf: periorbitalConf ?? this.periorbitalConf,
      hirsutism: hirsutism ?? this.hirsutism,
      hirsutismConf: hirsutismConf ?? this.hirsutismConf,
      acneJawline: acneJawline ?? this.acneJawline,
      acneProbs: acneProbs ?? this.acneProbs,
      result: result ?? this.result,
      currentStep: currentStep ?? this.currentStep,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage,
      suddenOnset: suddenOnset ?? this.suddenOnset,
    );
  }
}

final ashaScreeningProvider =
    StateNotifierProvider<AshaScreeningNotifier, ScreeningState>(
  AshaScreeningNotifier.new,
);

class AshaScreeningNotifier extends StateNotifier<ScreeningState> {
  AshaScreeningNotifier(this.ref) : super(const ScreeningState());

  final Ref ref;

  void setPhoto(String step, String path) {
    state = switch (step) {
      'neck' => state.copyWith(
          neckImagePath: path,
          currentStep: ScreeningStep.knuckleCapture,
        ),
      'knuckle' => state.copyWith(
          knuckleImagePath: path,
          currentStep: ScreeningStep.faceCapture,
        ),
      _ => state.copyWith(
          faceImagePath: path,
          currentStep: ScreeningStep.measurements,
        ),
    };
  }

  void setMeasurements({
    required double heightCm,
    required double weightKg,
    required bool suddenOnset,
  }) {
    final meters = heightCm / 100;
    state = state.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: weightKg / (meters * meters),
      suddenOnset: suddenOnset,
      currentStep: ScreeningStep.menstrual,
    );
  }

  void setMenstrual(String text) {
    final score = MenstrualScorer().analyze(text);
    state = state.copyWith(
      menstrualText: text,
      menstrualScore: score.score,
      menstrualFeatures: score.features,
    );
  }

  void applyVision(VisionResult result) {
    state = state.copyWith(
      anNeckScore: result.anNeckScore,
      anKnuckle: result.anKnuckle,
      anKnuckleConf: result.anKnuckleConf,
      periorbital: result.periorbital,
      periorbitalConf: result.periorbitalConf,
      hirsutism: result.hirsutism,
      hirsutismConf: result.hirsutismConf,
      acneJawline: result.acneJawline,
      acneProbs: result.acneProbs,
    );
  }

  void setResult(RiskResult result) {
    state = state.copyWith(
      result: result,
      currentStep: ScreeningStep.result,
      isProcessing: false,
    );
  }

  void setProcessing(bool value) {
    state = state.copyWith(
      isProcessing: value,
      currentStep: value ? ScreeningStep.processing : state.currentStep,
    );
  }

  void setError(String? message) {
    state = state.copyWith(errorMessage: message, isProcessing: false);
  }

  void reset() => state = const ScreeningState();
}
