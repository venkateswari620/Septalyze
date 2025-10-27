-- Update existing demo user password to plain text
USE septalyze;

UPDATE users 
SET password = 'password123' 
WHERE email = 'demo@septalyze.com';

-- Verify the update
SELECT id, name, email, password FROM users WHERE email = 'demo@septalyze.com';
