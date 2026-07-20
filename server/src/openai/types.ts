import type { PatchIR, ReviewFinding, SimulationReport } from '../domain/types.js';

export const OPENAI_MODELS = {
  luna: 'gpt-5.6-luna',
  terra: 'gpt-5.6-terra',
  sol: 'gpt-5.6-sol',
} as const;

export type ModelTier = keyof typeof OPENAI_MODELS;
export type OpenAIModel = (typeof OPENAI_MODELS)[ModelTier];

export interface ModelRoute {
  model: OpenAIModel;
  reasoning: 'low' | 'medium' | 'high' | 'max';
  purpose:
    | 'classify'
    | 'extract'
    | 'communications'
    | 'patch'
    | 'programmatic_simulation'
    | 'multi_agent_audit'
    | 'computer_use';
  maxOutputTokens: number;
}

export interface ResponsesUsage {
  input_tokens?: number;
  output_tokens?: number;
  input_tokens_details?: { cached_tokens?: number };
}

export interface ResponsesApiResponse {
  id: string;
  status?: string;
  output?: Array<Record<string, unknown>>;
  output_text?: string;
  usage?: ResponsesUsage;
  error?: { code?: string; message?: string } | null;
}

export interface ResponsesRequest {
  model: string;
  input: unknown;
  store?: boolean;
  reasoning?: { effort: string };
  max_output_tokens?: number;
  text?: Record<string, unknown>;
  tools?: Array<Record<string, unknown>>;
  tool_choice?: unknown;
  previous_response_id?: string;
  [key: string]: unknown;
}

export interface ResponsesTransport {
  create(
    request: ResponsesRequest,
    options?: { beta?: string; signal?: AbortSignal },
  ): Promise<ResponsesApiResponse>;
}

export interface TokenCeiling {
  maxInputTokens: number;
  maxOutputTokens: number;
}

export interface PatchSynthesisResult {
  responseId: string;
  patch: PatchIR;
  compiledDiffs: number;
  provenanceCoverage: number;
}

export interface ProgrammaticSimulationResult {
  responseId: string;
  report: SimulationReport;
  invokedPathwayIds: string[];
}

export interface SpecialistAuditResult {
  responseId: string;
  reviews: ReviewFinding[];
  rootVerdict: 'accept' | 'revise';
}
