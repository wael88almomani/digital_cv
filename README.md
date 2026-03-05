# Digital CV

Professional Digital CV Application

## About the App

Digital CV is a Flutter application that allows users to create and manage professional CVs in both Arabic and English. Users can export their CVs as modern, stylish PDF files with full support for Arabic (RTL) layout. The app supports multiple CVs per user, with a unique profile photo for each CV.

## Main Features
- Create multiple CVs for each user
- Support for Arabic and English languages
- Export CVs to PDF with modern, professional design
- Full RTL (right-to-left) support for Arabic
- Separate profile photo for each CV
- Add achievements, courses, certifications, skills, experience, education, references, hobbies
- Fast and user-friendly interface
- Local data storage with optional Firebase integration

## App Screens

### 1. Login Screen
- Sign in with email and password
- Create a new account

### 2. CV List Screen
- View all your CVs
- Create a new CV and select its language
- Activate/select the current CV
- Edit or delete any CV

### 3. Dashboard Screen
- View details of the active CV
- Quick edit for CV data
- Export CV to PDF

### 4. Edit CV Screen
- Edit all CV data (name, email, phone, job title, skills, achievements, etc.)
- Add or remove items (skills, certifications, courses, etc.)
- Upload a unique profile photo for each CV

### 5. CV Preview Screen
- Preview the final design of your CV before exporting
- Support for multiple templates (Modern/Classic)
- Export PDF in both Arabic and English

## How to Run

1. Make sure you have Flutter and Dart installed
2. Install dependencies:
	```
	flutter pub get
	```
3. Run the app:
	```
	flutter run
	```

## Project Structure & Architecture

### Directory Structure

```
digital_cv/
├── lib/                          # Main application code
│   ├── main.dart                 # App entry point & initialization
│   ├── firebase_options.dart     # Firebase configuration
│   │
│   ├── auth/                     # Authentication module
│   │   ├── data/
│   │   │   └── auth_service.dart    # Firebase authentication logic
│   │   └── presentation/
│   │       └── login_screen.dart    # Login/Register UI
│   │
│   ├── core/                     # Core features & utilities
│   │   ├── constants/
│   │   │   └── app_strings.dart     # App text constants (English/Arabic)
│   │   ├── localization/
│   │   │   └── app_localizations.dart # Language support (i18n)
│   │   ├── theme/
│   │   │   └── app_theme.dart       # Dark theme & styling
│   │   └── widgets/
│   │       └── [Reusable UI components]
│   │
│   ├── cv/                       # CV management module
│   │   ├── data/
│   │   │   ├── cv_repository.dart      # Firebase CV data operations
│   │   │   └── local_image_store.dart  # Local image storage
│   │   ├── models/
│   │   │   └── cv_model.dart          # CV data structure
│   │   ├── pdf/
│   │   │   ├── cv_pdf_generator.dart  # PDF export logic
│   │   │   └── [PDF utilities]
│   │   ├── presentation/
│   │   │   ├── cv_edit_screen.dart    # Edit CV details screen
│   │   │   ├── cv_preview_screen.dart # Preview before export
│   │   │   └── [CV UI screens]
│   │   ├── templates/
│   │   │   ├── modern_template.dart   # Modern CV design
│   │   │   └── classic_template.dart  # Classic CV design
│   │   └── rules/
│   │       └── [Validation rules]
│   │
│   ├── home/                     # Home & main screens
│   │   ├── main_screen.dart      # Main dashboard screen
│   │   ├── home_screen.dart      # CV list & management
│   │   ├── settings_screen.dart  # App settings
│   │   └── widgets/
│   │       └── [Home UI components]
│   │
│   └── settings/                 # Settings module
│
├── assets/                       # App resources
│   ├── fonts/                    # Custom fonts for PDF export
│   │   ├── Arabic fonts (Almarai, Cairo, etc.)
│   │   └── English fonts
│   └── icon/                     # App icons & images
│
├── android/                      # Android build files
│   ├── app/
│   │   ├── google-services.json  # Firebase configuration
│   │   ├── key.jks               # Signing certificate
│   │   └── build.gradle.kts      # Android build config
│   ├── key.properties            # Signing configuration
│   └── local.properties          # SDK paths
│
├── ios/                          # iOS build files
│   └── Runner/                   # iOS app configuration
│
├── test/                         # Unit & widget tests
│   └── widget_test.dart
│
├── pubspec.yaml                  # Project dependencies
├── firebase.json                 # Firebase project settings
├── analysis_options.yaml         # Linting rules
└── README.md                     # This file
```

