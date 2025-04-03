import SwiftUI
import AVFoundation


// Timer mode enum
enum TimerMode: String {
    case work = "Work"
    case shortBreak = "Short Break"
    case longBreak = "Long Break"
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
