-- Septalyze Database Setup
-- Run this SQL to create the database and tables

CREATE DATABASE IF NOT EXISTS septalyze CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE septalyze;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Patients table
CREATE TABLE IF NOT EXISTS patients (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Scan results table
CREATE TABLE IF NOT EXISTS scan_results (
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
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Reports table
CREATE TABLE IF NOT EXISTS reports (
    id INT AUTO_INCREMENT PRIMARY KEY,
    scan_result_id INT,
    pdf_path VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (scan_result_id) REFERENCES scan_results(id) ON DELETE CASCADE,
    INDEX idx_scan_result (scan_result_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Insert demo user (password: password123)
INSERT INTO users (name, email, password) VALUES 
('Demo User', 'demo@septalyze.com', 'password123');

-- Insert demo patients
INSERT INTO patients (name, age, gender, patient_id, referring_doctor, notes) VALUES
('John Doe', '45', 'Male', 'P001', 'Dr. Smith', 'Regular checkup'),
('Jane Smith', '32', 'Female', 'P002', 'Dr. Johnson', 'Follow-up scan'),
('Mike Wilson', '28', 'Male', 'P003', 'Dr. Brown', 'Initial consultation');

-- Insert demo scan results
INSERT INTO scan_results (patient_id, filename, predictions, diagnosis, has_concha_bullosa, has_deviation) VALUES
(1, 'scan_001.jpg', '[{"cls":"Normal","conf":0.95}]', 'Normal Nasal Septum', FALSE, FALSE),
(2, 'scan_002.jpg', '[{"cls":"Deviated_Septum_Left","conf":0.87}]', 'Deviated Nasal Septum', FALSE, TRUE),
(3, 'scan_003.jpg', '[{"cls":"CB_Right","conf":0.92}]', 'Concha Bullosa', TRUE, FALSE);
