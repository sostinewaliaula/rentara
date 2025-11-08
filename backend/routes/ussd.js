import express from 'express';

const router = express.Router();

router.post('/', async (req, res) => {
  console.log('Received USSD request', req.body);
  res.set('Content-Type', 'text/plain');
  res.send('END Rentara USSD service is being upgraded. Please try again later.');
});

export default router;




