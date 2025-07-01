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
  res.status(404).json({ message: 'Route non trouvée' });
});

// Middleware global de gestion d'erreur
app.use((err, req, res, next) => {
  console.error('Erreur serveur:', err);
  res.status(500).json({ message: 'Erreur serveur' });
});

// Connexion MongoDB
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log("✅ Connecté à MongoDB"))
  .catch(err => console.error("❌ Erreur de connexion MongoDB:", err));

// Démarrer serveur
const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Serveur en écoute sur le port ${PORT}`));


