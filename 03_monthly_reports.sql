USE social_influence_db;

-- REPORT 1: People You May Know. Change @target_user_id for another user.
SET @target_user_id = 1;
SELECT candidate.user_id, candidate.username, COUNT(*) AS mutual_connections
FROM follows f1
JOIN follows f2 ON f1.following_id = f2.follower_id
JOIN users candidate ON candidate.user_id = f2.following_id
WHERE f1.follower_id = @target_user_id
  AND f2.following_id <> @target_user_id
  AND NOT EXISTS (
    SELECT 1 FROM follows already_followed
    WHERE already_followed.follower_id = @target_user_id
      AND already_followed.following_id = f2.following_id
  )
GROUP BY candidate.user_id, candidate.username
ORDER BY mutual_connections DESC, candidate.username;

-- REPORT 2: Viral share cascade and estimated reach for one original post.
-- Every share adds the number of followers of the sharer to its potential reach.
SET @post_id = 1;
WITH RECURSIVE share_tree AS (
  SELECT s.share_id, s.parent_share_id, s.shared_by_user_id, 1 AS depth,
         CAST(CONCAT('/', s.share_id, '/') AS CHAR(1000)) AS path
  FROM shares s
  WHERE s.original_post_id = @post_id AND s.parent_share_id IS NULL
  UNION ALL
  SELECT child.share_id, child.parent_share_id, child.shared_by_user_id,
         st.depth + 1, CONCAT(st.path, child.share_id, '/')
  FROM shares child
  JOIN share_tree st ON child.parent_share_id = st.share_id
  WHERE st.depth < 20 AND st.path NOT LIKE CONCAT('%/', child.share_id, '/%')
), share_reach AS (
  SELECT st.depth, st.share_id, u.username AS shared_by,
         COUNT(f.follower_id) AS potential_new_viewers
  FROM share_tree st
  JOIN users u ON u.user_id = st.shared_by_user_id
  LEFT JOIN follows f ON f.following_id = st.shared_by_user_id
  GROUP BY st.depth, st.share_id, u.username
)
SELECT depth, share_id, shared_by, potential_new_viewers,
       SUM(potential_new_viewers) OVER () AS estimated_total_reach
FROM share_reach
ORDER BY depth, share_id;

-- REPORT 3: Monthly influencer leaderboard. It also saves the reporting snapshot.
SET @report_month = DATE('2026-09-01');
DELETE FROM influence_scores WHERE month_start = @report_month;
INSERT INTO influence_scores (user_id, month_start, followers_count, engagement_rate, posts_count, influence_score)
WITH monthly_posts AS (
  SELECT p.post_id, p.user_id
  FROM posts p
  WHERE p.posted_at >= @report_month
    AND p.posted_at < DATE_ADD(@report_month, INTERVAL 1 MONTH)
), post_metrics AS (
  SELECT mp.post_id, mp.user_id, COUNT(pe.engagement_id) AS engagement_count
  FROM monthly_posts mp
  LEFT JOIN post_engagements pe ON pe.post_id = mp.post_id
  GROUP BY mp.post_id, mp.user_id
), creator_metrics AS (
  SELECT user_id, COUNT(*) AS posts_count, AVG(engagement_count) AS avg_engagement_per_post
  FROM post_metrics GROUP BY user_id
), follower_metrics AS (
  SELECT following_id AS user_id, COUNT(*) AS followers_count
  FROM follows GROUP BY following_id
)
SELECT u.user_id, @report_month, COALESCE(fm.followers_count,0),
       COALESCE(cm.avg_engagement_per_post / NULLIF(fm.followers_count,0),0),
       COALESCE(cm.posts_count,0),
       ROUND(COALESCE(fm.followers_count,0)*0.30 +
             COALESCE(cm.avg_engagement_per_post / NULLIF(fm.followers_count,0),0)*100*0.50 +
             COALESCE(cm.posts_count,0)*0.20, 4)
FROM users u
LEFT JOIN follower_metrics fm ON fm.user_id = u.user_id
LEFT JOIN creator_metrics cm ON cm.user_id = u.user_id;

SELECT s.month_start, s.user_id, u.username, s.followers_count,
       ROUND(s.engagement_rate * 100,2) AS engagement_rate_percent,
       s.posts_count, s.influence_score,
       RANK() OVER (PARTITION BY s.month_start ORDER BY s.influence_score DESC) AS leaderboard_rank
FROM influence_scores s
JOIN users u ON u.user_id = s.user_id
WHERE s.month_start = @report_month
ORDER BY leaderboard_rank, u.username;
