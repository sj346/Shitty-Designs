-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    designs_count INTEGER DEFAULT 0,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_banned BOOLEAN DEFAULT FALSE,
    warning_count INTEGER DEFAULT 0
);

-- Designs table with moderation fields
CREATE TABLE designs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT NOT NULL,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name VARCHAR(50) NOT NULL,
    user_avatar_url TEXT,
    likes_count INTEGER DEFAULT 0,
    comments_count INTEGER DEFAULT 0,
    tags TEXT[] DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_approved BOOLEAN DEFAULT TRUE,
    needs_review BOOLEAN DEFAULT FALSE,
    is_flagged BOOLEAN DEFAULT FALSE,
    moderation_notes TEXT,
    flagged_at TIMESTAMP WITH TIME ZONE,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES users(id)
);

-- Likes table
CREATE TABLE likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(design_id, user_id)
);

-- Comments table with moderation
CREATE TABLE comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID NOT NULL REFERENCES designs(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    user_name VARCHAR(50) NOT NULL,
    user_avatar_url TEXT,
    content TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    is_flagged BOOLEAN DEFAULT FALSE,
    flagged_at TIMESTAMP WITH TIME ZONE
);

-- Followers table
CREATE TABLE followers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(follower_id, following_id)
);

-- Reports table for content moderation
CREATE TABLE reports (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    design_id UUID REFERENCES designs(id) ON DELETE CASCADE,
    comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason VARCHAR(255) NOT NULL,
    details TEXT,
    status VARCHAR(50) DEFAULT 'pending', -- pending, reviewed, resolved, dismissed
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    reviewed_at TIMESTAMP WITH TIME ZONE,
    reviewed_by UUID REFERENCES users(id),
    action_taken VARCHAR(255), -- removed, warned, banned, etc.
    CHECK (design_id IS NOT NULL OR comment_id IS NOT NULL)
);

-- Content moderation logs
CREATE TABLE moderation_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    moderator_id UUID NOT NULL REFERENCES users(id),
    action_type VARCHAR(50) NOT NULL, -- approve, reject, flag, ban, warn
    target_type VARCHAR(50) NOT NULL, -- design, comment, user
    target_id UUID NOT NULL,
    reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for better performance
CREATE INDEX idx_designs_user_id ON designs(user_id);
CREATE INDEX idx_designs_created_at ON designs(created_at DESC);
CREATE INDEX idx_designs_is_approved ON designs(is_approved);
CREATE INDEX idx_designs_needs_review ON designs(needs_review);
CREATE INDEX idx_designs_is_flagged ON designs(is_flagged);
CREATE INDEX idx_likes_design_id ON likes(design_id);
CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_comments_design_id ON comments(design_id);
CREATE INDEX idx_comments_created_at ON comments(created_at DESC);
CREATE INDEX idx_comments_is_flagged ON comments(is_flagged);
CREATE INDEX idx_followers_follower_id ON followers(follower_id);
CREATE INDEX idx_followers_following_id ON followers(following_id);
CREATE INDEX idx_reports_design_id ON reports(design_id);
CREATE INDEX idx_reports_comment_id ON reports(comment_id);
CREATE INDEX idx_reports_status ON reports(status);
CREATE INDEX idx_reports_created_at ON reports(created_at DESC);
CREATE INDEX idx_moderation_logs_target_type_target_id ON moderation_logs(target_type, target_id);
CREATE INDEX idx_moderation_logs_created_at ON moderation_logs(created_at DESC);

-- Functions to update counts
CREATE OR REPLACE FUNCTION update_design_likes_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE designs SET likes_count = likes_count + 1 WHERE id = NEW.design_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE designs SET likes_count = likes_count - 1 WHERE id = OLD.design_id;
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
        UPDATE designs SET comments_count = comments_count - 1 WHERE id = OLD.design_id;
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
        UPDATE users SET designs_count = designs_count - 1 WHERE id = OLD.user_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION update_user_followers_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE users SET followers_count = followers_count + 1 WHERE id = NEW.following_id;
        UPDATE users SET following_count = following_count + 1 WHERE id = NEW.follower_id;
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE users SET followers_count = followers_count - 1 WHERE id = OLD.following_id;
        UPDATE users SET following_count = following_count - 1 WHERE id = OLD.follower_id;
        RETURN OLD;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Function to auto-flag content based on reports
CREATE OR REPLACE FUNCTION auto_flag_content()
RETURNS TRIGGER AS $$
DECLARE
    report_count INTEGER;
BEGIN
    -- Count reports for this content
    IF NEW.design_id IS NOT NULL THEN
        SELECT COUNT(*) INTO report_count 
        FROM reports 
        WHERE design_id = NEW.design_id AND status = 'pending';
        
        -- Auto-flag if 3 or more reports
        IF report_count >= 3 THEN
            UPDATE designs 
            SET is_flagged = TRUE, flagged_at = NOW() 
            WHERE id = NEW.design_id;
        END IF;
    ELSIF NEW.comment_id IS NOT NULL THEN
        SELECT COUNT(*) INTO report_count 
        FROM reports 
        WHERE comment_id = NEW.comment_id AND status = 'pending';
        
        -- Auto-flag if 2 or more reports
        IF report_count >= 2 THEN
            UPDATE comments 
            SET is_flagged = TRUE, flagged_at = NOW() 
            WHERE id = NEW.comment_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers
CREATE TRIGGER trigger_update_design_likes_count
    AFTER INSERT OR DELETE ON likes
    FOR EACH ROW EXECUTE FUNCTION update_design_likes_count();

CREATE TRIGGER trigger_update_design_comments_count
    AFTER INSERT OR DELETE ON comments
    FOR EACH ROW EXECUTE FUNCTION update_design_comments_count();

CREATE TRIGGER trigger_update_user_designs_count
    AFTER INSERT OR DELETE ON designs
    FOR EACH ROW EXECUTE FUNCTION update_user_designs_count();

CREATE TRIGGER trigger_update_user_followers_count
    AFTER INSERT OR DELETE ON followers
    FOR EACH ROW EXECUTE FUNCTION update_user_followers_count();

CREATE TRIGGER trigger_auto_flag_content
    AFTER INSERT ON reports
    FOR EACH ROW EXECUTE FUNCTION auto_flag_content();

-- Row Level Security (RLS) policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE designs ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE followers ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE moderation_logs ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view all profiles" ON users
    FOR SELECT USING (true);

CREATE POLICY "Users can update their own profile" ON users
    FOR UPDATE USING (auth.uid() = id);

-- Designs policies (only show approved designs to public)
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

-- Comments policies (only show non-flagged comments)
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

-- Reports policies
CREATE POLICY "Users can view their own reports" ON reports
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert reports" ON reports
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Moderation logs policies (admin only)
CREATE POLICY "Only admins can view moderation logs" ON moderation_logs
    FOR SELECT USING (false); -- Will be overridden by admin role

CREATE POLICY "Only admins can insert moderation logs" ON moderation_logs
    FOR INSERT WITH CHECK (false); -- Will be overridden by admin role 