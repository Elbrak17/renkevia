import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:renkevia/src/features/legacy_ehr/legacy_ehr_fixture.dart';

enum LegacySandboxState {
  locate,
  searching,
  result,
  inspected,
  comparing,
  driftBlocked,
  compared,
  prepared,
  staging,
  staged,
}

class LegacyEhrSandboxController extends ChangeNotifier {
  LegacySandboxState _state = LegacySandboxState.locate;
  String? _message;
  String _screenHash = legacyExpectedBeforeHash;
  LegacyStagingProof? _proof;

  LegacySandboxState get state => _state;
  String? get message => _message;
  String get screenHash => _screenHash;
  LegacyStagingProof? get proof => _proof;
  bool get hasResult => _state.index >= LegacySandboxState.result.index;
  bool get hasInspected => _state.index >= LegacySandboxState.inspected.index;
  bool get isStaged => _state == LegacySandboxState.staged;

  List<String> get completedActions {
    final actions = <String>[];
    if (hasResult) actions.add('SEARCH');
    if (hasInspected) actions.add('INSPECT');
    if (_state == LegacySandboxState.compared ||
        _state == LegacySandboxState.prepared ||
        _state == LegacySandboxState.staging ||
        _state == LegacySandboxState.staged) {
      actions.add('RECHECK');
      actions.add('COMPARE');
    }
    if (_state == LegacySandboxState.prepared ||
        _state == LegacySandboxState.staging ||
        _state == LegacySandboxState.staged) {
      actions.add('PREPARE');
    }
    if (_state == LegacySandboxState.staged) actions.add('STAGE');
    return actions;
  }

  Future<void> search(String query) async {
    if (_state == LegacySandboxState.searching) return;
    _state = LegacySandboxState.searching;
    _message = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (query.trim().toUpperCase() != 'EHR-OS-014') {
      _state = LegacySandboxState.locate;
      _message = 'No staging order set matches that identifier.';
      notifyListeners();
      return;
    }
    _state = LegacySandboxState.result;
    notifyListeners();
  }

  void inspectOrderSet() {
    if (_state != LegacySandboxState.result) return;
    _state = LegacySandboxState.inspected;
    _screenHash = legacyExpectedBeforeHash;
    _message = null;
    notifyListeners();
  }

  void simulateScreenDrift() {
    if (_state != LegacySandboxState.inspected) return;
    _screenHash = legacyDriftedHash;
    _message = 'Synthetic screen drift injected after inspection.';
    notifyListeners();
  }

  Future<void> compareWithPatch() async {
    if (_state != LegacySandboxState.inspected) return;
    _state = LegacySandboxState.comparing;
    _message = null;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 360));
    if (_screenHash != legacyExpectedBeforeHash) {
      _state = LegacySandboxState.driftBlocked;
      _message =
          'STATE-DRIFT • inspected $legacyExpectedBeforeHash, observed $_screenHash. Staging blocked.';
      notifyListeners();
      return;
    }
    _state = LegacySandboxState.compared;
    notifyListeners();
  }

  void prepareStaging() {
    if (_state != LegacySandboxState.compared) return;
    _state = LegacySandboxState.prepared;
    notifyListeners();
  }

  Future<void> stageChange() async {
    if (_state != LegacySandboxState.prepared) return;
    _state = LegacySandboxState.staging;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 420));
    _proof = const LegacyStagingProof(
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
    _state = LegacySandboxState.staged;
    _message = null;
    notifyListeners();
  }

  void reset() {
    _state = LegacySandboxState.locate;
    _message = null;
    _screenHash = legacyExpectedBeforeHash;
    _proof = null;
    notifyListeners();
  }
}
