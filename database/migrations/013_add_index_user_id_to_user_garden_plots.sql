-- 013_add_index_user_id_to_user_garden_plots.sql

CREATE INDEX IF NOT EXISTS idx_user_garden_user_id
ON user_garden_plots(user_id);