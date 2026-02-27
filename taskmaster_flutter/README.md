# TaskMaster — Flutter Task Management App

A production-ready Flutter task management app built for the 24-hour technical assessment. Clean architecture, real API integration, dark mode, caching, animations, and more.

---

## 📱 Features

- **Authentication** — Login & Register (backed by [dummyjson.com](https://dummyjson.com))
- **Task Management** — Create, Read, Update, Delete tasks
- **Task Fields** — Title, Description, Status, Due Date
- **Pull-to-Refresh** — Swipe down to reload tasks
- **Infinite Scroll / Pagination** — Loads more tasks as you scroll
- **Filter Chips** — Filter by All / Pending / In Progress / Completed
- **Offline Cache** — Hive-based local cache for offline fallback
- **Dark Mode** — Follows system theme
- **Animations** — Fade/slide-in with flutter_animate
- **Shimmer Loading** — Skeleton screens during fetch
- **Error & Empty States** — Proper feedback for all edge cases
- **Secure Token Storage** — flutter_secure_storage
- **Unit Tests** — Validators fully tested

---

## 🏗 Architecture

```
lib/
├── main.dart               # Entry point, ProviderScope + routes
├── models/                 # Data classes (Task, AuthUser)
├── services/
│   ├── api_service.dart    # Dio HTTP client, all API calls
│   └── cache_service.dart  # Hive local cache
├── providers/
│   ├── auth_provider.dart  # Auth state (login/register/logout)
│   └── tasks_provider.dart # Tasks CRUD state + filter
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   └── tasks/
│       ├── home_screen.dart    # Task list + stats
│       └── task_form_screen.dart # Create/Edit form
├── widgets/
│   ├── task_card.dart      # Reusable task card
│   └── app_states.dart     # Loading, Empty, Error, LoadingButton
├── theme/
│   └── app_theme.dart      # Material 3 light + dark themes
└── utils/
    ├── routes.dart         # Named route constants
    └── validators.dart     # Form validation logic
```

### State Management: **Riverpod**

Riverpod was chosen because:
- It's compile-safe (no `context.read` magic strings)
- Providers are testable in isolation
- `StateNotifier` gives a clean pattern for managing async state
- Derived providers (`filteredTasksProvider`) are reactive and efficient

### API: **Dio**

Dio was chosen over `http` because:
- Interceptors make it easy to inject auth tokens globally
- Better error types (`DioException`) with detailed info
- Timeout configuration out of the box

### Caching: **Hive**

- First-page results are cached on every successful fetch
- On network error, stale cache is shown with a warning snackbar
- HiveAdapter generated via build_runner

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter 3.16+ (`flutter --version`)
- Dart 3.0+
- Android Studio / Xcode for device/emulator

### 1. Clone the repository
```bash
git clone https://github.com/YOUR_USERNAME/taskmaster.git
cd taskmaster
```

### 2. Install dependencies
```bash
flutter pub get
```

### 3. Generate Hive adapter (already included, but run if you change Task model)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. Run the app
```bash
# On connected device or emulator
flutter run

# Release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 🔑 API Documentation

This app uses [dummyjson.com](https://dummyjson.com) as a free mock backend.

| Endpoint | Method | Description |
|---|---|---|
| `/auth/login` | POST | Login with username + password |
| `/users/add` | POST | Register new user (mock) |
| `/todos?limit=10&skip=0` | GET | Paginated task list |
| `/todos/add` | POST | Create new task |
| `/todos/:id` | PUT | Update task |
| `/todos/:id` | DELETE | Delete task |

**Demo credentials:**
- Username: `emilys`
- Password: `emilyspass`

To connect a real backend, update `_baseUrl` in `lib/services/api_service.dart` and adjust the response parsing in each method.

---

## 🧪 Running Tests
```bash
flutter test
```

Tests cover the `Validators` utility class (email, password, taskTitle).

---

## 📦 Key Dependencies

| Package | Version | Purpose |
|---|---|---|
| flutter_riverpod | ^2.4.9 | State management |
| dio | ^5.4.0 | HTTP client |
| flutter_secure_storage | ^9.0.0 | Token storage |
| hive + hive_flutter | ^2.2.3 | Local cache |
| flutter_animate | ^4.5.0 | Animations |
| shimmer | ^3.0.0 | Loading skeletons |
| intl | ^0.19.0 | Date formatting |

---

## 📸 Screenshots

> Add screenshots here after building the app.

---

## 🤖 AI Usage Disclosure

AI tools were used to accelerate boilerplate generation and theming. All architecture decisions, provider structure, error handling logic, and caching strategy were designed and understood by the developer. Ready to explain any part in detail during the discussion.
