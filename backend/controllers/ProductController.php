<?php
include_once __DIR__ . '/../models/Product.php';
include_once __DIR__ . '/../models/Category.php';
include_once __DIR__ . '/../models/Favorite.php';
include_once __DIR__ . '/../utils/Response.php';

class ProductController
{
    private $db;
    private $product;

    public function __construct($db)
    {
        $this->db = $db;
        $this->product = new Product($db);
    }

    public function getAll($categoryName = null, $search = null, $userId = null)
    {
        $stmt = $this->product->read($categoryName, $search);
        $favorite = new Favorite($this->db);

        $protocol = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http") . "://";
        $host = $_SERVER['HTTP_HOST'];
        $script_name = str_replace('\\', '/', $_SERVER['SCRIPT_NAME']);
        $base_path = dirname($script_name);
        $upload_base = $protocol . $host . str_replace('/api', '', $base_path) . "/";

        $products_arr = array();
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);

            // Sanitize Path: Fix backslashes and remove any accidental hardcoded base URLs from DB
            $cleanPath = str_replace('\\', '/', $image_path);
            if (strpos($cleanPath, 'http') !== false || strpos($cleanPath, 'localhost') !== false) {
                // Try to extract just the 'uploads/...' part
                $parts = explode('uploads/', $cleanPath);
                if (count($parts) > 1) {
                    $cleanPath = 'uploads/' . end($parts);
                }
            }
            $finalImage = $cleanPath;



            $isFav = false;
            if ($userId) {
                $isFav = $favorite->isFavorite($userId, $id);
            }

            $product_item = array(
                "id" => (string) $id,
                "name" => $name,
                "category" => $category,
                "price" => (double) $price,
                "imagePath" => $finalImage,
                "description" => $description,
                "quantity" => (int) $quantity,
                "isFavorite" => $isFav
            );
            array_push($products_arr, $product_item);
        }

        error_log("ProductController::getAll - Returned " . count($products_arr) . " products");
        Response::success(["data" => $products_arr]);
    }

    public function create($data)
    {
        $this->handleSave(null, $data);
    }

    public function update($id, $data)
    {
        error_log("ProductController::update called for ID: $id");
        $this->handleSave($id, $data);
    }

    private function handleSave($id = null, $data = null)
    {
        error_log("ProductController::handleSave Called");
        error_log("POST: " . print_r($_POST, true));
        error_log("FILES: " . print_r($_FILES, true));

        $name = $_POST['name'] ?? ($data->name ?? null);
        $price = $_POST['price'] ?? ($data->price ?? null);
        $catName = $_POST['category'] ?? ($data->category ?? 'skin care');
        $description = $_POST['description'] ?? ($data->description ?? "Default description");
        $imagePath = $_POST['imagePath'] ?? ($data->imagePath ?? null);
        $quantity = $_POST['quantity'] ?? ($data->quantity ?? 0);

        error_log("ProductController::handleSave - Name: $name, Price: $price, Quantity: $quantity");

        if (!$name || !$price) {
            error_log("ProductController::handleSave - Missing name or price");
            Response::error("Incomplete data. Name and Price are required.");
        }

        // Handle Image Upload
        if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
            $target_dir = __DIR__ . "/../uploads/";
            if (!file_exists($target_dir))
                mkdir($target_dir, 0777, true);

            $extension = pathinfo($_FILES["image"]["name"], PATHINFO_EXTENSION);
            $filename = time() . "_" . uniqid() . "." . $extension;
            $target_file = $target_dir . $filename;

            if (move_uploaded_file($_FILES["image"]["tmp_name"], $target_file)) {
                $imagePath = "uploads/" . $filename;
            }
        }

        $this->product->name = $name;
        $this->product->price = $price;
        $this->product->description = $description;
        $this->product->category = $catName;
        $this->product->image_path = $imagePath ?? 'assets/images/product1.png';
        $this->product->quantity = $quantity;

        if ($id) {
            $this->product->id = $id;
            if ($this->product->update()) {
                error_log("ProductController::handleSave - Update Success");
                Response::success(null, "Product updated.");
            } else {
                error_log("ProductController::handleSave - Update Failed");
                Response::error("Unable to update product.", 500);
            }
        } else {
            if ($this->product->create()) {
                error_log("ProductController::handleSave - Create Success");
                Response::success(null, "Product created.");
            } else {
                error_log("ProductController::handleSave - Create Failed");
                Response::error("Unable to create product.", 500);
            }
        }
    }

    public function delete($id)
    {
        error_log("ProductController::delete called for ID: $id");
        $this->product->id = $id;
        if ($this->product->delete()) {
            error_log("ProductController::delete - Success");
            Response::success(null, "Product deleted.");
        } else {
            error_log("ProductController::delete - Failed");
            Response::error("Unable to delete product.", 500);
        }
    }
}