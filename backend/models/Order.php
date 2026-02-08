<?php
class Order
{
    private $conn;
    private $table_name = "orders";
    private $items_table = "order_items";

    public $id;
    public $user_id;
    public $total_amount;
    public $status;
    public $created_at;
    public $items = [];

    public function __construct($db)
    {
        $this->conn = $db;
    }

    public function create()
    {
        try {
            $this->conn->beginTransaction();

            $query = "INSERT INTO " . $this->table_name . "
                    SET
                        user_id = :user_id,
                        total_amount = :total_amount,
                        status = 'confirmed'";

            $stmt = $this->conn->prepare($query);

            $this->user_id = htmlspecialchars(strip_tags($this->user_id));
            $this->total_amount = htmlspecialchars(strip_tags($this->total_amount));

            $stmt->bindParam(':user_id', $this->user_id);
            $stmt->bindParam(':total_amount', $this->total_amount);

            if ($stmt->execute()) {
                $this->id = $this->conn->lastInsertId();

                if (!empty($this->items)) {
                    $item_query = "INSERT INTO " . $this->items_table . "
                                (order_id, product_id, quantity, price)
                                VALUES (:order_id, :product_id, :quantity, :price)";

                    $item_stmt = $this->conn->prepare($item_query);

                    // Prepare product quantity update query
                    $update_qty_query = "UPDATE products SET quantity = quantity - :ordered_qty WHERE id = :product_id AND quantity >= :ordered_qty";
                    $update_stmt = $this->conn->prepare($update_qty_query);

                    foreach ($this->items as $item) {
                        // Insert order item
                        $item_stmt->bindValue(':order_id', $this->id);
                        $item_stmt->bindValue(':product_id', $item['productId']);
                        $item_stmt->bindValue(':quantity', $item['quantity']);
                        $item_stmt->bindValue(':price', $item['price']);
                        $item_stmt->execute();

                        // Reduce product quantity
                        $update_stmt->bindValue(':ordered_qty', $item['quantity']);
                        $update_stmt->bindValue(':product_id', $item['productId']);
                        $update_stmt->execute();

                        // Check if quantity was actually updated (ensures stock was sufficient)
                        if ($update_stmt->rowCount() === 0) {
                            // Insufficient stock - rollback everything
                            error_log("Insufficient stock for product ID: " . $item['productId']);
                            $this->conn->rollBack();
                            return false;
                        }
                    }
                }

                $this->conn->commit();
                return true;
            } else {
                $this->conn->rollBack();
                return false;
            }
        } catch (Exception $e) {
            error_log("Order creation error: " . $e->getMessage());
            $this->conn->rollBack();
            return false;
        }
    }

    public function readByUser($userId)
    {
        $query = "SELECT * FROM " . $this->table_name . "
                WHERE user_id = ?
                ORDER BY created_at DESC";

        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $userId);
        $stmt->execute();

        return $stmt;
    }

    public function getTotalRevenue()
    {
        $query = "SELECT 
                    COUNT(*) as total_orders,
                    COALESCE(SUM(total_amount), 0) as total_revenue
                  FROM " . $this->table_name . "
                  WHERE status = 'confirmed'";

        $stmt = $this->conn->prepare($query);
        $stmt->execute();

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return [
            'total_orders' => (int) $row['total_orders'],
            'total_revenue' => (double) $row['total_revenue']
        ];
    }
}
?>