const mongoose = require("mongoose");

const slotSchema = new mongoose.Schema({
  time: { type: String, required: true },
  available: { type: Boolean, default: true }
});

const availabilitySchema = new mongoose.Schema({
  doctorId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true
  },
  date: { type: Date, required: true },
  slots: [slotSchema]
}, { timestamps: true });

module.exports = mongoose.model("Availability", availabilitySchema);
