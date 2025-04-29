# Pomo-Pulse

## Team Name: Widget Wits

## Team Members: Vansh Joshi, Matthew Phan, Larry Wang, Jake Brown

---

## Section 1: Introduction

### Overview

Pomo-Pulse is a SwiftUI-based Pomodoro timer application designed to help users improve productivity through structured work and break intervals. The application implements the Pomodoro Technique, a time management method that uses a timer to break work into intervals, traditionally 25 minutes in length, separated by short breaks. This technique helps users maintain focus and avoid burnout by structuring their work and rest periods.

### Motivation

Our motivation for this project was to address the common challenge of maintaining productivity and focus in today's distraction-filled environment. Many students and professionals struggle with time management and maintaining consistent focus during work or study sessions. The Pomodoro Technique has been proven effective for enhancing productivity, and we wanted to create an accessible, user-friendly application that would help people implement this technique in their daily routines.

### Approach

We approached this project by first establishing the core functionality of the Pomodoro timer and then expanding to additional features that enhance the user experience. We used SwiftUI for building the user interface, which provided a modern, responsive design across iOS devices. Our development process followed an iterative approach, where we continuously tested and refined features based on team feedback.

### Changes to Requirements

Our initial project proposal focused on creating "QuickFocus," a widget-based Pomodoro timer. However, as we progressed, we expanded our vision to create a full-featured application called "Pomo-Pulse" with more robust functionality. This shift allowed us to implement user authentication, cloud synchronization, and more detailed progress tracking than would have been possible with just a widget. We also enhanced the customization options to provide users with greater control over their Pomodoro sessions.

### Results and Conclusions

We successfully completed our project goals, delivering a fully functional Pomodoro timer application with additional features like user authentication, session history tracking, and customizable settings. The app includes visual timers, multiple break types, progress tracking, and audio notifications. We also implemented cloud synchronization for user data and email notification preferences. While the original widget concept evolved into a more comprehensive application, the core objective of helping users manage their time effectively was achieved and enhanced through the additional features we implemented.

---

## Section 2: Customer Value

## Changes from Project Proposal

### Date of Change: Week 2

- **Motivation**: After evaluating user needs and technical considerations, we determined that a full application would provide greater value than a widget alone.

- **Description**: Changed project focus from "QuickFocus" widget to "Pomo-Pulse" full application. This change expanded our scope to include user authentication, cloud synchronization, and more detailed session tracking. The implications included increased development time for these features but resulted in a more valuable product for users.

### Date of Change: Week 4

- **Motivation**: User research indicated a strong desire for tracking progress over time.

- **Description**: Added session history functionality that records and displays completed Pomodoro sessions. This feature was implemented with local storage and Firebase Firestore synchronization, allowing users to access their history across devices and providing them with insights into their productivity patterns.

### Date of Change: Week 5

- **Motivation**: Identified opportunity to enhance user engagement through periodic updates.

- **Description**: Implemented email notification system with customizable frequency (daily/weekly/monthly). This addition required developing a cloud function simulation for sending summaries and creating user preference settings, but added significant value by helping users stay engaged with their productivity goals.

---

## Section 3: Technology

## Architecture

Pomo-Pulse follows a client-server architecture with the following components:

1. **Frontend (Client)**:
   - Built with SwiftUI for iOS
   - Implements MVVM (Model-View-ViewModel) pattern for separation of concerns
   - Uses local storage for session data and settings

2. **Backend (Server)**:
   - Firebase Authentication for user management
   - Firebase Firestore for cloud data storage and synchronization
   - Simulated cloud functions for email notifications

3. **Key Components**:
   - **Timer Engine**: Core logic for managing Pomodoro sessions, breaks, and cycles
   - **User Authentication**: Account creation, login, and profile management
   - **Session History**: Recording and displaying completed sessions
   - **Settings Manager**: User preferences and customization options
   - **Notification System**: Timer completion alerts and email updates

The components interact through a centralized state management system, ensuring that changes in one component (like timer completion) trigger appropriate actions in others (like updating session history).

## Changes from Status Reports

### What Works

- User Authentication (Sign up, Login, Sign out)

- User Profiles with customizable email notification preferences

- Complete Pomodoro Timer functionality (Work, Short Break, Long Break modes)

- Settings customization (work/break durations, number of Pomodoros before long break)

- Session History tracking and cloud synchronization

- Email notification system (simulated)

- Persistent settings across app sessions

### What Doesn't Work / Limitations

- Widget functionality was not implemented as initially planned

- Advanced statistics and productivity insights were deprioritized

- Theme customization features were not completed

- iOS-only implementation (no cross-platform support)

## Screenshots

<!-- Note: For GitHub markdown, you would need to add actual screenshot images to your repository -->

<img width="371" alt="Screenshot 2025-04-29 at 8 15 46 AM" src="https://github.com/user-attachments/assets/687a39a9-39ee-4af0-99cb-702461ca1607" />
<img width="374" alt="Screenshot 2025-04-29 at 8 16 06 AM" src="https://github.com/user-attachments/assets/b45e1bfc-7720-4450-9dc4-1f2f3f06f46a" />

