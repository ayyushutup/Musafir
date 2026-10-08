# Musafir — Technical Architecture

> **Version:** 1.0  
> **Date:** October 2026

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│  ┌─────────────────────────────────────────────────┐    │
│  │              Flutter App (iOS/Android)            │    │
│  │  ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐ ┌──────┐  │    │
│  │  │ Home │ │Explore│ │Comms │ │ Chat │ │Profile│  │    │
│  │  └──────┘ └──────┘ └──────┘ └──────┘ └──────┘  │    │
│  │  ┌──────────────────────────────────────────┐   │    │
│  │  │         State Management (Riverpod)       │   │    │
│  │  └──────────────────────────────────────────┘   │    │
│  │  ┌──────────────────────────────────────────┐   │    │
│  │  │         Local Cache (Hive/Isar)           │   │    │
│  │  └──────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────┘
                         │ HTTPS / WSS
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   EDGE / CDN LAYER                       │
│  ┌─────────────────────────────────────────────────┐    │
│  │            Cloudflare (CDN + WAF + DDoS)         │    │
│  └─────────────────────────────────────────────────┘    │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   BACKEND LAYER                          │
│                                                          │
│  ┌──────────────────┐  ┌──────────────────────────┐     │
│  │   Supabase        │  │   Python FastAPI          │     │
│  │   ┌────────────┐  │  │   (AI Microservice)       │     │
│  │   │ Auth       │  │  │   ┌──────────────────┐   │     │
│  │   │ (GoTrue)   │  │  │   │ Recommendations  │   │     │
│  │   ├────────────┤  │  │   │ Friend Matching  │   │     │
│  │   │ PostgREST  │  │  │   │ Event Scoring    │   │     │
│  │   │ (REST API) │  │  │   │ Content Mod      │   │     │
│  │   ├────────────┤  │  │   │ Search (pgvector)│   │     │
│  │   │ Realtime   │  │  │   └──────────────────┘   │     │
│  │   │ (WebSocket)│  │  │                           │     │
│  │   ├────────────┤  │  └──────────────────────────┘     │
│  │   │ Storage    │  │                                    │
│  │   │ (S3-compat)│  │  ┌──────────────────────────┐     │
│  │   ├────────────┤  │  │   Firebase Cloud          │     │
│  │   │ Edge Funcs │  │  │   Messaging (FCM)         │     │
│  │   │ (Deno)     │  │  └──────────────────────────┘     │
│  │   └────────────┘  │                                    │
│  └──────────────────┘                                    │
└────────────────────────┬────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────┐
│                   DATA LAYER                             │
│  ┌──────────────────┐  ┌──────────────────────────┐     │
│  │ PostgreSQL        │  │ Supabase Storage          │     │
│  │ + PostGIS         │  │ (Images, Videos, Media)   │     │
│  │ + pgvector        │  │                           │     │
│  └──────────────────┘  └──────────────────────────┘     │
│  ┌──────────────────┐  ┌──────────────────────────┐     │
│  │ Redis (optional)  │  │ Mapbox APIs               │     │
│  │ (Caching, Queues) │  │ (Geocoding, Maps)         │     │
│  └──────────────────┘  └──────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Database Schema

### 2.1 Core Tables

