import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  Put,
  Delete,
  UseGuards,
  Res,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { Response } from 'express';
import { QuotesService } from './quotes.service';
import { CreateQuoteDto, UpdateQuoteDto } from './dto/quote.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Quotes')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('quotes')
export class QuotesController {
  constructor(private readonly quotesService: QuotesService) {}

  @Post()
  @ApiOperation({ summary: 'Criar novo orçamento' })
  create(@CurrentUser() user: any, @Body() dto: CreateQuoteDto) {
    return this.quotesService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar orçamentos do usuário com filtro por status' })
  @ApiQuery({ name: 'status', required: false, enum: ['DRAFT', 'SENT', 'APPROVED', 'REJECTED'] })
  findAll(@CurrentUser() user: any, @Query('status') status?: string) {
    return this.quotesService.findAll(user.id, status);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obter detalhes de um orçamento' })
  findOne(@CurrentUser() user: any, @Param('id') id: string) {
    return this.quotesService.findOne(user.id, id);
  }

  @Post(':id/duplicate')
  @ApiOperation({ summary: 'Duplicar um orçamento existente como rascunho' })
  duplicate(@CurrentUser() user: any, @Param('id') id: string) {
    return this.quotesService.duplicate(user.id, id);
  }

  @Get(':id/pdf')
  @ApiOperation({ summary: 'Gerar e baixar o PDF do orçamento' })
  async downloadPdf(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Res() res: Response,
  ) {
    const pdfBuffer = await this.quotesService.generatePdf(user.id, id);
    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="Orcamento_${id}.pdf"`,
      'Content-Length': pdfBuffer.length,
    });
    res.end(pdfBuffer);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar orçamento' })
  update(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateQuoteDto,
  ) {
    return this.quotesService.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Excluir orçamento' })
  remove(@CurrentUser() user: any, @Param('id') id: string) {
    return this.quotesService.remove(user.id, id);
  }
}
