const Appointment = require("../models/Appointment");

// ✅ Créer un rendez-vous (patient)
exports.createAppointment = async (req, res) => {
  try {
    const { doctorId, datetime, reason, patientNotes } = req.body;
    const patientId = req.user.id;

    // Empêcher la double réservation du même créneau
    const existing = await Appointment.findOne({
      doctorId,
      datetime,
      status: { $ne: "canceled" }
    });
    if (existing) {
      return res.status(400).json({ message: "Ce créneau est déjà réservé." });
    }

    const appointment = new Appointment({
      doctorId,
      patientId,
      datetime,
      reason,
      notes: { patientNotes }
    });

    await appointment.save();
    res.status(201).json({ message: "Rendez-vous créé", appointment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✅ Voir les rendez-vous du patient ou du médecin
exports.getMyAppointments = async (req, res) => {
  try {
    const userId = req.user.id;
    const role = req.user.role;

    const filter = role === "doctor"
      ? { doctorId: userId }
      : { patientId: userId };

    const appointments = await Appointment.find(filter)
      .populate("doctorId", "firstname lastname specialty")
      .populate("patientId", "firstname lastname");

    res.status(200).json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✅ Mettre à jour le statut d'un rendez-vous
exports.updateAppointmentStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const { role, id: userId } = req.user;

    const allowedStatuses = ["booked", "confirmed", "completed", "canceled"];
    if (!allowedStatuses.includes(status)) {
      return res.status(400).json({ message: "Statut invalide" });
    }

    const appointment = await Appointment.findById(id);
    if (!appointment) {
      return res.status(404).json({ message: "Rendez-vous non trouvé" });
    }

    //  Règles de rôle
    if (status === "canceled") {
      if (role !== "patient" || appointment.patientId.toString() !== userId) {
        return res.status(403).json({ message: "Seul le patient peut annuler ce rendez-vous" });
      }
    }

    if (["confirmed", "completed"].includes(status)) {
      if (role !== "doctor" || appointment.doctorId.toString() !== userId) {
        return res.status(403).json({ message: "Seul le médecin concerné peut confirmer ou compléter ce rendez-vous" });
      }
    }

    appointment.status = status;
    await appointment.save();

    res.status(200).json({ message: "Statut mis à jour", appointment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ✅ Reprogrammer un rendez-vous (patient ou médecin)
exports.rescheduleAppointment = async (req, res) => {
  try {
    const { id } = req.params;
    const { datetime } = req.body;
    const { role, id: userId } = req.user;

    if (!datetime) {
      return res.status(400).json({ message: "Nouvelle date/heure requise" });
    }

    const appointment = await Appointment.findById(id);
    if (!appointment) {
      return res.status(404).json({ message: "Rendez-vous non trouvé" });
    }

    // Seul le patient ou le médecin concerné peut reprogrammer
    if (
      appointment.patientId.toString() !== userId &&
      appointment.doctorId.toString() !== userId
    ) {
      return res.status(403).json({ message: "Accès refusé" });
    }

    // Vérifier qu'il n'y a pas déjà un rendez-vous à ce créneau pour ce médecin
    const existing = await Appointment.findOne({
      doctorId: appointment.doctorId,
      datetime,
      status: { $ne: "canceled" },
      _id: { $ne: id }
    });
    if (existing) {
      return res.status(400).json({ message: "Ce créneau est déjà réservé." });
    }

    appointment.datetime = datetime;
    appointment.status = "booked"; // repasse en attente de validation
    await appointment.save();

    res.status(200).json({ message: "Rendez-vous reprogrammé", appointment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

