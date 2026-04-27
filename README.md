# 👾 GlitchDex

**GlitchDex** is an advanced anomaly-tracking application built with Flutter. Designed as a professional investigation tool, it allows users to capture, annotate, and document real-world "glitches" or anomalies with high precision, complete with automated geographical metadata.

---

## ✨ Core Features

- **📸 Intelligent Capture & Annotation**
  Capture photos and immediately draw annotations (red circles, arrows) directly on the image to highlight the anomaly using the integrated `image_painter` engine.
  
- **📍 Auto-Metadata Extraction**
  Forget manual data entry. GlitchDex automatically extracts high-accuracy GPS coordinates and reverse-geocodes them into human-readable street addresses upon opening the scanner.
  
- **☁️ Free Cloud Image Hosting (ImgBB + Proxy Bypass)**
  Images are automatically uploaded to ImgBB via a secure API to bypass Firebase Storage paid limits. Includes a built-in proxy bypass (`wsrv.nl`) to circumvent ISP blocking (e.g., Indihome/Telkomsel blocking `i.ibb.co`).
  
- **💾 Dual Database Architecture**
  Saves data locally using `sqflite` for lightning-fast offline viewing, with the ability to synchronize and backup to Firebase **Cloud Firestore** with a single tap.
  
- **🔍 Full-Screen Interactive Viewer**
  Tap on any captured anomaly card to enter a full-screen interactive mode with pinch-to-zoom capabilities.
  
- **🔐 Environment Security**
  API Keys are strictly secured using `flutter_dotenv`, keeping the public repository clean and safe from unauthorized API abuse.

---

## 🔄 Application Flow

1. **Authentication (Login)**
   - User logs in using Firebase Authentication (Email/Password).
2. **Dashboard (Local State)**
   - The main screen displays a list of previously saved anomalies retrieved from the local **SQLite** database.
3. **Capture Mode (Scanning)**
   - User taps **"Scan Glitch"**.
   - The app instantly fetches the current GPS coordinates and translates them into a street address.
   - User takes a photo using the device camera.
   - User is redirected to a Full-Screen Annotation Canvas to draw on the image.
4. **Processing & Storage**
   - The annotated image is converted to Base64 and uploaded securely to **ImgBB**.
   - The returned public URL (proxied for safety), title, notes, and GPS data are saved into the local SQLite database.
5. **Cloud Synchronization (Backup)**
   - User taps the "Cloud" icon on the AppBar.
   - All local records are uploaded to **Firebase Firestore**, strictly segregated into a secure folder `users/{userId}/glitches`.

---

## 🛠️ Technology Stack

- **Framework**: Flutter (Dart)
- **Local Database**: SQLite (`sqflite`)
- **Cloud Database**: Firebase Cloud Firestore
- **Authentication**: Firebase Auth
- **Geocoding API**: `geolocator`, `geocoding`
- **Image Processing**: `image_picker`, `image_painter`
- **Network & Security**: `http`, `flutter_dotenv`
- **Image Proxy CDN**: Images.weserv.nl (`wsrv.nl`)

---

## 🚀 Setup & Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Udong0/Mini-Project_Flutter_PBB.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Create a `.env` file in the root directory and add your ImgBB API Key:
   ```env
   IMGBB_KEY=your_api_key_here
   ```
4. Run the application:
   ```bash
   flutter run
   ```

---
*Built as a Mini-Project for Mobile Device Programming (PPB).*
