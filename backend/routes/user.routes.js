const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.controller");
const auth = require('../middlewares/auth.middleware');

router.post("/register", userController.register);
router.post("/login", userController.login);
router.get('/me', auth(), userController.getMe);
router.put('/me', auth(), userController.updateMe);
router.get('/doctors', userController.getDoctors);
router.get('/:id', userController.getUserById);

module.exports = router;
