import { AIProvider, AIResponse } from './ai-provider.interface';
export declare class OpenAIProvider implements AIProvider {
    readonly name = "OpenAI GPT-4o Provider";
    private readonly logger;
    generateText(prompt: string, context?: Record<string, any>): Promise<AIResponse>;
}
