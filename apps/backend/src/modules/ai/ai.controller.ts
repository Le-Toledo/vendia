import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AIService } from './ai.service';
import { ChatAiDto, GenerateMarketingCopyDto } from './dto/ai-request.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@ApiTags('AI Engine')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AIController {
  constructor(private readonly aiService: AIService) {}

  @Post('chat')
  @ApiOperation({ summary: 'Conversar com o Assistente de IA VendeAI' })
  chat(@Body() dto: ChatAiDto) {
    return this.aiService.processChatMessage(dto);
  }

  @Post('generate-copy')
  @ApiOperation({ summary: 'Gerar anúncios, posts ou descrições para e-commerce (Mercado Livre, Shopee, Amazon)' })
  generateCopy(@Body() dto: GenerateMarketingCopyDto) {
    return this.aiService.generateMarketingCopy(dto);
  }
}
