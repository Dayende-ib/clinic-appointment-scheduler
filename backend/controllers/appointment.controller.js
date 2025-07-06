const Appointment = require("../models/Appointment");

// ✅ Créer un rendez-vous (patient)
exports.createAppointment = async (req, res) => {
  try {
    const { doctorId, datetime, reason, patientNotes } = req.body;
    const patientId = req.user.id;

    // Vérifier que la date/heure est dans le futur
    if (new Date(datetime) < new Date()) {
      return res.status(400).json({ message: "Cannot book a past slot." });
    }

    // Empêcher la double réservation du même créneau
    const existing = await Appointment.findOne({
      doctorId,
      datetime,
      status: { $ne: "canceled" }
    });
    if (existing) {
      return res.status(400).json({ message: "This slot is already booked." });
    }

    const appointment = new Appointment({
      doctorId,
      patientId,
      datetime,
      reason,
      notes: { patientNotes }
    });

    await appointment.save();
    res.status(201).json({ message: "Appointment created", appointment });
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
      return res.status(400).json({ message: "Invalid status" });
    }

    const appointment = await Appointment.findById(id);
    if (!appointment) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    //  Règles de rôle
    if (status === "canceled") {
      // Le patient peut annuler son propre rendez-vous
      if (role === "patient" && appointment.patientId.toString() === userId) {
        // OK
      }
      // Le médecin peut aussi annuler/refuser un rendez-vous dont il est responsable
      else if (role === "doctor" && appointment.doctorId.toString() === userId) {
        // OK
      }
      else {
        return res.status(403).json({ message: "Only the patient or the concerned doctor can cancel this appointment" });
      }
    }

    if (["confirmed", "completed"].includes(status)) {
      if (role !== "doctor" || appointment.doctorId.toString() !== userId) {
        return res.status(403).json({ message: "Only the concerned doctor can confirm or complete this appointment" });
      }
    }

    appointment.status = status;
    await appointment.save();

    res.status(200).json({ message: "Status updated", appointment });
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
      return res.status(400).json({ message: "New date/time required" });
    }

    const appointment = await Appointment.findById(id);
    if (!appointment) {
      return res.status(404).json({ message: "Appointment not found" });
    }

    // Seul le patient ou le médecin concerné peut reprogrammer
    if (
      appointment.patientId.toString() !== userId &&
      appointment.doctorId.toString() !== userId
    ) {
      return res.status(403).json({ message: "Access denied" });
    }

    // Vérifier qu'il n'y a pas déjà un rendez-vous à ce créneau pour ce médecin
    const existing = await Appointment.findOne({
      doctorId: appointment.doctorId,
      datetime,
      status: { $ne: "canceled" },
      _id: { $ne: id }
    });
    if (existing) {
      return res.status(400).json({ message: "This slot is already booked." });
    }

    appointment.datetime = datetime;
    appointment.status = "booked"; // repasse en attente de validation
    await appointment.save();

    res.status(200).json({ message: "Appointment rescheduled", appointment });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// Suppression d'un rendez-vous par l'admin
exports.deleteAppointmentByAdmin = async (req, res) => {
  try {
    const { id } = req.params;
    console.log('[ADMIN] Suppression RDV, id reçu :', id);
    const deleted = await Appointment.findByIdAndDelete(id);
    console.log('[ADMIN] Résultat suppression :', deleted);
    if (!deleted) {
      return res.status(404).json({ message: "Appointment not found" });
    }
    res.status(200).json({ message: "Appointment deleted" });
  } catch (err) {
    console.error('[ADMIN] Erreur suppression RDV :', err);
    res.status(500).json({ message: err.message });
  }
};

