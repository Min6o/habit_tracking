import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:habit_tracking/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app shows dashboard greeting and empty state', (tester) async {
    SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('مرحباً، أيمن'), findsOneWidget);
    expect(find.text('لا توجد عادات حتى الآن'), findsOneWidget);
  });

  testWidgets('analytics tab shows streaks, adherence, chart, and badges', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('الإحصائيات'));
    await tester.pumpAndSettle();

    expect(find.text('السلسلة الحالية'), findsOneWidget);
    expect(find.text('أفضل سلسلة'), findsOneWidget);
    expect(find.text('نسبة الالتزام'), findsOneWidget);
    expect(find.byType(BarChart), findsOneWidget);
    expect(find.text('بطل البداية'), findsOneWidget);
    expect(find.text('مستمر للأسبوع الأول'), findsOneWidget);
    expect(find.text('عزيمة فولاذية'), findsOneWidget);

    await tester.tap(find.text('العادات'));
    await tester.pumpAndSettle();
    expect(find.text('مرحباً، أيمن'), findsOneWidget);
  });

  testWidgets(
    'left drawer opens, persists appearance, and navigates to analytics',
    (tester) async {
      SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
      await tester.pumpWidget(const HabitTrackerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('فتح القائمة'));
      await tester.pumpAndSettle();

      expect(find.text('Tasks'), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(
        tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
        ThemeMode.dark,
      );

      await tester.tap(find.byKey(const ValueKey('drawer_analytics')));
      await tester.pumpAndSettle();
      expect(find.text('إنجازات الأسبوع'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('dark_mode_enabled'), isTrue);
    },
  );

  testWidgets('language switch changes UI direction and custom categories', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('فتح القائمة'));
    await tester.pumpAndSettle();
    final languageDropdown = find.byType(DropdownButton<String>);
    await tester.ensureVisible(languageDropdown);
    await tester.pumpAndSettle();
    await tester.tap(languageDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('English').last);
    await tester.pumpAndSettle();

    expect(
      tester.widget<Directionality>(find.byKey(const ValueKey('home_directionality')))
          .textDirection,
      TextDirection.ltr,
    );
    expect(find.text('Your habits'), findsOneWidget);

    await tester.tap(find.byTooltip('فتح القائمة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Manage categories'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add category'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Travel');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_code'), 'en');
    expect(prefs.getStringList('habit_categories'), contains('Travel'));
  });

  testWidgets('user can add a habit and toggle completion', (tester) async {
    SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('إضافة العادة'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'قراءة كتاب');
    await tester.tap(find.widgetWithText(ChoiceChip, 'قراءة').last);
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة العادة'));
    await tester.pumpAndSettle();

    expect(find.text('قراءة كتاب'), findsOneWidget);

    final checkboxFinder = find.byType(AnimatedCheckboxButton);
    expect(checkboxFinder, findsOneWidget);

    await tester.tap(checkboxFinder);
    await tester.pumpAndSettle();

    expect(find.byType(AnimatedCheckboxButton), findsOneWidget);
  });

  testWidgets('free limit opens paywall and demo Pro unlocks another habit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index++) {
      await tester.tap(find.byTooltip('إضافة العادة'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'عادة ${index + 1}');
      await tester.tap(find.widgetWithText(FilledButton, 'إضافة العادة'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.byTooltip('إضافة العادة'));
    await tester.pumpAndSettle();

    expect(find.text('الترقية إلى Habit Tracker Pro'), findsOneWidget);
    expect(find.text('اسم العادة'), findsNothing);

    await tester.ensureVisible(find.text('اشترك الآن'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('اشترك الآن'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('إضافة العادة'));
    await tester.pumpAndSettle();

    expect(find.text('اسم العادة'), findsOneWidget);
  });

  testWidgets('first launch prompts for a name and greeting can update it', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('مرحباً بك'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'أيمن');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('مرحباً، أيمن'), findsOneWidget);
    await tester.tap(find.text('مرحباً، أيمن'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'سارة');
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(find.text('مرحباً، سارة'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_name'), 'سارة');
  });

  testWidgets('saving the first name preserves habits loaded on startup', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'is_first_login': false,
      'habits_key':
          '[{"title":"قراءة كتاب","category":"قراءة","streak":1,"completed":true,"frequency":"يومياً","lastCompletedDate":"${DateTime.now().toIso8601String()}"}]',
    });

    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'أيمن');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('قراءة كتاب'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final savedHabits =
        jsonDecode(prefs.getString('habits_key')!) as List<dynamic>;
    expect(savedHabits, hasLength(1));
    expect(savedHabits.single['completed'], isTrue);
    expect(prefs.getString('user_name'), 'أيمن');
  });

  testWidgets('habit menu edits and persists title and category', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({'user_name': 'أيمن'});
    await tester.pumpWidget(const HabitTrackerApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('إضافة العادة'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'قراءة كتاب');
    await tester.tap(find.widgetWithText(FilledButton, 'إضافة العادة'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byTooltip('خيارات العادة'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('خيارات العادة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تعديل العادة'));
    await tester.pumpAndSettle();

    final titleField = find.byType(TextField);
    expect(tester.widget<TextField>(titleField).controller?.text, 'قراءة كتاب');
    await tester.enterText(titleField, 'قراءة يومية');
    await tester.tap(find.widgetWithText(ChoiceChip, 'عبادات').last);
    await tester.tap(find.widgetWithText(ChoiceChip, 'أسبوعياً').last);
    await tester.tap(find.text('حفظ التعديلات'));
    await tester.pumpAndSettle();

    expect(find.text('قراءة كتاب'), findsNothing);
    expect(find.text('قراءة يومية'), findsOneWidget);
    expect(find.text('عبادات').last, findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('habits_key'), contains('قراءة يومية'));
    expect(prefs.getString('habits_key'), contains('عبادات'));
    expect(prefs.getString('habits_key'), contains('أسبوعياً'));
  });

  testWidgets(
    'launch resets expired completions and preserves current periods',
    (tester) async {
      final now = DateTime.now();
      final expiredDate = DateTime(now.year, now.month - 1, 1);
      final persistedHabits = [
        {
          'title': 'يومي قديم',
          'category': 'صحة',
          'streak': 7,
          'completed': true,
          'frequency': 'يومياً',
          'lastCompletedDate': now
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
        {
          'title': 'أسبوعي قديم',
          'category': 'رياضة',
          'streak': 4,
          'completed': true,
          'frequency': 'أسبوعياً',
          'lastCompletedDate': now
              .subtract(const Duration(days: 8))
              .toIso8601String(),
        },
        {
          'title': 'شهري قديم',
          'category': 'عمل',
          'streak': 3,
          'completed': true,
          'frequency': 'شهرياً',
          'lastCompletedDate': expiredDate.toIso8601String(),
        },
        {
          'title': 'أسبوعي حالي',
          'category': 'تطوير',
          'streak': 9,
          'completed': true,
          'frequency': 'أسبوعياً',
          'lastCompletedDate': now.toIso8601String(),
        },
        {
          'title': 'شهري حالي',
          'category': 'عبادات',
          'streak': 2,
          'completed': true,
          'frequency': 'شهرياً',
          'lastCompletedDate': now.toIso8601String(),
        },
      ];
      SharedPreferences.setMockInitialValues({
        'user_name': 'أيمن',
        'habits_key': jsonEncode(persistedHabits),
      });

      await tester.pumpWidget(const HabitTrackerApp());
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      final saved = (jsonDecode(prefs.getString('habits_key')!) as List)
          .cast<Map<String, dynamic>>();
      final completedByTitle = {
        for (final habit in saved)
          habit['title'] as String: habit['completed'] as bool,
      };
      expect(completedByTitle['يومي قديم'], isFalse);
      expect(completedByTitle['أسبوعي قديم'], isFalse);
      expect(completedByTitle['شهري قديم'], isFalse);
      expect(completedByTitle['أسبوعي حالي'], isTrue);
      expect(completedByTitle['شهري حالي'], isTrue);
      final expiredDaily = saved.firstWhere(
        (habit) => habit['title'] == 'يومي قديم',
      );
      expect(expiredDaily['completed'], isFalse);
      expect(expiredDaily['streak'], 7);
      expect(expiredDaily['category'], 'صحة');
      expect(expiredDaily['lastCompletedDate'], isNotNull);
    },
  );
}
