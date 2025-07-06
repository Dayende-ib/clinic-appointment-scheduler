const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");
const { setAvailability, deleteAvailability, getDoctorAvailabilitiesbyDate, getDoctorAllAvailabilities, getAllAvailabilities } = require("../controllers/availability.controller");

router.post("/", auth(["doctor"]), setAvailability);
router.delete("/", auth(["doctor"]), deleteAvailability);
router.get("/all", getAllAvailabilities);
router.get("/all/:doctorId", getDoctorAllAvailabilities);
router.get("/:doctorId", getDoctorAvailabilitiesbyDate);

module.exports = router;
