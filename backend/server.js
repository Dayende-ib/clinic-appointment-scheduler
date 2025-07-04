// backend/server.js
require("dotenv").config();
const express = require("express");
const mongoose = require("mongoose");
const helmet = require("helmet");
const cors = require("cors");
const Appointment = require("./models/Appointment");

const app = express();

// Middlewares
app.use(express.json());
app.use(helmet());
app.use(cors());

// Middleware global de log des requêtes
app.use((req, res, next) => {
  console.log(`[${req.method}] ${req.originalUrl}`);
  next();
});

// Vérification des variables d'environnement critiques
if (!process.env.JWT_SECRET || !process.env.MONGO_URI) {
  console.error('❌ JWT_SECRET ou MONGO_URI manquant dans .env');
  process.exit(1);
}

// Routes
app.use("/api/users", require("./routes/user.routes"));
app.use("/api/appointments", require("./routes/appointment.routes"));
app.use("/api/availability", require("./routes/availability.routes"));
app.use("/api/admin", require("./routes/admin.routes"));

// Gestion des routes inconnues (404)
app.use((req, res, next) => {
  res.status(404).json({ message: 'Route not found' });
});

// Middleware global de gestion d'erreur
app.use((err, req, res, next) => {
  console.error('Erreur serveur:', err);
  res.status(500).json({ message: 'Server error' });
});

// Connexion MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ Connecté à MongoDB"))
  .catch(err => console.error("❌ Erreur de connexion MongoDB:", err));

// Cron : Met à jour les rendez-vous confirmés passés en 'completed'
setInterval(async () => {
  const now = new Date();
  try {
    const result = await Appointment.updateMany(
      {
        status: "confirmed",
        datetime: { $lt: now }
      },
      { $set: { status: "completed" } }
    );
    if (result.modifiedCount > 0) {
      console.log(`[CRON] ${result.modifiedCount} rendez-vous passés à 'completed'`);
    }
  } catch (err) {
    console.error("[CRON] Erreur lors de la mise à jour des rendez-vous :", err);
  }
}, 5 * 60 * 1000); // toutes les 5 minutes

// Démarrer serveur
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Serveur en écoute sur le port ${PORT}`));


