<?php

class Response
{
    public static function json($isSuccess, $data = null, $message = null, $httpCode = 200)
    {
        if (ob_get_length())
            ob_clean();

        header("Content-Type: application/json; charset=UTF-8");
        http_response_code($httpCode);

        $response = [
            'status' => (bool) $isSuccess,
            'message' => $message
        ];

        if (is_array($data) || is_object($data)) {
            foreach ($data as $key => $value) {
                $response[$key] = $value;
            }
        } elseif ($data !== null && $message === null) {
            // Fallback for old usage
            $response['message'] = (string) $data;
        }

        $json = json_encode($response);
        if ($json === false) {
            echo json_encode(["status" => false, "message" => "JSON encoding error: " . json_last_error_msg()]);
        } else {
            echo $json;
        }
        exit;
    }

    public static function success($data = null, $message = "Success")
    {
        self::json(true, $data, $message);
    }

    public static function error($message = "Error", $httpCode = 400)
    {
        self::json(false, null, $message, $httpCode);
    }
}
?>