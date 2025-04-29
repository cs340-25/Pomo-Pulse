import SwiftUI
import AVFoundation
import AuthenticationServices
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

// Firebase configuration setup
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

// Model for storing completed session data
struct PomodoroSession: Identifiable, Codable {
    var id = UUID()
    var date: Date
    var duration: Int // in minutes
    var type: String // "Work", "Short Break", or "Long Break"
    var userId: String? // For linking sessions to user accounts
    
    // Computed property for formatted date
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// Authentication Manager
class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var db = Firestore.firestore()
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        if let user = Auth.auth().currentUser {
            self.isAuthenticated = true
            self.loadUserProfile(userId: user.uid)
        } else {
            self.isAuthenticated = false
            self.currentUser = nil
        }
    }
    
    func loadUserProfile(userId: String) {
        self.isLoading = true
        
        db.collection("users").document(userId).getDocument { [weak self] document, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = "Failed to load profile: \(error.localizedDescription)"
                return
            }
            
            if let document = document, document.exists,
               let data = try? document.data(as: UserProfile.self) {
                self?.currentUser = data
            } else {
                // Create new profile if it doesn't exist
                if let user = Auth.auth().currentUser {
                    let newProfile = UserProfile(
                        userId: user.uid,
                        email: user.email ?? "",
                        displayName: user.displayName
                    )
                    
                    try? self?.db.collection("users").document(user.uid).setData(from: newProfile)
                    self?.currentUser = newProfile
                }
            }
        }
    }
    
    func signInWithEmail(email: String, password: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            if let user = authResult?.user {
                self?.isAuthenticated = true
                self?.loadUserProfile(userId: user.uid)
                completion(true)
            } else {
                self?.errorMessage = "Unknown error occurred"
                completion(false)
            }
        }
    }
    
    func signUpWithEmail(email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {
        self.isLoading = true
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.isLoading = false
                self?.errorMessage = error.localizedDescription
                completion(false)
                return
            }
            
            if let user = authResult?.user {
                // Update display name
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { _ in }
                
                // Create user profile
                let newProfile = UserProfile(
                    userId: user.uid,
                    email: email,
                    displayName: name
                )
                
                try? self?.db.collection("users").document(user.uid).setData(from: newProfile)
                
                self?.isAuthenticated = true
                self?.currentUser = newProfile
                self?.isLoading = false
                completion(true)
            } else {
                self?.isLoading = false
                self?.errorMessage = "Unknown error occurred"
                completion(false)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
            self.currentUser = nil
        } catch {
            self.errorMessage = "Failed to sign out: \(error.localizedDescription)"
        }
    }
    
    func updateEmailPreferences(enabled: Bool, frequency: UserProfile.EmailFrequency, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        
        self.isLoading = true
        
        db.collection("users").document(userId).updateData([
            "emailNotificationsEnabled": enabled,
            "emailFrequency": frequency.rawValue
        ]) { [weak self] error in
            self?.isLoading = false
            
            if let error = error {
                self?.errorMessage = "Failed to update preferences: \(error.localizedDescription)"
                completion(false)
                return
            }
            
            if let currentUser = self?.currentUser {
                var updatedUser = currentUser
                updatedUser.emailNotificationsEnabled = enabled
                updatedUser.emailFrequency = frequency
                self?.currentUser = updatedUser
            }
            
            completion(true)
        }
    }
}

// User Profile Model
struct UserProfile: Codable {
    var userId: String
    var email: String
    var displayName: String?
    var emailNotificationsEnabled: Bool = true
    var emailFrequency: EmailFrequency = .weekly
    var lastEmailSent: Date?
    
    enum EmailFrequency: String, Codable, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case monthly = "Monthly"
    }
}

// Session History Manager with Cloud Sync
class SessionHistoryManager: ObservableObject {
    private let localHistoryKey = "pomodoroSessionHistory"
    private var db = Firestore.firestore()
    @Published var sessions: [PomodoroSession] = []
    
