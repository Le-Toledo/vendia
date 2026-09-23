import { Module } from '@nestjs/common';
import { AIService } from './ai.service';
import { AIController } from './ai.controller';
import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';
import { GeminiProvider } from './providers/gemini.provider';
import { PrismaService } from '../../common/prisma/prisma.service';
import { GroqProvider } from './providers/groq.provider';

@Module({
  controllers: [AIController],
  providers: [
    AIService,
    MockAIProvider,
    OpenAIProvider,
    GeminiProvider,
    GroqProvider,
    PrismaService,
  ],
  exports: [AIService],
})
export class AIModule {}
