const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");
const { setAvailability, getAvailability, deleteAvailability, getDoctorAvailabilities } = require("../controllers/availability.controller");

router.post("/", auth(["doctor"]), setAvailability);
router.get("/:doctorId", getAvailability);
router.get('/:doctorId', getDoctorAvailabilities); 
router.delete("/", auth(["doctor"]), deleteAvailability);

module.exports = router;
