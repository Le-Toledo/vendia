import { Controller, Post, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { AIService } from './ai.service';
import { ChatAiDto, GenerateMarketingCopyDto } from './dto/ai-request.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('AI Engine')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('ai')
export class AIController {
  constructor(private readonly aiService: AIService) {}

  @Post('chat')
  @ApiOperation({ summary: 'Conversar com o Assistente de IA VendeAI' })
  chat(@CurrentUser() user: any, @Body() dto: ChatAiDto) {
    return this.aiService.processChatMessage(user.id, dto);
  }

  @Post('generate-copy')
  @ApiOperation({
    summary: 'Gerar anúncios, posts ou descrições para e-commerce (Mercado Livre, Shopee, Amazon)',
  })
  generateCopy(@CurrentUser() user: any, @Body() dto: GenerateMarketingCopyDto) {
    return this.aiService.generateMarketingCopy(user.id, dto);
  }
}
