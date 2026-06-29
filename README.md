# Digital Sky - Cloud Gallery App

A Flutter mobile application that automatically backs up your phone's gallery to Firebase Cloud Storage. Built with clean architecture using GetX state management.

## Features

- **Google Sign-In** — Secure authentication via Firebase Auth + Google
- **Auto Cloud Backup** — Toggle backup on/off; resumes from where it left off
- **Duplicate Detection** — Skips already-uploaded images using hash-based tracking
- **Real-time Upload Status** — Cloud icon overlay on each photo that has been backed up
- **Full-Screen Viewer** — Pinch-to-zoom interactive image viewer
- **Persistent State** — Backup progress survives app restarts via SharedPreferences
- **User Profile Dialog** — View account info, manage backup, and logout in one place

## Screenshots

> _Add screenshots here_

| Login | Gallery | Full Screen |
|-------|---------|-------------|
| ![Login](screenshots/login.png) | ![Gallery](screenshots/gallery.png) | ![Full Screen](screenshots/fullscreen.png) |

## Tech Stack

| Layer | Technology |
|---|---|
| UI | Flutter |
| State Management | GetX |
| Authentication | Firebase Auth + Google Sign-In |
| Database | Cloud Firestore |
| Storage | Firebase Cloud Storage |
| Local Storage | SharedPreferences |
| Photo Access | photo_manager |
| Responsive UI | flutter_screenutil |

## Architecture

```
lib/
├── main.dart                        # App entry point, Firebase init
├── login_page.dart                  # Google Sign-In screen
├── home_page.dart                   # Main gallery grid view
├── FullScreen_Imagepage.dart        # Zoomable full-screen image viewer
├── models/
│   ├── user.dart                    # UserData model (Firestore <-> Dart)
│   └── gallery.dart                 # GalleryData model (Firestore <-> Dart)
├── controllers/
│   ├── auth_controller.dart         # Auth state, Google Sign-In, routing
│   └── gallery_controller.dart      # Gallery fetch, upload, backup state
└── services/
    ├── gallery_service.dart         # Firestore + Storage operations
    └── storage.dart                 # (Reserved for future use)
```

## Data Flow

```
User opens app
    └── AuthController.onReady()
            ├── No user  →  LoginPage
            └── User found  →  GalleryController.onInit()
                                    ├── Load backup state (SharedPrefs)
                                    ├── Fetch uploaded image hashes (Firestore)
                                    ├── Load device gallery (photo_manager)
                                    └── Resume backup if previously active
```

## Firebase Setup

1. Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
2. Enable **Authentication** → Google Sign-In
3. Enable **Cloud Firestore** and **Firebase Storage**
4. Download `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) and place in the respective platform folders
5. Add your SHA-1 fingerprint to Firebase for Google Sign-In on Android

### Firestore Structure

```
users/
  {uid}/
    displayName: string
    profileUrl: string
    useremail: string
    my_photos/
      {docId}/
        imageHash: string        # Local asset ID for deduplication
        galleryIconURL: string   # Firebase Storage download URL
        uid: string
        addedTime: timestamp
        lastUpdatedOn: timestamp
        lastUpdatedBy: string
```

## Getting Started

### Prerequisites

- Flutter SDK >= 3.0.0
- Dart >= 3.0.0
- A Firebase project (see Firebase Setup above)

### Installation

```bash
# Clone the repository
git clone https://github.com/Rupha001/cloud-gallery.git
cd cloud-gallery

# Install dependencies
flutter pub get

# Run the app
flutter run
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first.

## License

[MIT](LICENSE)
