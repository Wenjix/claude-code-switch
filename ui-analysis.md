# CCM UI/UX Analysis & Design Document

## Current System Analysis

### Supported Models/Providers
Based on the codebase analysis, CCM supports the following providers:

1. **Claude (Official)** - Anthropic's official models
   - Sonnet (claude-sonnet-4-5-20250929)
   - Opus (claude-opus-4-1-20250805)
   - Haiku (claude-haiku-4-5)

2. **DeepSeek** - Efficient reasoning model
   - deepseek-chat / deepseek-v3.2-exp

3. **KIMI** - Moonshot AI (Long text processing)
   - kimi-for-coding
   - kimi-k2-thinking (CN version)

4. **Qwen** - Alibaba Tongyi Qianwen
   - qwen3-max
   - qwen3-next-80b-a3b-instruct

5. **GLM** - Zhipu AI
   - glm-4.6
   - glm-4.5-air

6. **MiniMax** - MiniMax M2
   - MiniMax-M2

7. **LongCat** - Meituan (not in switch list but in config)
   - LongCat-Flash-Thinking

8. **Seed/Doubao** - ByteDance
   - doubao-seed-code-preview-latest

9. **KAT** - StreamLake service

10. **PPINFRA** - Fallback service provider

### Configuration System
- **Config File**: `~/.ccm_config`
- **Accounts File**: `~/.ccm_accounts`
- **Environment Variables**: Priority over config file
- **API Keys**: Per-provider authentication
- **Model Override**: Customizable model IDs

### Key Environment Variables Set by CCM
- `ANTHROPIC_BASE_URL` - API endpoint
- `ANTHROPIC_AUTH_TOKEN` - Authentication token
- `ANTHROPIC_MODEL` - Primary model
- `ANTHROPIC_SMALL_FAST_MODEL` - Fast/fallback model

## UI/UX Design Concept

### Design Principles
1. **Visual Clarity** - Immediately show current active configuration
2. **Quick Access** - One-click switching between models
3. **Status Transparency** - Clear indication of API key status
4. **Non-Intrusive** - Complement CLI, don't replace it
5. **Safety First** - Confirm before switching, show what will change

### User Personas
1. **Power User** - Uses CLI primarily, wants quick visual confirmation
2. **Visual Learner** - Prefers GUI, wants to see all options at once
3. **Multi-Model User** - Frequently switches between providers

### Core User Flows

#### Flow 1: Check Current Status
```
Launch UI → See current active model highlighted → View API key status
```

#### Flow 2: Switch Model
```
Launch UI → Browse available models → Click desired model → Confirm → Switch applied
```

#### Flow 3: Manage API Keys
```
Launch UI → Click settings → View/Edit API keys → Save → Keys updated
```

## UI Components Design

### 1. Main Dashboard View
**Purpose**: Show current status at a glance

**Components**:
- **Current Model Card** (Prominent, top center)
  - Provider logo/icon
  - Model name
  - Status indicator (active/inactive)
  - Base URL display
  - Last switched timestamp

- **Quick Stats Panel**
  - Number of configured providers
  - API keys status summary
  - Environment variable status

### 2. Model Grid/List View
**Purpose**: Browse and select models

**Components**:
- **Model Cards** (Grid layout, 3-4 columns)
  - Provider name & logo
  - Model description
  - API key status badge (✓ Configured / ⚠️ Missing / 🔄 Fallback)
  - "Switch" button
  - "Details" expand button

- **Filters**
  - Show all / Configured only / Favorites
  - Sort by: Name, Recently used, Provider

### 3. Switch Confirmation Modal
**Purpose**: Confirm before applying changes

**Components**:
- Current configuration (before)
- New configuration (after)
- What will change (diff view)
- "Apply" and "Cancel" buttons
- Option: "Don't ask again for this session"

### 4. Settings Panel
**Purpose**: Manage configuration

**Components**:
- **API Keys Management**
  - List of all providers
  - Masked key display
  - Edit/Add/Delete keys
  - Test connection button

- **Preferences**
  - Language selection (EN/CN)
  - Auto-refresh interval
  - Confirmation preferences
  - Theme (light/dark)

### 5. Status Indicator
**Purpose**: Always-visible status

**Components**:
- Small icon in menu bar/system tray (for desktop app)
- Shows current provider with color coding
- Quick menu on click

## Technical Architecture Options

### Option A: Terminal UI (TUI)
**Technology**: Python + Rich/Textual or Go + Bubble Tea
**Pros**:
- Stays in terminal environment
- Fast and lightweight
- No GUI dependencies
**Cons**:
- Limited visual design options
- Less intuitive for non-technical users

### Option B: Web-based UI
**Technology**: React/Vue + Node.js backend
**Pros**:
- Rich visual design possibilities
- Cross-platform (browser-based)
- Easy to style and animate
**Cons**:
- Requires running a web server
- More complex setup

### Option C: Native Desktop App
**Technology**: Electron or Tauri
**Pros**:
- Native OS integration
- System tray support
- Best user experience
**Cons**:
- Larger application size
- More complex distribution

### Option D: Menu Bar App (macOS)
**Technology**: Swift + SwiftUI or Python + rumps
**Pros**:
- Perfect for quick access
- Native macOS integration
- Minimal footprint
**Cons**:
- macOS only
- Limited screen space

## Recommended Approach

### Phase 1: Web-based Dashboard (MVP)
Build a local web UI that can be launched with a command like `ccm ui`

**Why**:
- Cross-platform compatibility
- Rich visual capabilities
- Can be accessed from any browser
- Easy to iterate and test
- Can later be packaged as desktop app

**Tech Stack**:
- Frontend: React + TypeScript + Tailwind CSS
- Backend: Node.js + Express (or Python Flask)
- Communication: REST API + WebSocket for real-time updates
- Data: Read/write to ~/.ccm_config and environment variables

**Key Features**:
1. Real-time status display
2. Visual model selector
3. API key management
4. Configuration editor
5. Switch history
6. Model comparison view

### Phase 2: Enhanced Features
- Desktop app packaging (Electron/Tauri)
- System tray integration
- Keyboard shortcuts
- Model performance metrics
- Usage statistics

## Visual Design Mockup Structure

### Color Scheme
- **Primary**: Blue (#3B82F6) - Trust, technology
- **Success**: Green (#10B981) - Active, configured
- **Warning**: Yellow (#F59E0B) - Fallback, needs attention
- **Error**: Red (#EF4444) - Missing, error
- **Neutral**: Gray scale for backgrounds

### Typography
- **Headings**: Inter or SF Pro (system font)
- **Body**: System font stack
- **Code**: JetBrains Mono or Fira Code

### Layout
- **Desktop**: 1200px max-width, centered
- **Responsive**: Mobile-friendly (though primary use is desktop)
- **Spacing**: 8px grid system

## Next Steps
1. Create visual mockups
2. Build prototype web UI
3. Integrate with existing CLI tools
4. User testing
5. Iterate based on feedback
