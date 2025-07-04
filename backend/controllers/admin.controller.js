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

// ✅ Supprimer un utilisateur et ses rendez-vous liés
exports.deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    // Supprimer tous les rendez-vous où ce user est patient ou docteur
    await Appointment.deleteMany({ $or: [ { doctorId: id }, { patientId: id } ] });
    await User.findByIdAndDelete(id);
    res.status(200).json({ message: "User and their appointments deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Désactiver un utilisateur (soft delete)
exports.disableUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: "User not found" });

    user.isActive = false;
    await user.save();
    res.status(200).json({ message: "User disabled", user });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// ✅ Réactiver un utilisateur (admin)
exports.enableUser = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await User.findById(id);
    if (!user) return res.status(404).json({ message: "User not found" });
    user.isActive = true;
    await user.save();
    res.status(200).json({ message: "User enabled", user });
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

// ✅ Statistiques globales pour le dashboard admin
exports.getAdminStats = async (req, res) => {
  try {
    const totalUsers = await User.countDocuments();
    const totalPatients = await User.countDocuments({ role: "patient" });
    const totalDoctors = await User.countDocuments({ role: "doctor" });
    const totalAdmins = await User.countDocuments({ role: "admin" });

    const totalAppointments = await Appointment.countDocuments();
    const confirmedAppointments = await Appointment.countDocuments({ status: "confirmed" });
    const canceledAppointments = await Appointment.countDocuments({ status: "canceled" });
    const bookedAppointments = await Appointment.countDocuments({ status: "booked" });
    const completedAppointments = await Appointment.countDocuments({ status: "completed" });

    // Calcul du nombre de rendez-vous du jour
    const startOfDay = new Date();
    startOfDay.setHours(0, 0, 0, 0);
    const endOfDay = new Date();
    endOfDay.setHours(23, 59, 59, 999);
    const todayAppointments = await Appointment.countDocuments({
      datetime: { $gte: startOfDay, $lte: endOfDay }
    });
    // Rendez-vous en attente (status 'booked')
    const pendingAppointments = await Appointment.countDocuments({ status: "booked" });

    res.status(200).json({
      users: {
        total: totalUsers,
        patients: totalPatients,
        doctors: totalDoctors,
        admins: totalAdmins
      },
      appointments: {
        total: totalAppointments,
        confirmed: confirmedAppointments,
        canceled: canceledAppointments,
        booked: bookedAppointments,
        completed: completedAppointments,
        today: todayAppointments,
        pending: pendingAppointments
      }
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};
