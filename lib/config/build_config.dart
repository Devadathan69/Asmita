class BuildConfig {
  const BuildConfig._();

  static const String appMode = String.fromEnvironment(
    'APP_MODE',
    defaultValue: 'public',
  );

  static bool get isPublic => appMode == 'public';
  static bool get isHackathon => appMode == 'hackathon';
  static bool get isAshaPilot => appMode == 'asha_pilot';

  static bool get showAshaMode => isHackathon || isAshaPilot;
  static bool get showWellnessCheck => isPublic || isHackathon;
  static bool get enableReferralLetter => isHackathon || isAshaPilot;
  static bool get showClinicalRiskScore => isHackathon || isAshaPilot;
}
