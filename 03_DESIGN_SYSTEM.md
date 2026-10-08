# Musafir — Design System & Screen Breakdown

> **Version:** 1.0  
> **Date:** October 2026

---

## 1. Design Philosophy

### Core Principles

| Principle | Description |
|---|---|
| **Alive** | The UI should feel like a living, breathing space — not a static listing app |
| **Warm** | Human-centered, inviting, approachable — never cold or corporate |
| **Minimal** | Every element earns its place. No clutter, no noise |
| **Premium** | Feels like a ₹10,000/year app that's free |
| **Fast** | Perceived performance matters — skeleton screens, instant feedback |

### Design Inspiration

- **Airbnb**: Warm photography, clean cards, excellent typography
- **Spotify**: Dark elegance, vibrant accents, personalized feel
- **Discord**: Community-first, chat UX, server structure
- **Partiful**: Event pages that feel alive and fun
- **Apple**: Spatial design, depth, attention to detail

---

## 2. Color System

### Primary Palette

```
Brand Primary:     #FF6B35  (Warm Orange — "Musafir Orange")
Brand Secondary:   #1A1A2E  (Deep Navy)
Brand Accent:      #E94560  (Coral Red)
```

### Dark Theme (Default)

```
Background:        #0A0A0F  (Near Black)
Surface:           #141420  (Dark Card)
Surface Elevated:  #1E1E30  (Elevated Card)
Surface Overlay:   #282840  (Modal/Sheet)

Text Primary:      #F5F5F7  (White-ish)
Text Secondary:    #9898A6  (Muted Gray)
Text Tertiary:     #5C5C6E  (Dim)

Border:            #2A2A3C  (Subtle)
Divider:           #1E1E2E  (Barely visible)
```

### Light Theme

```
Background:        #FAFAFA
Surface:           #FFFFFF
Surface Elevated:  #F5F5F7
Surface Overlay:   #FFFFFF

Text Primary:      #1A1A2E
Text Secondary:    #6B6B7B
Text Tertiary:     #9898A6

Border:            #E8E8EC
Divider:           #F0F0F4
```

### Semantic Colors

```
Success:           #2ECC71
Warning:           #F39C12
Error:             #E74C3C
Info:              #3498DB
```

### Interest Category Colors

```
AI & Tech:         #6C5CE7
Cycling:           #00B894
Photography:       #E17055
Music:             #A29BFE
Startups:          #FDCB6E
Running:           #74B9FF
Cricket:           #55E6C1
Books:             #FDA7DF
Food:              #F8B739
Trekking:          #58B19F
Fitness:           #FF6348
Pets:              #C8D6E5
```

---

## 3. Typography

### Font Family

**Primary:** Inter (Google Fonts)  
**Accent:** Outfit (for headings that need personality)  
**Mono:** JetBrains Mono (for numbers, stats)

### Type Scale

| Name | Size | Weight | Line Height | Use |
|---|---|---|---|---|
| **Display Large** | 32px | Bold (700) | 40px | Hero text, event titles |
| **Display Medium** | 28px | SemiBold (600) | 36px | Section headers |
| **Headline** | 24px | SemiBold (600) | 32px | Screen titles |
| **Title Large** | 20px | SemiBold (600) | 28px | Card titles |
| **Title Medium** | 18px | Medium (500) | 24px | Subtitles |
| **Body Large** | 16px | Regular (400) | 24px | Primary body text |
| **Body Medium** | 14px | Regular (400) | 20px | Secondary body text |
| **Body Small** | 12px | Regular (400) | 16px | Captions, meta |
| **Label** | 12px | SemiBold (600) | 16px | Chips, badges, buttons |
| **Stat** | 24px | Bold (700) | 28px | Numbers, counts (JetBrains Mono) |

---

## 4. Spacing & Grid

### Spacing Scale

```
4px   (xs)    — Icon padding, tight spacing
8px   (sm)    — Between related elements
12px  (md)    — Between card elements
16px  (base)  — Standard padding, gaps
20px  (lg)    — Section spacing
24px  (xl)    — Between sections
32px  (2xl)   — Major section breaks
48px  (3xl)   — Screen-level spacing
```

### Grid

- **Screen Padding:** 16px horizontal
- **Card Gap:** 12px
- **Grid Columns:** 2 (cards), flexible

---

## 5. Component Library

### 5.1 Buttons

