const DEFAULT_BASE_URL = 'https://api.openai.com/v1';
const DEFAULT_TIMEOUT_MS = 120_000;

export const MODELS = Object.freeze([
  'gpt-5.6-sol',
  'gpt-5.6-terra',
  'gpt-5.6-luna',
]);

export class ProbeError extends Error {
  constructor(message, details = {}) {
    super(message);
    this.name = 'ProbeError';
    this.details = details;
  }
}

export function environmentStatus() {
  const major = Number.parseInt(process.versions.node.split('.')[0], 10);
  return {
    node: process.version,
    nodeSupported: Number.isFinite(major) && major >= 20,
    apiKeyConfigured: Boolean(process.env.OPENAI_API_KEY),
    baseUrl: process.env.OPENAI_BASE_URL || DEFAULT_BASE_URL,
  };
}

export function requireApiKey() {
  const key = process.env.OPENAI_API_KEY;
  if (!key) {
    throw new ProbeError('OPENAI_API_KEY is not configured.', {
      kind: 'missing_api_key',
      remediation: 'Inject the key through a secure environment and rerun the live probe.',
    });
  }
  return key;
}

export async function createResponse(body, { beta, timeoutMs = DEFAULT_TIMEOUT_MS } = {}) {
  const apiKey = requireApiKey();
  const baseUrl = (process.env.OPENAI_BASE_URL || DEFAULT_BASE_URL).replace(/\/$/, '');
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), timeoutMs);

  let response;
  try {
    response = await fetch(`${baseUrl}/responses`, {
      method: 'POST',
      headers: {
        authorization: `Bearer ${apiKey}`,
        'content-type': 'application/json',
        ...(beta ? { 'openai-beta': beta } : {}),
      },
      body: JSON.stringify(body),
      signal: controller.signal,
    });
  } catch (error) {
    const kind = error?.name === 'AbortError' ? 'timeout' : 'network_error';
    throw new ProbeError(`Responses API request failed before a response was received (${kind}).`, {
      kind,
    });
  } finally {
    clearTimeout(timeout);
  }

  const requestId = response.headers.get('x-request-id') || undefined;
  let payload;
  try {
    payload = await response.json();
  } catch {
    throw new ProbeError('Responses API returned a non-JSON body.', {
      kind: 'invalid_response',
      httpStatus: response.status,
      requestId,
    });
  }

  if (!response.ok) {
    throw new ProbeError('Responses API rejected the probe.', {
      kind: 'api_error',
      httpStatus: response.status,
      requestId,
      errorType: payload?.error?.type,
      errorCode: payload?.error?.code,
      errorParam: payload?.error?.param,
    });
  }

  return { payload, requestId };
}

export function extractOutputText(response) {
  if (typeof response?.output_text === 'string' && response.output_text.length > 0) {
    return response.output_text;
  }
  return (response?.output || [])
    .filter((item) => item?.type === 'message')
    .flatMap((item) => item.content || [])
    .filter((part) => part?.type === 'output_text')
    .map((part) => part.text)
    .join('');
}

export function usageSummary(response) {
  const details = response?.usage?.input_tokens_details || {};
  return {
    inputTokens: response?.usage?.input_tokens,
    outputTokens: response?.usage?.output_tokens,
    cachedTokens: details.cached_tokens,
    cacheWriteTokens: details.cache_write_tokens,
  };
}

export function assertProbe(condition, message, details = {}) {
  if (!condition) throw new ProbeError(message, { kind: 'assertion_failed', ...details });
}

export async function runLiveProbe(name, probe) {
  const startedAt = new Date().toISOString();
  try {
    const evidence = await probe();
    console.log(JSON.stringify({ name, status: 'verified', startedAt, evidence }, null, 2));
  } catch (error) {
    const details = error instanceof ProbeError
      ? error.details
      : { kind: 'unexpected_error', errorType: error?.name };
    const status = details.kind === 'missing_api_key' ? 'blocked' : 'failed';
    console.error(JSON.stringify({ name, status, startedAt, error: details }, null, 2));
    process.exitCode = status === 'blocked' ? 2 : 1;
  }
}

