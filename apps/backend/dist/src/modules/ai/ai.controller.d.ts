import { AIService } from './ai.service';
import { ChatAiDto, GenerateMarketingCopyDto } from './dto/ai-request.dto';
export declare class AIController {
    private readonly aiService;
    constructor(aiService: AIService);
    chat(dto: ChatAiDto): Promise<import("./providers/ai-provider.interface").AIResponse>;
    generateCopy(dto: GenerateMarketingCopyDto): Promise<import("./providers/ai-provider.interface").AIResponse>;
}
