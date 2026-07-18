import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_app.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_fixture.dart';

void main() {
  Future<void> setLegacyCanvas(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
  }

  Future<void> inspectOrderSet(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('legacy-search-button')));
    await tester.pump(const Duration(milliseconds: 360));
    await tester.tap(find.byKey(const Key('legacy-open-order-set-button')));
    await tester.pumpAndSettle();
  }

  Future<void> stageOrderSet(WidgetTester tester) async {
    await inspectOrderSet(tester);
    await tester.tap(find.byKey(const Key('legacy-compare-button')));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('legacy-prepare-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legacy-stage-button')));
    await tester.pump(const Duration(milliseconds: 470));
  }

  test('typed staging proof requires a state match and no final commit', () {
    const valid = LegacyStagingProof(
      proofId: 'LEGACY-PROOF-014',
      runId: 'RUN 24-0717-A',
      artifactId: 'EHR-OS-014',
      patchVersion: 'v0.8',
      inspectedHash: legacyExpectedBeforeHash,
      recheckedHash: legacyExpectedBeforeHash,
      stagedHash: legacyStagedHash,
      screenshotHash: 'SCR-6D22-A901',
      actionCount: 6,
      capturedAt: '2026-07-18T14:02:48Z',
    );
    const drifted = LegacyStagingProof(
      proofId: 'LEGACY-PROOF-014',
      runId: 'RUN 24-0717-A',
      artifactId: 'EHR-OS-014',
      patchVersion: 'v0.8',
      inspectedHash: legacyExpectedBeforeHash,
      recheckedHash: legacyDriftedHash,
      stagedHash: legacyStagedHash,
      screenshotHash: 'SCR-6D22-A901',
      actionCount: 6,
      capturedAt: '2026-07-18T14:02:48Z',
    );
    const unexpectedButMatched = LegacyStagingProof(
      proofId: 'LEGACY-PROOF-014',
      runId: 'RUN 24-0717-A',
      artifactId: 'EHR-OS-014',
      patchVersion: 'v0.8',
      inspectedHash: legacyDriftedHash,
      recheckedHash: legacyDriftedHash,
      stagedHash: legacyStagedHash,
      screenshotHash: 'SCR-6D22-A901',
      actionCount: 6,
      capturedAt: '2026-07-18T14:02:48Z',
    );

    expect(valid.isValid, isTrue);
    expect(drifted.isValid, isFalse);
    expect(unexpectedButMatched.isValid, isFalse);
  });

  testWidgets(
    'legacy sandbox stages through visible actions and stops safely',
    (tester) async {
      await setLegacyCanvas(tester);
      await tester.pumpWidget(const LegacyEhrSandboxApp());
      await tester.pumpAndSettle();
      await stageOrderSet(tester);

      expect(find.text('STAGED • AWAITING HUMAN APPROVAL'), findsOneWidget);
      expect(find.textContaining('LEGACY-PROOF-014'), findsWidgets);
      expect(
        find.textContaining('No final commit was performed'),
        findsOneWidget,
      );

      final commitButton = tester.widget<FilledButton>(
        find.byKey(const Key('legacy-final-commit-button')),
      );
      expect(commitButton.onPressed, isNull);
    },
  );

  testWidgets('screen drift fails closed before patch comparison', (
    tester,
  ) async {
    await setLegacyCanvas(tester);
    await tester.pumpWidget(const LegacyEhrSandboxApp());
    await tester.pumpAndSettle();
    await inspectOrderSet(tester);

    await tester.tap(find.byKey(const Key('legacy-simulate-drift-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('legacy-compare-button')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('legacy-drift-blocker')), findsOneWidget);
    expect(find.textContaining('STATE-DRIFT'), findsOneWidget);
    expect(find.byKey(const Key('legacy-stage-button')), findsNothing);
  });

  testWidgets('staged legacy sandbox matches the reviewed golden layout', (
    tester,
  ) async {
    await setLegacyCanvas(tester);
    await tester.pumpWidget(const LegacyEhrSandboxApp());
    await tester.pumpAndSettle();
    await stageOrderSet(tester);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/legacy_ehr_staged.png'),
    );
  });
}
