# Samiir - Premium E-Commerce Application

**Samiir** is a fully functional, high-fidelity e-commerce mobile application built with Flutter. Designed for a premium cosmetics brand, it features a modern UI, robust state management, and a comprehensive admin backend.

## 🚀 Features

### 👤 User Authentication
- **Splash Screen**: A branded entry point that initializes the app.
- **Login & Registration**: Secure user access with validation.
- **Forgot Password**: A dedicated screen for password recovery flows.
- **Role-Based Access**: Distinguishes between standard 'User' and 'Admin' roles.

### 🛍️ Product Exploration
- **Home Screen**: Dynamic product grid with category filtering (Skin Care, Hair Cut, Makeup, etc.).
- **Search**: Real-time product search functionality.
- **Product Details**: High-quality image viewer, detailed descriptions, size selection (e.g., 200 ML), and price display.

### 🛒 Shopping Experience
- **Smart Cart**: Add/remove items, adjust quantities, applies delivery/tax calculations dynamically.
- **Favorites (Wishlist)**: Save items to a personalized wishlist for later purchase.
- **Checkout Flow**: a smooth transition from Cart to Payment.

### 💳 Payments & Orders
- **Payment Selection**: Support for local payment methods (EVC Plus, e-Dahab) with visual selection.
- **Order Success**: A confirmation screen with animation to reassure users.
- **Order History**: A dedicated chronological list of past orders with status and total amounts.

### ⚙️ User Profile
- **Personal Dashboard**: Displays user name and email.
- **Activity**: Access to Order History.
- **Logout**: Secure session termination.

### 🛡️ Admin Dashboard
- **Analytics**: Visualization of total products, users, revenue, and categories.
- **Product Management**: Full CRUD (Create, Read, Update, Delete) capabilities for the inventory.
- **User Management**: Admin control to view and manage registered users.
- **Image Handling**: Support for uploading product images or using URL links.

## 📂 File Structure Explained

The project follows a **Feature-First** architecture inside the `lib/` directory, keeping concerns separated for scalability and maintainability.

### 1. `lib/core`
Contains core utilities used throughout the application.
- **`constants/`**: Holds app-wide configuration like `app_colors.dart` for the consistent Green/Peach theme.

### 2. `lib/models`
Defines the data structures (Data Transfer Objects) used by the app.
- **`product.dart`**: Blueprint for a product (id, name, price, category, image, etc.).
- **`user.dart`**: Blueprint for a user profile (id, name, email, role, password hash).
- **`order.dart`**: Blueprint for an order, containing a list of items and total cost.

### 3. `lib/providers`
Implements State Management using the `Provider` package.
- **`product_provider.dart`**: Manages the global state of products, cart items, and favorites.
- **`user_provider.dart`**: Handles authentication state, user list, and profile updates.
- **`order_provider.dart`**: Manages the list of placed orders and history.

### 4. `lib/widgets`
Contains reusable UI components to avoid code duplication.
- **`custom_text_field.dart`**: A styled text input used in forms (Login, Register, Add Product).
- **`product_image.dart`**: A smart widget that handles different image sources (Asset, File, Network) gracefully.

### 5. `lib/screens`
This is where the visible pages of the application live, organized by feature.

#### `screens/auth/` (Authentication)
- **`splash_screen.dart`**: The initial loading screen.
- **`login_screen.dart`**: The sign-in form for users and admins.
- **`register_screen.dart`**: The sign-up form for new users.
- **`forgot_password_screen.dart`**: UI for resetting passwords.

#### `screens/main/` (Navigation)
- **`main_screen.dart`**: The "Shell" of the app. It handles the bottom navigation bar and switches between Home, Cart, Favorites, and Profile screens.

#### `screens/product/` (Shopping Flow)
- **`home_screen.dart`**: The main landing page with categories and product grid.
- **`product_detail_screen.dart`**: The single product view with "Add to Cart" functionality.
- **`cart_screen.dart`**: The shopping cart view with totals and checkout button.
- **`fav_screen.dart`**: The list of favorited items.
- **`payments_screen.dart`**: The payment method selection screen.
- **`order_success_screen.dart`**: The "Thank You" page displayed after payment.
- **`order_history_screen.dart`**: The list of the user's past purchases.

#### `screens/profile/` (User Settings)
- **`profile_screen.dart`**: The user's account page showing details and menu options.

#### `screens/admin/` (Back-Office)
- **`admin_dashboard_screen.dart`**: The main control panel for admins.
- **`product_management_screen.dart`**: A list view of all products with Edit/Delete options.
- **`add_product_screen.dart`**: A form to add new products or edit existing ones.
- **`user_management_screen.dart`**: A list view of all registered users with management options.

---

## 🛠️ Getting Started

1.  **Prerequisites**: Ensure you have Flutter installed (`flutter doctor`).
2.  **Dependencies**: Run various packages:
    ```bash
    flutter pub get
    ```
3.  **Run**:
    ```bash
    flutter run
    ```

---

## 🗄️ Proposed Database Schema (Backend Ready)

If you plan to build a backend (Node.js, PHP, Python, etc.) for this system, here is the recommended database structure (SQL) to support all current features.

### 1. `users` Table
Stores all registered customers and admins.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | VARCHAR(50) | Primary Key (Unique User ID) |
| `name` | VARCHAR(100) | Full Name |
| `email` | VARCHAR(100) | Unique Email Address |
| `password_hash` | VARCHAR(255) | Securely hashed password |
| `role` | ENUM('user', 'admin') | distinct access levels |
| `created_at` | TIMESTAMP | Registration date |

### 2. `products` Table
The central inventory catalog.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | VARCHAR(50) | Primary Key |
| `name` | VARCHAR(150) | Product Name |
| `category` | VARCHAR(50) | e.g. "skin care", "makeup" |
| `price` | DECIMAL(10, 2) | Price in USD |
| `image_url` | TEXT | URL or path to image |
| `is_active` | BOOLEAN | Soft delete flag |

### 3. `orders` Table
Records purchase transactions.
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | VARCHAR(50) | Primary Key |
| `user_id` | VARCHAR(50) | Foreign Key -> `users.id` |
| `total_amount` | DECIMAL(10, 2) | Final cost of order |
| `status` | VARCHAR(20) | 'pending', 'completed', 'cancelled' |
| `created_at` | TIMESTAMP | Order placement time |

### 4. `order_items` Table
Connects Orders to Products (Many-to-Many).
| Column | Type | Description |
| :--- | :--- | :--- |
| `id` | INT | Primary Key (Auto Increment) |
| `order_id` | VARCHAR(50) | Foreign Key -> `orders.id` |
| `product_id` | VARCHAR(50) | Foreign Key -> `products.id` |
| `quantity` | INT | Number of items purchased |
| `price_at_purchase`| DECIMAL(10, 2) | Price snapshot (locks cost if price changes later) |

### 5. `favorites` Table
Stores user wishlists.
| Column | Type | Description |
| :--- | :--- | :--- |
| `user_id` | VARCHAR(50) | Foreign Key -> `users.id` |
| `product_id` | VARCHAR(50) | Foreign Key -> `products.id` |
| **Primary Key** | Composite | (`user_id`, `product_id`) |
