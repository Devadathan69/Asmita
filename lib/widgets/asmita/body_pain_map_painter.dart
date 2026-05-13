import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

enum BodyViewSide { front, back }

enum PainRegion {
  head('head', 'Head'),
  neck('neck', 'Neck'),
  shoulders('shoulders', 'Shoulders'),
  chest('chest', 'Chest'),
  upperAbdomen('upper abdomen', 'Upper abdomen'),
  lowerAbdomen('lower abdomen', 'Lower abdomen'),
  upperBack('upper back', 'Upper back'),
  middleBack('middle back', 'Middle back'),
  lowerBack('lower back', 'Lower back'),
  leftArm('left arm', 'Left arm'),
  rightArm('right arm', 'Right arm'),
  leftThigh('left thigh', 'Left thigh'),
  rightThigh('right thigh', 'Right thigh'),
  leftLowerLeg('left lower leg', 'Left lower leg'),
  rightLowerLeg('right lower leg', 'Right lower leg'),
  hips('hips', 'Hips');

  const PainRegion(this.key, this.label);

  final String key;
  final String label;
  String get labelKey => 'pain_region_${key.replaceAll(' ', '_')}';

  static List<PainRegion> valuesFor(BodyViewSide side) {
    return switch (side) {
      BodyViewSide.front => const [
          PainRegion.head,
          PainRegion.neck,
          PainRegion.shoulders,
          PainRegion.chest,
          PainRegion.upperAbdomen,
          PainRegion.lowerAbdomen,
          PainRegion.leftArm,
          PainRegion.rightArm,
          PainRegion.leftThigh,
          PainRegion.rightThigh,
          PainRegion.leftLowerLeg,
          PainRegion.rightLowerLeg,
        ],
      BodyViewSide.back => const [
          PainRegion.head,
          PainRegion.neck,
          PainRegion.shoulders,
          PainRegion.upperBack,
          PainRegion.middleBack,
          PainRegion.lowerBack,
          PainRegion.leftArm,
          PainRegion.rightArm,
          PainRegion.hips,
          PainRegion.leftThigh,
          PainRegion.rightThigh,
          PainRegion.leftLowerLeg,
          PainRegion.rightLowerLeg,
        ],
    };
  }

  static PainRegion? fromKey(String key) {
    for (final region in values) {
      if (region.key == key) return region;
    }
    return null;
  }
}

class BodyPainMapLayout {
  const BodyPainMapLayout._();

  static Rect regionRect(PainRegion region, BodyViewSide side, Size size) {
    final specs = _specs(side)[region]!;
    return Rect.fromLTWH(
      specs.left * size.width,
      specs.top * size.height,
      specs.width * size.width,
      specs.height * size.height,
    );
  }

  static Map<PainRegion, _RegionSpec> _specs(BodyViewSide side) {
    return switch (side) {
      BodyViewSide.front => _frontSpecs,
      BodyViewSide.back => _backSpecs,
    };
  }

  static const _frontSpecs = <PainRegion, _RegionSpec>{
    PainRegion.head: _RegionSpec(.39, .015, .22, .145),
    PainRegion.neck: _RegionSpec(.455, .15, .09, .06),
    PainRegion.shoulders: _RegionSpec(.235, .2, .53, .075),
    PainRegion.chest: _RegionSpec(.345, .27, .31, .16),
    PainRegion.upperAbdomen: _RegionSpec(.36, .43, .28, .145),
    PainRegion.lowerAbdomen: _RegionSpec(.335, .57, .33, .12),
    PainRegion.leftArm: _RegionSpec(.205, .275, .105, .31),
    PainRegion.rightArm: _RegionSpec(.69, .275, .105, .31),
    PainRegion.leftThigh: _RegionSpec(.355, .695, .13, .18),
    PainRegion.rightThigh: _RegionSpec(.515, .695, .13, .18),
    PainRegion.leftLowerLeg: _RegionSpec(.36, .875, .115, .12),
    PainRegion.rightLowerLeg: _RegionSpec(.525, .875, .115, .12),
  };

