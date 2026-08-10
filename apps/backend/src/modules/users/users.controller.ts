import { Controller, Get, Put, Body, UseGuards } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto, UpdateSettingsDto } from './dto/user.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

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
}
