import { Module } from '@nestjs/common';
import { AIService } from './ai.service';
import { AIController } from './ai.controller';
import { MockAIProvider } from './providers/mock.provider';
import { OpenAIProvider } from './providers/openai.provider';

@Module({
  controllers: [AIController],
  providers: [AIService, MockAIProvider, OpenAIProvider],
  exports: [AIService],
})
export class AIModule {}
