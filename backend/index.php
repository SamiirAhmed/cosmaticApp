<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, PUT, DELETE, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

// Fast fail-safe for time-outs - Increased to allow for complex DB/Auth operations
set_time_limit(30); 
ini_set('mysql.connect_timeout', 10);
ini_set('default_socket_timeout', 30);

include_once __DIR__ . '/config/database.php';
include_once __DIR__ . '/controllers/AuthController.php';
include_once __DIR__ . '/controllers/ProductController.php';
include_once __DIR__ . '/controllers/OrderController.php';
include_once __DIR__ . '/controllers/FavoriteController.php';

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', $uri);

// Look for 'api' segment
$apiIndex = array_search('api', $uri);
if ($apiIndex === false) {
    // If no 'api' in path, check if it's directly calling index.php via some other means or just root
    // But we assume /api/resource
    // Fallback: assume last segment is resource if 'api' not found? No, stricly require 'api'.
    echo json_encode(["message" => "Invalid Endpoint. Use /api/resource"]);
    exit;
}

$resource = $uri[$apiIndex + 1] ?? null;
$id = $uri[$apiIndex + 2] ?? null;

// Get database connection
$database = new Database();
$db = $database->getConnection();

// Validate database connection
if ($db === null) {
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Database connection failed. Please check your database configuration."
    ]);
    exit;
}

// Fallback: Check for ID in query parameter if not in path
if (!$id && isset($_GET['id'])) {
    $id = $_GET['id'];
}


// Read and parse request body for POST requests
$data = null;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Attempt to get JSON input from php://input
    $input_json_string = file_get_contents("php://input");
    error_log("Raw Input: " . $input_json_string);
    $data = json_decode($input_json_string);

    // If JSON decoding failed or input was empty, check $_POST and $_FILES
    if (json_last_error() !== JSON_ERROR_NONE && !empty($input_json_string)) {
        // If there was a non-empty string but it wasn't valid JSON
        http_response_code(400);
        echo json_encode([
            "status" => false,
            "message" => "Invalid JSON: " . json_last_error_msg()
        ]);
        exit;
    }
}

// Wrap in try-catch to handle any uncaught exceptions
try {
    switch ($resource) {
        case 'register':
            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                $auth = new AuthController($db);
                $auth->register($data);
            }
            break;
        case 'login':
            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                $auth = new AuthController($db);
                $auth->login($data);
            }
            break;
        case 'products':
            $controller = new ProductController($db);
            if ($_SERVER['REQUEST_METHOD'] === 'GET') {
                $controller->getAll(
                    $_GET['category'] ?? null,
                    $_GET['search'] ?? null,
                    $_GET['user_id'] ?? null
                );
            } elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
                // Check if update intent (POST with id) or create
                // Simplest: POST is create.
                // If delete, use DELETE method.
                // If update, use POST with 'action' field OR just assume generic creates.
                // Flutter usage: updateProduct calls API.
                // I'll stick to: POST = Create.
                // If ID is in URL, it's invalid for POST in standard REST, usually PUT.
                // But if clients don't support PUT (image upload issues), POST /products/{id} can be update.
                if ($id) {
                    $controller->update($id, $data);
                } else {
                    $controller->create($data);
                }
            } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE' && $id) {
                $controller->delete($id);
            }
            break;
        case 'users':
            $auth = new AuthController($db);
            if ($_SERVER['REQUEST_METHOD'] === 'GET') {
                $auth->getAllUsers();
            } elseif ($_SERVER['REQUEST_METHOD'] === 'PUT' && $id) {
                // Read and parse request body for PUT
                $input_json_string = file_get_contents("php://input");
                $data = json_decode($input_json_string);
                $auth->updateUser($id, $data);
            } elseif ($_SERVER['REQUEST_METHOD'] === 'DELETE' && $id) {
                $auth->deleteUser($id);
            } else {
                http_response_code(405);
                echo json_encode([
                    "status" => false,
                    "message" => "Method not allowed for users endpoint."
                ]);
            }
            break;
        case 'orders':
            $controller = new OrderController($db);
            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                $controller->create($data);
            }
            break;
        case 'admin':
            if ($id === 'stats' && $_SERVER['REQUEST_METHOD'] === 'GET') {
                $controller = new OrderController($db);
                $controller->getAdminStats();
            } else {
                http_response_code(404);
                echo json_encode([
                    "status" => false,
                    "message" => "Admin endpoint not found."
                ]);
            }
            break;
        case 'favorites':
            $controller = new FavoriteController($db);
            if ($_SERVER['REQUEST_METHOD'] === 'POST') {
                $controller->toggle($data);
            } elseif ($_SERVER['REQUEST_METHOD'] === 'GET') {
                $controller->getFavorites($_GET['user_id'] ?? null);
            }
            break;
        default:
            http_response_code(404);
            echo json_encode([
                "status" => false,
                "message" => "Endpoint not found."
            ]);
            break;
    }
} catch (Exception $e) {
    // Catch any uncaught exceptions and return JSON error
    error_log("Backend Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode([
        "status" => false,
        "message" => "Internal server error: " . $e->getMessage()
    ]);
}
exit;
?>