const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");
const { setAvailability, getAvailability } = require("../controllers/availability.controller");

router.post("/", auth(["doctor"]), setAvailability);
router.get("/:doctorId", getAvailability); // ex: /api/availability/DOCTOR_ID?date=2025-07-02

module.exports = router;
