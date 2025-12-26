const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.controller");

// Route pour obtenir la liste des docteurs
router.get("/doctors", userController.getDoctors);

module.exports = router;
