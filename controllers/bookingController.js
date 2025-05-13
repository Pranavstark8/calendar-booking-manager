const Booking = require('../models/Booking');
const dayjs = require('dayjs');

exports.getAll = async (req, res) => {
  const bookings = await Booking.find().sort({ startTime: 1 });
  res.json(bookings);
};

exports.getById = async (req, res) => {
  const booking = await Booking.findById(req.params.bookingId);
  if (!booking) return res.status(404).json({ error: 'Booking not found' });
  res.json(booking);
};

exports.create = async (req, res) => {
  const { userId, startTime, endTime } = req.body;
  if (!userId || !startTime || !endTime)
    return res.status(400).json({ error: 'Missing fields' });

  if (!dayjs(startTime).isValid() || !dayjs(endTime).isValid())
    return res.status(400).json({ error: 'Invalid date format' });

  if (dayjs(endTime).isBefore(startTime))
    return res.status(400).json({ error: 'End time must be after start time' });

  const conflict = await Booking.findOne({
    $or: [
      { startTime: { $lt: endTime }, endTime: { $gt: startTime } }
    ]
  });

  if (conflict)
    return res.status(409).json({ error: 'Booking conflict with existing' });

  const booking = new Booking({ userId, startTime, endTime });
  await booking.save();
  res.status(201).json(booking);
};

exports.update = async (req, res) => {
  const { startTime, endTime } = req.body;
  const bookingId = req.params.bookingId;

  if (!dayjs(startTime).isValid() || !dayjs(endTime).isValid())
    return res.status(400).json({ error: 'Invalid date format' });

  if (dayjs(endTime).isBefore(startTime))
    return res.status(400).json({ error: 'End time must be after start time' });

  const conflict = await Booking.findOne({
    _id: { $ne: bookingId },
    startTime: { $lt: endTime },
    endTime: { $gt: startTime }
  });

  if (conflict)
    return res.status(409).json({ error: 'Updated booking conflicts with existing' });

  const updated = await Booking.findByIdAndUpdate(
    bookingId,
    { startTime, endTime },
    { new: true }
  );
  if (!updated) return res.status(404).json({ error: 'Booking not found' });
  res.json(updated);
};

exports.remove = async (req, res) => {
  const deleted = await Booking.findByIdAndDelete(req.params.bookingId);
  if (!deleted) return res.status(404).json({ error: 'Booking not found' });
  res.json({ message: 'Booking deleted successfully' });
};