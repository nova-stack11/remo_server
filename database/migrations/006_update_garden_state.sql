-- ============================================
-- 006_update_garden_state.sql
-- Đổi kiểu plot_state từ INT sang TEXT
-- ============================================

ALTER TABLE user_garden_plots
  ALTER COLUMN plot_state TYPE TEXT
  USING plot_state::text;