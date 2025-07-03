const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');
require('dotenv').config();

const users = [
  // Admin
  {
    firstname: 'Admin',
    lastname: 'User',
    email: 'admin@caretime.com',
    password: 'admin123',
    role: 'admin',
    country: 'Bénin',
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
    dateOfBirth: new Date('1998-07-22'),
    gender: 'female',
    isActive: true,
  },
];

async function seedUsers() {
  await mongoose.connect(process.env.MONGO_URI);
  await User.deleteMany({});
  for (const user of users) {
    const hashed = await bcrypt.hash(user.password, 10);
    await User.create({ ...user, password: hashed });
  }
  console.log('✅ Utilisateurs insérés !');
  await mongoose.disconnect();
}

seedUsers().catch(err => {
  console.error('Erreur lors du seed des utilisateurs :', err);
  process.exit(1);
}); 