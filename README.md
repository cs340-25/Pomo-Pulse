# Pomo-Pulse

Pomo-Pulse is a SwiftUI-based Pomodoro timer application designed to help users improve productivity through structured work and break intervals.

<img width="371" alt="Screenshot 2025-04-29 at 8 15 46 AM" src="https://github.com/user-attachments/assets/9e58f0cb-7d73-4ddd-8947-d96a7feed267" />
<img width="374" alt="Screenshot 2025-04-29 at 8 16 06 AM" src="https://github.com/user-attachments/assets/64571150-eae3-4d26-bb08-fdda2d1e17d3" />


## Features

- **Pomodoro Technique Implementation**: Alternates between focused work sessions and breaks
- **Visual Timer**: Circular progress indicator shows remaining time at a glance
- **Multiple Break Types**: Short breaks after each work session with longer breaks after completing a set
- **Customizable Settings**:
  - Work duration (1-60 minutes)
  - Short break duration (1-30 minutes)
  - Long break duration (5-60 minutes)
  - Number of pomodoros until a long break (1-10)
- **Progress Tracking**: Visual indicators show completed pomodoros in the current set
- **Audio Notification**: Sound alert when a timer completes
- **Persistent Settings**: User preferences are saved between app sessions

## How It Works

1. Start a work session (default 25 minutes)
2. When the timer completes, a short break begins (default 5 minutes)
3. After completing the specified number of work sessions, a long break is triggered (default 15 minutes)
4. The cycle repeats to help maintain focus and prevent burnout

## Controls

- **Play/Pause**: Start or pause the current timer
- **Reset**: Reset the current timer to its original duration
- **Skip**: Immediately end the current phase and move to the next one
- **Settings**: Customize timer durations and sequence preferences

## Technical Details

- Built with SwiftUI for iOS
- Uses AVFoundation for sound alerts
- Implements @AppStorage for persistent settings
- Responsive circular progress indicator with animations

## Requirements

- iOS 14.0 or later
- Compatible with iPhone and iPad

## Installation

1. Clone the repository
2. Open the project in Xcode
3. Build and run on your device or simulator
4. Add app icon photo under Pomo-pulse->Assets->App icon (Optional)

## Future Enhancements

- Task tracking and history
- Themes and appearance customization
- Extended statistics and productivity insights
- Additional sound options
- Focus mode integration
