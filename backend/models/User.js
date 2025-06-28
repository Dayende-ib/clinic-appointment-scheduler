const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  lastname: { type: String, required: true, trim: true },
  firstname: { type: String, required: true, trim: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  password: { type: String, required: true, minlength: 6 },
  dateOfBirth: { type: Date, required: true },
  gender: { type: String, enum: ["Male", "Female", "Other"], required: true },
  address: {
    country: { type: String, required: false, trim: true },
    city: { type: String, required: false, trim: true }
  },
  role: { type: String, enum: ["patient", "doctor", "admin"], default: "patient" },
  specialty: { type: String }, // optionnel pour les médecins
  licenseNumber: { type: String }, // optionnel pour les médecins
  isActive: { type: Boolean, default: true }
}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);
