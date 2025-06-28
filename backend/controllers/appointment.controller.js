const Appointment = require("../models/Appointment");

// ➤ Créer un rendez-vous (patient)
exports.createAppointment = async (req, res) => {
  try {
    const { doctorId, datetime, reason, patientNotes } = req.body;
    const patientId = req.user.id; // Récupéré via le middleware d'authentification

    const appointment = new Appointment({
      doctorId,
      patientId,
      datetime,
      reason,
      notes: { patientNotes }
    });

    await appointment.save();

    res.status(201).json({
      message: "Rendez-vous créé",
      appointment
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};

// ➤ Récupérer les rendez-vous du patient ou du médecin connecté
exports.getMyAppointments = async (req, res) => {
  try {
    const userId = req.user.id;
    const role = req.user.role;

    // Si c'est un médecin, on filtre par doctorId
    // Sinon, on filtre par patientId
    const filter = role === "doctor"
      ? { doctorId: userId }
      : { patientId: userId };

    const appointments = await Appointment.find(filter)
      .populate("doctorId", "name specialty") // pour afficher les infos du médecin
      .populate("patientId", "name");         // pour afficher les infos du patient

    res.status(200).json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
