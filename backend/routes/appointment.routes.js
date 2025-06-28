const express = require("express");
const router = express.Router();
const { createAppointment, getMyAppointments } = require("../controllers/appointment.controller");
const auth = require("../middlewares/auth.middleware");

router.post("/", auth(["patient"]), createAppointment);            // route pour prendre RDV
router.get("/me", auth(["patient", "doctor"]), getMyAppointments); // voir ses RDV

module.exports = router;