```
┌─────────────────────────────────┐
│  Primary Button (Filled)        │  → Orange gradient, white text
│  height: 52px, radius: 14px    │
│  gradient: #FF6B35 → #E94560   │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│  Secondary Button (Outlined)    │  → Border only, accent text
│  height: 48px, radius: 12px    │
│  border: 1.5px #FF6B35         │
└─────────────────────────────────┘

┌──────────────┐
│  Chip Button │  → Small, rounded, for filters
│  height: 36px│
│  radius: 18px│
└──────────────┘

┌───────┐
│  Icon │  → Circular, 44x44px tap target
│  Btn  │
└───────┘
```

### 5.2 Cards

#### Event Card (Home Feed)

```
┌───────────────────────────────────────┐
│  ┌─────────────────────────────────┐  │
│  │         COVER IMAGE             │  │
│  │         (16:9 ratio)            │  │
│  │                    ┌──────────┐ │  │
│  │                    │ 🔥 2.3K  │ │  │  ← Attendee badge
│  │                    └──────────┘ │  │
│  └─────────────────────────────────┘  │
│                                        │
│  🎵 Music                             │  ← Category chip
│                                        │
│  Coldplay - Music of the Spheres      │  ← Title (Title Large)
│  DY Patil Stadium, Navi Mumbai        │  ← Venue (Body Small)
│                                        │
│  📅 Sat, Jan 18 · 6:00 PM            │  ← Date (Body Small)
│                                        │
│  ┌───────┐ ┌───────┐ ┌───────┐       │
│  │Solo 2K│ │📸 542 │ │🚆 783 │       │  ← Mini Aura chips
│  └───────┘ └───────┘ └───────┘       │
│                                        │
│  [     I'm Going     ]  [  🔖 ]      │  ← CTA + Bookmark
└───────────────────────────────────────┘
```

#### Community Card

```
┌───────────────────────────────────────┐
│  ┌────┐                               │
│  │ 📸 │  Mumbai Street Photography    │  ← Avatar + Name
│  └────┘  1,245 members · 23 events   │
│                                        │
│  Photography walks around Mumbai's    │  ← Short desc
│  most iconic locations                │
│                                        │
│  ┌───────┐ ┌───────┐ ┌───────┐       │
│  │ 📷    │ │ 🚶    │ │ 🌆    │       │  ← Activity tags
│  └───────┘ └───────┘ └───────┘       │
│                                        │
│  [     Join Community     ]           │  ← CTA
└───────────────────────────────────────┘
```

### 5.3 Event Aura Widget (Killer Feature)

```
┌───────────────────────────────────────┐
│                                        │
│           ✨ EVENT AURA ✨             │
│                                        │
│        ┌──────────────────┐           │
│        │    12,482         │           │  ← Big animated counter
│        │    Attendees      │           │
│        └──────────────────┘           │
│                                        │
│  ┌──────────────────────────────────┐ │
│  │ 🔥 2,341  Solo Attendees        │ │  ← Animated bar
│  │ ████████████████░░░░░░░░░░░░░░░ │ │
│  ├──────────────────────────────────┤ │
│  │ 📸   542  Photographers         │ │
│  │ ██████░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│  ├──────────────────────────────────┤ │
│  │ 🎓 1,102  Students              │ │
│  │ ██████████░░░░░░░░░░░░░░░░░░░░░ │ │
│  ├──────────────────────────────────┤ │
│  │ 🚆   783  Train Travelers       │ │
│  │ ████████░░░░░░░░░░░░░░░░░░░░░░░ │ │
│  ├──────────────────────────────────┤ │
│  │ 🚴   234  Cyclists              │ │
│  │ ████░░░░░░░░░░░░░░░░░░░░░░░░░░░ │ │
│  └──────────────────────────────────┘ │
│                                        │
│  💡 "542 photographers are going —    │ │
│      find your photo buddy!"          │  ← AI-generated insight
│                                        │
└───────────────────────────────────────┘
```

### 5.4 Bottom Navigation

```
┌───────────────────────────────────────────┐
│                                            │
│   🏠        🗺️        👥        💬    👤  │
│  Home    Explore   Communities  Chat  Profile│
│                                            │
│  Active: Orange icon + dot indicator       │
│  Inactive: Gray icon                       │
│  Height: 60px + safe area                  │
│  Background: Surface with blur             │
└───────────────────────────────────────────┘
```

---

## 6. Screen-by-Screen Breakdown

### 6.1 Onboarding Flow (3 screens)

#### Screen 1: Welcome

