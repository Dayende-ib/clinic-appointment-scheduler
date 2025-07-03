const User = require("../models/User");
const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");

exports.register = async (req, res) => {
  try {
    const {
      lastname,
      firstname,
      email,
      password,
      dateOfBirth,
      gender,
      role,
      specialty,
      licenseNumber
    } = req.body;

    const existingUser = await User.findOne({ email });
    if (existingUser) return res.status(400).json({ message: "Email déjà utilisé" });

    const hashedPassword = await bcrypt.hash(password, 10);
    const newUser = await User.create({
      lastname,
      firstname,
      email,
      password: hashedPassword,
      dateOfBirth,
      gender,
      role,
      specialty,
      licenseNumber
    });

    // Générer un token JWT
    const token = jwt.sign(
      { id: newUser._id, role: newUser.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(201).json({
      message: "Utilisateur enregistré",
      token,
      user: {
        id: newUser._id,
        lastname: newUser.lastname,
        firstname: newUser.firstname,
        email: newUser.email,
        role: newUser.role,
        specialty: newUser.specialty,
        licenseNumber: newUser.licenseNumber
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return res.status(400).json({ message: "Email non trouvé" });

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Mot de passe incorrect" });

    const token = jwt.sign(
      { id: user._id, role: user.role },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(200).json({
      token,
      user: {
        id: user._id,
        lastname: user.lastname,
        firstname: user.firstname,
        email: user.email,
        role: user.role,
        specialty: user.specialty,
        licenseNumber: user.licenseNumber
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Récupérer le profil de l'utilisateur connecté
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user.id).select('-password');
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

// Modifier le profil de l'utilisateur connecté
exports.updateMe = async (req, res) => {
  try {
    const fields = ['firstname', 'lastname', 'specialty', 'email', 'phone', 'city'];
    const updates = {};
    fields.forEach(f => { if (req.body[f] !== undefined) updates[f] = req.body[f]; });

    // Empêcher la modification de l'email en double
    if (updates.email) {
      const emailExists = await User.findOne({ email: updates.email, _id: { $ne: req.user.id } });
      if (emailExists) return res.status(400).json({ message: 'Email déjà utilisé' });
    }

    const user = await User.findByIdAndUpdate(
      req.user.id,
      { $set: updates },
      { new: true, runValidators: true, context: 'query' }
    ).select('-password');
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });
    // Retourne un objet filtré
    res.json({
      id: user._id,
      lastname: user.lastname,
      firstname: user.firstname,
      email: user.email,
      role: user.role,
      specialty: user.specialty,
      licenseNumber: user.licenseNumber,
      phone: user.phone,
      city: user.city
    });
  } catch (err) {
    res.status(500).json({ message: 'Erreur serveur' });
  }
};

exports.getDoctors = async (req, res) => {
  console.log('Appel GET /api/users/doctors');
  try {
    const doctors = await require('../models/User').find({ role: "doctor", isActive: true }).select("-password");
    console.log('Résultat MongoDB (doctors):', doctors);
    res.status(200).json(doctors);
  } catch (err) {
    console.error('Erreur dans getDoctors:', err);
    res.status(500).json({ message: err.message });
  }
};

exports.getUserById = async (req, res) => {
  try {
    const user = await require('../models/User').findById(req.params.id).select('-password');
    if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });
    res.status(200).json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

exports.getPatients = async (req, res) => {
  try {
    const patients = await require('../models/User').find({ role: "patient", isActive: true }).select("-password");
    res.status(200).json(patients);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
