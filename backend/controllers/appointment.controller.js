const Appointment = require("../models/Appointment");

exports.createAppointment = async (req, res) => {
  try {
    const { doctorId, datetime, reason, patientNotes } = req.body;
    const patientId = req.user.id; // On récupère depuis le token

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

exports.getMyAppointments = async (req, res) => {
  try {
    const userId = req.user.id;
    const role = req.user.role;

    const filter = role === "doctor"
      ? { doctorId: userId }
      : { patientId: userId };

    const appointments = await Appointment.find(filter)
      .populate("doctorId", "name specialty")
      .populate("patientId", "name");

    res.status(200).json(appointments);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
};
