<?php
include_once __DIR__ . '/../models/Favorite.php';
include_once __DIR__ . '/../utils/Response.php';

class FavoriteController
{
    private $db;
    private $favorite;

    public function __construct($db)
    {
        $this->db = $db;
        $this->favorite = new Favorite($db);
    }

    public function toggle($data)
    {
        if (!isset($data->user_id) || !isset($data->product_id)) {
            Response::error("User ID and Product ID are required.");
            return;
        }

        $this->favorite->user_id = $data->user_id;
        $this->favorite->product_id = $data->product_id;

        if ($this->favorite->isFavorite($data->user_id, $data->product_id)) {
            if ($this->favorite->delete()) {
                Response::success(["isFavorite" => false], "Removed from favorites.");
            } else {
                Response::error("Unable to remove from favorites.");
            }
        } else {
            if ($this->favorite->create()) {
                Response::success(["isFavorite" => true], "Added to favorites.");
            } else {
                Response::error("Unable to add to favorites.");
            }
        }
    }

    public function getFavorites($user_id)
    {
        if (!$user_id) {
            Response::error("User ID is required.");
            return;
        }

        $stmt = $this->favorite->getUserFavorites($user_id);
        $favorites = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            extract($row);

            // Sanitize Path: Fix backslashes and remove any accidental hardcoded base URLs from DB
            $cleanPath = str_replace('\\', '/', $image_path);
            if (strpos($cleanPath, 'http') !== false || strpos($cleanPath, 'localhost') !== false) {
                $parts = explode('uploads/', $cleanPath);
                if (count($parts) > 1) {
                    $cleanPath = 'uploads/' . end($parts);
                }
            }

            $favorites[] = [
                "id" => (string) $id,
                "name" => $name,
                "category" => $category,
                "price" => (double) $price,
                "imagePath" => $cleanPath,
                "description" => $description,
                "isFavorite" => true // It's in the favorites list, so it's true
            ];
        }

        Response::success(["data" => $favorites]);
    }
}
?>