---

## Key Dependencies & Packages

### Authentication & Backend
- **firebase_core** (3.10.0) - Firebase initialization
- **firebase_auth** (5.4.0) - Email/password authentication
- **cloud_firestore** (5.6.0) - Cloud database
- **google_sign_in** (6.2.1) - Google authentication

### UI & Localization
- **flutter_localizations** - Multi-language support (Arabic/English)
- **google_fonts** (6.2.1) - Professional fonts
- **provider** (6.1.2) - State management

### Data Persistence
- **shared_preferences** (2.3.2) - Local preferences
- **path_provider** (2.1.4) - File system access
- **image_picker** (1.1.2) - Image selection

### PDF Export
- **pdf** (3.11.1) - PDF generation
- **printing** (5.13.4) - Print & PDF export

---

## Module Breakdown

### 🔐 Auth Module (`lib/auth/`)
**Responsibility:** User authentication and authorization

**Key Components:**
- `AuthService` - Manages Firebase authentication
- `LoginScreen` - User login/signup UI
- `AuthGate` - Checks user session & redirects

**Functionality:**
- Email/password registration & login
- Google Sign-In integration
- Session management
- Remember me functionality

### 📝 CV Module (`lib/cv/`)
**Responsibility:** CV creation, management, and export

**Key Components:**

#### Data Layer
- `CvRepository` - Firestore operations (CRUD)
- `LocalImageStore` - Local image caching
- `CvModel` - CV data structure

#### Presentation Layer
- `CvEditScreen` - Edit CV details
- `CvPreviewScreen` - Preview before export
- CV list management screens

#### PDF Export
- `CvPdfGenerator` - Converts CV to PDF
- `ModernTemplate` - Modern CV design
- `ClassicTemplate` - Classic CV design

**Functionality:**
- Create multiple CVs per user
- Add/edit education, experience, skills, certifications
- Upload unique profile photo per CV
- Preview CV with different templates
- Export to PDF (Arabic & English support)

### 🎨 Core Module (`lib/core/`)
**Responsibility:** Shared utilities and configurations

**Components:**
- `AppStrings` - All text constants
- `AppLocalizations` - i18n/localization logic
- `AppTheme` - Dark theme configuration
- Reusable widgets & UI components

### 🏠 Home Module (`lib/home/`)
**Responsibility:** Main app screens and navigation

**Screens:**
- `MainScreen` - Dashboard with CV overview
- `HomeScreen` - CV list & management
- `SettingsScreen` - App preferences & logout

---

## Key Features Explained

### 1. **Multi-Language Support**
- Full Arabic & English support
- RTL (Right-to-Left) for Arabic
- Centralized string management
- Automatic system language detection

### 2. **PDF Export**
- Modern & Classic templates
- Arabic text rendering
- High-quality PDF generation
- Local & cloud storage

### 3. **Firebase Integration**
- User authentication
- Real-time database (Firestore)
- Secure data storage
- Cloud backup

### 4. **Data Management**
- Local storage (Shared Preferences)
- Cloud sync (Firestore)
- Image caching
- Remember me functionality

### 5. **Security**
- Firebase security rules
- Password encryption
- Secure token management
- HTTPS communication

---

## User Flow

```
1. Login/Register
   ↓
2. Create/Select CV
   ↓
3. Edit CV Details
   ├─ Add/Edit Education
   ├─ Add/Edit Experience
   ├─ Add/Edit Skills
   ├─ Upload Photo
   └─ ...
   ↓
4. Preview CV
   └─ Select Template (Modern/Classic)
   ↓
5. Export to PDF
   └─ Share/Download
```

