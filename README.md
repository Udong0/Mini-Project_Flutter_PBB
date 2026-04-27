# 👾 GlitchDex

> A Flutter mobile application to capture, catalog, and backup real-world anomalies or "glitches" (like broken ATM screens, funny typos, or UI errors).

🎥 **Watch the Demo Video:** [https://youtu.be/MC45hQ6WzHw](https://youtu.be/MC45hQ6WzHw)

---

## 🎯 Mini-Project Requirements Fulfillment

This project was developed to fulfill the 40% Mini-Project grading rubric. Below is the mapping of the required features to the actual implementation in the app:

- [x] **CRUD with a Relational Database (10%)**
  - **Implemented using:** `sqflite` package.
  - **Description:** The app uses an SQLite database (`glitch_dex` table) to perform Create (catch new glitch), Read (display collection grid), Update (edit title/description), and Delete (remove from Pokedex) operations.
  
- [x] **Device Resource / Hardware (5%)**
  - **Implemented using:** `image_picker` package (Camera).
  - **Description:** Users can open their smartphone camera directly from the app to take a snapshot of the real-world glitch. The image path is then stored locally in SQLite.

- [x] **Notifications (5%)**
  - **Implemented using:** `flutter_local_notifications` package.
  - **Description:** A local push notification is triggered immediately after a user successfully catches and saves a new glitch into the database.

- [x] **Firebase Authentication (5%)**
  - **Implemented using:** `firebase_auth` package.
  - **Description:** Secure login and registration using Email & Password to authenticate the glitch collector before they can access their Pokedex.

- [x] **Storing Data in Firebase (5%)**
  - **Implemented using:** `cloud_firestore` package.
  - **Description:** A "Backup to Cloud" feature that acts as a synchronization tool. It reads the local SQLite data and pushes it to Firestore as a cloud backup.

---

## ✨ Additional Features (Beyond Requirements)

- **📍 Auto GPS & Reverse Geocoding** — Automatically fetches coordinates and converts them to a human-readable street address using `geolocator` & `geocoding`.
- **✏️ Image Annotation Canvas** — Draw directly on captured photos (circles, arrows, freehand) using `image_painter` to mark the exact anomaly.
- **☁️ Free Cloud Image Hosting** — Photos are uploaded to ImgBB via `http` (Base64 POST), returning a permanent public URL stored in SQLite — no Firebase Storage costs!
- **🛡️ ISP Proxy Bypass** — Uses `wsrv.nl` as a CDN proxy to serve ImgBB images, bypassing regional ISP blocks (e.g., Indihome/Telkomsel).
- **🔐 Secure API Key Management** — ImgBB API key stored in `.env` via `flutter_dotenv`, excluded from version control via `.gitignore`.
- **🔍 Full-Screen Pinch-to-Zoom Viewer** — Tap any glitch card image to open a fullscreen interactive viewer with `InteractiveViewer`.
- **🔒 Firestore Security Rules** — Data is isolated per user: `allow read, write: if request.auth.uid == userId`. No cross-user data access.

---

## 🔄 Application Flow

1. **Authentication (Login)**
   - User logs in via Firebase Authentication (Email/Password).
2. **Dashboard (Local State)**
   - Main screen loads all saved anomalies from the local **SQLite** database (offline-first).
3. **Capture Mode (Scan Glitch)**
   - User taps **"Scan Glitch"** → GPS coordinates fetched and reverse-geocoded automatically.
   - User takes a photo → directed to **Annotation Canvas** to draw on the image.
4. **Processing & Storage**
   - Annotated image → converted to Base64 → uploaded to **ImgBB** → public URL returned.
   - URL + metadata (title, notes, GPS) → saved to **SQLite** locally.
5. **Cloud Synchronization (Backup)**
   - User taps the ☁️ icon → all local records pushed to **Firebase Firestore** under `users/{userId}/glitches`.

---

## 🛠️ Tech Stack & Dependencies

| Category | Package |
|---|---|
| Framework | Flutter (Dart) |
| Local DB | `sqflite`, `path_provider` |
| Cloud / BaaS | `firebase_core`, `firebase_auth`, `cloud_firestore` |
| Hardware / Sensors | `image_picker`, `geolocator`, `geocoding` |
| Image Tools | `image_painter` |
| Networking | `http` |
| Security | `flutter_dotenv` |
| Notifications | `flutter_local_notifications` |

---

## 🚀 How to Run the Project Locally

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Udong0/Mini-Project_Flutter_PBB.git
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Create a `.env` file** in the root project directory:
   ```env
   IMGBB_KEY=your_imgbb_api_key_here
   ```
   > Get a free API key at [https://api.imgbb.com](https://api.imgbb.com)

4. **Configure Firebase:**
   - Create a Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
   - Enable **Authentication** (Email/Password) and **Firestore Database**
   - Download `google-services.json` and place it in `android/app/`

5. **Run the application:**
   ```bash
   flutter run
   ```

---

## 🔐 Security Notes

- The `.env` file containing the ImgBB API Key is **excluded from this repository** via `.gitignore`.
- Firebase Security Rules are configured so each user can **only access their own data**.
- `google-services.json` is included for reproducibility but access is protected by Firebase Security Rules.

---

*Built as a Mini-Project for Mobile Device Programming (PPB) — Semester 6.*
