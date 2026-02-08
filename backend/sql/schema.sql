-- Database Schema for Cosmetics App

CREATE DATABASE IF NOT EXISTS cosmetics_db;
USE cosmetics_db;

-- Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products Table
CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    description TEXT,
    quantity INT NOT NULL DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Favorites Table (Many-to-Many relationship between Users and Products)
CREATE TABLE IF NOT EXISTS favorites (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Orders Table
CREATE TABLE IF NOT EXISTS orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order Items Table
CREATE TABLE IF NOT EXISTS order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Insert Dummy Data --

-- Users (Password: 123456)
INSERT INTO users (name, email, password, role) VALUES 
('Admin User', 'admin@samiir.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Samiir User', 'user@samiir.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'user');

-- Products
INSERT INTO products (name, category, price, image_path, description, quantity) VALUES 
('Skin Light', 'skin care', 25.00, 'assets/images/product1.png', 'High quality skin lightening cream.', 50),
('Glow Serum', 'skin care', 35.00, 'assets/images/product1.png', 'Serum for glowing skin.', 30),
('Hair Oil', 'hair cut', 15.00, 'assets/images/product1.png', 'Nourishing hair oil.', 100),
('Face Wash', 'face wash', 12.00, 'assets/images/product1.png', 'Daily gentle face wash.', 75),
('Lipstick Set', 'make up', 45.00, 'assets/images/product1.png', 'Set of 5 premium lipsticks.', 40),
('Hair Mask', 'hair cut', 22.00, 'assets/images/product1.png', 'Deep conditioning hair mask.', 60),
('Salon Kit', 'salon', 150.00, 'assets/images/product1.png', 'Complete professional salon kit.', 15);
