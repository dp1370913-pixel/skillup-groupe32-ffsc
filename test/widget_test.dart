// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skillup/core/theme/app_colors.dart';
import 'package:skillup/core/theme/app_theme.dart';

void main() {
  testWidgets('Thème SkillUp applique la palette forêt / sable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          backgroundColor: AppColors.sand,
          body: Text(
            'Mes cours',
            style: AppTheme.light.textTheme.headlineLarge,
          ),
        ),
      ),
    );

    expect(find.text('Mes cours'), findsOneWidget);
    expect(AppColors.forest, const Color(0xFF1F3A2E));
    expect(AppColors.moss, const Color(0xFF3E7C59));
    expect(AppColors.gold, const Color(0xFFC9962F));
    expect(AppColors.sand, const Color(0xFFEDE6D3));
    expect(AppColors.ink, const Color(0xFF182620));
  });
}
