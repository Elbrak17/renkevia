import type { ResponsesApiResponse, ResponsesUsage } from './types.js';

export class OpenAIProtocolError extends Error {
  constructor(message: string, readonly responseId?: string) {
    super(message);
    this.name = 'OpenAIProtocolError';
  }
}

export function responseText(response: ResponsesApiResponse): string {
  if (typeof response.output_text === 'string' && response.output_text.trim()) {
    return response.output_text;
  }
  const texts: string[] = [];
  for (const item of response.output ?? []) {
    const content = item.content;
    if (!Array.isArray(content)) continue;
    for (const part of content) {
      if (part && typeof part === 'object' && typeof (part as { text?: unknown }).text === 'string') {
        texts.push((part as { text: string }).text);
      }
    }
  }
  if (!texts.length) throw new OpenAIProtocolError('Response contained no text output.', response.id);
  return texts.join('\n');
}

export function parseResponseJson(response: ResponsesApiResponse): unknown {
  try {
    return JSON.parse(responseText(response));
  } catch (error) {
    if (error instanceof OpenAIProtocolError) throw error;
    throw new OpenAIProtocolError('Response text was not valid JSON.', response.id);
  }
}

export function normalizedUsage(usage?: ResponsesUsage): Required<ResponsesUsage> & {
  input_tokens_details: { cached_tokens: number };
} {
  return {
    input_tokens: Math.max(0, usage?.input_tokens ?? 0),
    output_tokens: Math.max(0, usage?.output_tokens ?? 0),
    input_tokens_details: { cached_tokens: Math.max(0, usage?.input_tokens_details?.cached_tokens ?? 0) },
  };
}
