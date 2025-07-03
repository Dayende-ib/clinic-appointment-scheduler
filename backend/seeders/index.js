async function runSeeders() {
  console.log('--- SEEDING USERS ---');
  await require('./user.seeder');
  console.log('--- SEEDING AVAILABILITIES ---');
  await require('./availability.seeder');
  console.log('--- SEEDING APPOINTMENTS ---');
  await require('./appointment.seeder');
  console.log('✅ Tous les seeders ont été exécutés !');
}

runSeeders(); 