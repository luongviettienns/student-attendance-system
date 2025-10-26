USE EducationManagement;
UPDATE users 
SET password_hash = '$2a$10$qtPZ9X2t5XJPO02yra9PT.Byxy9LXa1gN4O2q.HRq1Y6T59.QQfES'
WHERE username = 'admin';