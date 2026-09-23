import { Controller, Get, Post, Body, Param, Query, Put, Delete, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ContractsService } from './contracts.service';
import { CreateContractDto, UpdateContractDto } from './dto/contract.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { PaginationDto } from '../../common/dto/pagination.dto';
import { IsEnum, IsOptional } from 'class-validator';
import { ContractStatus } from '@prisma/client';

class ContractListQueryDto extends PaginationDto {
  @IsOptional()
  @IsEnum(ContractStatus)
  status?: ContractStatus;
}

@ApiTags('Contracts')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('contracts')
export class ContractsController {
  constructor(private readonly contractsService: ContractsService) {}

  @Post()
  @ApiOperation({ summary: 'Criar novo contrato' })
  create(@CurrentUser() user: any, @Body() dto: CreateContractDto) {
    return this.contractsService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar contratos do usuário com filtro por status' })
  @ApiQuery({
    name: 'status',
    required: false,
    enum: ['DRAFT', 'ACTIVE', 'COMPLETED', 'CANCELLED'],
  })
  findAll(@CurrentUser() user: any, @Query() query: ContractListQueryDto) {
    return this.contractsService.findAll(user.id, query.status, query);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Obter detalhes de um contrato por ID' })
  findOne(@CurrentUser() user: any, @Param('id') id: string) {
    return this.contractsService.findOne(user.id, id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar contrato' })
  update(@CurrentUser() user: any, @Param('id') id: string, @Body() dto: UpdateContractDto) {
    return this.contractsService.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Excluir contrato' })
  remove(@CurrentUser() user: any, @Param('id') id: string) {
    return this.contractsService.remove(user.id, id);
  }
}
