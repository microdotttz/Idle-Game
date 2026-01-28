# Potion Shop Tycoon

A cozy idle game where you run a potion shop. Grow ingredients, brew potions, serve customers, and build your alchemical empire.

## Running on Your Phone

### Option 1: Android (Easiest)

**Requirements:**
- Godot 4.2+ with Android export templates
- Android phone with USB debugging enabled

**Steps:**

1. **Install Godot 4.2+**
   - Download from [godotengine.org](https://godotengine.org/download)

2. **Install Android Export Templates**
   - In Godot: `Editor → Manage Export Templates → Download and Install`

3. **Set Up Android SDK** (one-time)
   - Install Android Studio OR just the command-line tools
   - In Godot: `Editor → Editor Settings → Export → Android`
   - Set paths to:
     - Android SDK (usually `~/Android/Sdk`)
     - Debug keystore (Godot can generate one)

4. **Enable USB Debugging on Phone**
   - Settings → About Phone → Tap "Build Number" 7 times
   - Settings → Developer Options → Enable USB Debugging

5. **Export & Run**
   - Connect phone via USB
   - In Godot: `Project → Export → Android`
   - Click "Export Project" or "Run on Device" (one-click deploy)

### Option 2: iOS

**Requirements:**
- Mac with Xcode installed
- Apple Developer account ($99/year) for device testing
- iPhone/iPad

**Steps:**

1. Install Godot 4.2+ on Mac
2. Install iOS export templates
3. `Project → Export → iOS`
4. Open generated Xcode project
5. Sign with your developer account
6. Build to device

### Option 3: Web (Test on Any Phone)

**No app install needed!**

1. In Godot: `Project → Export → Web`
2. Click "Export Project"
3. Upload the `exports/web/` folder to any web host
4. Open URL on your phone's browser

**Free hosting options:**
- [itch.io](https://itch.io) (game-focused)
- [GitHub Pages](https://pages.github.com) (free)
- [Netlify](https://netlify.com) (drag & drop)

---

## Quick Start (Development)

```bash
# Clone the repo
git clone <your-repo-url>
cd Idle-Game

# Open in Godot
# 1. Launch Godot 4.2+
# 2. Click "Import"
# 3. Navigate to project.godot
# 4. Press F5 to run
```

---

## Project Structure

```
Idle-Game/
├── project.godot          # Project config
├── export_presets.cfg     # Export settings
│
├── scenes/
│   ├── main/              # Root scene
│   ├── shop/              # Shop UI
│   ├── workshop/          # Workshop/machines
│   ├── garden/            # Planting
│   ├── activities/        # Fishing, hunting, foraging
│   └── ui/                # Shared components
│
├── scripts/
│   ├── autoload/          # Global singletons
│   ├── shop/              # Shop logic
│   ├── workshop/          # Machine logic
│   ├── garden/            # Growing logic
│   ├── activities/        # Side activities
│   ├── resources/         # Data classes
│   └── ui/                # UI scripts
│
├── resources/             # Theme, data files
└── assets/                # Sprites, audio (add your own)
```

---

## Mobile Optimization

The game is already configured for mobile:

- **Portrait mode** (720x1280)
- **Touch input** enabled
- **Mobile renderer** selected
- **Stretch mode** set for all screen sizes
- **Large tap targets** for buttons

---

## Exporting Checklist

Before exporting, consider:

- [ ] Add app icons (see `export_presets.cfg` for sizes needed)
- [ ] Add splash screen
- [ ] Test on multiple screen sizes
- [ ] Set version number
- [ ] Remove debug prints

---

## Controls

- **Tap** buttons to interact
- **Swipe** tab bar to switch screens
- **Long press** items for details

---

## Game Features

### Shop
- Stock display shelves with potions
- Serve customers before patience runs out
- Earn gold and reputation

### Workshop
- Place machines on a grid
- Process ingredients: Raw → Processed → Refined → Enchanted
- Brew potions in cauldrons

### Garden
- Plant seeds in plots
- Wait for growth (real time)
- Harvest for ingredients

### Activities
- **Fishing**: Cast line, wait for bite, tap to catch
- **Hunting**: Track creatures, attempt hunt
- **Foraging**: Search areas for materials

---

## Save System

- Auto-saves every 60 seconds
- Saves on app minimize/close
- Offline progress calculated on return (up to 8 hours)

---

## License

[Add your license here]
