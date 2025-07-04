const mongoose = require('mongoose');
require('dotenv').config();

async function runSeeders() {
  await mongoose.connect(process.env.MONGO_URI);
  console.log('--- SEEDING USERS ---');
  await require('./user.seeder')();
  console.log('--- SEEDING AVAILABILITIES ---');
  await require('./availability.seeder')();
  console.log('--- SEEDING APPOINTMENTS ---');
  await require('./appointment.seeder')();
  await mongoose.disconnect();
  console.log('✅ Tous les seeders ont été exécutés !');
}

runSeeders(); 