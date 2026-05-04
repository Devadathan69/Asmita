import 'package:flutter/material.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class AsmitaApp extends StatelessWidget {
  const AsmitaApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp.router(
        title: 'Asmita',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        routerConfig: appRouter,
      );
}
