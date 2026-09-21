# TubeWell

**TubeWell** is a Flutter-based mobile and web application designed to help tube-well owners/operators manage customers, usage records, payments, and outstanding balances in one place.

The app provides a simple customer ledger system where each customer's tube-well usage and payments can be tracked and settled.

## Features

### 🔐 Authentication

* User registration and sign in
* Email verification
* Secure logout
* Account deletion with re-authentication

### 👥 Customer Management

* Add customers
* Edit customer information
* Delete customers
* Search customers
* Filter customers by payment status
* View individual customer accounts

### ⏱️ Tube-Well Runs

* Record tube-well usage
* Automatically use the customer's hourly rate
* Edit and delete usage records
* Calculate total running time
* Calculate total charges

### 💰 Payments & Ledger

* Record customer payments
* Edit payments
* Swipe to delete payments
* Automatically calculate:

  * Total charges
  * Total paid
  * Remaining balance
* View complete customer transaction history

### 📊 Dashboard

* Customer overview
* Monthly usage summary
* Monthly payment summary
* Outstanding customer balances
* Search and date-based filtering

### 👤 Profile

* Display account information
* Select a profile emoji
* Persist profile avatar selection
* Delete account and associated data

## Technology Stack

* **Flutter**
* **Dart**
* **Firebase Authentication**
* **Firebase Realtime Database**
* **SharedPreferences**
* **Material Design**

## Platforms

TubeWell has been tested successfully on:

* 🌐 **Web / Chrome**
* 📱 **Android**

## Project Structure

```text
lib/
├── Auth_Screens/
│   ├── signin_screen.dart
│   ├── signup_screen.dart
│   └── splash_screen.dart
│
├── Screens/
│   ├── home_screen.dart
│   ├── customers_screen.dart
│   ├── customer_details_screen.dart
│   ├── add_customer_screen.dart
│   ├── add_run_screen.dart
│   ├── add_payment_screen.dart
│   ├── transaction_screen.dart
│   └── profile_screen.dart
│
├── Services/
│   └── database_service.dart
│
├── core/
│   └── profile_avatar.dart
│
├── firebase_options.dart
└── main.dart
```

## Firebase Data Structure

Customer and transaction data is stored under each authenticated user's UID:

```text
users/
└── {uid}/
    ├── customers/
    │   └── {customerId}
    │
    ├── runs/
    │   └── {runId}
    │
    └── payments/
        └── {paymentId}
```

Realtime Database rules restrict users to their own data.

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/digitalirastudio/tube-well.git
cd tube-well
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Create/configure your Firebase project and enable:

* Firebase Authentication
* Realtime Database

Then configure the Flutter Firebase options for your project.

### 4. Run the application

For Chrome:

```bash
flutter run -d chrome
```

For Android:

```bash
flutter run
```

## Testing

The current version has been tested successfully on both:

* Chrome
* Physical Android device

Core authentication, database operations, customer management, runs, payments, balances, profile functionality, and account deletion were tested successfully.

## Design

TubeWell uses a simple blue-based interface designed around clarity and easy access to customer financial records.

Primary colors:

* Light Blue: `#C9E8F7`
* Dark Blue: `#123B5D`

## Future Improvements

Possible future additions include:

* PDF/printable customer statements
* Monthly reports
* Backup/export functionality
* Notifications and reminders
* Advanced analytics
* Cloud-based reporting
* Production Android release

## Author

**Digital Ira Studio**

GitHub: https://github.com/digitalirastudio

## License

This project is currently intended as a personal/portfolio project.
