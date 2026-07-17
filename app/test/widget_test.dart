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

  testWidgets(
    'Patch Studio recompiles one source of truth into six artifacts',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Patch Studio'));
      await tester.pumpAndSettle();

      expect(find.text('CANDIDATE • BLOCKED'), findsOneWidget);
      expect(find.textContaining('PED-07 exception missing'), findsOneWidget);
      expect(
        find.text('! population exception is not represented'),
        findsOneWidget,
      );
      expect(find.text('APPROVAL REMAINS LOCKED'), findsOneWidget);

      await tester.tap(find.byKey(const Key('recompile-patch-button')));
      await tester.pump();
      expect(find.text('Projecting six artifacts…'), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 900));
      expect(find.text('REVISED • RETEST REQUIRED'), findsOneWidget);
      expect(find.textContaining('Encode pediatric exception'), findsOneWidget);
      expect(find.text('RETEST REQUIRED'), findsOneWidget);
      expect(
        find.text('+ exception PED-07 when population == PEDIATRIC:'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('affected-orderSet')), findsOneWidget);
      expect(find.byKey(const Key('affected-pumpLibrary')), findsOneWidget);
      expect(find.byKey(const Key('affected-label')), findsOneWidget);
      expect(find.byKey(const Key('affected-legacyEhr')), findsOneWidget);
      expect(find.byKey(const Key('affected-policy')), findsOneWidget);
      expect(find.byKey(const Key('affected-communication')), findsOneWidget);
      expect(find.text('APPROVAL REMAINS LOCKED'), findsOneWidget);
    },
  );

  testWidgets('artifact tabs keep the Patch IR projection inspectable', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patch Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('artifact-pumpLibrary')));
    await tester.pumpAndSettle();

    expect(find.text('Infusion pump library fragment'), findsOneWidget);
    expect(find.text('- ADULT_IV,STANDARD-A,120,adult'), findsOneWidget);
    expect(find.text('! PED_IV mapping unverified'), findsOneWidget);
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

  testWidgets('revised Patch Studio matches the reviewed visual baseline', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patch Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recompile-patch-button')));
    await tester.pump(const Duration(milliseconds: 900));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/patch_studio_revised.png'),
    );
  });
}