<!-- Since we don't have actual screenshots, this is a placeholder comment -->

---

## Section 4: Team

## Team Member Roles

**Vansh Joshi**:

- Primary role: Frontend Development

- Contributions: Implemented the main SwiftUI interface, designed the circular timer component, and created the settings UI

- Led the design and implementation of the visual elements

**Matthew Phan**:

- Primary role: Backend Development & Debugging

- Contributions: Implemented Firebase integration for authentication and cloud storage

- Assisted with debugging timer functionality and cloud synchronization issues

**Larry Wang**:

- Primary role: Backend Development & Debugging

- Contributions: Developed the core timer logic and session history tracking

- Worked on debugging cloud synchronization and notification systems

**Jake Brown**:

- Primary role: Project Management & Development

- Contributions: Previous experience with Swift was leveraged for overall architecture design

- Contributed to debugging efforts and implementation of audio notification system

- Coordinated team meetings and project timeline

## Contribution Balance

While team members had primary focus areas based on their expertise, all members contributed to various aspects of the project as needed. Jake's prior experience with Swift provided valuable guidance, but all team members were actively involved in development and problem-solving. The team maintained a collaborative approach throughout, with members learning from each other and contributing across different areas as required.

## Role Evolution

Team member roles remained relatively consistent throughout the project, though there was some natural evolution as the project progressed:

- During the initial planning phase, Jake took a more prominent leadership role due to his experience with Swift

- As development progressed, Vansh took increasing ownership of the frontend components

- Matthew and Larry, initially focused on backend development, became more involved in debugging and optimization in the later stages of the project

- All team members participated in testing and quality assurance during the final weeks

---

## Section 5: Project Management

## Goal Completion

We completed most of our primary goals for the product on schedule, successfully delivering a functional Pomodoro timer application with user authentication, session history, and customizable settings. However, some originally planned features were not implemented within the project timeframe:

1. **Widget Functionality**: The original concept focused heavily on a widget implementation, but this was deprioritized in favor of a more robust full application.

2. **Advanced Statistics**: Detailed productivity insights and extended statistics were planned but not fully implemented.

3. **Theme Customization**: Visual themes and appearance customization options were not completed.

## Challenges and Schedule Adjustments

The main reasons for not meeting all initial goals were:

1. **Scope Expansion**: The decision to build a full-featured application with authentication and cloud synchronization increased the development workload beyond our initial estimates.

2. **Technical Challenges**: Implementing and debugging the Firebase integration took longer than anticipated, particularly ensuring reliable synchronization of session history.

3. **Learning Curve**: While the team had programming experience, some aspects of SwiftUI and Firebase required additional learning time.

Despite these challenges, we maintained our weekly meeting schedule at Hodges Library and used these sessions effectively to reassess priorities and adjust our development focus. This allowed us to ensure that the core functionality was robust and user-friendly, even though some secondary features were deferred.

---

## Section 6: Reflection

## What Went Well

1. **Team Collaboration**: Our weekly meetings and open communication channels allowed us to effectively share knowledge and solve problems collectively.

2. **SwiftUI Implementation**: The decision to use SwiftUI provided a modern, responsive interface with relatively efficient development time.

3. **Core Functionality**: The Pomodoro timer functionality was implemented successfully with all the essential features working as intended.

4. **User Authentication**: Despite being an addition to the original concept, the authentication system was implemented smoothly and provides valuable user account functionality.

5. **Adaptability**: The team showed strong adaptability in pivoting from a widget-focused approach to a full application when we recognized the opportunity for greater user value.

## What Did Not Go Well

1. **Initial Scope Definition**: Our original project proposal lacked sufficient detail on technical implementation, which led to underestimating the complexity of certain features.

2. **Time Estimation**: We underestimated the time required for Firebase integration and cloud synchronization, causing us to adjust our feature priorities later in the project.

3. **Testing Strategy**: Our testing was somewhat ad-hoc rather than following a structured testing plan, which resulted in discovering some issues later than ideal.

4. **Widget Implementation**: The shift away from our original widget focus meant that this feature, which was central to our initial concept, was not realized.

## Project Success Evaluation

Overall, we consider the final project a success for several reasons:

1. **Core Value Delivered**: The primary objective of creating a tool to help users implement the Pomodoro Technique was achieved successfully.

2. **Enhanced Functionality**: The addition of user accounts, cloud synchronization, and session history provides greater value than our original widget concept.

3. **Learning Outcomes**: Team members gained valuable experience with SwiftUI, Firebase integration, and collaborative software development.

4. **Solid Foundation**: The application as delivered provides a strong foundation for future enhancements and feature additions.

While we didn't implement every initially planned feature, the decisions to reprioritize were made thoughtfully based on maximizing user value within our time constraints. The result is a polished, functional application that successfully addresses the productivity challenges we set out to solve.

The experience has taught us valuable lessons about scope management, technical planning, and the importance of flexibility in software development projects. These insights will serve us well in future endeavors, both in potential updates to Pomo-Pulse and in other software development projects.
