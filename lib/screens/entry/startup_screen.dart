import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../db/database_helper.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_logo_mark.dart';
import '../../widgets/common/gradient_background.dart';

class StartupScreen extends StatefulWidget {
  const StartupScreen({super.key});

  @override
  State<StartupScreen> createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen> {
  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final profile = await DatabaseHelper.instance.getProfile();
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    context.go(profile == null ? '/mode' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GradientBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AsmitaLogoMark(size: 118, heroTag: 'asmita-logo'),
              SizedBox(height: 20),
              Text(
                'Asmita',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 18),
              CircularProgressIndicator(color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}