```
┌──────────────────────────────┐
│                               │
│                               │
│     🌟 (Lottie animation)    │
│                               │
│     Welcome to Musafir       │ ← Display Large
│                               │
│     "I want to go,           │
│      but I don't want        │ ← Body Large, muted
│      to go alone."           │
│                               │
│     Discover communities,    │
│     events, and meaningful   │
│     connections in Mumbai    │
│                               │
│                               │
│     [    Continue with Google    ]  │ ← Primary
│     [    Continue with Phone     ]  │ ← Secondary
│                               │
│     By continuing, you agree │
│     to our Terms & Privacy   │ ← Body Small, link
│                               │
└──────────────────────────────┘
```

#### Screen 2: Select Interests

```
┌──────────────────────────────┐
│  ← Back                      │
│                               │
│  What are you into?          │ ← Headline
│  Pick 3 or more              │ ← Body Medium, muted
│                               │
│  ┌────────┐ ┌────────┐      │
│  │ 🤖     │ │ 🚴     │      │
│  │ AI &   │ │Cycling │      │  ← Interest chips
│  │ Tech ✓ │ │        │      │    (animated selection)
│  └────────┘ └────────┘      │
│  ┌────────┐ ┌────────┐      │
│  │ 📸     │ │ 🚀     │      │
│  │ Photo  │ │Startup │      │
│  │graphy✓ │ │  s     │      │
│  └────────┘ └────────┘      │
│  ┌────────┐ ┌────────┐      │
│  │ 📚     │ │ 🏃     │      │
│  │ Books  │ │Running │      │
│  │   ✓    │ │        │      │
│  └────────┘ └────────┘      │
│  ┌────────┐ ┌────────┐      │
│  │ 🏏     │ │ 🎵     │      │
│  │Cricket │ │ Music  │      │
│  │        │ │        │      │
│  └────────┘ └────────┘      │
│  ┌────────┐ ┌────────┐      │
│  │ 🍜     │ │ 🐕     │      │
│  │ Food   │ │ Pets   │      │
│  │Explorer│ │        │      │
│  └────────┘ └────────┘      │
│                               │
│  3 selected                  │
│                               │
│  [      Continue  →      ]   │ ← Primary (enabled at 3+)
│                               │
└──────────────────────────────┘
```

#### Screen 3: Location

```
┌──────────────────────────────┐
│  ← Back                      │
│                               │
│  Where are you?              │ ← Headline
│  We'll show events near you  │ ← Body Medium
│                               │
│  ┌──────────────────────────┐│
│  │ 📍 Use my location       ││ ← Auto-detect button
│  └──────────────────────────┘│
│                               │
│  or pick your area:          │
│                               │
│  ┌──────────────────────────┐│
│  │ 🔍 Search area...        ││
│  └──────────────────────────┘│
│                               │
│  Popular areas:              │
│  ┌──────┐ ┌──────┐ ┌──────┐ │
│  │Bandra│ │Powai │ │Andheri│ │
│  └──────┘ └──────┘ └──────┘ │
│  ┌──────┐ ┌──────┐ ┌──────┐ │
│  │Thane │ │Navi  │ │Lower │ │
│  │      │ │Mumbai│ │Parel │ │
│  └──────┘ └──────┘ └──────┘ │
│  ┌──────┐ ┌──────┐ ┌──────┐ │
│  │Dadar │ │Panvel│ │Malad │ │
│  └──────┘ └──────┘ └──────┘ │
│                               │
│  [    Let's Go! 🚀    ]     │ ← Primary
│                               │
└──────────────────────────────┘
```

### 6.2 Home Screen

```
┌──────────────────────────────┐
│  Musafir           🔔  🔍   │ ← App bar
│  📍 Powai, Mumbai            │ ← Location
│──────────────────────────────│
│                               │
│  Good evening, Arjun 👋     │ ← Greeting
│                               │
│  ┌──────────────────────────┐│
│  │ 🔥 This Weekend          ││ ← Section header
│  │    12 events near you    ││
│  └──────────────────────────┘│
│                               │
│  ← [Event Card] [Event Card] → │ ← Horizontal scroll
│                               │
│  ┌──────────────────────────┐│
│  │ 📍 Near You              ││
│  │    See all →             ││
│  └──────────────────────────┘│
│                               │
│  ← [Event Card] [Event Card] → │
│                               │
│  ┌──────────────────────────┐│
│  │ 👥 Communities for You   ││
│  │    See all →             ││
│  └──────────────────────────┘│
│                               │
│  ← [Community Card] [Card] → │
│                               │
│  ┌──────────────────────────┐│
│  │ 🔥 Trending Now          ││
│  └──────────────────────────┘│
│                               │
│  ← [Event Card] [Event Card] → │
│                               │
│  ┌──────────────────────────┐│
│  │ 🎯 Based on your         ││
│  │    interests             ││
│  └──────────────────────────┘│
│                               │
│  [Event Card (full width)]   │
│  [Event Card (full width)]   │
│                               │
├──────────────────────────────┤
│ 🏠    🗺️    👥    💬    👤  │
└──────────────────────────────┘
```

