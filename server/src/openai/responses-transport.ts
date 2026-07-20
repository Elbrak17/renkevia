import type { ResponsesApiResponse, ResponsesRequest, ResponsesTransport } from './types.js';

export class OpenAITransportError extends Error {
  constructor(
    message: string,
    readonly status: number,
    readonly requestId?: string,
  ) {
    super(message);
    this.name = 'OpenAITransportError';
  }
}

export interface OpenAITransportOptions {
  apiKey?: string;
  baseUrl?: string;
  fetchImpl?: typeof fetch;
}

export class HttpResponsesTransport implements ResponsesTransport {
  private readonly apiKey: string;
  private readonly baseUrl: string;
  private readonly fetchImpl: typeof fetch;

  constructor(options: OpenAITransportOptions = {}) {
    this.apiKey = options.apiKey ?? process.env.OPENAI_API_KEY ?? '';
    this.baseUrl = (options.baseUrl ?? process.env.OPENAI_BASE_URL ?? 'https://api.openai.com/v1').replace(/\/$/, '');
    this.fetchImpl = options.fetchImpl ?? fetch;
  }

  async create(
    request: ResponsesRequest,
    options: { beta?: string; signal?: AbortSignal } = {},
  ): Promise<ResponsesApiResponse> {
    if (!this.apiKey) throw new OpenAITransportError('OPENAI_API_KEY is not configured.', 0);
    const response = await this.fetchImpl(`${this.baseUrl}/responses`, {
      method: 'POST',
      headers: {
        authorization: `Bearer ${this.apiKey}`,
        'content-type': 'application/json',
        ...(options.beta ? { 'openai-beta': options.beta } : {}),
      },
      body: JSON.stringify(request),
      signal: options.signal,
    });
    const requestId = response.headers.get('x-request-id') ?? undefined;
    const payload = await response.json().catch(() => ({})) as Record<string, unknown>;
    if (!response.ok) {
      const upstream = payload.error;
      const code = upstream && typeof upstream === 'object' && typeof (upstream as { code?: unknown }).code === 'string'
        ? (upstream as { code: string }).code
        : 'upstream_error';
      throw new OpenAITransportError(`OpenAI request failed (${code}).`, response.status, requestId);
    }
    return payload as unknown as ResponsesApiResponse;
  }
}
