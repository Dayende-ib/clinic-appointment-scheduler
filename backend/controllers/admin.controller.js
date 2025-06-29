const User = require("../models/User");
const Appointment = require("../models/Appointment");

// ✅ Voir tous les utilisateurs (admin only)
exports.getAllUsers = async (req, res) => {
  try {
    const users = await User.find().select("-password"); // on masque le mot de passe
    res.status(200).json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Supprimer un utilisateur
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    await User.findByIdAndDelete(id);
    res.status(200).json({ message: "Utilisateur supprimé" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Désactiver un utilisateur (soft delete)
exports.disableUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: "Utilisateur non trouvé" });

    user.isActive = false;
    await user.save();
    res.status(200).json({ message: "Utilisateur désactivé", user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Voir tous les rendez-vous
exports.getAllAppointments = async (req, res) => {
  try {
    const appointments = await Appointment.find()
      .populate("doctorId", "firstname lastname email")
      .populate("patientId", "firstname lastname email");

    res.status(200).json(appointments);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