### 6.3 Event Detail Screen

```
┌──────────────────────────────┐
│  ← Back      [Share] [Save] │
│──────────────────────────────│
│                               │
│  ┌──────────────────────────┐│
│  │                           ││
│  │     HERO COVER IMAGE      ││
│  │     (Parallax scroll)     ││
│  │                           ││
│  │            ┌────────────┐ ││
│  │            │ 🎵 Concert │ ││ ← Category chip
│  │            └────────────┘ ││
│  └──────────────────────────┘│
│                               │
│  Coldplay — Music of the     │ ← Display Large
│  Spheres World Tour          │
│                               │
│  📅 Saturday, Jan 18, 2025   │
│  🕕 6:00 PM — 11:00 PM      │
│  📍 DY Patil Stadium,        │
│     Navi Mumbai              │ ← Tappable → Maps
│                               │
│  ┌──────────────────────────┐│
│  │  Organized by             ││
│  │  ┌────┐ BookMyShow Live   ││ ← Verified badge
│  │  │ ✓  │ Verified Organizer││
│  │  └────┘                   ││
│  └──────────────────────────┘│
│                               │
│  ┌──────────────────────────┐│
│  │ 💰 Tickets               ││
│  │ ₹2,500 — ₹35,000        ││
│  │ [  Buy Tickets  →  ]     ││ ← External link
│  └──────────────────────────┘│
│                               │
│══════════════════════════════│
│                               │
│  ✨ EVENT AURA               │ ← Killer Feature Section
│  ┌──────────────────────────┐│
│  │  12,482 Attendees        ││ ← Animated counter
│  │                           ││
│  │  🔥 2,341 Solo           ││
│  │  ████████████░░░░░░░░░░░ ││
│  │  📸   542 Photographers  ││
│  │  ██████░░░░░░░░░░░░░░░░░ ││
│  │  🎓 1,102 Students       ││
│  │  ██████████░░░░░░░░░░░░░ ││
│  │  🚆   783 Train          ││
│  │  ████████░░░░░░░░░░░░░░░ ││
│  └──────────────────────────┘│
│                               │
│══════════════════════════════│
│                               │
│  Social Layer                │ ← Tab bar
│  ┌────┐┌────┐┌────┐┌────┐┌──┐│
│  │Chat││Solo││Travel│Tix ││📷││
│  └────┘└────┘└────┘└────┘└──┘│
│                               │
│  [Selected: Going Solo]      │
│  ┌──────────────────────────┐│
│  │  2,341 people going solo ││
│  │                           ││
│  │  ┌────┐ Arjun, 23        ││
│  │  │ 🧑 │ Software Engineer││
│  │  │    │ Powai · 3 km     ││
│  │  └────┘ 🤖 📸 🎵        ││
│  │         [  Connect  ]    ││
│  │                           ││
│  │  ┌────┐ Priya, 26        ││
│  │  │ 👩 │ Photographer     ││
│  │  │    │ Bandra · 8 km    ││
│  │  └────┘ 📸 🎵 🍜        ││
│  │         [  Connect  ]    ││
│  │                           ││
│  │  See all 2,341 →         ││
│  └──────────────────────────┘│
│                               │
│══════════════════════════════│
│                               │
│  🫂 Meetup Pods              │
│  ┌──────────────────────────┐│
│  │  Powai Group (8/12)      ││
│  │  Meeting at Hiranandani  ││
│  │  [Join Pod]              ││
│  ├──────────────────────────┤│
│  │  Thane Gang (5/10)       ││
│  │  Meeting at Thane Stn    ││
│  │  [Join Pod]              ││
│  └──────────────────────────┘│
│  [+ Create a Pod]           │
│                               │
│══════════════════════════════│
│                               │
│  📝 About                    │
│  Chris Martin and Coldplay   │
│  bring their spectacular...  │
│  [Read more]                 │
│                               │
├──────────────────────────────┤
│                               │
│  ┌──────────────────────────┐│
│  │ [  I'm Going  🎉  ]     ││ ← Sticky bottom CTA
│  │ [  Going Solo  🔥  ]     ││
│  └──────────────────────────┘│
│                               │
└──────────────────────────────┘
```

