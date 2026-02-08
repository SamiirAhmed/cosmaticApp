<?php
// Router script for PHP built-in server
// This ensures all API requests are routed through index.php

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);

// Debug logging
error_log("Router: Handling URI '$uri'");

// If the request is for a static file that exists, serve it
if ($uri !== '/') {
    $filePath = __DIR__ . $uri;
    // Fix formatting for Windows
    $filePath = str_replace('/', DIRECTORY_SEPARATOR, $filePath);
    $exists = file_exists($filePath);

    // Force serve uploads to bypass potential file_exists issues on some environments
    if (strpos($uri, '/uploads/') === 0) {
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Authorization");

        if (file_exists($filePath)) {
            $ext = pathinfo($filePath, PATHINFO_EXTENSION);
            $mimes = [
                'png' => 'image/png',
                'jpg' => 'image/jpeg',
                'jpeg' => 'image/jpeg',
                'gif' => 'image/gif',
            ];
            if (isset($mimes[strtolower($ext)])) {
                header("Content-Type: " . $mimes[strtolower($ext)]);
            }
            readfile($filePath);
            exit;
        } else {
            // File really doesn't exist
            http_response_code(404);
            echo "File not found: $filePath";
            exit;
        }
    }

    if ($exists) {
        // Handle OPTIONS for static files explicitly
        if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
            header("Access-Control-Allow-Origin: *");
            header("Access-Control-Allow-Methods: GET, OPTIONS");
            header("Access-Control-Allow-Headers: Content-Type, Authorization");
            exit(0);
        }

        $ext = pathinfo($filePath, PATHINFO_EXTENSION);
        $mimes = [
            'png' => 'image/png',
            'jpg' => 'image/jpeg',
            'jpeg' => 'image/jpeg',
            'gif' => 'image/gif',
            'css' => 'text/css',
            'js' => 'application/javascript',
        ];

        // If it's an image or we just want to allow everything
        if (isset($mimes[strtolower($ext)])) {
            header("Access-Control-Allow-Origin: *");
            header("Access-Control-Allow-Methods: GET, OPTIONS");
            header("Access-Control-Allow-Headers: Content-Type, Authorization");
            header("Content-Type: " . $mimes[strtolower($ext)]);
            readfile($filePath);
            exit;
        }
    }
}

// Parse API routes manually for the built-in server
// Example: /api/users/123 -> $_GET['route']='users', $_GET['id']='123'
if (strpos($uri, '/api/') === 0) {
    // $uri (from line 5) already has query string removed by parse_url(..., PHP_URL_PATH)
    // So we just need to strip /api/
    $pathStr = str_replace('/api/', '', $uri);
    $pathParts = explode('/', trim($pathStr, '/'));

    error_log("Router: URI '$uri' -> PathStr '$pathStr'");

    if (isset($pathParts[0]) && !empty($pathParts[0])) {
        $_GET['route'] = $pathParts[0];
        error_log("Router: Set route = " . $_GET['route']);
    }
    if (isset($pathParts[1]) && !empty($pathParts[1])) {
        $_GET['id'] = $pathParts[1];
        error_log("Router: Set id = " . $_GET['id']);
    }
} else {
    error_log("Router: No API match for '$uri'");
}

// Otherwise, route through index.php
$_SERVER['SCRIPT_NAME'] = '/index.php';
require __DIR__ . '/index.php';
?>