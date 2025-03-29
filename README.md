# BizHub

<!-- <img src="/api/placeholder/200/200" alt="BizHub Logo" /> -->

BizHub is a community-driven mobile application that provides a comprehensive business directory with integrated productivity tools. The app allows users to discover, search, and contribute to a database of local businesses while offering useful tools like resume creation and business card scanning.

## 🌟 Features

### 📋 Company Directory
- **Search & Filter**: Find companies by name, category, or location
- **Detailed Profiles**: View comprehensive information about each business
- **Community Contributions**: Users can suggest edits to keep information current
- **Moderation System**: All edits are reviewed before approval

### 💬 Comments & Reviews
- Leave feedback on company profiles
- Simple thumbs-up/thumbs-down rating system
- Report inappropriate content with ease

### 🛠️ Productivity Tools
- **Resume Builder**: Create professional resumes using customizable templates
- **Text Extraction (OCR)**: Extract text from images of documents
- **Business Card Scanner**: Quickly digitize business cards and save contact information

### 👤 User Profiles
- Track your contributions and edits
- Build reputation through quality submissions
- Manage your created resumes and scanned business cards

## 📱 Screenshots

<!-- <div style="display: flex; justify-content: space-between;">
  <img src="/api/placeholder/180/360" alt="Home Screen" />
  <img src="/api/placeholder/180/360" alt="Company Profile" />
  <img src="/api/placeholder/180/360" alt="Resume Builder" />
</div> -->

## 🔧 Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase (Firestore, Authentication, Storage)
- **OCR Processing**: Google Vision API / Tesseract
- **State Management**: Provider / Bloc

## 📂 Project Structure

```
lib/
├── main.dart                 // App entry point
├── config/                   // App configuration
│   ├── theme.dart            // App theming
│   └── routes.dart           // App routing
├── models/                   // Data models
│   ├── company.dart          // Company model
│   ├── user.dart             // User model
│   ├── comment.dart          // Comment model
│   └── resume.dart           // Resume model
├── screens/                  // App screens
│   ├── home/                 // Home screen
│   ├── company/              // Company screens
│   ├── auth/                 // Authentication screens
│   ├── profile/              // User profile screens
│   └── tools/                // Productivity tools screens
├── services/                 // Backend services
│   ├── auth_service.dart     // Authentication service
│   ├── company_service.dart  // Company data service
│   ├── user_service.dart     // User data service
│   ├── ocr_service.dart      // OCR processing service
│   └── storage_service.dart  // File storage service
├── widgets/                  // Reusable widgets
│   ├── company_card.dart     // Company list item
│   ├── comment_item.dart     // Comment item
│   ├── filter_widget.dart    // Filter widget
│   └── rating_widget.dart    // Rating widget
└── utils/                    // Utilities
    ├── validators.dart       // Input validators
    └── constants.dart        // App constants
```

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Firebase account
- Android Studio / VS Code
- Google Vision API key (for OCR functionality)

### Installation

1. Clone this repository
```bash
git clone https://github.com/HassenGHR/Biz_hub.git
```

2. Navigate to the project directory
```bash
cd bizhub
```

3. Install dependencies
```bash
flutter pub get
```

4. Set up Firebase
   - Create a new Firebase project
   - Add Android & iOS apps to your Firebase project
   - Download and add the `google-services.json` and `GoogleService-Info.plist` files
   - Enable Authentication, Firestore, and Storage services

5. Set up Google Vision API (for OCR)
   - Get an API key from Google Cloud Console
   - Add the key to your app configuration

6. Run the app
```bash
flutter run
```

## 🔒 Privacy & Security

BizHub takes user privacy seriously:
- User data is stored securely in Firebase
- Contributions are anonymous by default
- Permissions are requested only when necessary
- Personal data is never shared with third parties

---

Made with ❤️ by [Hassen]