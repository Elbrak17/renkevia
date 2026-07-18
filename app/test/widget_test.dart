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

  Future<void> sealEvidenceVault(WidgetTester tester) async {
    await tester.tap(find.text('Patch Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recompile-patch-button')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Simulation Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('simulation-primary-button')));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.text('Evidence Vault'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('evidence-vault-primary-button')));
    await tester.pump(const Duration(milliseconds: 1050));
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

  testWidgets(
    'Simulation Lab prevents the regression gate from being skipped',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simulation Lab'));
      await tester.pumpAndSettle();

      expect(find.text('SIMULATION LAB / 03'), findsOneWidget);
      expect(find.text('BASELINE • 1 FAILURE'), findsOneWidget);
      expect(find.text('PATH-PED-07-04'), findsOneWidget);
      expect(find.text('Compile Patch v0.8 first'), findsOneWidget);

      await tester.tap(find.byKey(const Key('simulation-primary-button')));
      await tester.pumpAndSettle();
      expect(find.text('PATCH STUDIO / 02'), findsOneWidget);
    },
  );

  testWidgets('sealed patient fixture turns red to green after Patch IR v0.8', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Patch Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recompile-patch-button')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Simulation Lab'));
    await tester.pumpAndSettle();

    expect(find.text('v0.8 • READY TO RETEST'), findsOneWidget);
    expect(find.text('23 / 24'), findsOneWidget);
    expect(find.text('Run revised candidate'), findsOneWidget);

    await tester.tap(find.byKey(const Key('simulation-primary-button')));
    await tester.pump();
    expect(find.text('Executing 96 assertions…'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('24 / 24 VERIFIED'), findsOneWidget);
    expect(find.text('REGRESSION GATE PASSED'), findsOneWidget);
    expect(find.text('RESOLVED'), findsOneWidget);
    expect(
      find.text('APPROVAL REMAINS LOCKED • 4 specialist audits pending'),
      findsOneWidget,
    );
  });

  testWidgets('Simulation Lab remains usable in the compact desktop shell', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.grid_view_outlined));
    await tester.pumpAndSettle();

    expect(find.text('SIMULATION LAB / 03'), findsOneWidget);
    expect(find.byKey(const Key('suite-PED-07')), findsOneWidget);
  });

  testWidgets('Evidence Vault prevents specialist review gates being skipped', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Evidence Vault'));
    await tester.pumpAndSettle();

    expect(find.text('EVIDENCE VAULT / 04'), findsOneWidget);
    expect(find.text('UPSTREAM GATE • LOCKED'), findsOneWidget);
    expect(find.text('Verify candidate first'), findsOneWidget);

    await tester.tap(find.byKey(const Key('evidence-vault-primary-button')));
    await tester.pumpAndSettle();
    expect(find.text('SIMULATION LAB / 03'), findsOneWidget);
  });

  testWidgets('Evidence Vault seals audits without erasing dissent', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await sealEvidenceVault(tester);

    expect(find.text('VAULT SEALED • 1 DISSENT'), findsOneWidget);
    expect(find.text('DISSENT PRESERVED • LEGACY-01'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.byKey(const Key('legacy-staging-blocker')), findsOneWidget);
    expect(find.text('APPROVAL REMAINS LOCKED'), findsOneWidget);

    final approvalButton = tester.widget<FilledButton>(
      find.byKey(const Key('request-approval-button')),
    );
    expect(approvalButton.onPressed, isNull);
  });

  testWidgets('proof ledger exposes exact rollback and append-only events', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await sealEvidenceVault(tester);

    final rollbackTab = find.byKey(const Key('vault-tab-rollback'));
    await tester.ensureVisible(rollbackTab);
    await tester.tap(rollbackTab);
    await tester.pumpAndSettle();
    expect(find.textContaining('ROLLBACK EXACT • 6 / 6'), findsOneWidget);
    expect(find.text('MATCH'), findsNWidgets(6));

    final auditTab = find.byKey(const Key('vault-tab-auditLog'));
    await tester.ensureVisible(auditTab);
    await tester.tap(auditTab);
    await tester.pumpAndSettle();
    expect(find.textContaining('EVT-035'), findsOneWidget);
    expect(find.text('locked pending legacy proof'), findsOneWidget);
  });

  testWidgets('sealed Evidence Vault remains usable in compact desktop shell', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await sealEvidenceVault(tester);

    tester.view.physicalSize = const Size(1000, 900);
    await tester.pumpAndSettle();

    expect(find.text('EVIDENCE VAULT / 04'), findsOneWidget);
    expect(
      find.byKey(const Key('review-clinical-informatics')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('legacy-staging-blocker')), findsOneWidget);
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

  testWidgets('verified Simulation Lab matches the reviewed visual baseline', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Patch Studio'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recompile-patch-button')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Simulation Lab'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('simulation-primary-button')));
    await tester.pump(const Duration(milliseconds: 1000));

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/simulation_lab_verified.png'),
    );
  });

  testWidgets('sealed Evidence Vault matches the reviewed visual baseline', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();
    await sealEvidenceVault(tester);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/evidence_vault_sealed.png'),
    );
  });
}
