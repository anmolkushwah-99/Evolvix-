# 🏛 Evolvix Architecture

Evolvix follows a layered architecture to maintain a separation of concerns and ensure scalability.

---

## 🎨 1. UI Layer (Presentation)
The UI is built using **Flutter widgets** and follows a modular structure.

- **Screens (`lib/screens/`)**: Full-page layouts such as `DashboardScreen`, `ProfileScreen`, and `StudyRoomScreen`.
- **Widgets (`lib/widgets/`)**: Reusable UI components like `XPBar`, `GlassContainer`, and `AppBottomNav`.
- **Theme (`lib/theme/`)**: Global styling including colors, typography, and button styles.

---

## 🧠 2. Logic Layer (Business Logic)
This layer handles the core functionality and rules of the gamified system.

- **Task System**: Manages task creation, completion, and status tracking.
- **XP & Leveling (`lib/services/progression_service.dart`)**: Calculates experience points earned from tasks and determines when a user levels up.
- **Character Growth**: Connects user progression to virtual character evolution.
- **Study Sessions**: Logic for Pomodoro timers and collaborative focus rooms.

---

## 💾 3. Data Layer (Persistence)
Handles data storage and retrieval.

- **Local Storage**: Uses `path_provider` and file handling for quick access to user settings and offline task data.
- **Cloud Integration**: Powered by **Firebase (Firestore & Auth)** for user accounts, real-time data sync, and multi-device support.
- **Models (`lib/models/`)**: Data classes like `UserProgress` that define the structure of information used across the app.

---

## 🔄 Data Flow
1. **User Action**: Completes a task in the UI.
2. **Logic Processing**: `ProgressionService` calculates XP and updates the user model.
3. **Data Sync**: The updated progress is saved to Firestore and reflected back in the UI via state management.
