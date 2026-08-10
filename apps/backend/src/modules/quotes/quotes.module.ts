import { Module } from '@nestjs/common';
import { QuotesService } from './quotes.service';
import { QuotesController } from './quotes.controller';
import { PdfService } from './pdf.service';
import { PrismaService } from '../../common/prisma/prisma.service';

@Module({
  controllers: [QuotesController],
  providers: [QuotesService, PdfService, PrismaService],
  exports: [QuotesService],
})
export class QuotesModule {}
