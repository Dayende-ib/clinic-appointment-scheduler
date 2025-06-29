const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",              // lien vers un utilisateur (médecin)
    required: true
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",              // lien vers un utilisateur (patient)
    required: true
  },
  datetime: {
    type: Date,
    required: true            // date et heure du rendez-vous
  },
  status: {
    type: String,
    enum: ["pending", "confirmed", "booked", "completed", "canceled"],
    default: "booked"
  },
  reason: {
    type: String,
    required: true            // pourquoi le patient prend rendez-vous
  },
  notes: {
    doctorNotes: { type: String },
    patientNotes: { type: String }
  }
}, { timestamps: true });     // Ajoute createdAt et updatedAt automatiquement

module.exports = mongoose.model("Appointment", appointmentSchema);
