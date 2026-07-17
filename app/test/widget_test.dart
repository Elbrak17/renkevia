import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/app.dart';

void main() {
  Future<void> setDesktopCanvas(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  testWidgets('renders an explicitly synthetic institutional workspace', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    expect(find.text('RENKEVIA'), findsOneWidget);
    expect(find.text('Critical IV carrier shortage'), findsOneWidget);
    expect(find.text('SYNTHETIC • NO PHI'), findsOneWidget);
    expect(find.text('FIXTURE REPLAY'), findsOneWidget);
    expect(find.text('Approval locked'), findsNothing);
  });

  testWidgets('fixture compilation exposes the pediatric blocker', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('compile-fixture-button')));
    await tester.pump();
    expect(find.text('Mapping 12 artifacts…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    expect(find.text('Pediatric exception table'), findsOneWidget);
    expect(find.text('Approval blocker'), findsOneWidget);
    expect(find.text('PED-07 • BLOCKER'), findsOneWidget);
    expect(find.text('Approval locked'), findsOneWidget);
  });

  testWidgets('navigation preserves the four-surface product model', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patch Studio'));
    await tester.pumpAndSettle();

    expect(find.text('PATCH STUDIO / 02'), findsOneWidget);
    expect(
      find.text('One Patch IR. Six synchronized artifacts.'),
      findsOneWidget,
    );
  });

  testWidgets('blocked response room matches the reviewed visual baseline', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('compile-fixture-button')));
    await tester.pump(const Duration(milliseconds: 800));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/response_room_blocked.png'),
    );
  });
}
