const mongoose = require('mongoose');
const Appointment = require('../models/Appointment');
const User = require('../models/User');
const Availability = require('../models/Availability');
require('dotenv').config();

async function seedAppointments() {
  await mongoose.connect(process.env.MONGO_URI);
  await Appointment.deleteMany({});

  const doctors = await User.find({ role: 'doctor' });
  const patients = await User.find({ role: 'patient' });

  // Pour chaque docteur, prendre le premier créneau de chaque jour et créer un rendez-vous avec un patient
  for (const doctor of doctors) {
    const availabilities = await Availability.find({ doctorId: doctor._id });
    for (let i = 0; i < availabilities.length && i < patients.length; i++) {
      const slot = availabilities[i].slots[0];
      if (!slot) continue;
      await Appointment.create({
        doctorId: doctor._id,
        patientId: patients[i]._id,
        datetime: new Date(availabilities[i].date + 'T' + slot.time.split('-')[0] + ':00'),
        status: 'booked',
        reason: 'Consultation de test',
        notes: { patientNotes: 'Je souhaite un contrôle.' },
      });
    }
  }
  console.log('✅ Rendez-vous insérés !');
  await mongoose.disconnect();
}

seedAppointments().catch(err => {
  console.error('Erreur lors du seed des rendez-vous :', err);
  process.exit(1);
}); 