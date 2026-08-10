export interface AIResponse {
  content: string;
  actionType?: 'create_quote' | 'create_contract' | 'create_copy' | 'financial_answer' | 'none';
  structuredData?: any;
}

export interface AIProvider {
  readonly name: string;
  generateText(prompt: string, context?: Record<string, any>): Promise<AIResponse>;
}
