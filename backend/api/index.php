<?php
// VERSION: 2026-02-04-18:20 - Updated with fallback routing
// Prevent any accidental output
ob_start();

// Fast fail-safe for time-outs - Increased to allow for complex DB operations
set_time_limit(30); 
ini_set('mysql.connect_timeout', 10);
ini_set('default_socket_timeout', 30);

include_once __DIR__ . '/../utils/Response.php';

// REGULATORY TRACE: If 'trace' is set, exit immediately to prove reachability.
if (isset($_GET['trace'])) {
    die("BACKEND_REACHED");
}

header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

// Handle preflight OPTIONS request immediately
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    if (ob_get_length())
        ob_clean();
    http_response_code(200);
    exit;
}

// Global Exception/Error Handling to prevent hanging
set_exception_handler(function ($e) {
    if (ob_get_length())
        ob_clean();
    Response::error("Critical Error: " . $e->getMessage(), 500);
});

set_error_handler(function ($errno, $errstr, $errfile, $errline) {
    if (!(error_reporting() & $errno))
        return;
    throw new ErrorException($errstr, 0, $errno, $errfile, $errline);
});

$route = isset($_GET['route']) ? $_GET['route'] : '';
error_log("Index: Received Route ['$route'] Method [" . $_SERVER['REQUEST_METHOD'] . "]");

// FALLBACK: If router.php failed to populate route, parse it directly from URI
if (empty($route)) {
    $uri_path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
    if (strpos($uri_path, '/api/') !== false) {
        $pathStr = str_replace('/api/', '', $uri_path);
        $pathParts = explode('/', trim($pathStr, '/'));

        if (isset($pathParts[0]) && !empty($pathParts[0])) {
            $route = $pathParts[0];
            // Manually populate $_GET for consistency
            $_GET['route'] = $route;
        }
        if (isset($pathParts[1]) && !empty($pathParts[1])) {
            $_GET['id'] = $pathParts[1];
        }
        error_log("Index: Fallback Parsed Route ['$route']");
    }
}


// error_log("Index.php: Received route: '$route'");


// Fast track ping to test reachability without DB
if ($route === 'ping') {
    Response::success(["pong" => true, "time" => date("Y-m-d H:i:s")]);
}

try {
    include_once __DIR__ . '/../config/database.php';
    include_once __DIR__ . '/../controllers/AuthController.php';
    include_once __DIR__ . '/../controllers/ProductController.php';
    include_once __DIR__ . '/../controllers/OrderController.php';

    $database = new Database();
    $db = $database->getConnection();

    if (!$db) {
        Response::error("Database connection failed. Check if MySQL is running.", 500);
    }

    $id = isset($_GET['id']) ? $_GET['id'] : null;
    $method = $_SERVER['REQUEST_METHOD'];

    $json = file_get_contents("php://input");
    $data = json_decode($json);

    switch ($route) {
        case 'register':
            if ($method == 'POST') {
                $auth = new AuthController($db);
                $auth->register($data);
            } else {
                Response::error("Method Not Allowed for register. Use POST.", 405);
            }
            break;

        case 'login':
            if ($method == 'POST') {
                $auth = new AuthController($db);
                $auth->login($data);
            } else {
                Response::error("Method Not Allowed for login. Use POST.", 405);
            }
            break;

        case 'products':
            $product = new ProductController($db);
            if ($method == 'GET') {
                $category = isset($_GET['category']) ? $_GET['category'] : null;
                $search = isset($_GET['search']) ? $_GET['search'] : null;
                $product->getAll($category, $search);
            } elseif ($method == 'POST') {
                if ($id) {
                    $product->update($id, $data);
                } else {
                    $product->create($data);
                }
            } elseif ($method == 'PUT' || ($method == 'POST' && $id)) {
                if ($id) {
                    $product->update($id, $data);
                } else {
                    Response::error("ID missing for update.");
                }
            } elseif ($method == 'DELETE') {
                if ($id) {
                    $product->delete($id);
                } else {
                    Response::error("ID missing for deletion.");
                }
            } else {
                Response::error("Method Not Allowed for products.", 405);
            }
            break;

        case 'orders':
            $order = new OrderController($db);
            if ($method == 'POST') {
                $order->create($data);
            } elseif ($method == 'GET') {
                $userId = isset($_GET['user_id']) ? $_GET['user_id'] : (isset($_GET['userId']) ? $_GET['userId'] : null);
                if ($userId) {
                    $order->getMyOrders($userId);
                } else {
                    Response::error("User ID required.");
                }
            } else {
                Response::error("Method Not Allowed for orders.", 405);
            }
            break;

        case 'users':
            $auth = new AuthController($db);
            if ($method == 'GET') {
                $auth->getAllUsers();
            } elseif ($method == 'DELETE') {
                if ($id) {
                    $auth->deleteUser($id);
                } else {
                    Response::error("ID missing for user deletion.");
                }
            } else {
                Response::error("Method Not Allowed for users.", 405);
            }
            break;

        default:
            Response::error("Route '$route' not found. URI: " . $_SERVER['REQUEST_URI'], 404);
            break;
    }

} catch (Exception $e) {
    Response::error("Processing Error: " . $e->getMessage(), 500);
} catch (Error $e) {
    Response::error("System Error: " . $e->getMessage(), 500);
}

// Fallback in case a controller doesn't call Response::json and finishes
Response::error("No response generated for route: " . $route, 500);
?>