### 6.4 Explore / Map Screen

```
┌──────────────────────────────┐
│  Explore              🔍    │
│──────────────────────────────│
│  ┌──────────────────────────┐│
│  │ [Map] [List]             ││ ← Toggle
│  └──────────────────────────┘│
│                               │
│  Category chips (scrollable) │
│  ← All│Music│Tech│Cycling│→  │
│                               │
│  ┌──────────────────────────┐│
│  │                           ││
│  │    MAPBOX MAP              ││
│  │                           ││
│  │    📍        📍           ││  ← Event pins
│  │         📍                ││    (clustered)
│  │    📍            📍       ││
│  │              📍           ││
│  │    📍    📍               ││
│  │                📍         ││
│  │                           ││
│  │              [📍 My loc]  ││  ← Re-center button
│  │                           ││
│  └──────────────────────────┘│
│                               │
│  ┌──────────────────────────┐│
│  │ 📍 3 events near you     ││ ← Bottom sheet (draggable)
│  │                           ││
│  │ [Event Card mini]        ││
│  │ [Event Card mini]        ││
│  │ [Event Card mini]        ││
│  └──────────────────────────┘│
│                               │
├──────────────────────────────┤
│ 🏠    🗺️    👥    💬    👤  │
└──────────────────────────────┘
```

### 6.5 Community Detail Screen

```
┌──────────────────────────────┐
│  ← Back              ⋮      │
│──────────────────────────────│
│  ┌──────────────────────────┐│
│  │     COVER IMAGE           ││
│  │                           ││
│  │   ┌────┐                  ││
│  │   │ 📸 │                  ││ ← Community avatar
│  │   └────┘                  ││
│  └──────────────────────────┘│
│                               │
│  Mumbai Street Photography   │ ← Headline
│  📸 Photography · 📍 Mumbai │
│                               │
│  1,245 members · 23 events   │
│                               │
│  [  Join  ] [  Chat  ]       │ ← CTAs
│                               │
│  ┌────┐┌────┐┌────┐┌────┐   │
│  │Feed││Events│Members│About│ │ ← Tabs
│  └────┘└────┘└────┘└────┘   │
│                               │
│  [Selected: Feed]            │
│                               │
│  ┌──────────────────────────┐│
│  │ ┌────┐ Priya · 2h ago    ││
│  │ │ 👩 │                    ││
│  │ └────┘ This weekend's     ││
│  │ Kala Ghoda walk was       ││
│  │ amazing! Here are some    ││
│  │ of my favorite shots 📸  ││
│  │                           ││
│  │ [photo] [photo] [photo]  ││
│  │                           ││
│  │ ❤️ 42  💬 8  ↗️ Share    ││
│  └──────────────────────────┘│
│                               │
│  ┌──────────────────────────┐│
│  │ ┌────┐ Arjun · 5h ago    ││
│  │ │ 🧑 │                    ││
│  │ └────┘ Anyone going to    ││
│  │ the photo exhibition at  ││
│  │ NCPA this Saturday?      ││
│  │                           ││
│  │ ❤️ 12  💬 15  ↗️ Share   ││
│  └──────────────────────────┘│
│                               │
├──────────────────────────────┤
│  [ Write something...  📎 ] │ ← Compose bar
└──────────────────────────────┘
```

### 6.6 Chat Screen

```
┌──────────────────────────────┐
│  ← Coldplay Mumbai           │
│    General Chat · 342 online │
│──────────────────────────────│
│                               │
│  ┌──────────────────────────┐│
│  │ System: Event chat        ││
│  │ created. Be respectful!  ││
│  └──────────────────────────┘│
│                               │
│         ┌──────────────────┐ │
│         │ Can't wait for    │ │ ← Other user
│         │ tonight! 🎉      │ │
│  Priya  │ 2:15 PM          │ │
│         └──────────────────┘ │
│                               │
│  ┌──────────────────┐        │
│  │ Same! Anyone from │        │ ← Current user
│  │ Powai area?       │        │
│  │ 2:16 PM      ✓✓  │        │
│  └──────────────────┘        │
│                               │
│         ┌──────────────────┐ │
│         │ Powai here! 🙋‍♂️  │ │
│  Rahul  │ 2:17 PM          │ │
│         └──────────────────┘ │
│                               │
│         ┌──────────────────┐ │
│         │ Let's share a cab │ │
│  Rahul  │ from Hiranandani │ │
│         │ 2:17 PM          │ │
│         └──────────────────┘ │
│                               │
│  ┌──────────────────┐        │
│  │ Yes! Create a pod │        │
│  │ for Powai group?  │        │
│  │ 2:18 PM      ✓✓  │        │
│  └──────────────────┘        │
│                               │
├──────────────────────────────┤
│  [  Message...   📎  📷  ➤ ]│ ← Input bar
└──────────────────────────────┘
```

