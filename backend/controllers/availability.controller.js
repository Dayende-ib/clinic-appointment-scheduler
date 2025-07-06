const Availability = require("../models/Availability");

// Sauvegarde ou met à jour les créneaux d'un docteur pour une date donnée
exports.setAvailability = async (req, res) => {
  try {
    const doctorId = req.user.id;
    const { date, slots } = req.body;

    if (!date || !Array.isArray(slots) || slots.length === 0) {
      return res.status(400).json({ message: "Missing date or slots" });
    }

    // Vérifie s'il existe déjà une dispo pour cette date
    let availability = await Availability.findOne({ doctorId, date });

    if (availability) {
      availability.slots = slots;
      await availability.save();
    } else {
      availability = await Availability.create({ doctorId, date, slots });
    }

    res.status(200).json({ message: "Availability updated", availability });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Supprimer toutes les disponibilités d'un docteur pour une date donnée
exports.deleteAvailability = async (req, res) => {
  try {
    const doctorId = req.user.id;
    const { date } = req.query;
    if (!date) {
      return res.status(400).json({ message: "Missing date" });
    }
    await Availability.deleteOne({ doctorId, date });
    res.status(200).json({ message: "Availability deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Récupère toutes les disponibilités d'un médecin (toutes les dates)
exports.getDoctorAllAvailabilities = async (req, res) => {
  try {
    const { doctorId } = req.params;
    if (!doctorId) {
      return res.status(400).json({ message: 'doctorId required' });
    }
    const availabilities = await Availability.find({ doctorId });
    res.status(200).json(availabilities);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Nouvelle route : toutes les disponibilités avec info médecin
exports.getAllAvailabilities = async (req, res) => {
  try {
    const availabilities = await Availability.find().populate('doctorId', 'firstname lastname specialty');
    // On formate la réponse pour inclure nom et spécialité
    const result = availabilities.map(avail => ({
      date: avail.date,
      slots: avail.slots,
      doctorName: avail.doctorId ? `${avail.doctorId.firstname} ${avail.doctorId.lastname}` : '',
      specialty: avail.doctorId ? avail.doctorId.specialty : '',
      doctorId: avail.doctorId ? avail.doctorId._id : '',
    }));
    res.status(200).json(result);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// Récupère les créneaux d'un docteur pour une date donnée (format attendu par Flutter)
exports.getDoctorAvailabilitiesbyDate = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { date } = req.query;

    if (!doctorId || !date) {
      return res.status(400).json({ message: "Missing parameters" });
    }

    // On cherche la disponibilité pour ce médecin et cette date
    const availability = await require('../models/Availability').findOne({ doctorId, date });

    if (!availability) {
      // Pour Flutter, on retourne une liste vide de slots
      return res.status(200).json({ doctorId, date, slots: [] });
    }

    // On retourne la liste des slots
    res.status(200).json({
      doctorId,
      date,
      slots: availability.slots
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