```sql
-- ============================================
-- USERS & AUTHENTICATION
-- ============================================

-- Extends Supabase auth.users
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT NOT NULL,
    avatar_url TEXT,
    bio TEXT,
    phone TEXT,
    date_of_birth DATE,
    gender TEXT CHECK (gender IN ('male', 'female', 'non-binary', 'prefer-not-to-say')),
    
    -- Location
    city TEXT DEFAULT 'Mumbai',
    area TEXT, -- e.g., "Powai", "Bandra"
    location GEOGRAPHY(POINT, 4326), -- PostGIS point
    location_updated_at TIMESTAMPTZ,
    
    -- Verification
    is_verified BOOLEAN DEFAULT FALSE,
    verification_method TEXT, -- 'phone', 'email', 'aadhaar', 'linkedin'
    trust_score INTEGER DEFAULT 50 CHECK (trust_score BETWEEN 0 AND 100),
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_banned BOOLEAN DEFAULT FALSE,
    last_seen_at TIMESTAMPTZ DEFAULT NOW(),
    onboarding_completed BOOLEAN DEFAULT FALSE,
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- User interests (many-to-many)
CREATE TABLE public.interests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT UNIQUE NOT NULL,          -- e.g., "cycling"
    display_name TEXT NOT NULL,         -- e.g., "Cycling"
    emoji TEXT,                         -- e.g., "🚴"
    category TEXT,                      -- e.g., "sports"
    icon_url TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_interests (
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    interest_id UUID REFERENCES public.interests(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, interest_id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- EVENTS (Flagship Feature)
-- ============================================

CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    title TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    cover_image_url TEXT,
    
    -- Organizer
    organizer_id UUID REFERENCES public.profiles(id),
    organizer_name TEXT,
    organizer_verified BOOLEAN DEFAULT FALSE,
    community_id UUID REFERENCES public.communities(id), -- if community event
    
    -- Category
    category TEXT NOT NULL, -- 'concert', 'trek', 'meetup', 'conference', etc.
    tags TEXT[] DEFAULT '{}',
    
    -- Date & Time
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    timezone TEXT DEFAULT 'Asia/Kolkata',
    is_multi_day BOOLEAN DEFAULT FALSE,
    
    -- Location
    venue_name TEXT,
    venue_address TEXT,
    city TEXT DEFAULT 'Mumbai',
    area TEXT,
    location GEOGRAPHY(POINT, 4326),
    is_online BOOLEAN DEFAULT FALSE,
    online_url TEXT,
    
    -- Ticketing
    is_free BOOLEAN DEFAULT TRUE,
    price_min NUMERIC(10,2),
    price_max NUMERIC(10,2),
    currency TEXT DEFAULT 'INR',
    ticket_url TEXT, -- external ticketing link
    
    -- Capacity
    max_attendees INTEGER,
    
    -- Status
    status TEXT DEFAULT 'active' CHECK (status IN ('draft', 'active', 'cancelled', 'completed')),
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Social Layer (auto-created flags)
    has_general_chat BOOLEAN DEFAULT TRUE,
    has_going_solo BOOLEAN DEFAULT TRUE,
    has_travel_together BOOLEAN DEFAULT TRUE,
    has_ticket_discussion BOOLEAN DEFAULT TRUE,
    has_media_hub BOOLEAN DEFAULT TRUE,
    
    -- AI / Search
    embedding VECTOR(1536), -- pgvector for semantic search
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Event attendance
CREATE TABLE public.event_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    status TEXT DEFAULT 'going' CHECK (status IN ('interested', 'going', 'not_going')),
    is_solo BOOLEAN DEFAULT FALSE,
    
    -- For Event Aura breakdown
    travel_mode TEXT, -- 'train', 'metro', 'cab', 'bike', 'walk'
    
    -- Metadata
    rsvp_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(event_id, user_id)
);

-- Event Aura (materialized/cached stats)
CREATE TABLE public.event_aura (
    event_id UUID PRIMARY KEY REFERENCES public.events(id) ON DELETE CASCADE,
    
    total_attendees INTEGER DEFAULT 0,
    total_interested INTEGER DEFAULT 0,
    solo_attendees INTEGER DEFAULT 0,
    
    -- Interest breakdown (JSONB for flexibility)
    interest_breakdown JSONB DEFAULT '{}',
    -- Example: {"photographers": 542, "students": 1102, "cyclists": 234}
    
    -- Travel breakdown
    travel_breakdown JSONB DEFAULT '{}',
    -- Example: {"train": 783, "metro": 456, "cab": 234}
    
    -- Location breakdown
    area_breakdown JSONB DEFAULT '{}',
    -- Example: {"Powai": 234, "Bandra": 567, "Thane": 123}
    
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- COMMUNITIES
-- ============================================

CREATE TABLE public.communities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    cover_image_url TEXT,
    avatar_url TEXT,
    
    -- Category
    category TEXT NOT NULL,
    interest_id UUID REFERENCES public.interests(id),
    tags TEXT[] DEFAULT '{}',
    
    -- Location
    city TEXT DEFAULT 'Mumbai',
    area TEXT,
    location GEOGRAPHY(POINT, 4326),
    
    -- Creator
    created_by UUID REFERENCES public.profiles(id),
    
    -- Settings
    is_public BOOLEAN DEFAULT TRUE,
    requires_approval BOOLEAN DEFAULT FALSE,
    max_members INTEGER DEFAULT 10000,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    is_featured BOOLEAN DEFAULT FALSE,
    
    -- Stats (denormalized for performance)
    member_count INTEGER DEFAULT 0,
    event_count INTEGER DEFAULT 0,
    post_count INTEGER DEFAULT 0,
    
    -- AI / Search
    embedding VECTOR(1536),
    
    -- Metadata
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.community_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    role TEXT DEFAULT 'member' CHECK (role IN ('member', 'moderator', 'admin', 'creator')),
    status TEXT DEFAULT 'active' CHECK (status IN ('pending', 'active', 'banned', 'left')),
    
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(community_id, user_id)
);

-- Community discussion posts
CREATE TABLE public.community_posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    content TEXT NOT NULL,
    media_urls TEXT[] DEFAULT '{}',
    
    -- Engagement
    like_count INTEGER DEFAULT 0,
    comment_count INTEGER DEFAULT 0,
    
    is_pinned BOOLEAN DEFAULT FALSE,
    is_deleted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID REFERENCES public.community_posts(id) ON DELETE CASCADE,
    author_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    parent_comment_id UUID REFERENCES public.post_comments(id), -- for threading
    
    content TEXT NOT NULL,
    like_count INTEGER DEFAULT 0,
    
    is_deleted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEETUP PODS
-- ============================================

CREATE TABLE public.meetup_pods (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Basic Info
    name TEXT NOT NULL,
    description TEXT,
    
    -- Association
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    community_id UUID REFERENCES public.communities(id),
    
    -- Creator
    created_by UUID REFERENCES public.profiles(id),
    
    -- Details
    meeting_point TEXT,
    meeting_time TIMESTAMPTZ,
    max_members INTEGER DEFAULT 20,
    
    -- Status
    is_active BOOLEAN DEFAULT TRUE,
    member_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.pod_members (
    pod_id UUID REFERENCES public.meetup_pods(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    role TEXT DEFAULT 'member' CHECK (role IN ('member', 'admin', 'creator')),
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (pod_id, user_id)
);

-- ============================================
-- MESSAGING / CHAT
-- ============================================

CREATE TABLE public.chat_rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Type determines context
    type TEXT NOT NULL CHECK (type IN (
        'event_general',    -- Event general chat
        'event_solo',       -- Event going-solo chat
        'event_travel',     -- Event travel-together chat
        'event_tickets',    -- Event ticket discussion
        'community',        -- Community chat
        'pod',              -- Pod chat
        'direct'            -- 1-on-1 DM
    )),
    
    -- Context references (one will be set based on type)
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
    pod_id UUID REFERENCES public.meetup_pods(id) ON DELETE CASCADE,
    
    -- For DMs
    name TEXT,
    
    -- Metadata
    last_message_at TIMESTAMPTZ,
    message_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.chat_room_members (
    chat_room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    last_read_at TIMESTAMPTZ DEFAULT NOW(),
    is_muted BOOLEAN DEFAULT FALSE,
    
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (chat_room_id, user_id)
);

CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    chat_room_id UUID REFERENCES public.chat_rooms(id) ON DELETE CASCADE,
    sender_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    content TEXT,
    message_type TEXT DEFAULT 'text' CHECK (message_type IN ('text', 'image', 'location', 'event_share', 'system')),
    media_url TEXT,
    
    -- For replies
    reply_to_id UUID REFERENCES public.messages(id),
    
    is_deleted BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- MEDIA HUB
-- ============================================

CREATE TABLE public.event_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    uploaded_by UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    media_type TEXT CHECK (media_type IN ('photo', 'video')),
    media_url TEXT NOT NULL,
    thumbnail_url TEXT,
    caption TEXT,
    
    like_count INTEGER DEFAULT 0,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- TRAVEL TOGETHER
-- ============================================

CREATE TABLE public.travel_groups (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    
    travel_mode TEXT NOT NULL CHECK (travel_mode IN ('train', 'metro', 'cab', 'carpool', 'bus', 'bike', 'walk')),
    route_description TEXT, -- e.g., "Western Line - Churchgate to Andheri"
    departure_point TEXT,
    departure_time TIMESTAMPTZ,
    
    max_members INTEGER DEFAULT 10,
    member_count INTEGER DEFAULT 0,
    
    created_by UUID REFERENCES public.profiles(id),
    chat_room_id UUID REFERENCES public.chat_rooms(id),
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.travel_group_members (
    travel_group_id UUID REFERENCES public.travel_groups(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (travel_group_id, user_id)
);

-- ============================================
-- SOCIAL CONNECTIONS
-- ============================================

CREATE TABLE public.connections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requester_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    addressee_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined', 'blocked')),
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(requester_id, addressee_id),
    CHECK (requester_id != addressee_id)
);

-- ============================================
-- SAFETY & MODERATION
-- ============================================

CREATE TABLE public.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    reporter_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    
    -- What is being reported
    reported_type TEXT NOT NULL CHECK (reported_type IN ('user', 'event', 'message', 'community', 'post', 'media')),
    reported_id UUID NOT NULL, -- polymorphic reference
    reported_user_id UUID REFERENCES public.profiles(id), -- if reporting a user
    
    reason TEXT NOT NULL CHECK (reason IN (
        'spam', 'harassment', 'inappropriate_content', 'fake_profile',
        'scam', 'hate_speech', 'violence', 'underage', 'other'
    )),
    description TEXT,
    
    -- Resolution
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewing', 'resolved', 'dismissed')),
    resolution_note TEXT,
    resolved_by UUID REFERENCES public.profiles(id),
    resolved_at TIMESTAMPTZ,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_blocks (
    blocker_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    blocked_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    PRIMARY KEY (blocker_id, blocked_id)
);

-- ============================================
-- NOTIFICATIONS
-- ============================================

CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    type TEXT NOT NULL, -- 'event_reminder', 'new_message', 'friend_request', 'community_invite', etc.
    title TEXT NOT NULL,
    body TEXT,
    
    -- Deep link data
    action_type TEXT, -- 'event', 'community', 'chat', 'profile'
    action_id UUID,
    
    is_read BOOLEAN DEFAULT FALSE,
    
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- BOOKMARKS
-- ============================================

CREATE TABLE public.bookmarks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE,
    
    bookmarkable_type TEXT NOT NULL CHECK (bookmarkable_type IN ('event', 'community')),
    bookmarkable_id UUID NOT NULL,
    
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, bookmarkable_type, bookmarkable_id)
);

-- ============================================
-- INDEXES
-- ============================================

-- Geospatial indexes (PostGIS)
CREATE INDEX idx_profiles_location ON public.profiles USING GIST (location);
CREATE INDEX idx_events_location ON public.events USING GIST (location);
CREATE INDEX idx_communities_location ON public.communities USING GIST (location);

-- Vector indexes (pgvector)
CREATE INDEX idx_events_embedding ON public.events USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_communities_embedding ON public.communities USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);

-- Time-based queries
CREATE INDEX idx_events_starts_at ON public.events (starts_at) WHERE status = 'active';
CREATE INDEX idx_events_category ON public.events (category) WHERE status = 'active';
CREATE INDEX idx_messages_chat_room ON public.messages (chat_room_id, created_at DESC);
CREATE INDEX idx_notifications_user ON public.notifications (user_id, is_read, created_at DESC);

-- Full-text search
CREATE INDEX idx_events_search ON public.events USING GIN (to_tsvector('english', title || ' ' || COALESCE(description, '')));
CREATE INDEX idx_communities_search ON public.communities USING GIN (to_tsvector('english', name || ' ' || COALESCE(description, '')));

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Example RLS policies
CREATE POLICY "Profiles are viewable by everyone"
    ON public.profiles FOR SELECT
    USING (is_active = true AND is_banned = false);

CREATE POLICY "Users can update own profile"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Active events are viewable by everyone"
    ON public.events FOR SELECT
    USING (status = 'active');

CREATE POLICY "Authenticated users can create events"
    ON public.events FOR INSERT
    WITH CHECK (auth.uid() = organizer_id);

CREATE POLICY "Users can read their own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Chat members can read messages"
    ON public.messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.chat_room_members
            WHERE chat_room_id = messages.chat_room_id
            AND user_id = auth.uid()
        )
    );

-- ============================================
-- DATABASE FUNCTIONS (Supabase Edge)
-- ============================================

-- Auto-update event aura when attendance changes
CREATE OR REPLACE FUNCTION update_event_aura()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.event_aura (event_id, total_attendees, solo_attendees)
    SELECT
        COALESCE(NEW.event_id, OLD.event_id),
        COUNT(*) FILTER (WHERE status = 'going'),
        COUNT(*) FILTER (WHERE status = 'going' AND is_solo = true)
    FROM public.event_attendees
    WHERE event_id = COALESCE(NEW.event_id, OLD.event_id)
    ON CONFLICT (event_id) DO UPDATE SET
        total_attendees = EXCLUDED.total_attendees,
        solo_attendees = EXCLUDED.solo_attendees,
        updated_at = NOW();
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_event_aura
    AFTER INSERT OR UPDATE OR DELETE ON public.event_attendees
    FOR EACH ROW EXECUTE FUNCTION update_event_aura();

-- Auto-update community member count
CREATE OR REPLACE FUNCTION update_community_member_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE public.communities
    SET member_count = (
        SELECT COUNT(*) FROM public.community_members
        WHERE community_id = COALESCE(NEW.community_id, OLD.community_id)
        AND status = 'active'
    ),
    updated_at = NOW()
    WHERE id = COALESCE(NEW.community_id, OLD.community_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_community_member_count
    AFTER INSERT OR UPDATE OR DELETE ON public.community_members
    FOR EACH ROW EXECUTE FUNCTION update_community_member_count();

-- Nearby events function
CREATE OR REPLACE FUNCTION get_nearby_events(
    user_lat FLOAT,
    user_lng FLOAT,
    radius_km FLOAT DEFAULT 15,
    event_limit INTEGER DEFAULT 20
)
RETURNS SETOF public.events AS $$
BEGIN
    RETURN QUERY
    SELECT e.*
    FROM public.events e
    WHERE e.status = 'active'
    AND e.starts_at > NOW()
    AND ST_DWithin(
        e.location,
        ST_SetSRID(ST_MakePoint(user_lng, user_lat), 4326)::geography,
        radius_km * 1000
    )
    ORDER BY e.starts_at ASC
    LIMIT event_limit;
END;
$$ LANGUAGE plpgsql;
```