  static const _backSpecs = <PainRegion, _RegionSpec>{
    PainRegion.head: _RegionSpec(.39, .015, .22, .145),
    PainRegion.neck: _RegionSpec(.455, .15, .09, .06),
    PainRegion.shoulders: _RegionSpec(.235, .2, .53, .075),
    PainRegion.upperBack: _RegionSpec(.335, .275, .33, .14),
    PainRegion.middleBack: _RegionSpec(.35, .415, .30, .13),
    PainRegion.lowerBack: _RegionSpec(.345, .545, .31, .13),
    PainRegion.leftArm: _RegionSpec(.205, .275, .105, .31),
    PainRegion.rightArm: _RegionSpec(.69, .275, .105, .31),
    PainRegion.hips: _RegionSpec(.325, .665, .35, .10),
    PainRegion.leftThigh: _RegionSpec(.355, .765, .13, .14),
    PainRegion.rightThigh: _RegionSpec(.515, .765, .13, .14),
    PainRegion.leftLowerLeg: _RegionSpec(.36, .9, .115, .095),
    PainRegion.rightLowerLeg: _RegionSpec(.525, .9, .115, .095),
  };
}

class _RegionSpec {
  const _RegionSpec(this.left, this.top, this.width, this.height);

  final double left;
  final double top;
  final double width;
  final double height;
}

class BodyPainMapPainter extends CustomPainter {
  const BodyPainMapPainter({
    required this.side,
    required this.selectedRegions,
    required this.isDark,
  });

  final BodyViewSide side;
  final Set<String> selectedRegions;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final baseFill = isDark
        ? AppColors.primaryPale.withOpacity(.07)
        : AppColors.primary.withOpacity(.045);
    final baseStroke = isDark
        ? AppColors.darkTextSecondary.withOpacity(.74)
        : AppColors.textSecondary.withOpacity(.48);
    final selectedFill = AppColors.coral.withOpacity(isDark ? .46 : .32);
    final selectedStroke = AppColors.secondary.withOpacity(isDark ? .9 : .72);

    final shadowPaint = Paint()
      ..color = AppColors.primary.withOpacity(isDark ? .1 : .06)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    final silhouette = _silhouettePath(size);
    canvas.drawPath(silhouette.shift(const Offset(0, 4)), shadowPaint);

    for (final region in PainRegion.valuesFor(side)) {
      final rect = BodyPainMapLayout.regionRect(region, side, size);
      final selected = selectedRegions.contains(region.key);
      final path = _regionPath(region, rect);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = selected ? selectedFill : baseFill,
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? 2.8 : 1.8
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = selected ? selectedStroke : baseStroke,
      );
    }
  }

  Path _silhouettePath(Size size) {
    final path = Path();
    for (final region in PainRegion.valuesFor(side)) {
      path.addPath(
        _regionPath(region, BodyPainMapLayout.regionRect(region, side, size)),
        Offset.zero,
      );
    }
    return path;
  }

  Path _regionPath(PainRegion region, Rect rect) {
    final path = Path();
    switch (region) {
      case PainRegion.head:
        path.addOval(rect);
        break;
      case PainRegion.shoulders:
        path.addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.height * .55)),
        );
        break;
      case PainRegion.leftArm:
      case PainRegion.rightArm:
      case PainRegion.leftLowerLeg:
      case PainRegion.rightLowerLeg:
        path.addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.width * .55)),
        );
        break;
      case PainRegion.leftThigh:
      case PainRegion.rightThigh:
        path.addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.width * .42)),
        );
        break;
      case PainRegion.neck:
      case PainRegion.chest:
      case PainRegion.upperAbdomen:
      case PainRegion.lowerAbdomen:
      case PainRegion.upperBack:
      case PainRegion.middleBack:
      case PainRegion.lowerBack:
      case PainRegion.hips:
        path.addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(rect.width * .28)),
        );
        break;
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant BodyPainMapPainter oldDelegate) =>
      oldDelegate.side != side ||
      oldDelegate.selectedRegions != selectedRegions ||
      oldDelegate.isDark != isDark;
}
