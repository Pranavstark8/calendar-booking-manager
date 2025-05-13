// models/Booking.js
const mongoose = require('mongoose');

const bookingSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  startTime: { type: Date, required: true },
  endTime: { type: Date, required: true },
}, { timestamps: true });

module.exports = mongoose.model('Booking', bookingSchema);
