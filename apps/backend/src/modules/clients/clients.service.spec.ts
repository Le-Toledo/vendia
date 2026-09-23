import { ConflictException, NotFoundException } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { ClientsService } from './clients.service';

describe('Client deletion', () => {
  const prisma: any = { client: { findFirst: jest.fn(), delete: jest.fn() } };
  const service = new ClientsService(prisma);
  beforeEach(() => jest.resetAllMocks());

  it.each(['quotes', 'contracts'])('preserves clients with linked %s', async (relation) => {
    prisma.client.findFirst.mockResolvedValue({
      quotes: [],
      contracts: [],
      [relation]: [{ id: 'link' }],
    });
    await expect(service.remove('owner', 'client')).rejects.toThrow(ConflictException);
    expect(prisma.client.delete).not.toHaveBeenCalled();
  });

  it('does not delete another user’s client', async () => {
    prisma.client.findFirst.mockResolvedValue(null);
    await expect(service.remove('owner', 'client')).rejects.toThrow(NotFoundException);
    expect(prisma.client.findFirst).toHaveBeenCalledWith(
      expect.objectContaining({ where: { id: 'client', userId: 'owner' } }),
    );
    expect(prisma.client.delete).not.toHaveBeenCalled();
  });

  it('deletes an unlinked client with an ownership filter', async () => {
    prisma.client.findFirst.mockResolvedValue({ quotes: [], contracts: [] });
    prisma.client.delete.mockResolvedValue({ id: 'client' });
    await expect(service.remove('owner', 'client')).resolves.toEqual({ id: 'client' });
    expect(prisma.client.delete).toHaveBeenCalledWith({ where: { id: 'client', userId: 'owner' } });
  });

  it('reports a relationship added concurrently as a clear conflict', async () => {
    prisma.client.findFirst.mockResolvedValue({ quotes: [], contracts: [] });
    prisma.client.delete.mockRejectedValue(
      new Prisma.PrismaClientKnownRequestError('foreign key', {
        code: 'P2003',
        clientVersion: '5.8.0',
      }),
    );
    await expect(service.remove('owner', 'client')).rejects.toThrow(
      'Este cliente não pode ser excluído enquanto possuir orçamentos ou contratos vinculados.',
    );
  });

  it('does not mislabel unrelated database failures as linked records', async () => {
    prisma.client.findFirst.mockResolvedValue({ quotes: [], contracts: [] });
    prisma.client.delete.mockRejectedValue(new Error('database unavailable'));
    await expect(service.remove('owner', 'client')).rejects.toThrow('database unavailable');
  });
});
