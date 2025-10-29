-- Fix Avatar Paths
-- Update avatar URL for users to correct format

USE EducationManagement;
GO

-- Update USER001 avatar path (using lowercase column names)
UPDATE users
SET avatar_url = '/avatars/user-001.jpg'
WHERE user_id = 'USER001';

-- Show updated records
SELECT user_id, username, avatar_url
FROM users
WHERE user_id = 'USER001';

PRINT 'Avatar path updated successfully!';
GO
