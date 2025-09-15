-- Create media_uploads table for storing user uploaded images and videos
-- This table will store metadata for all media files uploaded to Supabase storage

CREATE TABLE IF NOT EXISTS media_uploads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    media_url TEXT NOT NULL,
    media_type VARCHAR(10) NOT NULL CHECK (media_type IN ('image', 'video')),
    file_name TEXT NOT NULL,
    thumbnail_url TEXT,
    file_size_bytes BIGINT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT now(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT now()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_media_uploads_user_id ON media_uploads(user_id);
CREATE INDEX IF NOT EXISTS idx_media_uploads_media_type ON media_uploads(media_type);
CREATE INDEX IF NOT EXISTS idx_media_uploads_created_at ON media_uploads(created_at DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE media_uploads ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
-- Users can only see their own media uploads
CREATE POLICY "Users can view their own media uploads" 
ON media_uploads FOR SELECT 
USING (auth.uid() = user_id);

-- Users can insert their own media uploads
CREATE POLICY "Users can insert their own media uploads" 
ON media_uploads FOR INSERT 
WITH CHECK (auth.uid() = user_id);

-- Users can update their own media uploads
CREATE POLICY "Users can update their own media uploads" 
ON media_uploads FOR UPDATE 
USING (auth.uid() = user_id);

-- Users can delete their own media uploads
CREATE POLICY "Users can delete their own media uploads" 
ON media_uploads FOR DELETE 
USING (auth.uid() = user_id);

-- Create a function to automatically update the updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger to automatically update updated_at
CREATE TRIGGER update_media_uploads_updated_at 
    BEFORE UPDATE ON media_uploads 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Grant permissions to authenticated users
GRANT ALL ON media_uploads TO authenticated;
GRANT USAGE ON SEQUENCE media_uploads_id_seq TO authenticated;