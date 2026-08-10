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
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { ClientsService } from './clients.service';
import { CreateClientDto, UpdateClientDto } from './dto/client.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@ApiTags('Clients')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('clients')
export class ClientsController {
  constructor(private readonly clientsService: ClientsService) {}

  @Post()
  @ApiOperation({ summary: 'Cadastrar novo cliente' })
  create(@CurrentUser() user: any, @Body() dto: CreateClientDto) {
    return this.clientsService.create(user.id, dto);
  }

  @Get()
  @ApiOperation({ summary: 'Listar todos os clientes com filtro de busca' })
  @ApiQuery({ name: 'search', required: false, description: 'Termo de busca por nome/empresa/cpf/cnpj/email' })
  findAll(@CurrentUser() user: any, @Query('search') search?: string) {
    return this.clientsService.findAll(user.id, search);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Buscar detalhes de um cliente por ID' })
  findOne(@CurrentUser() user: any, @Param('id') id: string) {
    return this.clientsService.findOne(user.id, id);
  }

  @Put(':id')
  @ApiOperation({ summary: 'Atualizar informações de um cliente' })
  update(
    @CurrentUser() user: any,
    @Param('id') id: string,
    @Body() dto: UpdateClientDto,
  ) {
    return this.clientsService.update(user.id, id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Remover cliente' })
  remove(@CurrentUser() user: any, @Param('id') id: string) {
    return this.clientsService.remove(user.id, id);
  }
}
