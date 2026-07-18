import type {
  EvidenceArtifactManifest,
  EvidenceReference,
} from '../domain/types.js';

export interface ProvenanceResolution {
  valid: boolean;
  resolved: number;
  issues: string[];
}

export function resolveEvidenceReferences(
  corpus: EvidenceArtifactManifest[],
  references: EvidenceReference[],
): ProvenanceResolution {
  const issues: string[] = [];
  const artifactIds = new Set<string>();
  const sources = new Map<string, { artifactId: string; locator: string; checksum: string }>();

  for (const artifact of corpus) {
    if (!artifact.synthetic || artifact.trust !== 'untrusted_input') {
      issues.push(`corpus artifact ${artifact.id} violates the synthetic trust boundary`);
    }
    if (artifactIds.has(artifact.id)) issues.push(`duplicate corpus artifact: ${artifact.id}`);
    artifactIds.add(artifact.id);
    for (const region of artifact.regions) {
      if (sources.has(region.sourceId)) issues.push(`duplicate corpus source: ${region.sourceId}`);
      sources.set(region.sourceId, {
        artifactId: artifact.id,
        locator: region.locator,
        checksum: region.checksum,
      });
    }
  }

  let resolved = 0;
  for (const reference of references) {
    const source = sources.get(reference.id);
    if (!source) {
      issues.push(`unknown corpus source: ${reference.id}`);
      continue;
    }
    if (source.artifactId !== reference.artifactId) {
      issues.push(`artifact mismatch for ${reference.id}`);
      continue;
    }
    if (source.locator !== reference.region) {
      issues.push(`region mismatch for ${reference.id}`);
      continue;
    }
    if (source.checksum !== reference.checksum) {
      issues.push(`checksum mismatch for ${reference.id}`);
      continue;
    }
    resolved += 1;
  }

  return { valid: issues.length === 0 && resolved === references.length, resolved, issues };
}
