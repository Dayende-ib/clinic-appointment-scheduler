const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");
const userController = require("../controllers/user.controller");

const {
  getAllUsers,
  deleteUser,
  disableUser,
  getAllAppointments,
  getAdminStats
} = require("../controllers/admin.controller");

// 🔐 Toutes les routes protégées par le rôle admin
router.get("/users", auth(["admin"]), getAllUsers);
router.delete("/users/:id", auth(["admin"]), deleteUser);
router.patch("/users/:id/disable", auth(["admin"]), disableUser);
router.get("/appointments", auth(["admin"]), getAllAppointments);
router.get("/stats", auth(["admin"]), getAdminStats);
router.get("/doctors", auth(["admin"]), userController.getDoctors);
router.get("/patients", auth(["admin"]), userController.getPatients);

module.exports = router;
