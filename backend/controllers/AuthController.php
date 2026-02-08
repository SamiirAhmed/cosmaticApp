<?php
include_once __DIR__ . '/../models/User.php';
include_once __DIR__ . '/../utils/Response.php';

class AuthController
{
    private $db;
    private $user;

    public function __construct($db)
    {
        $this->db = $db;
        $this->user = new User($db);
    }

    public function register($data)
    {
        error_log("AuthController::register called");
        error_log("Payload: " . json_encode($data));

        if (!isset($data->name) || !isset($data->email) || !isset($data->password) || !isset($data->phone) || empty($data->phone)) {
            error_log("AuthController::register - Missing required fields");
            Response::error("Missing required fields (name, email, phone, password).");
        }

        $this->user->name = $data->name;
        $this->user->email = $data->email;
        $this->user->phone = isset($data->phone) ? $data->phone : null;
        $this->user->password = $data->password;
        $this->user->role = isset($data->role) ? $data->role : 'user';

        if ($this->user->emailExists()) {
            error_log("AuthController::register - Email exists: " . $data->email);
            Response::error("Email already exists.");
        }

        if ($this->user->create()) {
            error_log("AuthController::register - Success for " . $data->email);
            Response::success(null, "Registration successful");
        } else {
            error_log("AuthController::register - Failed DB create");
            Response::error("Registration failed");
        }
    }

    public function login($data)
    {
        error_log("AuthController::login called");
        error_log("Payload: " . json_encode($data));

        if (!isset($data->email) || !isset($data->password)) {
            error_log("AuthController::login - Missing credentials");
            Response::error("Missing email or password.");
        }

        $this->user->email = $data->email;

        if ($this->user->emailExists()) {
            if (password_verify($data->password, $this->user->password)) {
                $userData = [
                    "id" => $this->user->id,
                    "name" => $this->user->name,
                    "email" => $this->user->email,
                    "phone" => $this->user->phone,
                    "role" => $this->user->role
                ];
                error_log("AuthController::login - Success: " . json_encode($userData));
                Response::success(["user" => $userData], "Login successful");
            } else {
                error_log("AuthController::login - Verify failed for " . $data->email);
                Response::error("Invalid credentials", 401);
            }
        } else {
            error_log("AuthController::login - Email not found: " . $data->email);
            Response::error("Invalid credentials", 401);
        }
    }

    public function getAllUsers()
    {
        error_log("AuthController::getAllUsers called");
        $stmt = $this->user->readAll();
        $users_arr = array();

        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $users_arr[] = [
                "id" => (string) $row['id'],
                "name" => $row['name'],
                "email" => $row['email'],
                "phone" => $row['phone'] ?? "",
                "role" => $row['role'],
                "password" => $row['password'] ?? "", // Using database hash or dummy for masking
                "created_at" => $row['created_at'] ?? ""
            ];
        }

        error_log("AuthController::getAllUsers - Count: " . count($users_arr));
        Response::success(["data" => $users_arr]);
    }

    public function updateUser($id, $data)
    {
        error_log("AuthController::updateUser called for ID: " . $id);
        if (!$id) {
            Response::error("User ID missing.");
        }

        if (!isset($data->name) || !isset($data->email) || !isset($data->role)) {
            Response::error("Missing required fields (name, email, role).");
        }

        $this->user->id = $id;
        $this->user->name = $data->name;
        $this->user->email = $data->email;
        $this->user->phone = $data->phone ?? "";
        $this->user->role = $data->role;

        if ($this->user->update()) {
            error_log("AuthController::updateUser - Success");
            Response::success(null, "User updated successfully.");
        } else {
            error_log("AuthController::updateUser - Failed");
            Response::error("Unable to update user.");
        }
    }

    public function deleteUser($id)
    {
        error_log("AuthController::deleteUser called for ID: " . $id);
        if (!$id) {
            Response::error("User ID missing.");
        }

        $this->user->id = $id;
        if ($this->user->delete()) {
            error_log("AuthController::deleteUser - Success");
            Response::success(null, "User deleted.");
        } else {
            error_log("AuthController::deleteUser - Failed to delete");
            Response::error("Unable to delete user.");
        }
    }
}
?>