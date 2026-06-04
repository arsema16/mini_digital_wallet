# Mini Digital Wallet

A production-style FinTech Flutter application built for the Chapa Flutter Internship Code Challenge.

---

## Features

### Authentication
- Email & password **registration** with full form validation
- Email & password **login**
- **Anonymous / Guest** login
- Persistent session — the app restores the last authenticated user on relaunch
- Proper error handling and loading states throughout all auth flows
- **Logout** with confirmation dialog

### Dashboard
- Displays user profile name (falls back to email prefix for email users, "Guest User" for anonymous)
- Live **Total Balance**, **Total Income**, and **Total Expense** cards
- Quick-action buttons to add income or expense directly from the dashboard
- **Recent transactions** list (last 5), tappable to view full details
- **Sync** button to push unsynced local records to Firestore and pull remote records down
- Pull-to-refresh
- **Shimmer skeleton** loading while data is being fetched

### Transactions Screen
- Full list of all transactions
- **Search** by title or category (via system search bar)
- **Filter** by type (income / expense), category, and date range — with active filter chips shown inline
- **Clear all filters** at once or remove individual filter chips
- Pull-to-refresh
- Shimmer loading skeleton
- Tap any transaction to view full details

### Transaction Details
- Full breakdown: amount, type, category, payment method, reference ID, date, time, sync status
- **Delete** transaction (with confirmation dialog) — removes from both SQLite and Firestore

### Add Transaction
- Bottom sheet form: title, amount, type toggle (income/expense), category, payment method, optional reference ID
- Full input validation before saving
- Saves to local SQLite immediately; syncs to Firestore if the user is signed in and online

---

## Architecture

The project follows **Clean Architecture** with three layers:

```
lib/
├── core/
│   ├── network/          # NetworkInfo (connectivity_plus)
│   └── platform/         # Platform detection helper
│
├── data/
│   ├── datasources/
│   │   ├── local/        # SQLite (sqflite) — SQLiteDatabase, WebDatabase, DatabaseFactory
│   │   └── remote/       # Firestore — TransactionRemoteDataSource
│   ├── models/           # TransactionModel (SQLite ↔ Firestore ↔ Entity mapping)
│   └── repositories/     # TransactionRepositoryImpl
│
├── domain/
│   ├── entities/         # TransactionEntity (pure Dart, no framework deps)
│   ├── repositories/     # TransactionRepository (abstract)
│   └── usecases/         # GetTransactions, AddTransactionUseCase,
│                         # DeleteTransactionUseCase, SyncTransactionsUseCase
│
└── presentation/
    ├── bloc/
    │   ├── auth/         # AuthBloc, AuthEvent, AuthState
    │   └── transaction/  # TransactionBloc, TransactionEvent, TransactionState
    ├── pages/
    │   ├── auth/         # LoginPage, RegisterPage
    │   ├── dashboard/    # DashboardPage
    │   ├── transactions/ # TransactionsScreen
    │   └── details/      # TransactionDetailScreen
    └── widgets/          # AddTransactionSheet, ShimmerLoading
```

### State Management
All UI state is managed with **flutter_bloc**. Blocs are provided at the root (`MultiBlocProvider` in `main.dart`) so they survive navigation.

### Offline-first data flow
1. Every write goes to **SQLite first** (instant, offline-safe).
2. If the device is online and the user is authenticated, the write is also pushed to **Firestore** and the local record is marked `is_synced = 1`.
3. On `LoadTransactions` the BLoC reads from SQLite so the UI always loads instantly.
4. `SyncTransactions` uploads any `is_synced = 0` records to Firestore, then downloads any remote records missing locally.

---

## Tech Stack

| Dependency | Purpose |
|---|---|
| `firebase_core`, `firebase_auth` | Authentication |
| `cloud_firestore` | Remote data storage |
| `sqflite` + `path` | Local SQLite database |
| `flutter_bloc` + `equatable` | State management |
| `dartz` | Functional error handling (`Either`) |
| `connectivity_plus` | Network status detection |
| `shimmer` | Loading skeleton animations |
| `shared_preferences` | Web fallback storage |
| `intl` | Date / number formatting |

---

## Setup Instructions

### Prerequisites
- Flutter SDK ≥ 3.11 (`flutter --version`)
- A Firebase project with **Authentication** and **Firestore** enabled

### 1. Clone and install dependencies

```bash
git clone https://github.com/<your-username>/mini_digital_wallet.git
cd mini_digital_wallet
flutter pub get
```

### 2. Configure Firebase

```bash
# Install FlutterFire CLI if you haven't already
dart pub global activate flutterfire_cli

# Connect to your Firebase project
flutterfire configure
```

This regenerates `lib/firebase_options.dart` for your project.

### 3. Enable Firebase services

In the Firebase Console:
- **Authentication** → Sign-in method → Enable **Email/Password** and **Anonymous**
- **Firestore** → Create database (start in test mode for development)

### 4. Run the app

```bash
flutter run                   # default device
flutter run -d android        # Android
flutter run -d windows        # Windows desktop
```

> **Note:** SQLite is used on Android, iOS, and desktop. The web build falls back to `SharedPreferences` for local storage since `sqflite` is not supported on web.

---

## Key Decisions & Trade-offs

### SQLite as primary store, Firestore as secondary
Local SQLite is always read first, giving instant load times regardless of network state. Firestore sync happens in the background. This trades some consistency (remote data may be slightly stale) for a far better offline experience.

### TransactionBloc directly accesses LocalDatabase
For the scope of this challenge the BLoC accesses `LocalDatabase` and Firestore directly, rather than going through the repository layer. This keeps the code simpler and easier to follow. In a production app the BLoC would call use cases, which call the repository, which coordinates the two data sources.

### Anonymous login as a first-class option
Some users want to try the app without creating an account. Anonymous sessions still work with local SQLite; Firestore sync is skipped for anonymous users since there is no stable user identity to associate data with.

### DatabaseFactory pattern for web compatibility
`DatabaseFactory.create()` returns `SQLiteDatabase` on native platforms and `WebDatabase` (SharedPreferences-backed) on web. This lets the app run in every Flutter environment without `#ifdef`-style guards scattered through the code.

### Shimmer over plain spinners
Shimmer skeletons that match the shape of the real content reduce perceived load time and feel more polished for a FinTech app.
