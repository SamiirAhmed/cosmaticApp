-- Database Schema for Cosmetics App

CREATE DATABASE IF NOT EXISTS cosmetics_db;
USE cosmetics_db;

-- Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    password VARCHAR(255) NOT NULL,
    role ENUM('user', 'admin') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Categories Table
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

-- Products Table
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category_id INT,
    price DECIMAL(10, 2) NOT NULL,
    image_path VARCHAR(255),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Favorites Table
CREATE TABLE favorites (
    user_id INT,
    product_id INT,
    PRIMARY KEY (user_id, product_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Orders Table
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Order Items Table
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Seed Categories
INSERT INTO categories (name) VALUES ('skin care'), ('hair cut'), ('face wash'), ('make up'), ('salon');

-- Seed Products
INSERT INTO products (name, category_id, price, image_path, description) VALUES 
('Skin Light', 1, 25.0, 'assets/images/product1.png', 'History, Purpose and Usage. Lorem ipsum...'),
('Glow Serum', 1, 35.0, 'assets/images/product1.png', 'History, Purpose and Usage. Lorem ipsum...'),
('Hair Oil', 2, 15.0, 'assets/images/product1.png', 'History, Purpose and Usage. Lorem ipsum...'),
('Face Wash', 3, 12.0, 'assets/images/product1.png', 'History, Purpose and Usage. Lorem ipsum...'),
('Lipstick Set', 4, 45.0, 'assets/images/product1.png', 'History, Purpose and Usage. Lorem ipsum...');
