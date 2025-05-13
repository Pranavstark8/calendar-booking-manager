const express = require('express');
const router = express.Router();
const controller = require('../controllers/bookingController');

router.get('/', controller.getAll);
router.get('/:bookingId', controller.getById);
router.post('/', controller.create);
router.put('/:bookingId', controller.update);
router.delete('/:bookingId', controller.remove);

module.exports = router;