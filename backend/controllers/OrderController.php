<?php
include_once __DIR__ . '/../models/Order.php';
include_once __DIR__ . '/../utils/Response.php';

class OrderController
{
    private $db;
    private $order;

    public function __construct($db)
    {
        $this->db = $db;
        $this->order = new Order($db);
    }

    public function create($data)
    {
        error_log("OrderController::create called");
        error_log("Order Payload: " . json_encode($data));

        if (empty($data->userId) || empty($data->totalAmount) || empty($data->items)) {
            error_log("OrderController::create - Missing data");
            Response::error("Incomplete data for order creation.");
        }

        $this->order->user_id = $data->userId;
        $this->order->total_amount = $data->totalAmount;
        $this->order->items = json_decode(json_encode($data->items), true); // Convert stdClass to array

        if ($this->order->create()) {
            error_log("OrderController::create - Success. Order ID: " . $this->order->id);
            Response::success(["id" => $this->order->id], "Order placed successfully.");
        } else {
            error_log("OrderController::create - Failed DB create");
            Response::error("Unable to place order.", 500);
        }
    }

    public function getMyOrders($userId)
    {
        error_log("OrderController::getMyOrders called for UserID: $userId");
        $stmt = $this->order->readByUser($userId);
        $orders_arr = array();

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $orders_arr[] = [
                "id" => (string) $row['id'],
                "user_id" => (string) $row['user_id'],
                "total_amount" => (double) $row['total_amount'],
                "status" => $row['status'],
                "created_at" => $row['created_at']
            ];
        }

        error_log("OrderController::getMyOrders - Count: " . count($orders_arr));
        Response::success(["data" => $orders_arr]);
    }

    public function getAdminStats()
    {
        error_log("OrderController::getAdminStats called");
        $stats = $this->order->getTotalRevenue();

        error_log("OrderController::getAdminStats - Revenue: $" . $stats['total_revenue']);
        Response::success(["data" => $stats]);
    }
}