// backend/server.js
require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const helmet = require("helmet");
const cors = require("cors");

const app = express();

// Middlewares
app.use(express.json());
app.use(helmet());
app.use(cors());

// Routes
app.use("/api/users", require("./routes/user.routes"));

// Connexion MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ Connecté à MongoDB"))
  .catch(err => console.error("❌ Erreur de connexion MongoDB:", err));

// Démarrer serveur
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Serveur en écoute sur le port ${PORT}`));

app.use("/api/appointments", require("./routes/appointment.routes"));
