import { Controller, Get, Post, Body, Param, Query, Delete, Put, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { FinanceService } from './finance.service';
import { CreateFinanceEntryDto, CreateCategoryDto, UpdateFinanceEntryDto } from './dto/finance.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { FinanceType } from '@prisma/client';
import { PaginationDto } from '../../common/dto/pagination.dto';
import { Type } from 'class-transformer';
import { IsEnum, IsInt, IsOptional, Max, Min } from 'class-validator';

class FinanceListQueryDto extends PaginationDto {
  @IsOptional()
  @IsEnum(FinanceType)
  type?: FinanceType;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(12)
  month?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(2000)
  @Max(2100)
  year?: number;
}

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
  findAllEntries(@CurrentUser() user: any, @Query() query: FinanceListQueryDto) {
    return this.financeService.findAllEntries(user.id, query.type, query.month, query.year, query);
  }

  @Put('entries/:id')
  updateEntry(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateFinanceEntryDto,
  ) {
    return this.financeService.updateEntry(user.id, id, dto);
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
