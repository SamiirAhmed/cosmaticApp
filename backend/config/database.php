<?php

class Database
{
    private $host = "127.0.0.1";
    private $db_name = "cosmetics_db";
    private $username = "root";
    private $password = "";
    public $conn;

    public function getConnection()
    {
        $this->conn = null;

        try {
            $options = [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_TIMEOUT => 30, // Increased from 5 to 30 seconds
                PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES utf8"
            ];
            $this->conn = new PDO("mysql:host=" . $this->host . ";dbname=" . $this->db_name, $this->username, $this->password, $options);
        } catch (PDOException $exception) {
            // Do NOT echo here, it breaks JSON headers. 
            // The index.php will check if $db is null.
            error_log("Database Connection Error: " . $exception->getMessage());
        }

        return $this->conn;
    }
}
?>