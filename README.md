# Event Booking App

A modern Flutter application for booking event tickets. Browse events, book tickets, make payments, and manage your booking history all in one place.

## 📱 Features

- **Event Listing**: Browse through a list of available events
- **Event Details**: View detailed information about each event including date, time, location, and pricing
- **Ticket Booking**: Select number of tickets and book your spot
- **Payment Integration**: Secure payment processing for ticket purchases
- **Booking Confirmation**: Receive confirmation after successful booking
- **Booking History**: View all your past bookings
- **Firebase Integration**: Real-time data synchronization using Firebase Realtime Database
- **Modern UI**: Beautiful, dark-themed user interface with smooth animations

## 🛠️ Tech Stack

- **Framework**: Flutter 3.38.6
- **Language**: Dart 3.10.7
- **State Management**: GetX
- **Backend**: Firebase (Core & Realtime Database)
- **HTTP Client**: http package
- **Architecture**: MVVM (Model-View-ViewModel)

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK (3.10.4 or higher)
- Dart SDK (3.10.7 or higher)
- Android Studio / Xcode (for mobile development)
- Firebase account and project setup
- Git

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/amarhumayunx/eventbookingapp.git
cd eventbookingapp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add Android and iOS apps to your Firebase project
3. Download configuration files:
   - For Android: `google-services.json` → Place in `android/app/`
   - For iOS: `GoogleService-Info.plist` → Place in `ios/Runner/`
4. Enable Firebase Realtime Database in your Firebase console

### 4. Run the App

#### Android
```bash
flutter run
```

#### iOS
```bash
flutter run
```

#### Build Release APK
```bash
flutter build apk --release
```

The APK will be generated at: `build/app/outputs/flutter-apk/app-release.apk`

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                  # Data models
│   ├── booking.dart
│   ├── event.dart
│   └── payment.dart
├── screens/                 # UI screens
│   ├── event_listing_screen.dart
│   ├── event_details_screen.dart
│   ├── ticket_booking_screen.dart
│   ├── payment_screen.dart
│   ├── booking_confirmation_screen.dart
│   └── booking_history_screen.dart
├── services/                # Business logic & API services
│   ├── api_service.dart
│   ├── firebase_service.dart
│   └── user_service.dart
└── viewmodels/              # ViewModels for state management
    ├── base_viewmodel.dart
    ├── event_listing_viewmodel.dart
    ├── ticket_booking_viewmodel.dart
    └── booking_history_viewmodel.dart
```

## 📦 Dependencies

- `flutter`: SDK
- `get`: ^4.6.6 - State management and navigation
- `firebase_core`: ^3.6.0 - Firebase core functionality
- `firebase_database`: ^11.1.5 - Firebase Realtime Database
- `http`: ^1.1.0 - HTTP client for API calls
- `cupertino_icons`: ^1.0.8 - iOS-style icons

## 🎨 App Screens

1. **Event Listing Screen**: Displays all available events
2. **Event Details Screen**: Shows detailed event information
3. **Ticket Booking Screen**: Select number of tickets and user details
4. **Payment Screen**: Process payment for tickets
5. **Booking Confirmation Screen**: Confirmation after successful booking
6. **Booking History Screen**: View all past bookings

## 🔧 Configuration

### Android
- Minimum SDK: Check `android/app/build.gradle.kts`
- Target SDK: Check `android/app/build.gradle.kts`
- Package Name: `com.eventbooking.app`

### iOS
- Minimum iOS Version: Check `ios/Podfile`
- Bundle Identifier: `com.eventbooking.app`

## 📱 Building for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🚢 Releases

Latest releases are available on [GitHub Releases](https://github.com/amarhumayunx/eventbookingapp/releases)

- **v1.0.1**: Updated app name to "Event Booking"
- **v1.0.0**: Initial release

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is private and not licensed for public use.

## 👤 Author

**Muhammad Humayun Amar**

- GitHub: [@amarhumayunx](https://github.com/amarhumayunx)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- GetX for state management

---

Made with ❤️ using Flutter
