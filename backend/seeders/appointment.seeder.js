const Appointment = require('../models/Appointment');
const User = require('../models/User');

module.exports = async function() {
  await Appointment.deleteMany({});

  const doctor1 = await User.findOne({ email: 'ibrahim@caretime.com' });
  const doctor2 = await User.findOne({ email: 'Aida.mad@caretime.com' });
  const doctor3 = await User.findOne({ email: 'moussa.kone@caretime.com' });
  const doctor4 = await User.findOne({ email: 'awa.traore@caretime.com' });

  const patient1 = await User.findOne({ email: 'Ali@caretime.com' });
  const patient2 = await User.findOne({ email: 'diane.sick@caretime.com' });
  const patient3 = await User.findOne({ email: 'fatoumata.diallo@caretime.com' });
  const patient4 = await User.findOne({ email: 'mamadou.ndiaye@caretime.com' });

  const appointments = [
    {
      doctorId: doctor1._id,
      patientId: patient1._id,
      datetime: new Date('2025-12-27T10:00:00'),
      status: 'booked',
      reason: 'Consultation annuelle',
      notes: { patientNotes: 'Examen de routine.' },
    },
    {
      doctorId: doctor2._id,
      patientId: patient2._id,
      datetime: new Date('2025-12-27T11:00:00'),
      status: 'booked',
      reason: 'Suivi de traitement',
      notes: { patientNotes: 'Discussion des résultats.' },
    },
    {
      doctorId: doctor3._id,
      patientId: patient3._id,
      datetime: new Date('2025-12-28T09:30:00'),
      status: 'booked',
      reason: 'Problème de peau',
      notes: { patientNotes: 'Eruption cutanée sur le bras.' },
    },
    {
      doctorId: doctor4._id,
      patientId: patient4._id,
      datetime: new Date('2025-12-28T14:00:00'),
      status: 'booked',
      reason: 'Maux de tête persistants',
      notes: { patientNotes: 'Depuis une semaine.' },
    },
    {
      doctorId: doctor1._id,
      patientId: patient2._id,
      datetime: new Date('2025-12-29T16:00:00'),
      status: 'booked',
      reason: 'Consultation pédiatrique',
      notes: { patientNotes: 'Contrôle pour mon enfant.' },
    },
    {
      doctorId: doctor2._id,
      patientId: patient3._id,
      datetime: new Date('2026-01-05T10:00:00'),
      status: 'booked',
      reason: 'Douleur au genou',
      notes: { patientNotes: 'Douleur après une chute.' },
    },
    {
      doctorId: doctor3._id,
      patientId: patient4._id,
      datetime: new Date('2026-01-06T11:30:00'),
      status: 'booked',
      reason: 'Renouvellement ordonnance',
      notes: { patientNotes: 'Pour mes médicaments habituels.' },
    },
    {
      doctorId: doctor4._id,
      patientId: patient1._id,
      datetime: new Date('2026-01-07T15:00:00'),
      status: 'booked',
      reason: 'Visite de contrôle',
      notes: { patientNotes: 'Check-up général.' },
    },
    {
      doctorId: doctor1._id,
      patientId: patient3._id,
      datetime: new Date('2026-01-08T09:00:00'),
      status: 'booked',
      reason: 'Fièvre et toux',
      notes: { patientNotes: 'Symptômes depuis 3 jours.' },
    },
    {
      doctorId: doctor2._id,
      patientId: patient4._id,
      datetime: new Date('2026-01-09T14:30:00'),
      status: 'booked',
      reason: 'Brûlures d\'estomac',
      notes: { patientNotes: 'Surtout après les repas.' },
    },
  ];

  for (const appointment of appointments) {
    await Appointment.create(appointment);
  }

  console.log('✅ Rendez-vous insérés !');
};