    // Load sessions from both local storage and cloud
    func loadSessions(for userId: String? = nil) -> [PomodoroSession] {
        var localSessions: [PomodoroSession] = []
        
        // Load from local storage first
        if let data = UserDefaults.standard.data(forKey: localHistoryKey),
           let decoded = try? JSONDecoder().decode([PomodoroSession].self, from: data) {
            localSessions = decoded
        }
        
        // If user is logged in, sync with cloud
        if let userId = userId {
            syncSessionsWithCloud(localSessions: localSessions, userId: userId)
        }
        
        return localSessions
    }

    // Sync local sessions with cloud
    func syncSessionsWithCloud(localSessions: [PomodoroSession], userId: String) {
        // Get cloud sessions
        db.collection("users").document(userId).collection("sessions").getDocuments { [weak self] snapshot, error in
            if let error = error {
                print("Error getting cloud sessions: \(error)")
                return
            }
            
            guard let snapshot = snapshot else { return }
            
            // Convert cloud documents to sessions
            var cloudSessions: [PomodoroSession] = []
            for document in snapshot.documents {
                if let session = try? document.data(as: PomodoroSession.self) {
                    cloudSessions.append(session)
                }
            }
            
            // Merge local and cloud sessions
            var mergedSessions = localSessions
            
            // Add cloud sessions that don't exist locally
            for cloudSession in cloudSessions {
                if !localSessions.contains(where: { $0.id == cloudSession.id }) {
                    mergedSessions.append(cloudSession)
                }
            }
            
            // Update local storage with merged sessions
            self?.sessions = mergedSessions
            self?.saveSessions(mergedSessions)
            
            // Upload local sessions that don't exist in cloud
            for localSession in localSessions {
                if !cloudSessions.contains(where: { $0.id == localSession.id }) {
                    var sessionWithUserId = localSession
                    sessionWithUserId.userId = userId
                    
                    do {
                        try self?.db.collection("users").document(userId)
                            .collection("sessions")
                            .document(localSession.id.uuidString)
                            .setData(from: sessionWithUserId)
                    } catch {
                        print("Error uploading session: \(error)")
                    }
                }
            }
        }
    }

    // Save sessions locally
    func saveSessions(_ sessions: [PomodoroSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            UserDefaults.standard.set(encoded, forKey: localHistoryKey)
        }
        self.sessions = sessions
    }
    
    // Add a new session both locally and to cloud if user is logged in
    func addSession(_ session: PomodoroSession, to sessions: inout [PomodoroSession], userId: String? = nil) {
        var sessionToAdd = session
        sessionToAdd.userId = userId
        
        sessions.append(sessionToAdd)
        saveSessions(sessions)
        
        // If user is logged in, also save to cloud
        if let userId = userId {
            do {
                try db.collection("users").document(userId)
                    .collection("sessions")
                    .document(session.id.uuidString)
                    .setData(from: sessionToAdd)
            } catch {
                print("Error saving session to cloud: \(error)")
            }
        }
    }
    
    // Delete session both locally and from cloud
    func deleteSession(at indexSet: IndexSet, from sessions: inout [PomodoroSession], userId: String? = nil) {
        let sessionsToDelete = indexSet.map { sessions[$0] }
        
        // Remove from local storage
        sessions.remove(atOffsets: indexSet)
        saveSessions(sessions)
        
        // Remove from cloud if user is logged in
        if let userId = userId {
            for session in sessionsToDelete {
                db.collection("users").document(userId)
                    .collection("sessions")
                    .document(session.id.uuidString)
                    .delete()
            }
        }
    }
}

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
    
    // MARK: - Filled Circles
    var displayFilledCount: Int {
        guard completedPomodoros > 0 else { return 0 }
            
        let mod = completedPomodoros % pomodorosUntilLongBreak
        if mod != 0 {
            return mod
        }
        
        return timerMode == .work ? 0 : pomodorosUntilLongBreak
    }
    
    // MARK: - View Body
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // MARK: - Pomodoro Progress Indicators
                // Display circles showing progress within the current pomodoro set
                HStack {
                    ForEach(0..<pomodorosUntilLongBreak, id: \.self) { index in
                        Image(systemName: index < displayFilledCount ? "circle.fill" : "circle")
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
