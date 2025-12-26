const Availability = require('../models/Availability');
const User = require('../models/User');

module.exports = async function() {
  await Availability.deleteMany({});

  const doctor1 = await User.findOne({ email: 'ibrahim@caretime.com' });
  const doctor2 = await User.findOne({ email: 'Aida.mad@caretime.com' });
  const doctor3 = await User.findOne({ email: 'moussa.kone@caretime.com' });
  const doctor4 = await User.findOne({ email: 'awa.traore@caretime.com' });

  const availabilities = [
    {
      doctorId: doctor1._id,
      date: new Date('2025-12-27'),
      slots: [
        { time: '10:00-11:00', available: true },
        { time: '11:00-12:00', available: true },
      ],
    },
    {
      doctorId: doctor2._id,
      date: new Date('2025-12-27'),
      slots: [
        { time: '11:00-12:00', available: true },
        { time: '12:00-13:00', available: true },
      ],
    },
    {
      doctorId: doctor3._id,
      date: new Date('2025-12-28'),
      slots: [
        { time: '09:30-10:30', available: true },
        { time: '10:30-11:30', available: true },
      ],
    },
    {
      doctorId: doctor4._id,
      date: new Date('2025-12-28'),
      slots: [
        { time: '14:00-15:00', available: true },
        { time: '15:00-16:00', available: true },
      ],
    },
    {
      doctorId: doctor1._id,
      date: new Date('2025-12-29'),
      slots: [
        { time: '16:00-17:00', available: true },
        { time: '17:00-18:00', available: true },
      ],
    },
    {
      doctorId: doctor2._id,
      date: new Date('2026-01-05'),
      slots: [
        { time: '10:00-11:00', available: true },
        { time: '11:00-12:00', available: true },
      ],
    },
    {
      doctorId: doctor3._id,
      date: new Date('2026-01-06'),
      slots: [
        { time: '11:30-12:30', available: true },
        { time: '12:30-13:30', available: true },
      ],
    },
    {
      doctorId: doctor4._id,
      date: new Date('2026-01-07'),
      slots: [
        { time: '15:00-16:00', available: true },
        { time: '16:00-17:00', available: true },
      ],
    },
    {
      doctorId: doctor1._id,
      date: new Date('2026-01-08'),
      slots: [
        { time: '09:00-10:00', available: true },
        { time: '10:00-11:00', available: true },
      ],
    },
    {
      doctorId: doctor2._id,
      date: new Date('2026-01-09'),
      slots: [
        { time: '14:30-15:30', available: true },
        { time: '15:30-16:30', available: true },
      ],
    },
  ];

  for (const availability of availabilities) {
    await Availability.create(availability);
  }

  console.log('✅ Disponibilités insérées !');
};