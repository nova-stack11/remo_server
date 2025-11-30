-- migration 016: add seed_dead_image column to seeds table

ALTER TABLE seed
ADD COLUMN seed_dead_image TEXT;