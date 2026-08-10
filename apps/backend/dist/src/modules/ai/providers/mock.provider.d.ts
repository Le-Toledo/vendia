import { AIProvider, AIResponse } from './ai-provider.interface';
export declare class MockAIProvider implements AIProvider {
    readonly name = "Mock AI Engine (Dev)";
    private readonly logger;
    generateText(prompt: string, context?: Record<string, any>): Promise<AIResponse>;
}
