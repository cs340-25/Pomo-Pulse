import SwiftUI
import AVFoundation


// Timer mode enum
enum TimerMode: String {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
}

// Settings view
struct SettingsView: View {
    @Binding var workDuration: Int 
    @Binding var shortBreakDuration: Int
    @Binding var longBreakDuration: Int
    @Binding var pomodorosUntilLongBreak: Int
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Timer Durations")) {
                    Stepper("Work: \(workDuration) minutes", value: $workDuration, in: 1...60)
                    Stepper("Short Break: \(shortBreakDuration) minutes", value: $shortBreakDuration, in: 1...30)
                    Stepper("Long Break: \(longBreakDuration) minutes", value: $longBreakDuration, in: 5...60)
                }
                
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

struct ContentView: View {
    // Timer states
    @State private var timeRemaining = 25 * 60 // 25 minutes in seconds
    @State private var timerActive = false
    @State private var timerMode: TimerMode = .work
    @State private var completedPomodoros = 0
    @State private var showingSettings = false

    // Sound
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let soundPlayer = try? AVAudioPlayer(data: NSDataAsset(name: "bell")?.data ?? Data())
    
    // Settings
    @State private var workDuration = 25
    @State private var shortBreakDuration = 5
    @State private var longBreakDuration = 15
    @State private var pomodorosUntilLongBreak = 4
    
    var body: some View {
        VStack {
            Text("Pomo-Pulse")
                .font(.largeTitle)
                .padding()

            Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                .font(.system(size: 48, weight: .bold, design: .monospaced))
                .padding()

            HStack {
                Button(action: {
                    timerActive.toggle()
                }) {
                    Text(timerActive ? "Pause" : "Start")
                        .font(.title)
                        .padding()
                        .background(timerActive ? Color.orange : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Button(action: {
                    timeRemaining = 25 * 60
                    timerActive = false
                }) {
                    Text("Reset")
                        .font(.title)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
        }
        .onReceive(timer) { _ in
            if timerActive && timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
    }
}

@main
struct PomoPulseApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
