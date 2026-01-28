# Mobile Development Workflow

Quick ways to iterate on your phone during development.

---

## Option 1: Web Preview (Fastest Setup)

**One command to test on phone:**

```bash
./test-mobile.sh
```

This will:
1. Export to web
2. Start a local server
3. Show you a URL like `http://192.168.1.100:8080`
4. Open that URL on your phone (same WiFi)

**To refresh after changes:**
- Save in Godot
- Run `./test-mobile.sh` again
- Refresh your phone browser

---

## Option 2: Auto-Rebuild (Best for Active Development)

```bash
./watch-and-serve.sh
```

This will:
1. Export to web
2. Start server
3. Watch for file changes
4. Auto-rebuild when you save

**Just refresh your phone browser after saving in Godot!**

Requires `inotifywait` (Linux) or `fswatch` (macOS):
```bash
# Linux
sudo apt install inotify-tools

# macOS
brew install fswatch
```

---

## Option 3: Godot Remote Debug (Best for Debugging)

Run the game on your phone with live debugging in Godot.

### Setup (One-Time)

1. In Godot: `Editor → Editor Settings → Network → Debug`
2. Set `Remote Host` to your computer's IP (e.g., `192.168.1.100`)
3. Set `Remote Port` to `6007`

### Deploy & Debug

1. Export to Android/iOS
2. Install the app on your phone
3. In Godot: `Debug → Deploy with Remote Debug`
4. The phone app connects back to Godot for debugging

---

## Option 4: Android One-Click Deploy

If you have Android SDK set up:

1. Connect phone via USB
2. Enable USB Debugging on phone
3. In Godot: Click the **Android icon** in the top-right toolbar
4. Game deploys and runs on phone instantly

Each new run takes ~10 seconds.

---

## Option 5: ADB Wireless (No Cable)

After initial USB setup:

```bash
# On computer (phone connected via USB first)
adb tcpip 5555
adb connect <phone-ip>:5555

# Now unplug USB - wireless deploys work!
```

---

## Comparison

| Method | Setup Time | Iteration Speed | Debug Support |
|--------|-----------|-----------------|---------------|
| Web Preview | 1 min | 5 sec refresh | Console only |
| Auto-Rebuild | 5 min | 5 sec auto | Console only |
| Remote Debug | 15 min | 10 sec | Full debugger |
| USB Deploy | 30 min | 10 sec | Full debugger |
| Wireless ADB | 35 min | 10 sec | Full debugger |

**Recommendation:** Start with Web Preview, upgrade to Auto-Rebuild when you want faster iteration.

---

## Quick Reference

### Get Your Computer's IP

```bash
# Linux
ip route get 1 | awk '{print $7}'

# macOS
ipconfig getifaddr en0

# Windows
ipconfig | findstr IPv4
```

### Phone and Computer Must Be on Same WiFi!

If you can't connect:
1. Check firewall allows port 8080
2. Make sure both devices on same network
3. Try disabling VPN

### Common Issues

**"Connection refused" on phone:**
- Firewall blocking port 8080
- Wrong IP address
- Different WiFi networks

**Export fails:**
- Install export templates: `Editor → Manage Export Templates`

**Godot not found:**
```bash
# Set path manually
GODOT_CMD=/path/to/godot ./test-mobile.sh
```

---

## File Structure

```
Idle-Game/
├── test-mobile.sh      # Quick export + serve
├── watch-and-serve.sh  # Auto-rebuild + serve
├── exports/
│   └── web/            # Web build output
│       └── index.html  # Open this on phone
└── export_presets.cfg  # Export settings
```
