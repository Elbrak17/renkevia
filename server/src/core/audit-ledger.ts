import { stableHash } from './canonical.js';
import type { AuditEvent } from '../domain/types.js';

const genesisHash = 'GENESIS';

function eventHash(event: Omit<AuditEvent, 'eventHash'>): string {
  return stableHash(event);
}

export class AuditLedger {
  readonly #events: AuditEvent[] = [];

  constructor(readonly runId: string) {
    if (runId.length === 0) throw new Error('Audit ledger requires a run id.');
  }

  append(input: {
    timestamp: string;
    actor: string;
    action: string;
    input: unknown;
    output: unknown;
  }): AuditEvent {
    const sequence = this.#events.length + 1;
    const unsigned: Omit<AuditEvent, 'eventHash'> = {
      id: `EVT-${String(sequence).padStart(4, '0')}`,
      runId: this.runId,
      sequence,
      timestamp: input.timestamp,
      actor: input.actor,
      action: input.action,
      inputHash: stableHash(input.input),
      outputHash: stableHash(input.output),
      previousEventHash: this.#events.at(-1)?.eventHash ?? genesisHash,
    };
    const event = Object.freeze({ ...unsigned, eventHash: eventHash(unsigned) });
    this.#events.push(event);
    return structuredClone(event);
  }

  entries(): AuditEvent[] {
    return structuredClone(this.#events);
  }

  verify(): boolean {
    return AuditLedger.verify(this.#events);
  }

  static verify(events: readonly AuditEvent[]): boolean {
    let previous = genesisHash;
    for (let index = 0; index < events.length; index += 1) {
      const event = events[index]!;
      const { eventHash: recordedHash, ...unsigned } = event;
      if (event.sequence !== index + 1) return false;
      if (event.previousEventHash !== previous) return false;
      if (eventHash(unsigned) !== recordedHash) return false;
      previous = recordedHash;
    }
    return true;
  }
}
