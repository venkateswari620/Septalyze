<?php
/**
 * Septalyze API - Database Connection and Functions
 */

require_once 'config.php';

// Global database connection
$db = null;

// Initialize database connection
function initDatabase() {
    global $db;
    
    $db = new mysqli(DB_HOST, DB_USER, DB_PASS, DB_NAME);
    
    if ($db->connect_error) {
        error_log("Database connection failed: " . $db->connect_error);
        return false;
    }
    
    $db->set_charset("utf8mb4");
    return true;
}

// Create database tables if they don't exist
function createTables() {
    global $db;
    
    // Users table
    $sql = "CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        password VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_email (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $db->query($sql);
    
    // Patients table
    $sql = "CREATE TABLE IF NOT EXISTS patients (
        id INT AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        age VARCHAR(10),
        gender VARCHAR(20),
        patient_id VARCHAR(100) UNIQUE NOT NULL,
        referring_doctor VARCHAR(255),
        notes TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX idx_patient_id (patient_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $db->query($sql);
    
    // Scan results table
    $sql = "CREATE TABLE IF NOT EXISTS scan_results (
        id INT AUTO_INCREMENT PRIMARY KEY,
        patient_id INT,
        filename VARCHAR(255),
        predictions TEXT,
        diagnosis VARCHAR(100),
        has_concha_bullosa BOOLEAN DEFAULT FALSE,
        has_deviation BOOLEAN DEFAULT FALSE,
        scan_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
        INDEX idx_patient (patient_id),
        INDEX idx_scan_date (scan_date)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $db->query($sql);
    
    // Reports table
    $sql = "CREATE TABLE IF NOT EXISTS reports (
        id INT AUTO_INCREMENT PRIMARY KEY,
        scan_result_id INT,
        pdf_path VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (scan_result_id) REFERENCES scan_results(id) ON DELETE CASCADE,
        INDEX idx_scan_result (scan_result_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4";
    
    $db->query($sql);
    
    // Create demo users if they don't exist
    createDemoUsers();
}

// Create demo users
function createDemoUsers() {
    global $db;
    
    // Check if demo user exists
    $result = $db->query("SELECT id FROM users WHERE email = 'demo@septalyze.com'");
    if ($result->num_rows === 0) {
        // Create demo user with plain text password
        $stmt = $db->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
        $name = "Demo User";
        $email = "demo@septalyze.com";
        $password = "password123"; // Plain text as requested
        $stmt->bind_param("sss", $name, $email, $password);
        $stmt->execute();
    }
    
    // Check if admin user exists
    $result = $db->query("SELECT id FROM users WHERE email = 'admin@septalyze.com'");
    if ($result->num_rows === 0) {
        $stmt = $db->prepare("INSERT INTO users (name, email, password) VALUES (?, ?, ?)");
        $name = "Admin";
        $email = "admin@septalyze.com";
        $password = "admin123"; // Plain text
        $stmt->bind_param("sss", $name, $email, $password);
        $stmt->execute();
    }
}

// Get all patients
function getAllPatients() {
    global $db;
    
    $result = $db->query("SELECT * FROM patients ORDER BY created_at DESC");
    $patients = [];
    
    while ($row = $result->fetch_assoc()) {
        $patients[] = $row;
    }
    
    return $patients;
}

// Create patient
function createPatient($data) {
    global $db;
    
    $stmt = $db->prepare("INSERT INTO patients (name, age, gender, patient_id, referring_doctor, notes) VALUES (?, ?, ?, ?, ?, ?)");
    
    $stmt->bind_param(
        "ssssss",
        $data['name'],
        $data['age'],
        $data['gender'],
        $data['patientID'],
        $data['referringDoctor'],
        $data['notes']
    );
    
    if ($stmt->execute()) {
        return [
            'success' => true,
            'patient_id' => $db->insert_id
        ];
    } else {
        return [
            'success' => false,
            'error' => $stmt->error
        ];
    }
}

// Get scan history
function getScanHistory() {
    global $db;
    
    $sql = "SELECT sr.*, p.name as patient_name, p.patient_id, p.age, p.gender, p.referring_doctor
            FROM scan_results sr
            LEFT JOIN patients p ON sr.patient_id = p.id
            ORDER BY sr.scan_date DESC
            LIMIT 50";
    
    $result = $db->query($sql);
    $history = [];
    
    while ($row = $result->fetch_assoc()) {
        $history[] = [
            'id' => (int)$row['id'],
            'patient_id' => (int)$row['patient_id'],
            'patient_name' => $row['patient_name'],
            'patient_age' => $row['age'],
            'patient_gender' => $row['gender'],
            'patient_patient_id' => $row['patient_id'],
            'filename' => $row['filename'],
            'diagnosis' => $row['diagnosis'],
            'has_concha_bullosa' => (bool)$row['has_concha_bullosa'],
            'has_deviation' => (bool)$row['has_deviation'],
            'scan_date' => $row['scan_date']
        ];
    }
    
    return $history;
}

// Get all reports
function getAllReports() {
    global $db;
    
    $result = $db->query("SELECT * FROM reports ORDER BY created_at DESC LIMIT 50");
    $reports = [];
    
    while ($row = $result->fetch_assoc()) {
        $reports[] = [
            'id' => (int)$row['id'],
            'scan_result_id' => (int)$row['scan_result_id'],
            'pdf_path' => $row['pdf_path'],
            'created_at' => $row['created_at']
        ];
    }
    
    return $reports;
}

// Get single report
function getReport($id) {
    global $db;
    
    $stmt = $db->prepare("SELECT * FROM reports WHERE id = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $result = $stmt->get_result();
    
    return $result->fetch_assoc();
}

// Save report
function saveReport($scanResultId, $pdfPath = null) {
    global $db;
    
    // Check if scan result exists
    $stmt = $db->prepare("SELECT id FROM scan_results WHERE id = ?");
    $stmt->bind_param("i", $scanResultId);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows === 0) {
        return [
            'success' => false,
            'error' => 'Scan result not found'
        ];
    }
    
    // Insert report
    $stmt = $db->prepare("INSERT INTO reports (scan_result_id, pdf_path, created_at) VALUES (?, ?, NOW())");
    $stmt->bind_param("is", $scanResultId, $pdfPath);
    
    if ($stmt->execute()) {
        return [
            'success' => true,
            'report_id' => $db->insert_id
        ];
    }
    
    return [
        'success' => false,
        'error' => 'Failed to save report'
    ];
}

// Initialize database on load
initDatabase();
createTables();
?>
