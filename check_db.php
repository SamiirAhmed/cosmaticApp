<?php
$host = "127.0.0.1";
$db_name = "cosmetics_db";
$username = "root";
$password = "";

try {
    $db = new PDO("mysql:host=$host;dbname=$db_name", $username, $password);
    $out = "TABLES:\n";
    $stmt = $db->query("SHOW TABLES");
    $tables = $stmt->fetchAll(PDO::FETCH_COLUMN);
    $out .= print_r($tables, true) . "\n\n";
    
    foreach ($tables as $table) {
        $out .= "DESCRIBE $table:\n";
        $stmt = $db->query("DESCRIBE $table");
        $out .= print_r($stmt->fetchAll(PDO::FETCH_ASSOC), true) . "\n\n";
        
        $out .= "DATA (LIMIT 5) from $table:\n";
        $stmt = $db->query("SELECT * FROM $table LIMIT 5");
        $out .= print_r($stmt->fetchAll(PDO::FETCH_ASSOC), true) . "\n\n";
    }
    
    file_put_contents("db_check_full.txt", $out);
    echo "Done. Results in db_check_full.txt";
} catch (Exception $e) {
    echo "Error: " . $e->getMessage();
}
