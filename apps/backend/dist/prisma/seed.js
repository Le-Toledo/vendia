"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const client_1 = require("@prisma/client");
const bcrypt = require("bcrypt");
const prisma = new client_1.PrismaClient();
async function main() {
    console.log('🌱 Starting VendeAI database seed...');
    const passwordHash = await bcrypt.hash('Senha123!', 10);
    const demoUser = await prisma.user.upsert({
        where: { email: 'demo@vendeai.com.br' },
        update: {},
        create: {
            email: 'demo@vendeai.com.br',
            passwordHash,
            role: client_1.Role.ADMIN,
            profile: {
                create: {
                    fullName: 'Carlos Eduardo Silva',
                    companyName: 'Silva Tech Services',
                    cpfCnpj: '12.345.678/0001-90',
                    phone: '(11) 98765-4321',
                    address: 'Av. Paulista, 1000 - Sala 42',
                    city: 'São Paulo',
                    state: 'SP',
                    zipCode: '01310-100',
                },
            },
            settings: {
                create: {
                    themeMode: 'dark',
                    language: 'pt-BR',
                    aiProvider: 'mock',
                },
            },
        },
    });
    console.log(`👤 Demo User created/verified: ${demoUser.email}`);
    const categoriesData = [
        { name: 'Vendas de Serviços', type: client_1.FinanceType.INCOME, colorHex: '#10B981' },
        { name: 'Vendas de Produtos', type: client_1.FinanceType.INCOME, colorHex: '#06B6D4' },
        { name: 'Consultoria', type: client_1.FinanceType.INCOME, colorHex: '#6366F1' },
        { name: 'Aluguel & Infraestrutura', type: client_1.FinanceType.EXPENSE, colorHex: '#EF4444' },
        { name: 'Marketing & Anúncios', type: client_1.FinanceType.EXPENSE, colorHex: '#F59E0B' },
        { name: 'Software & Ferramentas', type: client_1.FinanceType.EXPENSE, colorHex: '#8B5CF6' },
        { name: 'Impostos & Taxas', type: client_1.FinanceType.EXPENSE, colorHex: '#64748B' },
    ];
    for (const cat of categoriesData) {
        await prisma.category.upsert({
            where: {
                userId_name_type: {
                    userId: demoUser.id,
                    name: cat.name,
                    type: cat.type,
                },
            },
            update: {},
            create: {
                userId: demoUser.id,
                name: cat.name,
                type: cat.type,
                colorHex: cat.colorHex,
            },
        });
    }
    console.log('🏷️  Standard Finance Categories created.');
    const client = await prisma.client.create({
        data: {
            userId: demoUser.id,
            name: 'Empresa Exemplo Ltda',
            companyName: 'Exemplo Digital',
            email: 'contato@exemplodigital.com',
            phone: '(11) 97777-8888',
            cpfCnpj: '98.765.432/0001-10',
            address: 'Rua Faria Lima, 500',
            notes: 'Cliente preferencial de desenvolvimento web e branding.',
        },
    });
    console.log(`🏢 Demo Client created: ${client.name}`);
    await prisma.quote.create({
        data: {
            userId: demoUser.id,
            clientId: client.id,
            codeNumber: 'ORC-2026-001',
            status: 'APPROVED',
            subtotal: 4500.0,
            discount: 500.0,
            total: 4000.0,
            notes: 'Orçamento para criação de aplicativo mobile com IA.',
            items: {
                create: [
                    {
                        description: 'Desenvolvimento de App Mobile (iOS e Android)',
                        quantity: 1,
                        unitPrice: 3500.0,
                        totalPrice: 3500.0,
                    },
                    {
                        description: 'Integração com IA Generativa',
                        quantity: 1,
                        unitPrice: 1000.0,
                        totalPrice: 1000.0,
                    },
                ],
            },
        },
    });
    console.log('📋 Demo Quote created.');
    console.log('✅ Database seed completed successfully!');
}
main()
    .catch((e) => {
    console.error('❌ Error seeding database:', e);
    process.exit(1);
})
    .finally(async () => {
    await prisma.$disconnect();
});
//# sourceMappingURL=seed.js.map