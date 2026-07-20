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

  Future<void> setCompactCanvas(
    WidgetTester tester, {
    Size size = const Size(390, 844),
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> sealEvidenceVault(WidgetTester tester) async {
    await tester.tap(find.text('Change plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recompile-patch-button')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Safety checks'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('simulation-primary-button')));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.text('Approval record'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('evidence-vault-primary-button')));
    await tester.pump(const Duration(milliseconds: 1050));
  }

  Future<void> stageLegacyAndReturnProof(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('evidence-vault-primary-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legacy-search-button')));
    await tester.pump(const Duration(milliseconds: 360));
    await tester.tap(find.byKey(const Key('legacy-open-order-set-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legacy-compare-button')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('legacy-prepare-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legacy-stage-button')));
    await tester.pump(const Duration(milliseconds: 470));
    final returnButton = find.byKey(const Key('legacy-return-proof-button'));
    await tester.ensureVisible(returnButton);
    await tester.tap(returnButton);
    await tester.pumpAndSettle();
  }

  testWidgets('renders an explicitly synthetic institutional workspace', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    expect(find.text('RENKEVIA'), findsOneWidget);
    expect(
      find.text('Protect every care pathway from one shortage.'),
      findsOneWidget,
    );
    expect(find.text('SYNTHETIC • NO PATIENT DATA'), findsOneWidget);
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
    expect(find.text('Tracing every dependency…'), findsOneWidget);

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

    await tester.tap(find.text('Change plan'));
    await tester.pumpAndSettle();

    expect(
      find.text('Fix the rule once. Never repair six files by hand.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Patch Studio recompiles one source of truth into six artifacts',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change plan'));
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
      expect(find.text('Updating every target…'), findsOneWidget);

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

    await tester.tap(find.text('Change plan'));
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

      await tester.tap(find.text('Safety checks'));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Make the hidden failure reproducible—then prove it is gone.',
        ),
        findsOneWidget,
      );
      expect(find.text('BASELINE • 1 FAILURE'), findsOneWidget);
      expect(find.text('PATH-PED-07-04'), findsOneWidget);
      expect(find.text('Resolve the change plan first'), findsOneWidget);

      await tester.tap(find.byKey(const Key('simulation-primary-button')));
      await tester.pumpAndSettle();
      expect(
        find.text('Fix the rule once. Never repair six files by hand.'),
        findsOneWidget,
      );
    },
  );

  testWidgets('sealed patient fixture turns red to green after Patch IR v0.8', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Change plan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('recompile-patch-button')));
    await tester.pump(const Duration(milliseconds: 900));
    await tester.tap(find.text('Safety checks'));
    await tester.pumpAndSettle();

    expect(find.text('v0.8 • READY TO RETEST'), findsOneWidget);
    expect(find.text('23 / 24'), findsOneWidget);
    expect(find.text('Test the revised plan'), findsOneWidget);

    await tester.tap(find.byKey(const Key('simulation-primary-button')));
    await tester.pump();
    expect(find.text('Checking 24 pathways…'), findsOneWidget);

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

    expect(
      find.text('Make the hidden failure reproducible—then prove it is gone.'),
      findsOneWidget,
    );
    expect(find.byKey(const Key('suite-PED-07')), findsOneWidget);
  });

  testWidgets('Evidence Vault prevents specialist review gates being skipped', (
    tester,
  ) async {
    await setDesktopCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Approval record'));
    await tester.pumpAndSettle();

    expect(
      find.text('Turn every claim into an accountable approval record.'),
      findsOneWidget,
    );
    expect(find.text('UPSTREAM GATE • LOCKED'), findsOneWidget);
    expect(find.text('Complete safety checks first'), findsOneWidget);

    await tester.tap(find.byKey(const Key('evidence-vault-primary-button')));
    await tester.pumpAndSettle();
    expect(
      find.text('Make the hidden failure reproducible—then prove it is gone.'),
      findsOneWidget,
    );
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

    expect(
      find.text('Agreement is useful. Preserved disagreement is safer.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('review-clinical-informatics')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('legacy-staging-blocker')), findsOneWidget);
  });

  testWidgets(
    'visual legacy proof resolves the machine gate but not human approval',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();
      await sealEvidenceVault(tester);
      await stageLegacyAndReturnProof(tester);

      expect(find.text('STAGED • AWAITING HUMAN APPROVAL'), findsOneWidget);
      expect(find.byKey(const Key('legacy-staging-proof')), findsOneWidget);
      expect(find.byKey(const Key('legacy-staging-blocker')), findsNothing);
      expect(
        find.text('No machine blocker remains. The demo stops here.'),
        findsOneWidget,
      );

      final approvalButton = tester.widget<FilledButton>(
        find.byKey(const Key('request-approval-button')),
      );
      expect(approvalButton.onPressed, isNull);
    },
  );

  testWidgets('mobile shell keeps all four institutional surfaces reachable', (
    tester,
  ) async {
    await setCompactCanvas(tester);
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    expect(find.text('RENKEVIA'), findsOneWidget);
    expect(
      find.byKey(const Key('mobile-workspace-navigation')),
      findsOneWidget,
    );
    expect(
      find.text('Protect every care pathway from one shortage.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('mobile-nav-patch-studio')));
    await tester.pumpAndSettle();
    expect(
      find.text('Fix the rule once. Never repair six files by hand.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('mobile-nav-simulation-lab')));
    await tester.pumpAndSettle();
    expect(
      find.text('Make the hidden failure reproducible—then prove it is gone.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('mobile-nav-evidence-vault')));
    await tester.pumpAndSettle();
    expect(
      find.text('Turn every claim into an accountable approval record.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('mobile-nav-response-room')));
    await tester.pumpAndSettle();
    expect(
      find.text('Protect every care pathway from one shortage.'),
      findsOneWidget,
    );
  });

  testWidgets('tablet shell uses the same complete responsive workspace', (
    tester,
  ) async {
    await setCompactCanvas(tester, size: const Size(768, 1024));
    await tester.pumpWidget(const RenkeviaApp());
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('mobile-workspace-navigation')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('mobile-nav-patch-studio')));
    await tester.pumpAndSettle();
    expect(
      find.text('Fix the rule once. Never repair six files by hand.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'blocked response room matches the reviewed visual baseline',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('compile-fixture-button')));
      await tester.pump(const Duration(milliseconds: 800));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/response_room_blocked.png'),
      );
    },
    skip: true, // Browser release captures are the current visual baseline.
  );

  testWidgets(
    'revised Patch Studio matches the reviewed visual baseline',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('recompile-patch-button')));
      await tester.pump(const Duration(milliseconds: 900));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/patch_studio_revised.png'),
      );
    },
    skip: true, // Browser release captures are the current visual baseline.
  );

  testWidgets(
    'verified Simulation Lab matches the reviewed visual baseline',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Change plan'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('recompile-patch-button')));
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(find.text('Safety checks'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('simulation-primary-button')));
      await tester.pump(const Duration(milliseconds: 1000));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/simulation_lab_verified.png'),
      );
    },
    skip: true, // Browser release captures are the current visual baseline.
  );

  testWidgets(
    'sealed Evidence Vault matches the reviewed visual baseline',
    (tester) async {
      await setDesktopCanvas(tester);
      await tester.pumpWidget(const RenkeviaApp());
      await tester.pumpAndSettle();
      await sealEvidenceVault(tester);

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/evidence_vault_sealed.png'),
      );
    },
    skip: true, // Browser release captures are the current visual baseline.
  );
}
