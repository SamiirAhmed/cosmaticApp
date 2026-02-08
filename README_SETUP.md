# Cosmetics App Setup Guide

This guide covers how to set up the PHP backend and run the Flutter frontend.

## Prerequisites
- **XAMPP** (or any PHP/MySQL stack)
- **Flutter SDK**

## 1. Backend Setup

### A. Deploy Files
1. Copy the `backend` folder to your server's document root:
   - **XAMPP (Windows):** `C:\xampp\htdocs\backend`
   - **MAMP (Mac):** `/Applications/MAMP/htdocs/backend`

### B. Database Setup
1. Open **phpMyAdmin** (usually `http://localhost/phpmyadmin`).
2. Create a new database named `cosmetics_db`.
3. Import the `backend/sql/schema.sql` file:
   - Click "Import" tab.
   - Choose `backend/sql/schema.sql`.
   - Click "Go".
   - This creates tables (`users`, `products`, `orders`) and inserts dummy data.

### C. Verify Connection
1. Ensure your database credentials in `backend/config/database.php` match your local setup:
   ```php
   private $username = "root";
   private $password = ""; // Default empty for XAMPP
   ```
2. Test the API in your browser:
   - Visit: `http://localhost/backend/api/index.php?route=products`
   - You should see a JSON response with products.

## 2. Frontend Setup

### A. Configuration
1. Open `lib/services/api_service.dart`.
2. Check the `baseUrl`.
   - **Windows/Web:** `http://localhost/backend/api/index.php`
   - **Android Emulator:** `http://10.0.2.2/backend/api/index.php`
   - **Physical Device:** Replace `localhost` with your PC's IP address (e.g., `http://192.168.1.5/backend/api/index.php`).

### B. Run
1. Open terminal in the project folder.
2. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## 3. Usage
- **Login:**
  - Admin: `admin@samiir.com` / `admin-password` (Note: Password hash in SQL script is for `password`, you might need to update hash if it fails, or register a new user). *Correction: The dummy data uses a hashed password. For testing, it's recommended to REGISTER a new user.*
- **Register:** Create a new account.
- **Shop:** Browse products, add to cart, and checkout.
