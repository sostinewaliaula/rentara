const errorHandler = (err, req, res, next) => {
  console.error('Error:', err);

  if (err.code === 'ER_DUP_ENTRY') {
    return res.status(400).json({
      error: 'Duplicate entry. This record already exists.',
    });
  }

  if (err.name === 'ValidationError') {
    return res.status(400).json({
      error: err.message,
    });
  }

  if (err.name === 'JsonWebTokenError') {
    return res.status(401).json({
      error: 'Invalid token.',
    });
  }

  res.status(err.status || 500).json({
    error: err.message || 'Internal server error.',
  });
};

export default errorHandler;