---

## 3. API Architecture

### 3.1 Supabase Auto-Generated REST API

Supabase automatically generates REST endpoints for all tables via PostgREST:

```
Base URL: https://<project>.supabase.co/rest/v1/

GET    /events                    -- List events (with filters)
GET    /events?id=eq.<id>         -- Get single event
POST   /events                    -- Create event
PATCH  /events?id=eq.<id>         -- Update event

GET    /communities               -- List communities
POST   /community_members         -- Join community

GET    /profiles?id=eq.<id>       -- Get user profile
PATCH  /profiles?id=eq.<id>       -- Update profile

POST   /event_attendees           -- RSVP to event
DELETE /event_attendees?...       -- Un-RSVP

POST   /messages                  -- Send message
GET    /messages?chat_room_id=eq.<id>&order=created_at.desc
```

### 3.2 Supabase Realtime (WebSocket)

```
-- Subscribe to new messages in a chat room
supabase
  .channel('chat:<room_id>')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages',
      filter: 'chat_room_id=eq.<room_id>' },
    handleNewMessage
  )
  .subscribe()

-- Subscribe to event aura updates
supabase
  .channel('aura:<event_id>')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'event_aura',
      filter: 'event_id=eq.<event_id>' },
    handleAuraUpdate
  )
  .subscribe()
```

