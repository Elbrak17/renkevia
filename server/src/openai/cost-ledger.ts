import { appendFile, mkdir, readFile } from 'node:fs/promises';
import { dirname } from 'node:path';

import { stableHash } from '../core/canonical.js';
import type { OpenAIModel, ResponsesUsage } from './types.js';

export type CostEntryState = 'reserved' | 'settled' | 'unknown';

export interface CostLedgerEntry {
  sequence: number;
  timestamp: string;
  runId: string;
  model: OpenAIModel;
  state: CostEntryState;
  reservedUsd: number;
  actualUsd?: number;
  usage?: ResponsesUsage;
  previousHash: string;
  entryHash: string;
}

type NewEntry = Omit<CostLedgerEntry, 'sequence' | 'timestamp' | 'previousHash' | 'entryHash'>;

export class CostLedger {
  constructor(readonly path: string) {}

  async entries(): Promise<CostLedgerEntry[]> {
    let source = '';
    try {
      source = await readFile(this.path, 'utf8');
    } catch (error) {
      if ((error as NodeJS.ErrnoException).code === 'ENOENT') return [];
      throw error;
    }
    const entries = source.split('\n').filter(Boolean).map((line) => JSON.parse(line) as CostLedgerEntry);
    let previousHash = 'GENESIS';
    entries.forEach((entry, index) => {
      const { entryHash, ...unsigned } = entry;
      if (entry.sequence !== index + 1 || entry.previousHash !== previousHash || stableHash(unsigned) !== entryHash) {
        throw new Error('OpenAI cost ledger integrity check failed.');
      }
      previousHash = entry.entryHash;
    });
    return entries;
  }

  async append(entry: NewEntry): Promise<CostLedgerEntry> {
    const entries = await this.entries();
    const unsigned = {
      ...entry,
      sequence: entries.length + 1,
      timestamp: new Date().toISOString(),
      previousHash: entries.at(-1)?.entryHash ?? 'GENESIS',
    };
    const complete: CostLedgerEntry = { ...unsigned, entryHash: stableHash(unsigned) };
    await mkdir(dirname(this.path), { recursive: true });
    await appendFile(this.path, `${JSON.stringify(complete)}\n`, { encoding: 'utf8', mode: 0o600 });
    return complete;
  }

  async committedUsd(): Promise<number> {
    const latest = new Map<string, CostLedgerEntry>();
    for (const entry of await this.entries()) latest.set(entry.runId, entry);
    return [...latest.values()].reduce(
      (sum, entry) => sum + (entry.state === 'settled' ? entry.actualUsd ?? entry.reservedUsd : entry.reservedUsd),
      0,
    );
  }
}
