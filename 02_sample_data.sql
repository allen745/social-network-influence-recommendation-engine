USE social_influence_db;

INSERT INTO users (username, full_name, email, bio, joined_date) VALUES
('aisha_khan','Aisha Khan','aisha@example.com','Data analyst','2025-01-10'),
('rohan_mehta','Rohan Mehta','rohan@example.com','Backend developer','2025-02-05'),
('priya_sharma','Priya Sharma','priya@example.com','Product designer','2025-03-12'),
('arjun_patel','Arjun Patel','arjun@example.com','ML student','2025-04-01'),
('neha_verma','Neha Verma','neha@example.com','Content creator','2025-05-18'),
('kabir_singh','Kabir Singh','kabir@example.com','Startup founder','2025-06-20');

INSERT INTO follows (follower_id, following_id, followed_at) VALUES
(1,2,'2026-07-02'),(1,3,'2026-07-03'),(2,3,'2026-07-04'),
(2,4,'2026-07-05'),(3,4,'2026-07-06'),(3,5,'2026-07-07'),
(4,1,'2026-07-08'),(4,5,'2026-07-09'),(5,1,'2026-07-10'),
(5,2,'2026-07-11'),(6,1,'2026-07-12'),(6,3,'2026-07-13');

INSERT INTO posts (user_id, body, content_type, posted_at) VALUES
(1,'SQL graph queries are surprisingly powerful.','article','2026-08-03 09:00:00'),
(2,'Building a recommendation engine this month.','text','2026-08-06 10:30:00'),
(3,'Design systems for social products.','image','2026-08-11 14:00:00'),
(1,'September analytics dashboard is live.','article','2026-09-02 08:00:00'),
(4,'A simple introduction to recursive CTEs.','video','2026-09-04 12:00:00'),
(5,'My content strategy checklist.','article','2026-09-05 16:00:00');

INSERT INTO post_engagements (post_id,user_id,engagement_type,comment_text,created_at) VALUES
(1,2,'like',NULL,'2026-08-03 10:00:00'),(1,3,'comment','Very useful!','2026-08-03 10:05:00'),(1,4,'share',NULL,'2026-08-03 10:10:00'),
(2,1,'like',NULL,'2026-08-06 11:00:00'),(2,3,'like',NULL,'2026-08-06 11:05:00'),(2,5,'comment','Good luck!','2026-08-06 11:10:00'),
(3,1,'like',NULL,'2026-08-11 15:00:00'),(3,2,'share',NULL,'2026-08-11 15:10:00'),
(4,2,'like',NULL,'2026-09-02 09:00:00'),(4,3,'comment','Great dashboard.','2026-09-02 09:05:00'),(4,5,'share',NULL,'2026-09-02 09:10:00'),
(5,1,'like',NULL,'2026-09-04 13:00:00'),(5,3,'share',NULL,'2026-09-04 13:05:00'),(5,6,'comment','Nice explanation.','2026-09-04 13:10:00'),
(6,1,'like',NULL,'2026-09-05 17:00:00'),(6,2,'like',NULL,'2026-09-05 17:05:00'),(6,4,'share',NULL,'2026-09-05 17:10:00');

INSERT INTO shares (original_post_id,parent_share_id,shared_by_user_id,shared_at) VALUES
(1,NULL,4,'2026-08-03 10:10:00'),(1,1,5,'2026-08-03 11:00:00'),(1,2,6,'2026-08-03 12:00:00'),
(4,NULL,5,'2026-09-02 09:10:00'),(4,4,6,'2026-09-02 10:00:00'),
(5,NULL,3,'2026-09-04 13:05:00'),(6,NULL,4,'2026-09-05 17:10:00');

INSERT INTO hashtags (tag_name) VALUES ('#SQL'),('#DataAnalytics'),('#RecommendationEngine'),('#Design'),('#MachineLearning');
INSERT INTO post_hashtags (post_id,hashtag_id) VALUES (1,1),(1,2),(2,3),(3,4),(4,2),(5,1),(5,5),(6,2);
