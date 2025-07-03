const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");
const { setAvailability, getAvailability, deleteAvailability, getDoctorAvailabilities } = require("../controllers/availability.controller");

router.post("/", auth(["doctor"]), setAvailability);
router.get("/:doctorId", getAvailability); // ex: /api/availability/DOCTOR_ID?date=2025-07-02
router.get('/:doctorId', getDoctorAvailabilities); // ex: /api/availability/DOCTOR_ID?date=2024-06-10
router.delete("/", auth(["doctor"]), deleteAvailability);

module.exports = router;
