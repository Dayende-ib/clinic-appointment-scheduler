const mongoose = require('mongoose');
const Availability = require('../models/Availability');
const User = require('../models/User');
require('dotenv').config();

async function seedAvailabilities() {
  await mongoose.connect(process.env.MONGO_URI);
  await Availability.deleteMany({});

  // Récupérer les docteurs
  const doctors = await User.find({ role: 'doctor' });
  const today = new Date();

  for (const doctor of doctors) {
    for (let i = 0; i < 5; i++) { // 5 jours à partir d'aujourd'hui
      const date = new Date(today);
      date.setDate(today.getDate() + i);
      const slots = [
        { time: '08:00-09:00', available: true },
        { time: '09:00-10:00', available: true },
        { time: '10:00-11:00', available: true },
        { time: '14:00-15:00', available: true },
        { time: '15:00-16:00', available: true },
      ];
      await Availability.create({
        doctorId: doctor._id,
        date: date.toISOString().split('T')[0],
        slots,
      });
    }
  }
  console.log('✅ Disponibilités insérées !');
  await mongoose.disconnect();
}

seedAvailabilities().catch(err => {
  console.error('Erreur lors du seed des disponibilités :', err);
  process.exit(1);
}); 