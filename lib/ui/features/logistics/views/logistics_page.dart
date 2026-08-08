import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class LogisticsPage extends StatelessWidget {
  const LogisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: ext.cream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: ext.sand,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.construction_rounded,
                  size: 40,
                  color: ext.cocoa50,
                ),
              ),
              const SizedBox(height: AppSpacing.x5),
              Text(
                'Under Development',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: ext.cocoa),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                'We\'re working on Logistics. Check back soon.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: ext.cocoa50),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
