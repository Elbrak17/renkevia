import { stableHash } from '../core/canonical.js';
import type {
  CorpusRegion,
  EvidenceArtifactManifest,
  EvidenceReference,
} from '../domain/types.js';

function region(sourceId: string, locator: string, syntheticContent: string): CorpusRegion {
  return {
    sourceId,
    locator,
    syntheticContent,
    checksum: `sha256:${stableHash(syntheticContent)}`,
  };
}

export const syntheticCorpus: EvidenceArtifactManifest[] = [
  {
    id: 'NOTICE-SYNTH-842',
    name: 'Synthetic shortage notice',
    mediaType: 'text/plain',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-001',
        'P1:L1-14',
        'SYNTHETIC DEMO: carrier token A is unavailable; compile an institution-wide candidate.',
      ),
    ],
  },
  {
    id: 'POL-IV-006',
    name: 'Institutional policy export',
    mediaType: 'text/plain',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-002',
        'P4:L18-27',
        'Synthetic policy maps carrier token A to candidate token B under change control.',
      ),
    ],
  },
  {
    id: 'EHR-OS-014',
    name: 'Legacy order-set export',
    mediaType: 'application/json',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-003',
        'JSON:$.items[14]',
        '{"syntheticOrder":"OS-014","carrier":"SYNTH-CARRIER-A","exception":"NONE"}',
      ),
    ],
  },
  {
    id: 'PUMP-LIB-092',
    name: 'Synthetic pump-library fragment',
    mediaType: 'text/csv',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-004',
        'R92:C1-7',
        'PUMP-LIB-092,SYNTH-CARRIER-A,NONE,CHANGE-842,LOCKED',
      ),
    ],
  },
  {
    id: 'LEGACY-SCREEN-014',
    name: 'Northstar legacy-screen capture',
    mediaType: 'image/png',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-005',
        'XYWH:118,204,640,188',
        'Visual region fingerprint for fictional order set OS-014 in staging.',
      ),
    ],
  },
  {
    id: 'PED-TABLE-007',
    name: 'Scanned synthetic pediatric exception table',
    mediaType: 'image/png',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-006',
        'T3:C7',
        'SYNTHETIC PEDIATRIC ROW: exception reference PED-07 must remain represented.',
      ),
    ],
  },
  {
    id: 'LBL-IV-021',
    name: 'Synthetic label template',
    mediaType: 'text/plain',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-007',
        'P1:L3-9',
        'Label template references carrier token A and exception field NONE.',
      ),
    ],
  },
  {
    id: 'COMMS-842',
    name: 'Synthetic operations communication',
    mediaType: 'text/plain',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-008',
        'P1:L1-12',
        'Draft communication for change ticket CHANGE-842; approval remains locked.',
      ),
    ],
  },
  {
    id: 'CHANGE-HISTORY-842',
    name: 'Synthetic institutional change history',
    mediaType: 'application/json',
    synthetic: true,
    trust: 'untrusted_input',
    regions: [
      region(
        'SRC-009',
        'P1:L7-14',
        'Sealed fixture FIXTURE-8D4A requires exact rollback and visual staging proof.',
      ),
    ],
  },
];

const sourceIndex = new Map(
  syntheticCorpus.flatMap((artifact) =>
    artifact.regions.map((entry) => [entry.sourceId, { artifact, entry }] as const),
  ),
);

export function evidenceReference(sourceId: string): EvidenceReference {
  const source = sourceIndex.get(sourceId);
  if (!source) throw new Error(`Unknown synthetic source ${sourceId}.`);
  return {
    id: sourceId,
    artifactId: source.artifact.id,
    region: source.entry.locator,
    checksum: source.entry.checksum,
  };
}
