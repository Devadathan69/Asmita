import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class VisionResult {
  const VisionResult({
    required this.anNeckScore,
    required this.anKnuckle,
    required this.anKnuckleConf,
    required this.periorbital,
    required this.periorbitalConf,
    required this.hirsutism,
    required this.hirsutismConf,
    required this.acneJawline,
    required this.acneProbs,
  });

  final double anNeckScore;
  final bool anKnuckle;
  final double anKnuckleConf;
  final bool periorbital;
  final double periorbitalConf;
  final bool hirsutism;
  final double hirsutismConf;
  final bool acneJawline;
  final List<double> acneProbs;
}

class VisionService {
  Interpreter? _neck;
  Interpreter? _knuckle;
  Interpreter? _periorbital;
  Interpreter? _hirsutism;
  Interpreter? _acne;

  Future<void> loadModels() async {
    _neck ??=
        await Interpreter.fromAsset('assets/models/asmita_an_neck.tflite');
    _knuckle ??=
        await Interpreter.fromAsset('assets/models/asmita_an_knuckle.tflite');
    _periorbital ??=
        await Interpreter.fromAsset('assets/models/asmita_periorbital.tflite');
    _hirsutism ??=
        await Interpreter.fromAsset('assets/models/asmita_hirsutism.tflite');
    _acne ??= await Interpreter.fromAsset('assets/models/asmita_acne.tflite');
  }

  Future<VisionResult> runScreening({
    required String neckImagePath,
    required String knuckleImagePath,
    required String faceImagePath,
  }) async {
    await loadModels();
    final neck = img.decodeImage(await File(neckImagePath).readAsBytes())!;
    final knuckle =
        img.decodeImage(await File(knuckleImagePath).readAsBytes())!;
    final face = img.decodeImage(await File(faceImagePath).readAsBytes())!;

    final neckScore = checkNecklaceArtifact(neck)
        ? max(0.0, _runBinary(_neck!, _preprocess(neck)) - .18)
        : _runBinary(_neck!, _preprocess(neck));
    final knuckleConf = _runBinary(_knuckle!, _preprocess(knuckle));
    final periConf = _runBinary(_periorbital!, _preprocess(face));
    final hirsConf = _runBinary(_hirsutism!, _preprocess(face));
    final acne = _runMulticlass(_acne!, _preprocess(face), 3);
    return VisionResult(
      anNeckScore: neckScore,
      anKnuckle: knuckleConf > .5,
      anKnuckleConf: knuckleConf,
      periorbital: periConf > .5,
      periorbitalConf: periConf,
      hirsutism: hirsConf > .5,
      hirsutismConf: hirsConf,
      acneJawline: acne.length > 1 && acne[1] > .5,
      acneProbs: acne,
    );
  }

  Float32List _preprocess(img.Image image) {
    final resized = img.copyResize(image, width: 224, height: 224);
    final input = Float32List(1 * 224 * 224 * 3);
    var i = 0;
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final p = resized.getPixel(x, y);
        input[i++] = p.r / 255.0;
        input[i++] = p.g / 255.0;
        input[i++] = p.b / 255.0;
      }
    }
    return input;
  }

  double _runBinary(Interpreter interp, Float32List input) {
    final output = List.generate(1, (_) => List<double>.filled(1, 0));
    interp.run(input.reshape([1, 224, 224, 3]), output);
    return output.first.first.clamp(0.0, 1.0).toDouble();
  }

  List<double> _runMulticlass(Interpreter interp, Float32List input, int n) {
    final output = List.generate(1, (_) => List<double>.filled(n, 0));
    interp.run(input.reshape([1, 224, 224, 3]), output);
    final raw = output.first;
    final sum = raw.fold<double>(0, (total, value) => total + value);
    if (sum <= 0) return raw;
    return raw.map((value) => value / sum).toList();
  }

  bool checkNecklaceArtifact(img.Image neckImage) {
    final resized = img.copyResize(neckImage, width: 224, height: 224);
    var horizontalEdges = 0;
    for (var y = 70; y < 160; y++) {
      var rowVariance = 0.0;
      var previous = 0.0;
      for (var x = 20; x < 204; x++) {
        final p = resized.getPixel(x, y);
        final lum = (.299 * p.r) + (.587 * p.g) + (.114 * p.b);
        rowVariance += (lum - previous).abs();
        previous = lum;
      }
      if (rowVariance > 4200) horizontalEdges++;
    }
    return horizontalEdges > 18;
  }

  void dispose() {
    _neck?.close();
    _knuckle?.close();
    _periorbital?.close();
    _hirsutism?.close();
    _acne?.close();
    _neck = _knuckle = _periorbital = _hirsutism = _acne = null;
  }
}
