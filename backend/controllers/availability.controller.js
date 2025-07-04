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

// Récupère les créneaux d'un docteur pour une date donnée
exports.getAvailability = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { date } = req.query;

    if (!doctorId || !date) {
      return res.status(400).json({ message: "Missing parameters" });
    }

    const availability = await Availability.findOne({ doctorId, date });

    if (!availability) {
      return res.status(404).json({ message: "No availability found" });
    }

    res.status(200).json(availability);
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

exports.getDoctorAvailabilities = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { date } = req.query;
    console.log('[getDoctorAvailabilities] doctorId:', doctorId, 'date:', date);
    if (!doctorId || !date) {
      console.log('[getDoctorAvailabilities] Paramètres manquants');
      return res.status(400).json({ message: 'doctorId and date required' });
    }
    const start = new Date(date + 'T00:00:00.000Z');
    const end = new Date(date + 'T23:59:59.999Z');
    console.log('[getDoctorAvailabilities] Recherche entre', start, 'et', end);
    const availability = await Availability.findOne({
      doctorId,
      date: { $gte: start, $lte: end }
    });
    console.log('[getDoctorAvailabilities] Résultat MongoDB:', availability);
    if (!availability) {
      return res.status(200).json({ doctorId, date, slots: [] });
    }
    res.status(200).json({ doctorId, date, slots: availability.slots });
  } catch (err) {
    console.error('[getDoctorAvailabilities] Erreur:', err);
    res.status(500).json({ message: err.message });
  }
};