### 3.3 Supabase Edge Functions (Deno)

```
supabase/functions/
├── create-event/          -- Event creation with auto social layer setup
├── rsvp-event/            -- RSVP with aura update + notification
├── send-notification/     -- Push notification via FCM
├── generate-embedding/    -- Generate vector embedding for content
├── update-event-aura/     -- Recalculate event aura stats
├── verify-profile/        -- Profile verification flow
├── moderate-content/      -- Content moderation check
└── cleanup-expired/       -- Scheduled cleanup of past events
```

### 3.4 Python FastAPI (AI Microservice)

```
Base URL: https://api.musafir.app/ai/v1/

POST /recommendations/events      -- Personalized event recommendations
POST /recommendations/communities -- Community suggestions
POST /recommendations/people      -- Friend discovery / matching
POST /search/semantic             -- Semantic search across events/communities
POST /moderation/check            -- AI content moderation
POST /embeddings/generate         -- Generate embeddings for content
GET  /analytics/event-aura/<id>   -- Compute detailed event aura
```

#### FastAPI Project Structure

```
ai-service/
├── main.py
├── requirements.txt
├── Dockerfile
├── app/
│   ├── __init__.py
│   ├── config.py
│   ├── database.py              -- Supabase/PostgreSQL connection
│   ├── routers/
│   │   ├── recommendations.py
│   │   ├── search.py
│   │   ├── moderation.py
│   │   └── embeddings.py
│   ├── services/
│   │   ├── recommendation_engine.py
│   │   ├── friend_matcher.py
│   │   ├── semantic_search.py
│   │   ├── content_moderator.py
│   │   └── embedding_service.py
│   ├── models/
│   │   ├── schemas.py
│   │   └── ml_models.py
│   └── utils/
│       ├── vectors.py
│       └── scoring.py
```

