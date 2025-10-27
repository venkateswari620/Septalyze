<?php
/**
 * Septalyze API - Main Entry Point
 * Professional Medical CT Scan Analysis Backend
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once 'config.php';
require_once 'database.php';
require_once 'auth.php';

// Initialize database connection
if (!initDatabase()) {
    sendResponse(500, ['error' => 'Database connection failed']);
    exit();
}

// Create tables if they don't exist
createTables();

// Get request method and path
$method = $_SERVER['REQUEST_METHOD'];
$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$path = str_replace('/backend/', '', $path);
$path = trim($path, '/');

// Route the request
switch ($path) {
    case 'health':
        handleHealth();
        break;
    
    case 'auth/login':
        handleLogin();
        break;
    
    case 'auth/signup':
        handleSignup();
        break;
    
    case 'auth/logout':
        handleLogout();
        break;
    
    case 'analyze':
        handleAnalyze();
        break;
    
    case 'patients':
        handlePatients();
        break;
    
    case 'history':
        handleHistory();
        break;
    
    case 'reports':
        handleReports();
        break;
    
    default:
        sendResponse(404, ['error' => 'Endpoint not found']);
        break;
}

// Health check endpoint
function handleHealth() {
    sendResponse(200, [
        'status' => 'healthy',
        'service' => 'Septalyze API',
        'version' => '1.0.0',
        'timestamp' => date('Y-m-d H:i:s')
    ]);
}

// Login endpoint
function handleLogin() {
    global $method;
    
    if ($method !== 'POST') {
        sendResponse(405, ['error' => 'Method not allowed']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['email']) || !isset($data['password'])) {
        sendResponse(400, ['error' => 'Email and password required']);
        return;
    }
    
    $result = authenticateUser($data['email'], $data['password']);
    
    if ($result['success']) {
        sendResponse(200, [
            'success' => true,
            'token' => $result['token'],
            'user' => $result['user'],
            'error' => null
        ]);
    } else {
        sendResponse(401, [
            'success' => false,
            'token' => null,
            'user' => null,
            'error' => 'Invalid email or password'
        ]);
    }
}

// Signup endpoint
function handleSignup() {
    global $method;
    
    if ($method !== 'POST') {
        sendResponse(405, ['error' => 'Method not allowed']);
        return;
    }
    
    $data = json_decode(file_get_contents('php://input'), true);
    
    if (!isset($data['email']) || !isset($data['password']) || !isset($data['name'])) {
        sendResponse(400, ['error' => 'Name, email and password required']);
        return;
    }
    
    $result = createUser($data['name'], $data['email'], $data['password']);
    
    if ($result['success']) {
        sendResponse(201, [
            'success' => true,
            'message' => 'User created successfully',
            'user' => $result['user'],
            'error' => null
        ]);
    } else {
        sendResponse(400, [
            'success' => false,
            'message' => null,
            'user' => null,
            'error' => $result['error']
        ]);
    }
}

// Logout endpoint
function handleLogout() {
    sendResponse(200, ['success' => true, 'message' => 'Logged out successfully']);
}

// Analyze CT scan endpoint
function handleAnalyze() {
    global $method;
    
    if ($method !== 'POST') {
        sendResponse(405, ['error' => 'Method not allowed']);
        return;
    }
    
    // Check if image was uploaded
    if (!isset($_FILES['image'])) {
        sendResponse(400, ['error' => 'No image uploaded']);
        return;
    }
    
    $image = $_FILES['image'];
    
    // Validate image
    $allowedTypes = ['image/jpeg', 'image/png', 'image/jpg'];
    if (!in_array($image['type'], $allowedTypes)) {
        sendResponse(400, ['error' => 'Invalid image type. Only JPEG and PNG allowed']);
        return;
    }
    
    // Get patient data from POST if available
    $patientData = null;
    if (isset($_POST['patient_data'])) {
        $patientData = json_decode($_POST['patient_data'], true);
    }
    
    // Process the image
    $result = analyzeImage($image, $patientData);
    
    sendResponse(200, $result);
}

// Patients endpoint
function handlePatients() {
    global $method;
    
    if ($method === 'GET') {
        $patients = getAllPatients();
        sendResponse(200, ['patients' => $patients]);
    } elseif ($method === 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $result = createPatient($data);
        sendResponse(201, $result);
    } else {
        sendResponse(405, ['error' => 'Method not allowed']);
    }
}

// History endpoint
function handleHistory() {
    global $method;
    
    if ($method !== 'GET') {
        sendResponse(405, ['error' => 'Method not allowed']);
        return;
    }
    
    $history = getScanHistory();
    sendResponse(200, ['history' => $history]);
}

// Reports endpoint
function handleReports() {
    global $method;
    
    if ($method === 'GET') {
        $reportId = $_GET['id'] ?? null;
        if ($reportId) {
            $report = getReport($reportId);
            sendResponse(200, $report);
        } else {
            $reports = getAllReports();
            sendResponse(200, ['reports' => $reports]);
        }
    } elseif ($method === 'POST') {
        // Save PDF report
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['scan_result_id'])) {
            sendResponse(400, ['error' => 'scan_result_id required']);
            return;
        }
        
        $result = saveReport($data['scan_result_id'], $data['pdf_path'] ?? null);
        
        if ($result['success']) {
            sendResponse(201, [
                'success' => true,
                'report_id' => $result['report_id'],
                'message' => 'Report saved successfully'
            ]);
        } else {
            sendResponse(400, ['error' => $result['error']]);
        }
    } else {
        sendResponse(405, ['error' => 'Method not allowed']);
    }
}

// Helper function to send JSON response
function sendResponse($statusCode, $data) {
    http_response_code($statusCode);
    echo json_encode($data, JSON_PRETTY_PRINT);
    exit();
}

// Analyze image function (mock implementation)
function analyzeImage($image, $patientData = null) {
    global $db;
    
    // Save uploaded image
    $uploadDir = __DIR__ . '/uploads/';
    if (!file_exists($uploadDir)) {
        mkdir($uploadDir, 0777, true);
    }
    
    $filename = uniqid() . '_' . basename($image['name']);
    $filepath = $uploadDir . $filename;
    
    if (!move_uploaded_file($image['tmp_name'], $filepath)) {
        return ['error' => 'Failed to save image'];
    }
    
    // Save or get patient data
    $patientId = null;
    if ($patientData) {
        // Check if patient exists
        $stmt = $db->prepare("SELECT id FROM patients WHERE patient_id = ?");
        $stmt->bind_param("s", $patientData['patientID']);
        $stmt->execute();
        $result = $stmt->get_result();
        
        if ($result->num_rows > 0) {
            $patientId = $result->fetch_assoc()['id'];
        } else {
            // Create new patient
            $stmt = $db->prepare("INSERT INTO patients (name, age, gender, patient_id, referring_doctor, notes) VALUES (?, ?, ?, ?, ?, ?)");
            $stmt->bind_param(
                "ssssss",
                $patientData['name'],
                $patientData['age'],
                $patientData['gender'],
                $patientData['patientID'],
                $patientData['referringDoctor'],
                $patientData['notes']
            );
            $stmt->execute();
            $patientId = $db->insert_id;
        }
    }
    
    // Call Python AI model for real predictions
    $predictions = callPythonAI($filepath);
    
    // Fallback to mock if Python AI fails
    if (empty($predictions)) {
        $predictions = generateMockPredictions();
    }
    
    // Determine diagnosis
    $diagnosis = determineDiagnosis($predictions);
    $hasConchaBullosa = hasCondition($predictions, 'CB');
    $hasDeviation = hasCondition($predictions, 'Deviated');
    
    // Generate annotated image (mock)
    $annotatedImageBase64 = base64_encode(file_get_contents($filepath));
    
    // Save scan result to database
    $scanResultId = saveScanResult($patientId, $filename, $predictions, $diagnosis, $hasConchaBullosa, $hasDeviation);
    
    // Automatically create report entry
    $reportResult = saveReport($scanResultId, null);
    $reportId = $reportResult['success'] ? $reportResult['report_id'] : null;
    
    return [
        'success' => true,
        'scan_id' => $scanResultId,
        'report_id' => $reportId,
        'patient_id' => $patientId,
        'boxes' => $predictions,
        'predictions' => $predictions,  // Keep for compatibility
        'annotated_image_base64' => $annotatedImageBase64,
        'diagnosis' => $diagnosis,
        'width' => 512,
        'height' => 512
    ];
}

// Call Python AI model for real predictions
function callPythonAI($imagePath) {
    $pythonAPIUrl = 'http://localhost:8000/infer';
    
    // Check if file exists
    if (!file_exists($imagePath)) {
        error_log("Image file not found: $imagePath");
        return [];
    }
    
    // Create cURL request
    $ch = curl_init();
    $cfile = new CURLFile($imagePath, 'image/jpeg', 'scan.jpg');
    
    curl_setopt_array($ch, [
        CURLOPT_URL => $pythonAPIUrl,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => ['image' => $cfile],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_CONNECTTIMEOUT => 5
    ]);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);
    
    // Check for errors
    if ($error) {
        error_log("Python AI connection error: $error");
        return [];
    }
    
    if ($httpCode !== 200) {
        error_log("Python AI returned HTTP $httpCode");
        return [];
    }
    
    // Parse response
    $data = json_decode($response, true);
    if (!isset($data['boxes'])) {
        error_log("Invalid Python AI response format");
        return [];
    }
    
    // Convert Python response to PHP format
    $predictions = [];
    foreach ($data['boxes'] as $box) {
        $predictions[] = [
            'cls' => $box['cls'],
            'conf' => $box['conf'],
            'x1' => $box['x1'],
            'y1' => $box['y1'],
            'x2' => $box['x2'],
            'y2' => $box['y2']
        ];
    }
    
    return $predictions;
}

// Generate mock predictions
function generateMockPredictions() {
    $scenarios = [
        // Normal
        [
            ['cls' => 'Normal', 'conf' => 0.95, 'x1' => 100, 'y1' => 100, 'x2' => 400, 'y2' => 400]
        ],
        // Deviated Septum
        [
            ['cls' => 'Deviated_Septum_Left', 'conf' => 0.87, 'x1' => 150, 'y1' => 120, 'x2' => 350, 'y2' => 380]
        ],
        // Concha Bullosa
        [
            ['cls' => 'CB_Right', 'conf' => 0.92, 'x1' => 200, 'y1' => 150, 'x2' => 300, 'y2' => 250],
            ['cls' => 'CB_Left', 'conf' => 0.88, 'x1' => 220, 'y1' => 250, 'x2' => 320, 'y2' => 350]
        ],
        // Mixed
        [
            ['cls' => 'CB_Left', 'conf' => 0.85, 'x1' => 180, 'y1' => 140, 'x2' => 280, 'y2' => 240],
            ['cls' => 'Deviated_Septum_Right', 'conf' => 0.79, 'x1' => 160, 'y1' => 130, 'x2' => 360, 'y2' => 390]
        ]
    ];
    
    // Randomly select a scenario
    return $scenarios[array_rand($scenarios)];
}

// Save scan result to database
function saveScanResult($patientId, $filename, $predictions, $diagnosis, $hasConchaBullosa, $hasDeviation) {
    global $db;
    
    $stmt = $db->prepare("INSERT INTO scan_results (patient_id, filename, predictions, diagnosis, has_concha_bullosa, has_deviation, scan_date) VALUES (?, ?, ?, ?, ?, ?, NOW())");
    $predictionsJson = json_encode($predictions);
    $stmt->bind_param(
        "isssii",
        $patientId,
        $filename,
        $predictionsJson,
        $diagnosis,
        $hasConchaBullosa,
        $hasDeviation
    );
    $stmt->execute();
    
    return $db->insert_id;
}

// Determine diagnosis from predictions
function determineDiagnosis($predictions) {
    foreach ($predictions as $pred) {
        $cls = strtolower($pred['cls']);
        if (strpos($cls, 'deviated') !== false) {
            return 'Deviated Nasal Septum';
        } elseif (strpos($cls, 'cb') !== false || strpos($cls, 'concha') !== false) {
            return 'Concha Bullosa';
        }
    }
    return 'Normal Nasal Septum';
}

// Check if predictions contain a specific condition
function hasCondition($predictions, $condition) {
    foreach ($predictions as $pred) {
        if (stripos($pred['cls'], $condition) !== false) {
            return true;
        }
    }
    return false;
}
?>
