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

## Important Folders
- `lib/` : Main application code
- `lib/cv/` : CV logic (models, export, templates)
- `lib/core/` : Constants, localization, utilities
- `lib/home/` : Main screens (dashboard, settings)
- `assets/fonts/` : Fonts used in PDF export


This app was developed to make building a professional, Arabic-friendly CV easy for everyone.

## Developer

- **Name:** Wael Almomani
- **Email:** wael88almomani@gmail.com
- **GitHub:** [wael88almomani](https://github.com/wael88almomani)
