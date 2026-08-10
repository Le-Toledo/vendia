import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';
import { ChatAiDto, GenerateMarketingCopyDto } from './dto/ai-request.dto';
export declare class AIService {
    private readonly mockProvider;
    private readonly openAiProvider;
    private provider;
    private readonly logger;
    constructor(mockProvider: MockAIProvider, openAiProvider: OpenAIProvider);
    processChatMessage(dto: ChatAiDto): Promise<import("./providers/ai-provider.interface").AIResponse>;
    generateMarketingCopy(dto: GenerateMarketingCopyDto): Promise<import("./providers/ai-provider.interface").AIResponse>;
}
