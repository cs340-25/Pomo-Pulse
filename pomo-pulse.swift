import SwiftUI

struct ContentView: View {
    @State private var timeRemaining = 25 * 60 // 25 minutes in seconds
        @State private var timerActive = false
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        
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
