const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create admin user
  const adminPassword = await bcrypt.hash('admin123', 10);
  const admin = await prisma.user.upsert({
    where: { phone: '+254712345678' },
    update: {},
    create: {
      name: 'Admin User',
      phone: '+254712345678',
      email: 'admin@rentara.com',
      passwordHash: adminPassword,
      role: 'ADMIN',
    },
  });

  // Create caretaker
  const caretakerPassword = await bcrypt.hash('caretaker123', 10);
  const caretaker = await prisma.user.upsert({
    where: { phone: '+254723456789' },
    update: {},
    create: {
      name: 'John Caretaker',
      phone: '+254723456789',
      email: 'caretaker@rentara.com',
      passwordHash: caretakerPassword,
      role: 'CARETAKER',
    },
  });

  // Create tenant
  const tenantPassword = await bcrypt.hash('tenant123', 10);
  const tenant = await prisma.user.upsert({
    where: { phone: '+254734567890' },
    update: {},
    create: {
      name: 'Jane Tenant',
      phone: '+254734567890',
      email: 'tenant@rentara.com',
      passwordHash: tenantPassword,
      role: 'TENANT',
    },
  });

  // Create property
  const property = await prisma.property.upsert({
    where: { id: 'property-1' },
    update: {},
    create: {
      id: 'property-1',
      name: 'Affordable Housing Estate - Phase 1',
      location: 'Nairobi, Kenya',
      type: 'Affordable Housing',
      description: 'Modern affordable housing units under Kenya AHP',
    },
  });

  // Assign caretaker to property
  await prisma.propertyCaretaker.upsert({
    where: {
      propertyId_userId: {
        propertyId: property.id,
        userId: caretaker.id,
      },
    },
    update: {},
    create: {
      propertyId: property.id,
      userId: caretaker.id,
    },
  });

  // Create units
  const unit1 = await prisma.unit.upsert({
    where: { id: 'unit-1' },
    update: {},
    create: {
      id: 'unit-1',
      propertyId: property.id,
      name: 'Block A, Unit 101',
      rentAmount: 5000,
      status: 'OCCUPIED',
      tenantId: tenant.id,
      description: '2-bedroom unit',
    },
  });

  const unit2 = await prisma.unit.upsert({
    where: { id: 'unit-2' },
    update: {},
    create: {
      id: 'unit-2',
      propertyId: property.id,
      name: 'Block A, Unit 102',
      rentAmount: 5000,
      status: 'VACANT',
      description: '2-bedroom unit',
    },
  });

  const unit3 = await prisma.unit.upsert({
    where: { id: 'unit-3' },
    update: {},
    create: {
      id: 'unit-3',
      propertyId: property.id,
      name: 'Block B, Unit 201',
      rentAmount: 6000,
      status: 'OCCUPIED',
      description: '3-bedroom unit',
    },
  });

  // Create sample payment
  const currentMonth = new Date().getMonth() + 1;
  const currentYear = new Date().getFullYear();

  await prisma.payment.upsert({
    where: {
      tenantId_unitId_month_year: {
        tenantId: tenant.id,
        unitId: unit1.id,
        month: currentMonth - 1 > 0 ? currentMonth - 1 : 12,
        year: currentMonth - 1 > 0 ? currentYear : currentYear - 1,
      },
    },
    update: {},
    create: {
      tenantId: tenant.id,
      unitId: unit1.id,
      amount: unit1.rentAmount,
      month: currentMonth - 1 > 0 ? currentMonth - 1 : 12,
      year: currentMonth - 1 > 0 ? currentYear : currentYear - 1,
      status: 'COMPLETED',
      paidAt: new Date(),
    },
  });

  // Create sample maintenance request
  await prisma.maintenance.create({
    data: {
      unitId: unit1.id,
      description: 'Leaking tap in kitchen',
      createdById: tenant.id,
      status: 'PENDING',
    },
  });

  console.log('✅ Seeding completed!');
  console.log('\n📝 Sample credentials:');
  console.log('Admin: +254712345678 / admin123');
  console.log('Caretaker: +254723456789 / caretaker123');
  console.log('Tenant: +254734567890 / tenant123');
}

main()
  .catch((e) => {
    console.error('❌ Seeding error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });




