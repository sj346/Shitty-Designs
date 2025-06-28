/*
  # Initial Schema for ShittyDesigns

  1. New Tables
    - `users`
      - `id` (uuid, primary key)
      - `username` (text, unique)
      - `email` (text, unique)
      - `avatar_url` (text, optional)
      - `bio` (text, optional)
      - `designs_count` (integer, default 0)
      - `followers_count` (integer, default 0)
      - `following_count` (integer, default 0)
      - `created_at` (timestamp)
      - `is_banned` (boolean, default false)
      - `warning_count` (integer, default 0)

    - `designs`
      - `id` (uuid, primary key)
      - `title` (text)
      - `description` (text, optional)
      - `image_url` (text)
      - `user_id` (uuid, foreign key)
      - `user_name` (text)
      - `user_avatar_url` (text, optional)
      - `likes_count` (integer, default 0)
      - `comments_count` (integer, default 0)
      - `tags` (text array)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
      - `is_approved` (boolean, default true)
      - `needs_review` (boolean, default false)
      - `is_flagged` (boolean, default false)
      - `moderation_notes` (text, optional)

    - `likes`
      - `id` (uuid, primary key)
      - `design_id` (uuid, foreign key)
      - `user_id` (uuid, foreign key)
      - `created_at` (timestamp)

    - `comments`
      - `id` (uuid, primary key)
      - `design_id` (uuid, foreign key)
      - `user_id` (uuid, foreign key)
      - `user_name` (text)
      - `user_avatar_url` (text, optional)
      - `content` (text)
      - `created_at` (timestamp)
      - `is_flagged` (boolean, default false)

  2. Security
    - Enable RLS on all tables
    - Add policies for authenticated users to read/write their own data
    - Add policies for public read access to approved content
*/

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    username text UNIQUE NOT NULL,
    email text UNIQUE NOT NULL,
    avatar_url text,
    bio text,
    designs_count integer DEFAULT 0,
    followers_count integer DEFAULT 0,
    following_count integer DEFAULT 0,
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    is_banned boolean DEFAULT false,
    warning_count integer DEFAULT 0
);

-- Designs table
CREATE TABLE IF NOT EXISTS designs (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    title text NOT NULL,
    description text,
    image_url text NOT NULL,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name text NOT NULL,
    user_avatar_url text,
    likes_count integer DEFAULT 0,
    comments_count integer DEFAULT 0,
    tags text[] DEFAULT '{}',
    created_at timestamptz DEFAULT now(),
    updated_at timestamptz DEFAULT now(),
    is_approved boolean DEFAULT true,
    needs_review boolean DEFAULT false,
    is_flagged boolean DEFAULT false,
    moderation_notes text
);

-- Likes table
CREATE TABLE IF NOT EXISTS likes (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id uuid NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    UNIQUE(design_id, user_id)
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id uuid NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name text NOT NULL,
    user_avatar_url text,
    content text NOT NULL,
    created_at timestamptz DEFAULT now(),
    is_flagged boolean DEFAULT false
);

-- Followers table
CREATE TABLE IF NOT EXISTS followers (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at timestamptz DEFAULT now(),
    UNIQUE(follower_id, following_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_designs_user_id ON designs(user_id);
CREATE INDEX IF NOT EXISTS idx_designs_created_at ON designs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_designs_is_approved ON designs(is_approved);
CREATE INDEX IF NOT EXISTS idx_likes_design_id ON likes(design_id);
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_comments_design_id ON comments(design_id);
CREATE INDEX IF NOT EXISTS idx_comments_created_at ON comments(created_at DESC);

-- Functions to update counts
CREATE OR REPLACE FUNCTION update_design_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE designs SET likes_count = likes_count + 1 WHERE id = NEW.design_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE designs SET likes_count = GREATEST(0, likes_count - 1) WHERE id = OLD.design_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_design_comments_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE designs SET comments_count = comments_count + 1 WHERE id = NEW.design_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE designs SET comments_count = GREATEST(0, comments_count - 1) WHERE id = OLD.design_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_user_designs_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET designs_count = designs_count + 1 WHERE id = NEW.user_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET designs_count = GREATEST(0, designs_count - 1) WHERE id = OLD.user_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
DROP TRIGGER IF EXISTS trigger_update_design_likes_count ON likes;
CREATE TRIGGER trigger_update_design_likes_count
    AFTER INSERT OR DELETE ON likes
    FOR EACH ROW EXECUTE FUNCTION update_design_likes_count();

DROP TRIGGER IF EXISTS trigger_update_design_comments_count ON comments;
CREATE TRIGGER trigger_update_design_comments_count
    AFTER INSERT OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_design_comments_count();

DROP TRIGGER IF EXISTS trigger_update_user_designs_count ON designs;
CREATE TRIGGER trigger_update_user_designs_count
    AFTER INSERT OR DELETE ON designs
    FOR EACH ROW EXECUTE FUNCTION update_user_designs_count();

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE designs ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all profiles" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Designs policies
CREATE POLICY "Anyone can view approved designs" ON designs
    FOR SELECT USING (is_approved = true);

CREATE POLICY "Users can view their own designs" ON designs
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own designs" ON designs
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own designs" ON designs
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own designs" ON designs
    FOR DELETE USING (auth.uid() = user_id);

-- Likes policies
CREATE POLICY "Anyone can view likes" ON likes
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own likes" ON likes
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete their own likes" ON likes
    FOR DELETE USING (auth.uid() = user_id);

-- Comments policies
CREATE POLICY "Anyone can view non-flagged comments" ON comments
    FOR SELECT USING (is_flagged = false);

CREATE POLICY "Users can view their own comments" ON comments
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own comments" ON comments
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own comments" ON comments
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own comments" ON comments
    FOR DELETE USING (auth.uid() = user_id);

-- Followers policies
CREATE POLICY "Anyone can view followers" ON followers
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own follows" ON followers
    FOR INSERT WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can delete their own follows" ON followers
    FOR DELETE USING (auth.uid() = follower_id);