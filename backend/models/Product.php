<?php
class Product
{
    private $conn;
    private $table_name = "products";

    public $id;
    public $name;
    public $category;
    public $price;
    public $image_path;
    public $description;
    public $quantity;

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function read($categoryName = null, $search = null)
    {
        $query = "SELECT p.id, p.name, p.price, p.image_path, p.description, c.name as category, p.quantity, p.created_at
                  FROM " . $this->table_name . " p 
                  LEFT JOIN categories c ON p.category_id = c.id
                  WHERE 1=1";

        if ($categoryName && $categoryName !== 'All') {
            $query .= " AND c.name = :category";
        }

        if ($search) {
            $query .= " AND p.name LIKE :search";
        }

        $query .= " ORDER BY p.created_at DESC";

        $stmt = $this->conn->prepare($query);

        if ($categoryName && $categoryName !== 'All') {
            $stmt->bindParam(":category", $categoryName);
        }

        if ($search) {
            $searchTerm = "%{$search}%";
            $stmt->bindParam(":search", $searchTerm);
        }

        $stmt->execute();
        return $stmt;
    }

    public function create()
    {
        // Resolve category_id if name is provided
        $category_id = $this->resolveCategoryId($this->category);

        $query = "INSERT INTO " . $this->table_name . " SET name=:name, price=:price, description=:description, category_id=:category_id, image_path=:image_path, quantity=:quantity";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":category_id", $category_id);
        $stmt->bindParam(":image_path", $this->image_path);
        $stmt->bindParam(":quantity", $this->quantity);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function update()
    {
        // Resolve category_id if name is provided
        $category_id = $this->resolveCategoryId($this->category);

        $query = "UPDATE " . $this->table_name . " SET name=:name, price=:price, description=:description, category_id=:category_id, image_path=:image_path, quantity=:quantity WHERE id=:id";
        $stmt = $this->conn->prepare($query);

        $this->name = htmlspecialchars(strip_tags($this->name));
        $this->price = htmlspecialchars(strip_tags($this->price));
        $this->description = htmlspecialchars(strip_tags($this->description));
        $this->category = htmlspecialchars(strip_tags($this->category));
        $this->image_path = htmlspecialchars(strip_tags($this->image_path));
        $this->quantity = htmlspecialchars(strip_tags($this->quantity));
        $this->id = htmlspecialchars(strip_tags($this->id));

        $stmt->bindParam(":name", $this->name);
        $stmt->bindParam(":price", $this->price);
        $stmt->bindParam(":description", $this->description);
        $stmt->bindParam(":category_id", $category_id);
        $stmt->bindParam(":image_path", $this->image_path);
        $stmt->bindParam(":quantity", $this->quantity);
        $stmt->bindParam(":id", $this->id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    private function resolveCategoryId($name) {
        if (!$name) return null;
        if (is_numeric($name)) return $name;

        $query = "SELECT id FROM categories WHERE name = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $name);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row ? $row['id'] : null;
    }

    public function delete()
    {
        $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $this->id = htmlspecialchars(strip_tags($this->id));
        $stmt->bindParam(1, $this->id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }
}
?>