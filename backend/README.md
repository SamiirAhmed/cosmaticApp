# Cosmetics Backend & Frontend Setup

## Prerequisites
1. **XAMPP** (or any PHP/MySQL stack) installed.
2. **Flutter SDK** installed.
3. **Android Emulator** or Physical Device.

## Backend Setup (PHP + MySQL)

1. **Start Apache & MySQL** in XAMPP Control Panel.
2. **Deploy Backend Code**:
   - Copy the `backend` folder to your XAMPP `htdocs` directory.
   - Example path: `C:\xampp\htdocs\backend`
   - Ensure the structure is `htdocs\backend\index.php`.

3. **Database Setup**:
   - Open phpMyAdmin (http://localhost/phpmyadmin).
   - Create a new database named `cosmetics_db`.
   - Import the schema from `backend/database/schema.sql` (or copy-paste the SQL content into the SQL tab).

4. **Verify Backend**:
   - Open a browser and visit: `http://localhost/backend/index.php/api/products`
   - You should see a JSON response (possibly with default products if seeded).

## Frontend Setup (Flutter)

1. **Update API URL**:
   - Open `lib/core/constants/api_constants.dart`.
   - Update `baseUrl` to match your backend URL.
   - For Android Emulator, `http://10.0.2.2/backend/index.php/api` is usually correct if backend is at `htdocs/backend`.
   - For Physical Device, use your PC's IP address (e.g., `http://192.168.1.100/backend/index.php/api`).

2. **Install Dependencies**:
   - Run `flutter pub get` in the `Samiir` project directory.

3. **Run App**:
   - Run `flutter run`.

## Notes
- **Images**: Uploaded images are stored in `backend/uploads/`.
- **Admin Login**: `admin@samiir.com` / `admin123` (Seed data).
- **User Login**: `user@samiir.com` / `123456`.
