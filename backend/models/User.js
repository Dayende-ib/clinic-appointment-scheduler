const mongoose = require("mongoose");

const userSchema = new mongoose.Schema({
  firstname: { type: String, required: true },
  lastname: { type: String, required: true },
  email: { type: String, required: true, unique: true, lowercase: true },
  phone: { type: String, unique: true }, // optionnel
  password: { type: String, required: true },
  role: {
    type: String,
    enum: ["patient", "doctor", "admin"],
    default: "patient"
  },
  specialty: { type: String }, // optionnel si patient
  licenseNumber: { type: String }, // optionnel si patient
  country: { type: String, required: true },
  city: { type: String },
  dateOfBirth: { type: Date, required: true },
  gender: {
    type: String,
    enum: ["male", "female", "other", "prefer_not_to_say"],
    required: true
  },
  isActive: { type: Boolean, default: true }

}, { timestamps: true });

module.exports = mongoose.model("User", userSchema);
