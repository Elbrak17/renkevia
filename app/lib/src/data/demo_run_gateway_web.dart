// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html';

import 'demo_run_gateway_contract.dart';
import 'demo_run_gateway_fixture.dart';

const _configuredBaseUrl = String.fromEnvironment(
  'RENKEVIA_API_BASE_URL',
  defaultValue: '',
);
const _liveReasoningEnabled = bool.fromEnvironment(
  'RENKEVIA_LIVE_REASONING',
  defaultValue: false,
);

DemoRunGateway createPlatformDemoRunGateway() {
  if (_configuredBaseUrl.trim().isEmpty) return const FixtureReplayGateway();
  return ConnectedCoreGateway(_configuredBaseUrl);
}

class ConnectedCoreGateway implements DemoRunGateway {
  ConnectedCoreGateway(String baseUrl)
    : _baseUrl = baseUrl.replaceFirst(RegExp(r'/$'), '');

  final String _baseUrl;
  Map<String, dynamic>? _liveProof;

  @override
  bool get isConnected => true;

  @override
  String get modeLabel =>
      _liveReasoningEnabled ? 'LIVE GPT-5.6' : 'CONNECTED CORE';

  Future<Map<String, dynamic>> _post(
    String path, {
    Map<String, dynamic> payload = const {'fixtureId': 'FIXTURE-8D4A'},
  }) async {
    final response = await HttpRequest.request(
      '$_baseUrl$path',
      method: 'POST',
      requestHeaders: const {'content-type': 'application/json'},
      sendData: jsonEncode(payload),
    );
    final status = response.status ?? 0;
    if (status < 200 || status >= 300) {
      throw DemoGatewayContractError('Core rejected $path ($status).');
    }
    final value = jsonDecode(response.responseText ?? '');
    if (value is! Map<String, dynamic>) {
      throw const DemoGatewayContractError('Core response was not an object.');
    }
    return value;
  }

  int _integer(Map<String, dynamic> value, String key) {
    final field = value[key];
    if (field is! int) {
      throw DemoGatewayContractError('Core field $key was invalid.');
    }
    return field;
  }

  bool _boolean(Map<String, dynamic> value, String key) {
    final field = value[key];
    if (field is! bool) {
      throw DemoGatewayContractError('Core field $key was invalid.');
    }
    return field;
  }

  String _string(Map<String, dynamic> value, String key) {
    final field = value[key];
    if (field is! String) {
      throw DemoGatewayContractError('Core field $key was invalid.');
    }
    return field;
  }

  List<String> _strings(Map<String, dynamic> value, String key) {
    final field = value[key];
    if (field is! List || field.any((item) => item is! String)) {
      throw DemoGatewayContractError('Core field $key was invalid.');
    }
    return field.cast<String>();
  }

  @override
  Future<CandidateRunResult> compileCandidate() async {
    final value = await _post('/api/demo/compile');
    return CandidateRunResult(
      patchVersion: _string(value, 'patchVersion'),
      diffCount: _integer(value, 'diffCount'),
      pathwayCount: _integer(value, 'pathwayCount'),
      passedPathways: _integer(value, 'passedPathways'),
      assertionCount: _integer(value, 'assertionCount'),
      passedAssertions: _integer(value, 'passedAssertions'),
      blockerIds: _strings(value, 'blockerIds'),
      finalCommitAllowed: _boolean(value, 'finalCommitAllowed'),
    );
  }

  @override
  Future<RecompileRunResult> recompilePatch() async {
    final value = _liveReasoningEnabled
        ? await _post(
            '/api/live/reasoning',
            payload: const {'fixtureId': 'FIXTURE-8D4A', 'confirmLive': true},
          )
        : await _post('/api/demo/recompile');
    if (_liveReasoningEnabled) {
      _liveProof = value;
    }
    return RecompileRunResult(
      patchVersion: _string(value, 'patchVersion'),
      diffCount: _integer(value, 'diffCount'),
      status: _string(value, _liveReasoningEnabled ? 'patchStatus' : 'status'),
      finalCommitAllowed: _boolean(value, 'finalCommitAllowed'),
    );
  }

  @override
  Future<SimulationRunResult> runSimulation() async {
    final value = _liveReasoningEnabled
        ? _requiredLiveProof()
        : await _post('/api/demo/simulate');
    return SimulationRunResult(
      patchVersion: _string(value, 'patchVersion'),
      pathwayCount: _integer(value, 'pathwayCount'),
      passedPathways: _integer(value, 'passedPathways'),
      assertionCount: _integer(value, 'assertionCount'),
      passedAssertions: _integer(value, 'passedAssertions'),
      provenanceCoverage: _integer(value, 'provenanceCoverage'),
      exactRollbackVerified: _boolean(value, 'exactRollbackVerified'),
      finalCommitAllowed: _boolean(value, 'finalCommitAllowed'),
    );
  }

  @override
  Future<AuditRunResult> runSpecialistAudit() async {
    final value = _liveReasoningEnabled
        ? _requiredLiveProof()
        : await _post('/api/demo/audit');
    return AuditRunResult(
      reviewCount: _integer(value, 'reviewCount'),
      roles: _strings(value, 'roles'),
      preservedDissentIds: _strings(value, 'preservedDissentIds'),
      approvalControlEnabled: _boolean(value, 'approvalControlEnabled'),
      finalCommitAllowed: _boolean(value, 'finalCommitAllowed'),
    );
  }

  Map<String, dynamic> _requiredLiveProof() {
    final proof = _liveProof;
    if (proof == null) {
      throw const DemoGatewayContractError(
        'Live reasoning must complete before proof replay.',
      );
    }
    return proof;
  }
}