---

## Development Guidelines

### Code Organization Pattern
The app follows **Clean Architecture** with separation:
- **Data Layer:** Repositories, Firebase integration
- **Presentation Layer:** UI screens and widgets
- **Domain Layer:** Business logic and models

### State Management
- Uses **Provider** for state management
- Multi-provider setup for multiple services
- Reactive streams for real-time updates

### Error Handling
- Try-catch blocks in service methods
- User-friendly error messages
- Logging for debugging

### Testing
- Widget tests in `test/` directory
- MockFirebaseFirestore for testing
- UI testing with integration tests

---

## Firebase Configuration

### Services Used
1. **Firebase Authentication** - User management
2. **Cloud Firestore** - Database
3. **Firebase Storage** - Cloud image storage (optional)

### Collections Structure (Firestore)
```
users/
  ├── {userId}/
      ├── email: string
      ├── name: string
      ├── CVs/
      │   ├── {cvId}/
      │   │   ├── title: string
      │   │   ├── language: string
      │   │   ├── personalInfo: object
      │   │   ├── education: array
      │   │   ├── experience: array
      │   │   ├── skills: array
      │   │   ├── certifications: array
      │   │   ├── achievements: array
      │   │   ├── references: array
      │   │   ├── hobbies: array
      │   │   └── photoUrl: string
      │   └── {cvId2}/
      │       └── ...
      └── metadata: object
```

---

## How to Use the App

### First Time Users
1. Download the app
2. Tap "Create Account"
3. Enter email & password
4. Or use "Sign in with Google"

### Creating a CV
1. At home screen, tap "New CV"
2. Choose language (Arabic/English)
3. Fill in your details
4. Upload profile photo
5. Add education, experience, skills, etc.

### Exporting CV
1. Go to dashboard
2. Tap "Preview"
3. Choose template design
4. Tap "Export to PDF"
5. Save or share PDF

---

## Installation & Setup

### Prerequisites
- Flutter SDK 3.10.8 or higher
- Dart SDK
- Android Studio or Xcode (for mobile development)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/wael88almomani/digital_cv.git
   cd digital_cv
   ```

2. **Install Flutter dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   - Set up Firebase project
   - Download google-services.json (Android)
   - Add to `android/app/`

4. **Run the app**
   ```bash
   flutter run
   ```

5. **Build Release APK**
   ```bash
   flutter build apk --release
   ```

6. **Build AAB (for Play Store)**
   ```bash
   flutter build appbundle --release
   ```

---

## Performance Optimization

### Image Handling
- Images stored locally first
- Cached in Shared Preferences
- Optimized for PDF export

### Database Queries
- Firestore indexing
- Pagination for large datasets
- Offline support with caching

### Memory Management
- Proper widget disposal
- Stream subscription cleanup
- Efficient state management

---

## Troubleshooting

### Common Issues

**Firebase connection failed**
- Check internet connection
- Verify google-services.json
- Ensure Firebase project is active

**PDF export fails**
- Check available storage space
- Verify fonts are loaded
- Check image permissions

**Missing images**
- Grant app storage permissions
- Ensure images are properly uploaded
- Check local cache

---

## Developer Information

- **Name:** Wael Almomani
- **Email:** wael88almomani@gmail.com
- **GitHub:** [wael88almomani](https://github.com/wael88almomani)
- **Portfolio:** [Digital CV](https://digital-cv.com)

---

## License

This project is licensed under the MIT License. See LICENSE file for details.

---

## Future Enhancements

- [ ] Video CV support
- [ ] Template marketplace
- [ ] AI-powered CV suggestions
- [ ] Collaboration features
- [ ] Advanced analytics
- [ ] Desktop application
- [ ] More languages
- [ ] Social sharing

---

## Contributing

Contributions are welcome! Please follow:
1. Create a feature branch
2. Make your changes
3. Submit a pull request
4. Include description of changes

---

**Last Updated:** March 6, 2026
**App Version:** 1.0.0+1
