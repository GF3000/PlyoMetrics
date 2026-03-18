import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:plyometrics/core/theme.dart';
import 'package:plyometrics/screens/dashboard_screen.dart';
import 'package:plyometrics/providers/management_providers.dart';
import 'package:plyometrics/models/athlete_group.dart';
import 'package:plyometrics/models/athlete.dart';

void main() {
  testWidgets('Dashboard renders title and empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Provide empty streams so the UI renders without Isar
          groupsProvider.overrideWith((_) => Stream.value(<AthleteGroup>[])),
          groupAthletesProvider.overrideWith((_) => Stream.value(<Athlete>[])),
        ],
        child: MaterialApp(
          theme: buildAppTheme(),
          home: const DashboardScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('PlyoMetrics'), findsOneWidget);
    expect(find.text('No groups'), findsOneWidget);
    expect(find.text('Select or add an athlete to get started'), findsOneWidget);
  });
}
