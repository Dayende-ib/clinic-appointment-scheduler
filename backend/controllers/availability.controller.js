const Availability = require("../models/Availability");

// Sauvegarde ou met à jour les créneaux d'un docteur pour une date donnée
exports.setAvailability = async (req, res) => {
  try {
    const doctorId = req.user.id;
    const { date, slots } = req.body;

    if (!date || !Array.isArray(slots) || slots.length === 0) {
      return res.status(400).json({ message: "Date ou créneaux manquants" });
    }

    // Vérifie s'il existe déjà une dispo pour cette date
    let availability = await Availability.findOne({ doctorId, date });

    if (availability) {
      availability.slots = slots;
      await availability.save();
    } else {
      availability = await Availability.create({ doctorId, date, slots });
    }

    res.status(200).json({ message: "Disponibilités mises à jour", availability });
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
      return res.status(400).json({ message: "Paramètres manquants" });
    }

    const availability = await Availability.findOne({ doctorId, date });

    if (!availability) {
      return res.status(404).json({ message: "Aucune disponibilité trouvée" });
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
      return res.status(400).json({ message: "Date manquante" });
    }
    await Availability.deleteOne({ doctorId, date });
    res.status(200).json({ message: "Disponibilité supprimée" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
