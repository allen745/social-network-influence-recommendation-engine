-- Social Network Influence & Recommendation Engine
-- DBMS Mini-Project | MySQL 8.0+

DROP DATABASE IF EXISTS social_influence_db;
CREATE DATABASE social_influence_db
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE social_influence_db;

CREATE TABLE users (
  user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(50) NOT NULL,
  full_name VARCHAR(100) NOT NULL,
  email VARCHAR(255) NOT NULL,
  bio VARCHAR(500) NULL,
  joined_date DATE NOT NULL,
  account_status ENUM('active','suspended','deactivated') NOT NULL DEFAULT 'active',
  CONSTRAINT uq_users_username UNIQUE (username),
  CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;

-- A directed self-referencing many-to-many relationship: one user follows another.
CREATE TABLE follows (
  follower_id BIGINT UNSIGNED NOT NULL,
  following_id BIGINT UNSIGNED NOT NULL,
  followed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (follower_id, following_id),
  CONSTRAINT chk_follows_not_self CHECK (follower_id <> following_id),
  CONSTRAINT fk_follows_follower FOREIGN KEY (follower_id) REFERENCES users(user_id) ON DELETE CASCADE,
  CONSTRAINT fk_follows_following FOREIGN KEY (following_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_follows_following (following_id)
) ENGINE=InnoDB;

CREATE TABLE posts (
  post_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id BIGINT UNSIGNED NOT NULL,
  body TEXT NOT NULL,
  content_type ENUM('text','image','video','article','poll') NOT NULL DEFAULT 'text',
  visibility ENUM('public','followers_only') NOT NULL DEFAULT 'public',
  posted_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_posts_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_posts_user_date (user_id, posted_at),
  INDEX idx_posts_date (posted_at)
) ENGINE=InnoDB;

CREATE TABLE post_engagements (
  engagement_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  post_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  engagement_type ENUM('like','comment','share') NOT NULL,
  comment_text VARCHAR(1000) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT chk_comment_text CHECK ((engagement_type = 'comment' AND comment_text IS NOT NULL) OR (engagement_type <> 'comment' AND comment_text IS NULL)),
  CONSTRAINT fk_engagement_post FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT fk_engagement_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  -- One member can perform each type of action once on a given post.
  UNIQUE KEY uq_post_user_action (post_id, user_id, engagement_type),
  INDEX idx_engagement_post_date (post_id, created_at),
  INDEX idx_engagement_user_date (user_id, created_at)
) ENGINE=InnoDB;

-- Each share records its direct parent share (NULL means it was shared from the original post).
CREATE TABLE shares (
  share_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  original_post_id BIGINT UNSIGNED NOT NULL,
  parent_share_id BIGINT UNSIGNED NULL,
  shared_by_user_id BIGINT UNSIGNED NOT NULL,
  shared_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_shares_post FOREIGN KEY (original_post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT fk_shares_parent FOREIGN KEY (parent_share_id) REFERENCES shares(share_id) ON DELETE CASCADE,
  CONSTRAINT fk_shares_user FOREIGN KEY (shared_by_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  UNIQUE KEY uq_share_user_post (original_post_id, shared_by_user_id),
  INDEX idx_shares_parent (parent_share_id),
  INDEX idx_shares_post_date (original_post_id, shared_at)
) ENGINE=InnoDB;

CREATE TABLE hashtags (
  hashtag_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  tag_name VARCHAR(100) NOT NULL,
  CONSTRAINT uq_hashtags_tag UNIQUE (tag_name),
  CONSTRAINT chk_hashtags_format CHECK (tag_name REGEXP '^#[A-Za-z0-9_]+$')
) ENGINE=InnoDB;

CREATE TABLE post_hashtags (
  post_id BIGINT UNSIGNED NOT NULL,
  hashtag_id BIGINT UNSIGNED NOT NULL,
  PRIMARY KEY (post_id, hashtag_id),
  CONSTRAINT fk_post_hashtags_post FOREIGN KEY (post_id) REFERENCES posts(post_id) ON DELETE CASCADE,
  CONSTRAINT fk_post_hashtags_tag FOREIGN KEY (hashtag_id) REFERENCES hashtags(hashtag_id) ON DELETE CASCADE,
  INDEX idx_post_hashtags_tag (hashtag_id)
) ENGINE=InnoDB;

-- Stores a reproducible monthly snapshot, rather than recalculating historical scores.
CREATE TABLE influence_scores (
  user_id BIGINT UNSIGNED NOT NULL,
  month_start DATE NOT NULL,
  followers_count INT UNSIGNED NOT NULL DEFAULT 0,
  engagement_rate DECIMAL(8,4) NOT NULL DEFAULT 0.0000,
  posts_count INT UNSIGNED NOT NULL DEFAULT 0,
  influence_score DECIMAL(12,4) NOT NULL,
  calculated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, month_start),
  CONSTRAINT chk_score_month_first_day CHECK (DAY(month_start) = 1),
  CONSTRAINT fk_scores_user FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  INDEX idx_scores_month_rank (month_start, influence_score DESC)
) ENGINE=InnoDB;
