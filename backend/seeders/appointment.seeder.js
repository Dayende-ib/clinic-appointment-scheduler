const Appointment = require('../models/Appointment');
const User = require('../models/User');
const Availability = require('../models/Availability');

module.exports = async function() {
  await Appointment.deleteMany({});
  const doctors = await User.find({ role: 'doctor' });
  const patients = await User.find({ role: 'patient' });
  // Pour chaque docteur, prendre le premier créneau de chaque jour et créer un rendez-vous avec un patient
  for (const doctor of doctors) {
    const availabilities = await Availability.find({ doctorId: doctor._id });
    for (let i = 0; i < availabilities.length && i < patients.length; i++) {
      const slot = availabilities[i].slots[0];
      if (!slot) continue;
      // Correction de la date
      const dateObj = availabilities[i].date instanceof Date
        ? availabilities[i].date
        : new Date(availabilities[i].date);
      const [hour, minute] = slot.time.split('-')[0].split(':');
      const datetime = new Date(
        dateObj.getFullYear(),
        dateObj.getMonth(),
        dateObj.getDate(),
        parseInt(hour, 10),
        parseInt(minute, 10)
      );
      await Appointment.create({
        doctorId: doctor._id,
        patientId: patients[i]._id,
        datetime,
        status: 'booked',
        reason: 'Consultation de test',
        notes: { patientNotes: 'Je souhaite un contrôle.' },
      });
    }
  }
  console.log('✅ Rendez-vous insérés !');
}; 