### 6.7 Profile Screen

```
┌──────────────────────────────┐
│  Profile              ⚙️    │
│──────────────────────────────│
│                               │
│  ┌──────────────────────────┐│
│  │       ┌────────┐         ││
│  │       │  AVATAR │         ││
│  │       │  (80px) │         ││
│  │       └────────┘         ││
│  │                           ││
│  │    Arjun Sharma ✓        ││ ← Verified badge
│  │    @arjun_sharma          ││
│  │                           ││
│  │    Software Engineer      ││
│  │    📍 Powai, Mumbai       ││
│  │                           ││
│  │    "Always looking for    ││
│  │     the next adventure"   ││
│  │                           ││
│  │  [Edit Profile]           ││
│  └──────────────────────────┘│
│                               │
│  Interests                   │
│  ┌──────┐ ┌──────┐ ┌──────┐ │
│  │🤖Tech│ │📸Photo│ │🎵Music│ │
│  └──────┘ └──────┘ └──────┘ │
│  ┌──────┐ ┌──────┐          │
│  │🚴Cycle│ │📚Books│         │
│  └──────┘ └──────┘          │
│                               │
│  Stats                       │
│  ┌────────┐┌────────┐┌─────┐│
│  │ 12     ││ 5      ││ 23  ││
│  │ Events ││ Comms  ││Friends│
│  └────────┘└────────┘└─────┘│
│                               │
│  Upcoming Events             │
│  ┌──────────────────────────┐│
│  │ Coldplay · Jan 18        ││
│  │ Tech Meetup · Jan 20     ││
│  │ Photo Walk · Jan 25      ││
│  └──────────────────────────┘│
│                               │
│  My Communities              │
│  ← [Card] [Card] [Card] →   │
│                               │
├──────────────────────────────┤
│ 🏠    🗺️    👥    💬    👤  │
└──────────────────────────────┘
```

---

## 7. Motion & Animation

### Principles

| Type | Usage | Duration |
|---|---|---|
| **Micro-interactions** | Button taps, like animations, toggles | 150-200ms |
| **Transitions** | Page transitions, bottom sheet | 250-350ms |
| **Loading** | Skeleton screens, shimmer | Continuous |
| **Celebration** | RSVP confirmation, milestone | 500-800ms |
| **Background** | Event Aura counters, live activity | Continuous, subtle |

### Specific Animations

1. **Event Aura Counter**: Numbers count up with easing when scrolled into view
2. **RSVP Confirmation**: Confetti burst + haptic feedback
3. **Interest Selection**: Chips bounce and glow on select
4. **Pull to Refresh**: Custom Musafir loader animation (Lottie)
5. **Page Transitions**: Shared element hero for event cards → detail
6. **Map Pins**: Pulse animation on nearby events
7. **Chat**: Smooth message entry from bottom
8. **Skeleton Loading**: Shimmer effect on all loading states

---

## 8. Iconography

| Icon | Usage | Style |
|---|---|---|
| Home | Tab bar | Outlined (inactive) / Filled (active) |
| Map | Tab bar | Custom pin icon |
| People | Communities tab | Two-person icon |
| Chat | Messages tab | Bubble icon |
| Person | Profile tab | Single person icon |
| Fire | Solo attendees, trending | 🔥 emoji or custom |
| Camera | Photography | 📸 emoji or custom |
| Bookmark | Save events | Outlined / Filled |
| Share | External sharing | Arrow-up-from-square |
| Location | Location indicator | Map pin |

Use **Phosphor Icons** (Flutter package) for consistent, modern iconography.

---

*Next: [04_ROADMAP_AND_STRATEGY.md] — MVP Roadmap, V1 Roadmap, Monetization, Growth, Safety*
