<?php
/**
 * Septalyze API - Configuration
 */

// Database configuration
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'septalyze');

// API configuration
define('API_VERSION', '1.0.0');
define('API_KEY', 'your_secret_api_key_here');

// JWT configuration
define('JWT_SECRET', 'your_jwt_secret_key_here_change_in_production');
define('JWT_EXPIRY', 86400); // 24 hours

// Upload configuration
define('UPLOAD_DIR', __DIR__ . '/uploads/');
define('MAX_UPLOAD_SIZE', 10 * 1024 * 1024); // 10MB
define('ALLOWED_EXTENSIONS', ['jpg', 'jpeg', 'png']);

// CORS configuration
define('CORS_ALLOWED_ORIGINS', '*');

// Error reporting
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);
ini_set('error_log', __DIR__ . '/logs/error.log');

// Timezone
date_default_timezone_set('Asia/Bangkok');

// Create necessary directories
$dirs = [
    __DIR__ . '/uploads',
    __DIR__ . '/logs',
    __DIR__ . '/temp'
];

foreach ($dirs as $dir) {
    if (!file_exists($dir)) {
        mkdir($dir, 0777, true);
    }
}
?>
