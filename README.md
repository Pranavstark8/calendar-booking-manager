#  Calendar Booking Application

This is a full-stack calendar booking app with:

*  **Backend**: Node.js + Express + MongoDB
*  **Frontend**: Flutter app (Web or Android)

---

## 🛠 Folder Structure

```
calendar-booking-api/          ← Node.js backend
└── calendar_booking_flutter/  ← Flutter frontend inside backend folder
```

---

##  Backend Setup (Node.js)

### 1. Prerequisites:

* Node.js (v18 or later)
* MongoDB (local or Atlas)

### 2. Install Dependencies:

```bash
cd calendar-booking-api
npm install
```

### 3. Create `.env` file:

```env
MONGO_URI=mongodb://localhost:27017/bookingDB
PORT=3000
```

### 4. Run the Server:

```bash
npm run dev
```

Visit API: [http://localhost:3000/bookings](http://localhost:3000/bookings)
Docs: [http://localhost:3000/api-docs](http://localhost:3000/api-docs)

---

##  Frontend Setup (Flutter)

### 1. Prerequisites:

* Flutter SDK

### 2. Install Flutter Dependencies:

```bash
cd calendar-booking-api/calendar_booking_flutter
flutter pub get
```

### 3. Configure API URL

In `main.dart`, set the correct base URL:

```dart
const String baseUrl = 'http://localhost:3000/bookings'; // for Web
const String baseUrl = 'http://10.0.2.2:3000/bookings'; // for Android
```

### 4. Run the App:

```bash
flutter run
```

---

##  Features

* Create and list room bookings
* Check for booking time conflicts
* Delete bookings
* View Swagger API docs

---

##  Todo / Enhancements

* Add user authentication
* Improve error UI in Flutter
* Deploy backend to Render/Vercel

---

##  Author

Developed by Pranav

---

##  License

This project is open-source and free to use.
