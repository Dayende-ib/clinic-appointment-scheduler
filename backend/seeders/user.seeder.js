const bcrypt = require('bcryptjs');
const User = require('../models/User');

module.exports = async function() {
  await User.deleteMany({});
  const users = [
    // Admin
    {
      firstname: 'Admin',
      lastname: 'User',
      email: 'admin@caretime.com',
      password: 'admin123',
      role: 'admin',
      country: 'Bénin',
      city: 'Cotonou',
      phone: '+22960000001',
      dateOfBirth: new Date('1990-01-01'),
      gender: 'male',
      isActive: true,
    },
    // Docteurs
    {
      firstname: 'Ougda',
      lastname: 'Ibrahim',
      email: 'ibrahim@caretime.com',
      password: 'doctor123',
      role: 'doctor',
      specialty: 'Cardiology',
      licenseNumber: 'DOC001',
      country: 'Bénin',
      city: 'Ouagadougou',
      phone: '+22670000002',
      dateOfBirth: new Date('1980-05-10'),
      gender: 'female',
      isActive: true,
    },
    {
      firstname: 'Madiega',
      lastname: 'Aida',
      email: 'Aida.mad@caretime.com',
      password: 'doctor123',
      role: 'doctor',
      specialty: 'Dermatology',
      licenseNumber: 'DOC002',
      country: 'Bénin',
      city: 'Parakou',
      phone: '+22960000003',
      dateOfBirth: new Date('1975-09-20'),
      gender: 'male',
      isActive: true,
    },
    // Patients
    {
      firstname: 'Guissou',
      lastname: 'Ali',
      email: 'Ali@caretime.com',
      password: 'patient123',
      role: 'patient',
      country: 'Bénin',
      city: 'Natitingou',
      phone: '+22960000004',
      dateOfBirth: new Date('2000-03-15'),
      gender: 'male',
      isActive: true,
    },
    {
      firstname: 'Diane',
      lastname: 'Sick',
      email: 'diane.sick@caretime.com',
      password: 'patient123',
      role: 'patient',
      country: 'Bénin',
      city: 'Porto-Novo',
      phone: '+22960000005',
      dateOfBirth: new Date('1998-07-22'),
      gender: 'female',
      isActive: true,
    },
  ];
  for (const user of users) {
    const hashed = await bcrypt.hash(user.password, 10);
    await User.create({ ...user, password: hashed });
  }
  console.log('✅ Utilisateurs insérés !');
}; 