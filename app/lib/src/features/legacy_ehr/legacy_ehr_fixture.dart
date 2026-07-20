class LegacyFieldDelta {
  const LegacyFieldDelta({
    required this.section,
    required this.field,
    required this.currentValue,
    required this.candidateValue,
    required this.source,
  });

  final String section;
  final String field;
  final String currentValue;
  final String candidateValue;
  final String source;
}

class LegacyStagingProof {
  const LegacyStagingProof({
    required this.proofId,
    required this.runId,
    required this.artifactId,
    required this.patchVersion,
    required this.inspectedHash,
    required this.recheckedHash,
    required this.stagedHash,
    required this.screenshotHash,
    required this.actionCount,
    required this.capturedAt,
    this.finalCommitPerformed = false,
  });

  final String proofId;
  final String runId;
  final String artifactId;
  final String patchVersion;
  final String inspectedHash;
  final String recheckedHash;
  final String stagedHash;
  final String screenshotHash;
  final int actionCount;
  final String capturedAt;
  final bool finalCommitPerformed;

  bool get stateRecheckMatches => inspectedHash == recheckedHash;

  bool get isValid =>
      proofId == 'LEGACY-PROOF-014' &&
      runId == 'RUN 24-0717-A' &&
      artifactId == 'EHR-OS-014' &&
      patchVersion == 'v0.8' &&
      inspectedHash == legacyExpectedBeforeHash &&
      stateRecheckMatches &&
      stagedHash == 'STG-4F91-0C2E' &&
      screenshotHash.isNotEmpty &&
      actionCount >= 6 &&
      !finalCommitPerformed;
}

const legacyFieldDeltas = <LegacyFieldDelta>[
  LegacyFieldDelta(
    section: 'Population branch',
    field: 'Exception reference',
    currentValue: 'Not represented',
    candidateValue: 'PED-07',
    source: 'SRC-006#T3:C7',
  ),
  LegacyFieldDelta(
    section: 'Population branch',
    field: 'Scope predicate',
    currentValue: 'Adult default only',
    candidateValue: 'population == PEDIATRIC',
    source: 'MUT-02',
  ),
  LegacyFieldDelta(
    section: 'Change control',
    field: 'Institutional ticket',
    currentValue: 'CHANGE-811',
    candidateValue: 'CHANGE-842',
    source: 'PATCH-IR-v0.8',
  ),
  LegacyFieldDelta(
    section: 'Audit metadata',
    field: 'Rollback package',
    currentValue: 'Revision v14',
    candidateValue: 'RBK-0.8 • exact',
    source: 'PRE-8D4A',
  ),
];

const legacyExpectedBeforeHash = 'B711-02EF';
const legacyDriftedHash = 'DRIFT-93A4';
const legacyStagedHash = 'STG-4F91-0C2E';
