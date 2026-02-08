<?php
class Category
{
    private $conn;
    private $table_name = "categories";

    public $id;
    public $name;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function getIdByName($name)
    {
        $query = "SELECT id FROM " . $this->table_name . " WHERE name = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $name);
        $stmt->execute();
        $num = $stmt->rowCount();

        if ($num > 0) {
            $row = $stmt->fetch(PDO::FETCH_ASSOC);
            return $row['id'];
        }
        return null;
    }
}
?>