---

## 4. Flutter App Architecture

### 4.1 Project Structure (Feature-First)

```
lib/
├── main.dart
├── app.dart                        -- MaterialApp + routing
│
├── core/                           -- Shared infrastructure
│   ├── config/
│   │   ├── app_config.dart
│   │   ├── supabase_config.dart
│   │   └── mapbox_config.dart
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── typography.dart
│   │   ├── spacing.dart
│   │   └── assets.dart
│   ├── extensions/
│   │   ├── context_extensions.dart
│   │   ├── datetime_extensions.dart
│   │   └── string_extensions.dart
│   ├── network/
│   │   ├── api_client.dart
│   │   ├── supabase_client.dart
│   │   └── api_exceptions.dart
│   ├── router/
│   │   ├── app_router.dart         -- GoRouter configuration
│   │   └── route_names.dart
│   ├── services/
│   │   ├── location_service.dart
│   │   ├── notification_service.dart
│   │   ├── storage_service.dart
│   │   └── analytics_service.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── dark_theme.dart
│   │   └── light_theme.dart
│   └── widgets/                    -- Shared UI components
│       ├── buttons/
│       ├── cards/
│       ├── inputs/
│       ├── loading/
│       ├── avatars/
│       └── bottom_sheets/
│
├── features/                       -- Feature modules
│   ├── auth/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   └── models/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   ├── presentation/
│   │   │   ├── providers/          -- Riverpod providers
│   │   │   ├── screens/
│   │   │   └── widgets/
│   │   └── auth.dart               -- Barrel file
│   │
│   ├── onboarding/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── welcome_screen.dart
│   │   │   │   ├── interests_screen.dart
│   │   │   │   └── location_screen.dart
│   │   │   └── widgets/
│   │   └── onboarding.dart
│   │
│   ├── home/
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   ├── screens/
│   │   │   │   └── home_screen.dart
│   │   │   └── widgets/
│   │   │       ├── event_card.dart
│   │   │       ├── community_card.dart
│   │   │       ├── trending_section.dart
│   │   │       └── nearby_section.dart
│   │   └── home.dart
│   │
│   ├── events/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── event_repository.dart
│   │   │   └── models/
│   │   │       └── event_model.dart
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   │   └── event_providers.dart
│   │   │   ├── screens/
│   │   │   │   ├── event_list_screen.dart
│   │   │   │   ├── event_detail_screen.dart
│   │   │   │   └── create_event_screen.dart
│   │   │   └── widgets/
│   │   │       ├── event_aura_widget.dart    -- 🔥 Killer feature
│   │   │       ├── going_solo_widget.dart
│   │   │       ├── travel_together_widget.dart
│   │   │       ├── ticket_discussion_widget.dart
│   │   │       └── media_hub_widget.dart
│   │   └── events.dart
│   │
│   ├── explore/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── explore_screen.dart
│   │   │   │   └── map_screen.dart     -- Mapbox integration
│   │   │   └── widgets/
│   │   │       ├── map_marker.dart
│   │   │       └── filter_sheet.dart
│   │   └── explore.dart
│   │
│   ├── communities/
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── community_list_screen.dart
│   │   │   │   ├── community_detail_screen.dart
│   │   │   │   └── create_community_screen.dart
│   │   │   └── widgets/
│   │   │       ├── community_feed.dart
│   │   │       ├── member_grid.dart
│   │   │       └── community_events.dart
│   │   └── communities.dart
│   │
│   ├── chat/
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   │   └── chat_repository.dart
│   │   │   └── models/
│   │   ├── presentation/
│   │   │   ├── providers/
│   │   │   ├── screens/
│   │   │   │   ├── chat_list_screen.dart
│   │   │   │   └── chat_room_screen.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       └── chat_input.dart
│   │   └── chat.dart
│   │
│   ├── pods/
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── pod_list_screen.dart
│   │   │   │   ├── pod_detail_screen.dart
│   │   │   │   └── create_pod_screen.dart
│   │   │   └── widgets/
│   │   └── pods.dart
│   │
│   ├── profile/
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   ├── edit_profile_screen.dart
│   │   │   │   └── settings_screen.dart
│   │   │   └── widgets/
│   │   └── profile.dart
│   │
│   ├── discovery/                   -- Friend discovery
│   │   ├── data/
│   │   ├── presentation/
│   │   │   ├── screens/
│   │   │   │   └── people_screen.dart
│   │   │   └── widgets/
│   │   │       └── person_card.dart
│   │   └── discovery.dart
│   │
│   └── notifications/
│       ├── data/
│       ├── presentation/
│       │   ├── screens/
│       │   │   └── notifications_screen.dart
│       │   └── widgets/
│       └── notifications.dart
│
├── shared/                         -- Shared domain models
│   ├── models/
│   │   ├── user.dart
│   │   ├── event.dart
│   │   ├── community.dart
│   │   └── message.dart
│   └── providers/
│       ├── auth_provider.dart
│       └── user_provider.dart
│
└── gen/                            -- Generated code
    ├── assets.gen.dart
    └── l10n/
```

