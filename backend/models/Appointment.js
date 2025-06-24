const mongoose = require("mongoose");

const appointmentSchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  patientId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  datetime: {
    type: Date,
    required: true
  },
  status: {
    type: String,
    enum: ["pending", "confirmed", "booked", "completed", "canceled"],
    default: "booked"
  },
  reason: {
    type: String,
    required: true
  },
  notes: {
    doctorNotes: { type: String },
    patientNotes: { type: String }
  }
}, { timestamps: true });

module.exports = mongoose.model("Appointment", appointmentSchema);
