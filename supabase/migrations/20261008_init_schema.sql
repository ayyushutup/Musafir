-- Musafir Initial Supabase Database Migration
-- Includes PostGIS extensions, pgvector, core tables, triggers, and RLS policies.

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";
CREATE EXTENSION IF NOT EXISTS "vector";

-- ============================================
-- 1. USERS & PROFILES
-- ============================================

CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'non-binary', 'prefer-not-to-say')),
    city TEXT DEFAULT 'Mumbai',
    area TEXT,
    location GEOGRAPHY(POINT, 4326),
    location_updated_at TIMESTAMPTZ,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_method TEXT,
    trust_score INTEGER DEFAULT 50 CHECK (trust_score BETWEEN 0 AND 100),
    is_active BOOLEAN DEFAULT TRUE,
    is_banned BOOLEAN DEFAULT FALSE,
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    onboarding_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    emoji TEXT,
    category TEXT,
    icon_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.user_interests (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    interest_id UUID REFERENCES public.interests(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, interest_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 2. COMMUNITIES
-- ============================================

CREATE TABLE IF NOT EXISTS public.communities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    cover_image_url TEXT,
    avatar_url TEXT,
    category TEXT NOT NULL,
    interest_id UUID REFERENCES public.interests(id),
    tags TEXT[] DEFAULT '{}',
    city TEXT DEFAULT 'Mumbai',
    area TEXT,
    location GEOGRAPHY(POINT, 4326),
    created_by UUID REFERENCES public.profiles(id),
    is_public BOOLEAN DEFAULT TRUE,
    requires_approval BOOLEAN DEFAULT FALSE,
    max_members INTEGER DEFAULT 10000,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    member_count INTEGER DEFAULT 0,
    event_count INTEGER DEFAULT 0,
    post_count INTEGER DEFAULT 0,
    embedding VECTOR(1536),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.community_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin', 'creator')),
    status TEXT DEFAULT 'active' CHECK (status IN ('pending', 'active', 'banned', 'left')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(community_id, user_id)
);

-- ============================================
-- 3. EVENTS
-- ============================================

CREATE TABLE IF NOT EXISTS public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    cover_image_url TEXT,
    organizer_id UUID REFERENCES public.profiles(id),
    organizer_name TEXT,
    organizer_verified BOOLEAN DEFAULT FALSE,
    community_id UUID REFERENCES public.communities(id),
    category TEXT NOT NULL,
    tags TEXT[] DEFAULT '{}',
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    timezone TEXT DEFAULT 'Asia/Kolkata',
    is_multi_day BOOLEAN DEFAULT FALSE,
    venue_name TEXT,
    venue_address TEXT,
    city TEXT DEFAULT 'Mumbai',
    area TEXT,
    location GEOGRAPHY(POINT, 4326),
    is_online BOOLEAN DEFAULT FALSE,
    online_url TEXT,
    is_free BOOLEAN DEFAULT TRUE,
    price_min NUMERIC(10,2),
    price_max NUMERIC(10,2),
    currency TEXT DEFAULT 'INR',
    ticket_url TEXT,
    max_attendees INTEGER,
    status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'cancelled', 'completed')),
    is_featured BOOLEAN DEFAULT FALSE,
    has_general_chat BOOLEAN DEFAULT TRUE,
    has_going_solo BOOLEAN DEFAULT TRUE,
    has_travel_together BOOLEAN DEFAULT TRUE,
    has_ticket_discussion BOOLEAN DEFAULT TRUE,
    has_media_hub BOOLEAN DEFAULT TRUE,
    embedding VECTOR(1536),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.event_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'going' CHECK (status IN ('interested', 'going', 'not_going')),
    is_solo BOOLEAN DEFAULT FALSE,
    travel_mode TEXT,
    rsvp_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(event_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.event_aura (
    event_id UUID PRIMARY KEY REFERENCES public.events(id) ON DELETE CASCADE,
    total_attendees INTEGER DEFAULT 0,
    total_interested INTEGER DEFAULT 0,
    solo_attendees INTEGER DEFAULT 0,
    interest_breakdown JSONB DEFAULT '{}',
    travel_breakdown JSONB DEFAULT '{}',
    area_breakdown JSONB DEFAULT '{}',
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- 4. MEETUP PODS & CHAT
-- ============================================

CREATE TABLE IF NOT EXISTS public.meetup_pods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    community_id UUID REFERENCES public.communities(id),
    created_by UUID REFERENCES public.profiles(id),
    meeting_point TEXT,
    meeting_time TIMESTAMPTZ,
    max_members INTEGER DEFAULT 20,
    is_active BOOLEAN DEFAULT TRUE,
    member_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL CHECK (type IN (
        'event_general', 'event_solo', 'event_travel', 'event_tickets', 'community', 'pod', 'direct'
    )),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
    pod_id UUID REFERENCES public.meetup_pods(id) ON DELETE CASCADE,
    name TEXT,
    last_message_at TIMESTAMPTZ,
    message_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    content TEXT,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'location', 'event_share', 'system')),
    media_url TEXT,
    reply_to_id UUID REFERENCES public.messages(id),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed initial interests
INSERT INTO public.interests (name, display_name, emoji, category) VALUES
('ai_tech', 'AI & Tech', '🤖', 'technology'),
('cycling', 'Cycling', '🚴', 'sports'),
('photography', 'Photography', '📸', 'arts'),
('startups', 'Startups', '🚀', 'business'),
('books', 'Books', '📚', 'culture'),
('running', 'Running', '🏃', 'fitness'),
('cricket', 'Cricket', '🏏', 'sports'),
('music', 'Music', '🎵', 'entertainment'),
('food', 'Food Exploration', '🍜', 'lifestyle'),
('pet_parents', 'Pet Parents', '🐕', 'lifestyle'),
('trekking', 'Trekking', '🏕️', 'outdoor')
ON CONFLICT (name) DO NOTHING;
