import type { Scalar } from '../domain/types.js';

const forbiddenSegments = new Set(['__proto__', 'prototype', 'constructor']);

function decodeSegment(segment: string): string {
  return segment.replaceAll('~1', '/').replaceAll('~0', '~');
}

function segmentsFor(pointer: string): string[] {
  if (!pointer.startsWith('/') || pointer === '/') {
    throw new Error(`Invalid field path: ${pointer}`);
  }
  const segments = pointer.slice(1).split('/').map(decodeSegment);
  if (segments.some((segment) => segment.length === 0 || forbiddenSegments.has(segment))) {
    throw new Error(`Unsafe field path: ${pointer}`);
  }
  return segments;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return value !== null && typeof value === 'object' && !Array.isArray(value);
}

export function readScalarAtPointer(root: Record<string, unknown>, pointer: string): Scalar {
  const segments = segmentsFor(pointer);
  let cursor: unknown = root;
  for (const segment of segments) {
    if (!isRecord(cursor) || !Object.hasOwn(cursor, segment)) {
      throw new Error(`Field path does not exist: ${pointer}`);
    }
    cursor = cursor[segment];
  }
  if (cursor !== null && !['string', 'number', 'boolean'].includes(typeof cursor)) {
    throw new Error(`Field path does not resolve to a scalar: ${pointer}`);
  }
  return cursor as Scalar;
}

export function writeScalarAtPointer(
  root: Record<string, unknown>,
  pointer: string,
  value: Scalar,
): void {
  const segments = segmentsFor(pointer);
  let cursor: Record<string, unknown> = root;
  for (const segment of segments.slice(0, -1)) {
    const child = cursor[segment];
    if (!isRecord(child)) throw new Error(`Field path does not exist: ${pointer}`);
    cursor = child;
  }
  const leaf = segments.at(-1)!;
  if (!Object.hasOwn(cursor, leaf)) throw new Error(`Field path does not exist: ${pointer}`);
  cursor[leaf] = value;
}
