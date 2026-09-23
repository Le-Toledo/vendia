import { Controller, Get, Put, Body, UseGuards, Delete } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto, UpdateSettingsDto } from './dto/user.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { IsBoolean, IsOptional, IsString, IsIn } from 'class-validator';

class AiConsentDto {
  @IsBoolean() approved: boolean;
  @IsString() @IsOptional() version?: string;
  @IsString() @IsOptional() provider?: string;
}
class DeleteAccountDto {
  @IsIn(['EXCLUIR'])
  confirmation: 'EXCLUIR';
}

@ApiTags('Profile & Settings')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Obter dados do perfil do usuário logado' })
  getProfile(@CurrentUser() user: any) {
    return this.usersService.getProfile(user.id);
  }

  @Put('profile')
  @ApiOperation({ summary: 'Atualizar dados pessoais, empresa e logotipo' })
  updateProfile(@CurrentUser() user: any, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateProfile(user.id, dto);
  }

  @Put('settings')
  @ApiOperation({ summary: 'Atualizar configurações de tema, idioma e IA' })
  updateSettings(@CurrentUser() user: any, @Body() dto: UpdateSettingsDto) {
    return this.usersService.updateSettings(user.id, dto);
  }

  @Put('ai-consent')
  aiConsent(@CurrentUser() user: any, @Body() dto: AiConsentDto) {
    return this.usersService.setAiConsent(user.id, dto.approved, dto.version, dto.provider);
  }

  @Get('export')
  @ApiOperation({ summary: 'Exportar dados pessoais do usuário autenticado' })
  exportData(@CurrentUser() user: any) {
    return this.usersService.exportData(user.id);
  }

  @Delete('me')
  @ApiOperation({ summary: 'Excluir permanentemente a conta e seus dados' })
  deleteAccount(@CurrentUser() user: any, @Body() dto: DeleteAccountDto) {
    return this.usersService.deleteAccount(user.id, dto.confirmation);
  }
}