### 4.2 Key Flutter Dependencies

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.0
  riverpod_annotation: ^2.3.0
  
  # Routing
  go_router: ^14.0.0
  
  # Backend
  supabase_flutter: ^2.5.0
  
  # Maps
  mapbox_maps_flutter: ^2.0.0
  geolocator: ^12.0.0
  
  # UI
  google_fonts: ^6.2.0
  flutter_animate: ^4.5.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  lottie: ^3.1.0
  flutter_svg: ^2.0.0
  
  # Media
  image_picker: ^1.0.0
  photo_view: ^0.15.0
  
  # Notifications
  firebase_core: ^3.0.0
  firebase_messaging: ^15.0.0
  flutter_local_notifications: ^17.0.0
  
  # Storage
  hive_flutter: ^1.1.0
  
  # Utils
  intl: ^0.19.0
  url_launcher: ^6.2.0
  share_plus: ^9.0.0
  permission_handler: ^11.0.0
  connectivity_plus: ^6.0.0

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0
  mockito: ^5.4.0
  flutter_test:
    sdk: flutter
```

### 4.3 State Management (Riverpod)

```dart
// Example: Event providers

// Supabase client provider
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Event repository
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(ref.read(supabaseProvider));
});

// Nearby events (auto-refreshing)
final nearbyEventsProvider = FutureProvider.autoDispose
    .family<List<Event>, LocationFilter>((ref, filter) async {
  final repo = ref.read(eventRepositoryProvider);
  return repo.getNearbyEvents(
    lat: filter.latitude,
    lng: filter.longitude,
    radiusKm: filter.radiusKm,
  );
});

