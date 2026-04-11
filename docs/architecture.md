# 🏗 Architecture Overview – Evolvix

Evolvix follows a simple and modular architecture to ensure clarity, scalability, and maintainability.

---

## 🔹 1. UI Layer (Presentation Layer)

This layer handles everything the user interacts with.

- Screens (Home, Character Creation, Dashboard, Profile)
- Widgets and UI components
- User inputs (adding tasks, completing tasks)

👉 Purpose:
To provide a clean, simple, and responsive user interface.

---

## 🔹 2. Logic Layer (Business Logic)

This layer manages the core functionality of the app.

- Task management system (add, update, complete tasks)
- XP and reward calculation
- Character progression and leveling system
- Validation and processing of user actions

👉 Purpose:
To process user actions and control app behavior.

---

## 🔹 3. Data Layer (Storage)

This layer handles data storage and retrieval.

- Stores tasks and user progress
- Maintains XP, levels, and achievements
- Uses local storage (can be extended to cloud in future)

👉 Purpose:
To persist user data and ensure continuity.

---

## 🔄 Data Flow

1. User interacts with UI (adds/completes task)  
2. Logic layer processes the action  
3. Data layer stores updates  
4. UI updates with new progress and character growth  

---

## ✅ Summary

The separation of UI, logic, and data ensures:
- Better code organization  
- Easier debugging  
- Scalability for future features