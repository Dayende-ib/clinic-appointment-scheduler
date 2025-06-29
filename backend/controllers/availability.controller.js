const Availability = require("../models/Availability");

exports.setAvailability = async (req, res) => {
  try {
    const doctorId = req.user.id;
    const { date, slots } = req.body;

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

exports.getAvailability = async (req, res) => {
  try {
    const { doctorId } = req.params;
    const { date } = req.query;

    const availability = await Availability.findOne({ doctorId, date });

    if (!availability) {
      return res.status(404).json({ message: "Aucune disponibilité trouvée" });
    }

    res.status(200).json(availability);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
