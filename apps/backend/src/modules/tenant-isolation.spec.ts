import { NotFoundException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GUARDS_METADATA } from '@nestjs/common/constants';
import { ClientsService } from './clients/clients.service';
import { QuotesService } from './quotes/quotes.service';
import { ContractsService } from './contracts/contracts.service';
import { FinanceService } from './finance/finance.service';
import { UsersService } from './users/users.service';
import { ClientsController } from './clients/clients.controller';
import { QuotesController } from './quotes/quotes.controller';
import { ContractsController } from './contracts/contracts.controller';
import { FinanceController } from './finance/finance.controller';
import { UsersController } from './users/users.controller';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

// No database or production API is accessed by this suite.
const model = () => ({
  findFirst: jest.fn(),
  findUnique: jest.fn(),
  findMany: jest.fn().mockResolvedValue([]),
  count: jest.fn().mockResolvedValue(0),
  create: jest.fn(),
  update: jest.fn(),
  upsert: jest.fn(),
  delete: jest.fn(),
  deleteMany: jest.fn(),
  aggregate: jest.fn().mockResolvedValue({ _sum: { amount: null } }),
});
const pagination = { page: 1, pageSize: 20 };
const owner = 'account-a';
const foreign = 'record-owned-by-b';

describe('Authenticated user isolation', () => {
  let db: any;
  let clients: ClientsService;
  let quotes: QuotesService;
  let contracts: ContractsService;
  let finance: FinanceService;
  let users: UsersService;
  beforeEach(() => {
    db = {
      client: model(),
      quote: model(),
      contract: model(),
      financeEntry: model(),
      category: model(),
      user: model(),
      profile: model(),
      setting: model(),
      auditLog: model(),
    };
    db.$transaction = jest.fn((input: any) =>
      typeof input === 'function' ? input(db) : Promise.all(input),
    );
    clients = new ClientsService(db);
    quotes = new QuotesService(db, {} as any);
    contracts = new ContractsService(db);
    finance = new FinanceService(db);
    users = new UsersService(db, new ConfigService(), { revoke: jest.fn() } as any);
  });

  it.each([
    ClientsController,
    QuotesController,
    ContractsController,
    FinanceController,
    UsersController,
  ])('%p requires a validated JWT', (controller) => {
    expect(Reflect.getMetadata(GUARDS_METADATA, controller)).toContain(JwtAuthGuard);
  });

  it('scopes every collection, count, category and dashboard query to the authenticated owner', async () => {
    await clients.findAll(owner, 'name', pagination);
    await quotes.findAll(owner, 'DRAFT', pagination);
    await contracts.findAll(owner, 'ACTIVE', pagination);
    await finance.findAllEntries(owner, undefined, 9, 2026, pagination);
    await finance.getCategories(owner);
    await finance.getSummary(owner);
    for (const name of ['client', 'quote', 'contract', 'financeEntry', 'category']) {
      expect(db[name].findMany).toHaveBeenCalled();
      for (const [query] of db[name].findMany.mock.calls) expect(query.where.userId).toBe(owner);
      for (const [query] of db[name].count.mock.calls) expect(query.where.userId).toBe(owner);
    }
    expect(db.financeEntry.aggregate).toHaveBeenCalledTimes(2);
    for (const [query] of db.financeEntry.aggregate.mock.calls)
      expect(query.where.userId).toBe(owner);
  });

  it.each(['client', 'quote', 'contract'])(
    'rejects foreign %s reads, edits and deletion',
    async (name) => {
      const service: any = { client: clients, quote: quotes, contract: contracts }[name];
      db[name].findFirst.mockResolvedValue(null);
      await expect(service.findOne(owner, foreign)).rejects.toBeInstanceOf(NotFoundException);
      await expect(service.update(owner, foreign, {})).rejects.toBeInstanceOf(NotFoundException);
      await expect(service.remove(owner, foreign)).rejects.toBeInstanceOf(NotFoundException);
      for (const [query] of db[name].findFirst.mock.calls)
        expect(query.where).toEqual({ id: foreign, userId: owner });
      expect(db[name].update).not.toHaveBeenCalled();
      expect(db[name].delete).not.toHaveBeenCalled();
    },
  );

  it.each(['quote', 'contract'])(
    'allows deletion of the owner’s %s only after checking ownership',
    async (name) => {
      const service: any = { quote: quotes, contract: contracts }[name];
      db[name].findFirst.mockResolvedValue({ id: 'owned', userId: owner });
      db[name].delete.mockResolvedValue({ id: 'owned' });
      await expect(service.remove(owner, 'owned')).resolves.toEqual({ id: 'owned' });
      expect(db[name].findFirst).toHaveBeenCalledWith(
        expect.objectContaining({ where: { id: 'owned', userId: owner } }),
      );
      expect(db[name].delete).toHaveBeenCalledWith({ where: { id: 'owned' } });
    },
  );

  it('cannot create a quote or contract for another owner’s client', async () => {
    db.client.findFirst.mockResolvedValue(null);
    await expect(quotes.create(owner, { clientId: foreign, items: [] })).rejects.toBeInstanceOf(
      NotFoundException,
    );
    await expect(
      contracts.create(owner, { clientId: foreign, title: 'Contract', content: 'Text', value: 1 }),
    ).rejects.toBeInstanceOf(NotFoundException);
    expect(db.quote.create).not.toHaveBeenCalled();
    expect(db.contract.create).not.toHaveBeenCalled();
  });

  it('rejects foreign financial edits/deletions and foreign category associations', async () => {
    db.financeEntry.findFirst.mockResolvedValue(null);
    await expect(finance.updateEntry(owner, foreign, {} as any)).rejects.toBeInstanceOf(
      NotFoundException,
    );
    await expect(finance.deleteEntry(owner, foreign)).rejects.toBeInstanceOf(NotFoundException);
    for (const [query] of db.financeEntry.findFirst.mock.calls)
      expect(query.where).toEqual({ id: foreign, userId: owner });
    db.category.findFirst.mockResolvedValue(null);
    await expect(
      finance.createEntry(owner, {
        categoryId: foreign,
        description: 'Entry',
        amount: 1,
        type: 'INCOME',
      }),
    ).rejects.toBeInstanceOf(NotFoundException);
    expect(db.category.findFirst).toHaveBeenCalledWith({
      where: { id: foreign, userId: owner },
      select: { id: true },
    });
    expect(db.financeEntry.create).not.toHaveBeenCalled();
    expect(db.financeEntry.update).not.toHaveBeenCalled();
    expect(db.financeEntry.delete).not.toHaveBeenCalled();
  });

  it('scopes profile, settings and export to the authenticated user and excludes credentials', async () => {
    db.user.findUnique.mockResolvedValue({ id: owner });
    await users.getProfile(owner);
    await users.exportData(owner);
    for (const [query] of db.user.findUnique.mock.calls) {
      expect(query.where).toEqual({ id: owner });
      for (const key of ['passwordHash', 'refreshToken', 'appleRefreshToken'])
        expect(query.select[key]).toBeUndefined();
    }
    await users.updateProfile(owner, { fullName: 'Account A' });
    await users.updateSettings(owner, {});
    for (const name of ['profile', 'setting']) {
      expect(db[name].upsert).toHaveBeenCalledWith(
        expect.objectContaining({
          where: { userId: owner },
          create: expect.objectContaining({ userId: owner }),
        }),
      );
    }
  });

  it('account deletion targets only the authenticated user, including dependent records', async () => {
    db.user.findUnique.mockResolvedValue({ id: owner });
    await users.deleteAccount(owner, 'EXCLUIR');
    for (const name of ['quote', 'contract', 'auditLog'])
      expect(db[name].deleteMany).toHaveBeenCalledWith({ where: { userId: owner } });
    expect(db.user.delete).toHaveBeenCalledWith({ where: { id: owner } });
  });
});
