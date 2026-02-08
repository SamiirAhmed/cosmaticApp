<?php
try {
    $db = new PDO("mysql:host=127.0.0.1", "root", "");
    $stmt = $db->query("SHOW DATABASES");
    print_r($stmt->fetchAll(PDO::FETCH_COLUMN));
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
