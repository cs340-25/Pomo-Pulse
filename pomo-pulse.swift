import SwiftUI
import AVFoundation

struct ContentView: View {
    // MARK: - State Properties
    // Timer state variables to track current timer status
    @State private var timeRemaining = 25 * 60 // 25 minutes in seconds
    @State private var timerActive = false     // Controls if timer is running
    @State private var timerMode: TimerMode = .work  // Current timer mode (work/break)
    @State private var completedPomodoros = 0  // Tracks completed work sessions
    @State private var showingSettings = false // Controls settings sheet visibility
    
    // MARK: - User Settings
    // Persistent settings stored using AppStorage
    @AppStorage("workDuration") private var workDuration = 25               // Work duration in minutes
    @AppStorage("shortBreakDuration") private var shortBreakDuration = 5    // Short break duration in minutes
    @AppStorage("longBreakDuration") private var longBreakDuration = 15     // Long break duration in minutes
    @AppStorage("pomodorosUntilLongBreak") private var pomodorosUntilLongBreak = 4  // Work sessions before long break
    
    // MARK: - Timer and Sound
    // Timer publisher to trigger updates every second
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    // Sound player for timer completion notification
    let soundPlayer = try? AVAudioPlayer(data: NSDataAsset(name: "bell")?.data ?? Data())
    
    // MARK: - Computed Properties
    // Calculate progress percentage for circular timer display
    var progress: Double {
        let totalTime = timerMode == .work ? workDuration * 60 :
                       (timerMode == .shortBreak ? shortBreakDuration * 60 : longBreakDuration * 60)
        return Double(totalTime - timeRemaining) / Double(totalTime)
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Pomodoro Progress Indicators
                // Display circles showing progress within the current pomodoro set
                HStack {
                    ForEach(0..<pomodorosUntilLongBreak, id: \.self) { index in
                        Image(systemName: index < completedPomodoros % pomodorosUntilLongBreak ? "circle.fill" : "circle")
                            .foregroundColor(.red)
                    }
                }
                .padding()
                
                // MARK: - Timer Mode Label
                // Display current mode (Work, Short Break, Long Break)
                Text(timerMode.rawValue)
                    .font(.title)
                    .foregroundColor(timerMode == .work ? .red : .green)
                    .fontWeight(.bold)
                
                // MARK: - Timer Circle Display
                // Visual circular timer with progress indicator
                ZStack {
                    // Background circle
                    Circle()
                        .stroke(lineWidth: 20)
                        .opacity(0.3)
                        .foregroundColor(timerMode == .work ? .red : .green)
                    
                    // Progress circle that grows as time passes
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                        .foregroundColor(timerMode == .work ? .red : .green)
                        .rotationEffect(Angle(degrees: 270))
                        .animation(.linear, value: progress)
                    
                    // Time remaining and mode label
                    VStack {
                        // Timer display in MM:SS format
                        Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                            .font(.system(size: 60, weight: .bold, design: .monospaced))
                        
                        // Current focus state label
                        Text("\(timerMode == .work ? "Focus" : "Break")")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(40)
                
                // MARK: - Control Buttons
                // Play/Pause and Reset buttons
                HStack(spacing: 30) {
                    // Play/Pause toggle button
                    Button(action: {
                        timerActive.toggle()
                    }) {
                        Image(systemName: timerActive ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(timerActive ? .orange : .green)
                    }
                    
                    // Reset button to restart current timer
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                    }
                }
                
                // MARK: - Skip Button
                // Button to bypass current phase and move to next one
                Button(action: skipToNextPhase) {
                    Text("Skip to next phase")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
            .navigationTitle("Pomo-Pulse")
            // MARK: - Settings Button
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(action: { showingSettings.toggle() }) {
                        Image(systemName: "gear")
                    }
                }
            }
            // MARK: - Settings Sheet
            // Modal sheet for timer configuration
            .sheet(isPresented: $showingSettings) {
                SettingsView(
                    workDuration: $workDuration,
                    shortBreakDuration: $shortBreakDuration,
                    longBreakDuration: $longBreakDuration,
                    pomodorosUntilLongBreak: $pomodorosUntilLongBreak
                )
            }
        }
        // MARK: - Timer Event Handler
        // Update timer every second when active
        .onReceive(timer) { _ in
            if timerActive && timeRemaining > 0 {
                // Decrement timer if active and not finished
                timeRemaining -= 1
            } else if timerActive && timeRemaining == 0 {
                // Timer finished - play sound and move to next phase
                playSound()
                moveToNextPhase()
            }
        }
    }
    
    // MARK: - Timer Control Methods
    
    /// Resets the current timer to its starting value
    func resetTimer() {
        timerActive = false
        updateTimeRemainingForCurrentMode()
    }
    
    /// Plays the notification sound when timer completes
    func playSound() {
        soundPlayer?.play()
    }
    
    /// Handles transition between work and break phases
    func moveToNextPhase() {
        timerActive = false
        
        if timerMode == .work {
            // If coming from work mode, increment completed count
            completedPomodoros += 1
            // Determine if we need a long break or short break
            if completedPomodoros % pomodorosUntilLongBreak == 0 {
                timerMode = .longBreak
            } else {
                timerMode = .shortBreak
            }
        } else {
            // If coming from break mode, go back to work
            timerMode = .work
        }
        
        // Update timer for the new mode
        updateTimeRemainingForCurrentMode()
    }
    
    /// Manually skips to next phase
    func skipToNextPhase() {
        moveToNextPhase()
    }
    
    /// Sets the timer value based on current mode
    func updateTimeRemainingForCurrentMode() {
        switch timerMode {
        case .work:
            timeRemaining = workDuration * 60
        case .shortBreak:
            timeRemaining = shortBreakDuration * 60
        case .longBreak:
            timeRemaining = longBreakDuration * 60
        }
    }
}

// MARK: - Timer Mode Enum
/// Defines the possible states of the Pomodoro timer
enum TimerMode: String {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

// MARK: - Settings View
/// View for customizing timer durations and sequence
struct SettingsView: View {
    // Bindings to parent view's settings variables
    @Binding var workDuration: Int
    @Binding var shortBreakDuration: Int
    @Binding var longBreakDuration: Int
    @Binding var pomodorosUntilLongBreak: Int
    @Environment(\.dismiss) var dismiss  // Used to dismiss the view
    
    var body: some View {
        NavigationView {
            Form {
                // Timer duration settings
                Section(header: Text("Timer Durations")) {
                    Stepper("Work: \(workDuration) minutes", value: $workDuration, in: 1...60)
                    Stepper("Short Break: \(shortBreakDuration) minutes", value: $shortBreakDuration, in: 1...30)
                    Stepper("Long Break: \(longBreakDuration) minutes", value: $longBreakDuration, in: 5...60)
                }
                
                // Pomodoro sequence settings
                Section(header: Text("Pomodoro Sequence")) {
                    Stepper("Pomodoros until long break: \(pomodorosUntilLongBreak)", value: $pomodorosUntilLongBreak, in: 1...10)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - App Entry Point
@main
struct PomoPulseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
