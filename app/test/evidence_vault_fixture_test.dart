import 'package:flutter_test/flutter_test.dart';
import 'package:renkevia/src/features/evidence_vault/evidence_vault_fixture.dart';

void main() {
  test('review mesh contains four distinct contexts and preserves dissent', () {
    expect(specialistReviews.length, 4);
    expect(specialistReviews.map((review) => review.id).toSet().length, 4);
    expect(
      specialistReviews.map((review) => review.inputHash).toSet().length,
      4,
    );

    final dissents = specialistReviews.where(
      (review) => review.verdict == ReviewVerdict.dissent,
    );
    expect(dissents.length, 1);
    expect(dissents.single.findingId, 'LEGACY-01');
    expect(dissents.single.isBlocking, isTrue);
    expect(dissents.single.disposition, contains('cannot overwrite'));
  });

  test(
    'every projection is source-linked and rollback restores exact hashes',
    () {
      expect(provenanceRecords.length, 6);
      expect(
        provenanceRecords.map((record) => record.artifactId).toSet().length,
        6,
      );
      expect(
        provenanceRecords.every(
          (record) =>
              record.sourceId.startsWith('SRC-') && record.region.isNotEmpty,
        ),
        isTrue,
      );

      expect(rollbackRecords.length, 6);
      expect(rollbackRecords.every((record) => record.isExact), isTrue);
      expect(
        rollbackRecords.map((record) => record.artifactId).toSet(),
        provenanceRecords.map((record) => record.artifactId).toSet(),
      );
    },
  );

  test('approval policy fails closed through every Evidence Vault state', () {
    expect(
      evidenceVaultBlockers(
        simulationVerified: false,
        state: EvidenceVaultRunState.ready,
      ),
      contains('Deterministic regression suite is not verified'),
    );
    expect(
      evidenceVaultBlockers(
        simulationVerified: true,
        state: EvidenceVaultRunState.ready,
      ),
      hasLength(2),
    );
    expect(
      evidenceVaultBlockers(
        simulationVerified: true,
        state: EvidenceVaultRunState.reviewing,
      ),
      hasLength(2),
    );
    expect(
      evidenceVaultBlockers(
        simulationVerified: true,
        state: EvidenceVaultRunState.sealed,
      ).single,
      contains('LEGACY-01'),
    );
  });
}
