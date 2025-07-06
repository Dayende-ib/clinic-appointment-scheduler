const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");
const userController = require("../controllers/user.controller");
const adminController = require("../controllers/admin.controller");
const appointmentController = require("../controllers/appointment.controller");

const {
  getAllUsers,
  deleteUser,
  disableUser,
<<<<<<< HEAD
  enableUser,
  getAllAppointments
=======
  getAllAppointments,
  getAdminStats
>>>>>>> Android
} = require("../controllers/admin.controller");

// 🔐 Toutes les routes protégées par le rôle admin
router.get("/users", auth(["admin"]), getAllUsers);
router.delete("/users/:id", auth(["admin"]), deleteUser);
router.patch("/users/:id/disable", auth(["admin"]), disableUser);
router.patch("/users/:id/enable", auth(["admin"]), adminController.enableUser);
router.get("/appointments", auth(["admin"]), getAllAppointments);
<<<<<<< HEAD
router.patch("/users/:id/enable", auth(["admin"]), enableUser);

=======
router.get("/stats", auth(["admin"]), getAdminStats);
router.get("/doctors", auth(["admin"]), userController.getDoctors);
router.get("/patients", auth(["admin"]), userController.getPatients);
router.delete("/appointments/:id", auth(["admin"]), appointmentController.deleteAppointmentByAdmin);
>>>>>>> Android

module.exports = router;

