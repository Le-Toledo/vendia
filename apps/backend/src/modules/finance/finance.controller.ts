import {
  Controller,
  Get,
  Post,
  Body,
  Param,
  Query,
  Delete,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { FinanceService } from './finance.service';
import { CreateFinanceEntryDto, CreateCategoryDto } from './dto/finance.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { FinanceType } from '@prisma/client';

@ApiTags('Finance')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('finance')
export class FinanceController {
  constructor(private readonly financeService: FinanceService) {}

  @Post('entries')
  @ApiOperation({ summary: 'Registrar nova entrada ou saída financeira' })
  createEntry(@CurrentUser() user: any, @Body() dto: CreateFinanceEntryDto) {
    return this.financeService.createEntry(user.id, dto);
  }

  @Get('entries')
  @ApiOperation({ summary: 'Listar extrato de lançamentos financeiros' })
  @ApiQuery({ name: 'type', required: false, enum: FinanceType })
  @ApiQuery({ name: 'month', required: false, type: Number })
  @ApiQuery({ name: 'year', required: false, type: Number })
  findAllEntries(
    @CurrentUser() user: any,
    @Query('type') type?: FinanceType,
    @Query('month') month?: string,
    @Query('year') year?: string,
  ) {
    return this.financeService.findAllEntries(
      user.id,
      type,
      month ? parseInt(month, 10) : undefined,
      year ? parseInt(year, 10) : undefined,
    );
  }

  @Get('summary')
  @ApiOperation({ summary: 'Obter resumo mensal, saldo total e métricas do dashboard' })
  getSummary(@CurrentUser() user: any) {
    return this.financeService.getSummary(user.id);
  }

  @Post('categories')
  @ApiOperation({ summary: 'Criar nova categoria financeira' })
  createCategory(@CurrentUser() user: any, @Body() dto: CreateCategoryDto) {
    return this.financeService.createCategory(user.id, dto);
  }

  @Get('categories')
  @ApiOperation({ summary: 'Listar categorias de receitas ou despesas' })
  @ApiQuery({ name: 'type', required: false, enum: FinanceType })
  getCategories(@CurrentUser() user: any, @Query('type') type?: FinanceType) {
    return this.financeService.getCategories(user.id, type);
  }

  @Delete('entries/:id')
  @ApiOperation({ summary: 'Excluir lançamento financeiro' })
  deleteEntry(@CurrentUser() user: any, @Param('id') id: string) {
    return this.financeService.deleteEntry(user.id, id);
  }
}
