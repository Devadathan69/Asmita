class RegularityResult {
  const RegularityResult({
    required this.score,
    required this.isWorthDiscussing,
    required this.variability,
  });
  final int score;
  final bool isWorthDiscussing;
  final double variability;
}

class IrregularityDetector {
  static RegularityResult analyze(List<int> cycleLengths) {
    if (cycleLengths.length < 3) {
      return const RegularityResult(
        score: 80,
        isWorthDiscussing: false,
        variability: 0,
      );
    }
    final recent = cycleLengths.length > 6
        ? cycleLengths.sublist(cycleLengths.length - 6)
        : cycleLengths;
    final mean = recent.reduce((a, b) => a + b) / recent.length;
    final variance =
        recent.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) /
            recent.length;
    final sd = variance.sqrt();
    final outOfRange = recent.where((v) => v < 21 || v > 45).length;
    final score = (100 - (sd * 6) - (outOfRange * 12)).round().clamp(0, 100);
    return RegularityResult(
      score: score,
      isWorthDiscussing: score < 40 && recent.length >= 3,
      variability: sd,
    );
  }
}

extension on double {
  double sqrt() {
    if (this <= 0) return 0;
    var x = this;
    for (var i = 0; i < 12; i++) {
      x = 0.5 * (x + this / x);
    }
    return x;
  }
}
