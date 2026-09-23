import { NotFoundException } from '@nestjs/common';
import { QuotesService } from './quotes.service';

describe('QuotesService tenant isolation and transactions', () => {
  const prisma: any = {
    client: { findFirst: jest.fn() },
    quote: { findFirst: jest.fn(), create: jest.fn() },
    $transaction: jest.fn(),
  };
  const service = new QuotesService(prisma, {} as any);

  beforeEach(() => jest.clearAllMocks());

  it('does not allow associating a client owned by another user', async () => {
    prisma.client.findFirst.mockResolvedValue(null);
    await expect(
      service.create('user-a', {
        clientId: 'client-b',
        items: [{ description: 'Serviço', quantity: 1, unitPrice: 10 }],
      }),
    ).rejects.toBeInstanceOf(NotFoundException);
    expect(prisma.client.findFirst).toHaveBeenCalledWith({
      where: { id: 'client-b', userId: 'user-a' },
      select: { id: true },
    });
    expect(prisma.quote.create).not.toHaveBeenCalled();
  });

  it('uses one interactive transaction for item replacement and update', async () => {
    prisma.quote.findFirst.mockResolvedValue({ id: 'quote-a', userId: 'user-a' });
    prisma.client.findFirst.mockResolvedValue({ id: 'client-a' });
    const tx = {
      quoteItem: { deleteMany: jest.fn().mockResolvedValue({ count: 1 }) },
      quote: { update: jest.fn().mockRejectedValue(new Error('write failed')) },
    };
    prisma.$transaction.mockImplementation((callback: any) => callback(tx));
    await expect(
      service.update('user-a', 'quote-a', {
        clientId: 'client-a',
        status: 'DRAFT',
        discount: 0,
        items: [{ description: 'Serviço', quantity: 1, unitPrice: 10 }],
      }),
    ).rejects.toThrow('write failed');
    expect(prisma.$transaction).toHaveBeenCalledTimes(1);
    expect(tx.quoteItem.deleteMany).toHaveBeenCalledWith({ where: { quoteId: 'quote-a' } });
  });
});
