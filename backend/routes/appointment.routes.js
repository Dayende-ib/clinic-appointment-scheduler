const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");

const {
  createAppointment,
  getMyAppointments,
  updateAppointmentStatus,
  rescheduleAppointment
} = require("../controllers/appointment.controller");

// ✅ Route pour créer un rendez-vous (seulement patient)
router.post("/", auth(["patient"]), createAppointment);

// ✅ Route pour consulter les rendez-vous du patient ou médecin connecté
router.get("/me", auth(["patient", "doctor"]), getMyAppointments);

// ✅ Route pour mettre à jour le statut d’un rendez-vous
router.patch("/:id/status", auth(["patient", "doctor"]), updateAppointmentStatus);

// ✅ Route pour reprogrammer un rendez-vous (patient ou médecin)
router.patch("/:id/reschedule", auth(["patient", "doctor"]), rescheduleAppointment);

module.exports = router;
