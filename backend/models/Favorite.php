<?php
class Favorite
{
    private $conn;
    private $table_name = "favorites";

    public $id;
    public $user_id;
    public $product_id;
    public $created_at;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function create()
    {
        $query = "INSERT INTO " . $this->table_name . " (user_id, product_id) VALUES (:user_id, :product_id)";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->bindParam(":product_id", $this->product_id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function delete()
    {
        $query = "DELETE FROM " . $this->table_name . " WHERE user_id = :user_id AND product_id = :product_id";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":user_id", $this->user_id);
        $stmt->bindParam(":product_id", $this->product_id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function isFavorite($user_id, $product_id)
    {
        $query = "SELECT 1 FROM " . $this->table_name . " WHERE user_id = :user_id AND product_id = :product_id LIMIT 1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->bindParam(":product_id", $product_id);
        $stmt->execute();

        return $stmt->rowCount() > 0;
    }

    public function getUserFavorites($user_id)
    {
        $query = "SELECT p.* 
                  FROM " . $this->table_name . " f
                  JOIN products p ON f.product_id = p.id
                  WHERE f.user_id = :user_id";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(":user_id", $user_id);
        $stmt->execute();

        return $stmt;
    }
}
?>