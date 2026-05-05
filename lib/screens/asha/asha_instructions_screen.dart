import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/gradient_background.dart';
import 'widgets/phase_instruction_card.dart';

class AshaInstructionsScreen extends ConsumerStatefulWidget {
  const AshaInstructionsScreen({super.key});

  @override
  ConsumerState<AshaInstructionsScreen> createState() =>
      _AshaInstructionsScreenState();
}

class _AshaInstructionsScreenState
    extends ConsumerState<AshaInstructionsScreen> {
  final controller = PageController();
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = _pages;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              AppBar(title: const Text('Screening Instructions')),
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: pages.length,
                  onPageChanged: (value) => setState(() => index = value),
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: pages[i],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: i == index ? 26 : 8,
                    height: 8,
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: i == index
                          ? AppColors.primary
                          : AppColors.navInactive,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: AsmitaButton(
                  label: index == pages.length - 1 ? 'Start Screening' : 'Next',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    if (index == pages.length - 1) {
                      context.go('/asha/camera/neck');
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> get _pages => const [
        PhaseInstructionCard(
          icon: Icons.camera_alt,
          title: 'Step 1 — Back of Neck Photo',
          color: AppColors.accent,
          instructions: [
            'Ask the girl to sit facing away from you',
            'Pull hair up or tie it back',
            'Remove any necklace',
            'Hold phone 20–30cm from neck',
            'Use natural daylight and avoid flash',
          ],
        ),
        PhaseInstructionCard(
          icon: Icons.back_hand,
          title: 'Step 2 — Knuckle Photo',
          color: AppColors.primaryLight,
          instructions: [
            'Ask the girl to make a loose fist',
            'Photograph the top of the fingers',
            'Use natural daylight',
            'No rings or bangles on knuckles',
          ],
        ),
        PhaseInstructionCard(
          icon: Icons.face_rounded,
          title: 'Step 3 — Face Photo',
          color: AppColors.secondary,
          instructions: [
            'Full face should be visible',
            'Natural daylight, no harsh shadows',
            'Neutral expression',
            'Remove glasses if worn',
          ],
        ),
        PhaseInstructionCard(
          icon: Icons.monitor_weight_outlined,
          title: 'Step 4 — Height & Weight',
          color: AppColors.success,
          instructions: [
            'Measure height with measuring tape',
            'Measure weight with weighing scale',
            'Record in centimetres and kilograms',
          ],
        ),
        PhaseInstructionCard(
          icon: Icons.question_answer_rounded,
          title: 'Step 5 — Cycle Questions',
          color: AppColors.luteal,
          instructions: [
            'Ask three simple questions',
            'Type her answer or use voice input',
            'Questions are in her local language',
            'No clinical terms needed',
          ],
        ),
      ];
}
