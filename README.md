# 🕒 Pomo-Pulse

**Pomo-Pulse** is a powerful SwiftUI-based Pomodoro timer designed to enhance productivity through focused work intervals, customizable settings, cloud-synced history, and real-time email summaries.

<p float="left">
  <img src="https://github.com/user-attachments/assets/9e58f0cb-7d73-4ddd-8947-d96a7feed267" width="300" />
  <img src="https://github.com/user-attachments/assets/64571150-eae3-4d26-bb08-fdda2d1e17d3" width="300" />
</p>

---

## 🚀 Features

- ⏱️ **Pomodoro Timer**: Alternate between focus and break phases
- 🔄 **Phase Cycling**: Short breaks after each work session; long breaks after multiple sessions
- 🎯 **Progress Indicators**: Visual display of completed Pomodoros
- 🔔 **Audio Alerts**: Bell sound when timer ends (via AVFoundation)
- ⚙️ **Settings Panel**:
  - Work duration: 1–60 minutes
  - Short break: 1–30 minutes
  - Long break: 5–60 minutes
  - Pomodoros until long break: 1–10
- 📊 **Session History**:
  - Stored locally and synced to Firebase Firestore (if logged in)
  - Filter by Work / Breaks / All
  - Summary stats and deletion support
- 👤 **Authentication**:
  - Email/password login and signup via FirebaseAuth
  - Email preferences stored in Firestore
- 📧 **Email Reports**:
  - Weekly, daily, or monthly session summaries
  - Automatically triggered based on frequency setting

---

## 🛠️ How It Works

1. Start a **Work** session (default: 25 minutes)
2. After the timer ends, a **Short Break** starts (default: 5 minutes)
3. After `n` work sessions, a **Long Break** (default: 15 minutes) begins
4. This loop continues until manually reset or paused

---

## 🧭 Controls

| Control       | Action                        |
|---------------|-------------------------------|
| ▶️ Play/Pause | Start or pause the timer      |
| 🔁 Reset      | Reset to current mode duration |
| ⏭️ Skip       | Move to the next phase         |
| ⚙️ Settings   | Adjust timer preferences       |
| 📜 History    | View past sessions             |
| 👤 Profile    | Manage account & email reports |

---

## 🔧 Technical Details

- **Language**: Swift (SwiftUI)
- **Dependencies**:
  - `FirebaseAuth`, `FirebaseFirestore`
  - `AVFoundation` for sound
- **Storage**:
  - `@AppStorage` for settings
  - `UserDefaults` + Firestore for session history
- **UI**: Animated circular progress, dark/light themes, segmented filters

---

## 📱 Requirements

- iOS 14.0+
- iPhone or iPad

---

## 📦 Installation

```bash
git clone https://github.com/your-username/pomo-pulse.git
cd pomo-pulse
open PomoPulse.xcodeproj
```

> Optionally add an app icon under `Assets > AppIcon`

---

## 🧪 Future Enhancements

- ✅ Task tracking & to-dos
- 📈 Visual productivity stats
- 🎨 Theme customization
- 🔕 Local notifications in background
- 🔊 Custom alert sounds
- 🧘 Focus mode integration

---
