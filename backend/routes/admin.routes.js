const express = require("express");
const router = express.Router();
const auth = require("../middlewares/auth.middleware");

const {
  getAllUsers,
  deleteUser,
  disableUser,
  getAllAppointments
} = require("../controllers/admin.controller");

// 🔐 Toutes les routes protégées par le rôle admin
router.get("/users", auth(["admin"]), getAllUsers);
router.delete("/users/:id", auth(["admin"]), deleteUser);
router.patch("/users/:id/disable", auth(["admin"]), disableUser);
router.get("/appointments", auth(["admin"]), getAllAppointments);

module.exports = router;