// Event detail with real-time aura
final eventDetailProvider = StreamProvider.autoDispose
    .family<Event, String>((ref, eventId) {
  final supabase = ref.read(supabaseProvider);
  return supabase
      .from('events')
      .stream(primaryKey: ['id'])
      .eq('id', eventId)
      .map((data) => Event.fromJson(data.first));
});

// Event aura (real-time)
final eventAuraProvider = StreamProvider.autoDispose
    .family<EventAura, String>((ref, eventId) {
  final supabase = ref.read(supabaseProvider);
  return supabase
      .from('event_aura')
      .stream(primaryKey: ['event_id'])
      .eq('event_id', eventId)
      .map((data) => EventAura.fromJson(data.first));
});
```

---

## 5. Third-Party Service Integration

### 5.1 Supabase Setup

| Service | Purpose | Free Tier Limit |
|---|---|---|
| **Auth** | Phone OTP, Google, Apple sign-in | 50K MAU |
| **Database** | PostgreSQL + PostGIS + pgvector | 500 MB |
| **Realtime** | WebSocket for chat, live updates | 200 concurrent |
| **Storage** | Images, videos, media | 1 GB |
| **Edge Functions** | Serverless Deno functions | 500K invocations/mo |

### 5.2 Mapbox

| Service | Purpose | Free Tier |
|---|---|---|
| **Maps SDK** | Event/community map | 25K map loads/mo |
| **Geocoding** | Address → coordinates | 100K requests/mo |
| **Directions** | Travel route suggestions | 100K requests/mo |

### 5.3 Firebase (FCM only)

| Service | Purpose | Free Tier |
|---|---|---|
| **Cloud Messaging** | Push notifications | Unlimited |

### 5.4 Cloudflare

| Service | Purpose | Free Tier |
|---|---|---|
| **CDN** | Static asset delivery | Unlimited bandwidth |
| **WAF** | Security | Basic rules |
| **Workers** | Edge compute (optional) | 100K requests/day |

---

*Next: [03_DESIGN_SYSTEM.md] — UI/UX Design System, Screen Breakdown, Wireframes*
