# WhatSUp (GROUP 14)


| Name               | Student ID |Responsibility                    |
|--------------------|------------|----------------------------------|
| Bahar Akbaş        | 30860      |Testing & Quality Assurance Lead  |
| Ilgaz Şahin        | 30756      |Integration & Repository Lead     |
| Emre Berk Hamarat  | 31188      |Testing & Quality Assurance Lead  |
| Elif Sude Yanar    | 32431      |Project Coordinator               |
| Ezgi Aslantürk     | 33937      |Presentation & Communication Lead | 
| Nil Karahan        | 32142      |Documentation & Submission Lead   |


A Flutter-based mobile app for Sabancı University students to discover, create, and receive notifications about campus events, unifying official and spontaneous activities in a single SU-only platform.

## Project Overview

**WhatSUp** is mobile application designed to help users discover and participate in campus and community events. The app combines event management features with social networking capabilities, allowing users to:

- **Discover Events**: Browse events by category (Academic, Clubs, Social) with an interactive calendar view
- **Create & Manage Events**: Organize events with details, images, and ticket pricing
- **Social Interaction**: Share posts, like content, and comment on posts
- **Ticket Management**: Book and manage tickets for events
- **Personalization**: Favorite events, manage profile, and customize theme preferences

### Motivation

This project was developed to address the need for a centralized platform where students and community members can easily discover, create, and participate in events. The app aims to streamline event discovery and foster community engagement through integrated social features.


## Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK**: Version 3.10.0 or higher
  - Check your Flutter version: `flutter --version`
  - If needed, install/update Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Included with Flutter
- **Firebase Account**: Access to Firebase Console
- **IDE**: VS Code, Android Studio, or IntelliJ IDEA with Flutter plugins
- **Platform-specific tools**:
  - **Android**: Android Studio with Android SDK
  - **iOS**: Xcode (macOS only)

## Setup Instructions

### 1. Clone the Repository

```bash
git clone https://github.com/CS310-Group-14/WhatSUp-ui-bahar.git
cd WhatSUp-ui-bahar
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will install all the required packages listed in `pubspec.yaml`.

### 3. Firebase Configuration

**Note**: Firebase configuration files (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`) are already included in this repository. The app is configured to use Firebase project `denemeproje-5ef72`.

#### For TAs/Examiners:

**Access to Existing Firebase Project** 
- Contact the project team to request access to the Firebase project `denemeproje-5ef72`
- Once granted access, you can run the app directly without additional setup
- The Firebase services (Authentication, Firestore, Storage) are already configured

- If you don't have access to the Firebase, please contact with: ilgaz.sahin@sabanciuniv.edu



### 4. Run the Application

#### For Android:

```bash
flutter run
```

Or specify a device:
```bash
flutter devices  # List available devices
flutter run -d <device-id>
```

#### For iOS (macOS only):

```bash
flutter run
```

#### For Web:

```bash
flutter run -d chrome
```

#### For Desktop:

```bash
flutter run -d macos  # macOS
flutter run -d windows  # Windows
flutter run -d linux  # Linux
```
## 5. How to run tests

All tests are located under `WhatSUp-ui-bahar/test/`.

### 1) Go to the Flutter project directory
```bash
cd WhatSUp-ui-bahar
```
### 2) Install dependencies (first time, or after pulling new changes)
```bash
flutter pub get
```
### 3) Run all tests (unit + widget)
```bash
flutter test

// or for verbose output, run:
// flutter test --reporter expanded
```

### Expected Results

If everything passes, Flutter prints something similar to:

    00:xx +N: All tests passed!

If a test fails, Flutter prints:

    the failing test name
    expected vs actual values
    a stack trace pointing to the failing line


## Project Structure

```
lib/
├── models/              # Data models (Event, Post, Comment, Ticket)
├── services/            # Business logic (Auth, Firestore, Storage)
├── providers/           # State management (Provider pattern)
├── screens/             # UI pages (17 screens)
├── widgets/             # Reusable UI components
├── utils/               # Helper functions and styles
├── theme.dart           # Theme configuration
└── main.dart            # App entry point
```

## Known Limitations 

1. **Image Upload**: 
   - Large images may take time to upload depending on network speed

2. **Offline Support**: 
   - Limited offline functionality
   - Requires internet connection for most operations

3. **Payment Integration**: 
   - Ticket booking doesn't include actual payment processing
   - Ticket price is informational only



This project is developed for educational purposes as part of CS310 course work.




