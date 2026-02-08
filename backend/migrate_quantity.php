<?php
include_once __DIR__ . '/config/database.php';

$database = new Database();
$db = $database->getConnection();

if ($db === null) {
    echo "Database connection failed.\n";
    exit;
}

try {
    // Check if quantity column exists
    $result = $db->query("SHOW COLUMNS FROM products LIKE 'quantity'");
    if ($result->rowCount() == 0) {
        echo "Adding 'quantity' column to 'products' table...\n";
        $db->exec("ALTER TABLE products ADD COLUMN quantity INT NOT NULL DEFAULT 0 AFTER description");
        echo "Column added successfully.\n";
    } else {
        echo "'quantity' column already exists.\n";
    }

    // Update existing products with some dummy quantity if they are 0
    $db->exec("UPDATE products SET quantity = 50 WHERE quantity = 0");
    echo "Updated existing products with default quantity (50).\n";

} catch (PDOException $e) {
    echo "Error: " . $e->getMessage() . "\n";
}
?>