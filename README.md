# Social Network Influence & Recommendation Engine

**DBMS mini-project | Platform:** MySQL 8.0+

## Objective

Build a relational social-network database that can recommend new connections, trace viral share cascades, and rank creators monthly by influence.

## ER diagram

```mermaid
erDiagram
    USERS ||--o{ POSTS : creates
    USERS ||--o{ FOLLOWS : follower
    USERS ||--o{ FOLLOWS : followed_user
    POSTS ||--o{ POST_ENGAGEMENTS : receives
    USERS ||--o{ POST_ENGAGEMENTS : performs
    POSTS ||--o{ SHARES : originates
    USERS ||--o{ SHARES : creates
    SHARES o|--o{ SHARES : parent_of
    POSTS ||--o{ POST_HASHTAGS : has
    HASHTAGS ||--o{ POST_HASHTAGS : labels
    USERS ||--o{ INFLUENCE_SCORES : receives

    USERS { bigint user_id
            varchar username
            varchar email
            date joined_date }
    FOLLOWS { bigint follower_id
              bigint following_id
              datetime followed_at }
    POSTS { bigint post_id
            bigint user_id
            enum content_type
            datetime posted_at }
    POST_ENGAGEMENTS { bigint engagement_id
                       bigint post_id
                       bigint user_id
                       enum engagement_type }
    SHARES { bigint share_id
             bigint original_post_id
             bigint parent_share_id
             bigint shared_by_user_id }
    HASHTAGS { bigint hashtag_id
               varchar tag_name }
    POST_HASHTAGS { bigint post_id
                    bigint hashtag_id }
    INFLUENCE_SCORES { bigint user_id
                       date month_start
                       decimal influence_score }
```

## Business rules and normalization

- A user cannot follow themself; duplicate follows are prevented by a composite primary key.
- Posts, shares, and engagements belong to registered users. Deleting a user removes dependent social data safely through foreign keys.
- `post_hashtags` resolves the many-to-many relation between posts and hashtags.
- `shares.parent_share_id` forms the share tree used in recursive reach analysis.
- `influence_scores` is a monthly snapshot with one score per user per month.
- Tables are in third normal form: multi-valued facts (follows, hashtags, engagements) are stored independently.

## How to run

In MySQL Workbench, run these files in order:

1. `01_schema.sql`
2. `02_sample_data.sql`
3. `03_monthly_reports.sql`

## Reports included

1. **People You May Know:** two self-joins on `follows`, excludes existing connections, and counts mutual paths.
2. **Viral reach:** a recursive CTE traverses the parent/child share tree, reports cascade depth, and estimates potential viewers from each sharer's followers.
3. **Influencer leaderboard:** CTEs aggregate monthly post engagement and followers, calculate a weighted score, save the snapshot, and rank it with `RANK()`.

### Influence formula

`0.30 × followers + 0.50 × (average engagements per post ÷ followers × 100) + 0.20 × monthly posts`

The engagement component is converted to a percentage so it has a comparable reporting scale. The weights can be adjusted to suit the platform's policy.
