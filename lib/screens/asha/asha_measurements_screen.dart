import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/asha_screening_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/common/asmita_button.dart';
import '../../widgets/common/asmita_card.dart';
import '../../widgets/common/gradient_background.dart';

class AshaMeasurementsScreen extends ConsumerStatefulWidget {
  const AshaMeasurementsScreen({super.key});

  @override
  ConsumerState<AshaMeasurementsScreen> createState() =>
      _AshaMeasurementsScreenState();
}

class _AshaMeasurementsScreenState
    extends ConsumerState<AshaMeasurementsScreen> {
  final formKey = GlobalKey<FormState>();
  final name = TextEditingController();
  final age = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  bool sudden = false;

  double? get bmi {
    final h = double.tryParse(height.text);
    final w = double.tryParse(weight.text);
    if (h == null || w == null || h <= 0) return null;
    final m = h / 100;
    return w / (m * m);
  }

  @override
  Widget build(BuildContext context) {
    final value = bmi;
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Form(
            key: formKey,
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                AppBar(title: const Text('Height & Weight')),
                const Text('Used to calculate BMI and adjust screening'),
                const SizedBox(height: 18),
                TextFormField(
                  controller: name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Name or initials (optional)',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: age,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age (optional)',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) return null;
                    final n = int.tryParse(value!.trim());
                    if (n == null || n < 8 || n > 25) {
                      return 'Enter age 8-25 or leave blank';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _field('Height (cm)', height, 100, 220),
                const SizedBox(height: 12),
                _field('Weight (kg)', weight, 20, 150),
                const SizedBox(height: 18),
                AsmitaCard(
                  accent: _bmiColor(value),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BMI: ${value?.toStringAsFixed(1) ?? '--'}',
                          style: Theme.of(context).textTheme.titleLarge),
                      Text('Category: ${_bmiCategory(value)}'),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  value: sudden,
                  onChanged: (v) => setState(() => sudden = v),
                  title:
                      const Text('Did symptoms appear suddenly after puberty?'),
                  subtitle: const Text(
                      'Sudden post-pubertal onset adds weight to score'),
                ),
                const SizedBox(height: 20),
                AsmitaButton(
                  label: 'Continue',
                  icon: Icons.arrow_forward,
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      ref.read(ashaScreeningProvider.notifier).setMeasurements(
                            girlName: name.text,
                            ageYears: int.tryParse(age.text.trim()),
                            heightCm: double.parse(height.text),
                            weightKg: double.parse(weight.text),
                            suddenOnset: sudden,
                          );
                      context.go('/asha/menstrual');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    name.dispose();
    age.dispose();
    height.dispose();
    weight.dispose();
    super.dispose();
  }

  Widget _field(
    String label,
    TextEditingController controller,
    double min,
    double max,
  ) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(labelText: label),
      onChanged: (_) => setState(() {}),
      validator: (value) {
        final n = double.tryParse(value ?? '');
        if (n == null || n < min || n > max) return 'Enter $min–$max';
        return null;
      },
    );
  }

  String _bmiCategory(double? value) {
    if (value == null) return 'Enter height and weight';
    if (value < 18.5) return 'Underweight';
    if (value < 25) return 'Normal';
    if (value < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double? value) {
    if (value == null) return AppColors.primary;
    if (value < 18.5) return Colors.blue;
    if (value < 25) return AppColors.success;
    if (value < 30) return AppColors.accent;
    return AppColors.danger;
  }
}
