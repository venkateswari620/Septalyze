<?php
/**
 * Test file to check XAMPP and database connection
 */

echo "<h1>Septalyze Backend Test</h1>";

// Test 1: PHP is working
echo "<h2>✅ PHP is working!</h2>";
echo "PHP Version: " . phpversion() . "<br>";

// Test 2: Check required extensions
echo "<h2>PHP Extensions:</h2>";
$required = ['mysqli', 'json', 'mbstring'];
foreach ($required as $ext) {
    $status = extension_loaded($ext) ? '✅' : '❌';
    echo "$status $ext<br>";
}

// Test 3: Database connection
echo "<h2>Database Connection:</h2>";
require_once 'config.php';

$db = new mysqli(DB_HOST, DB_USER, DB_PASS);

if ($db->connect_error) {
    echo "❌ Connection failed: " . $db->connect_error . "<br>";
    echo "<p><strong>Fix:</strong> Make sure MySQL is running in XAMPP</p>";
} else {
    echo "✅ Connected to MySQL successfully!<br>";
    
    // Check if database exists
    $result = $db->query("SHOW DATABASES LIKE 'septalyze'");
    if ($result->num_rows > 0) {
        echo "✅ Database 'septalyze' exists<br>";
        
        // Select database and check tables
        $db->select_db('septalyze');
        $tables = $db->query("SHOW TABLES");
        echo "✅ Tables found: " . $tables->num_rows . "<br>";
        
        while ($row = $tables->fetch_array()) {
            echo "  - " . $row[0] . "<br>";
        }
    } else {
        echo "❌ Database 'septalyze' not found<br>";
        echo "<p><strong>Fix:</strong> Import setup.sql in phpMyAdmin</p>";
        echo "<p>1. Go to <a href='http://localhost/phpmyadmin'>phpMyAdmin</a></p>";
        echo "<p>2. Click 'Import' tab</p>";
        echo "<p>3. Choose file: /Applications/XAMPP/htdocs/backend/setup.sql</p>";
        echo "<p>4. Click 'Go'</p>";
    }
}

// Test 4: Check directories
echo "<h2>Directory Permissions:</h2>";
$dirs = ['uploads', 'logs', 'temp'];
foreach ($dirs as $dir) {
    $path = __DIR__ . '/' . $dir;
    if (is_dir($path) && is_writable($path)) {
        echo "✅ $dir/ (writable)<br>";
    } elseif (is_dir($path)) {
        echo "⚠️ $dir/ (not writable)<br>";
    } else {
        echo "❌ $dir/ (not found)<br>";
    }
}

// Test 5: API Health endpoint
echo "<h2>API Test:</h2>";
echo "<p>Test API: <a href='http://localhost/backend/health'>http://localhost/backend/health</a></p>";

echo "<hr>";
echo "<h2>Next Steps:</h2>";
echo "<ol>";
echo "<li>If MySQL connection failed: Start MySQL in XAMPP Control Panel</li>";
echo "<li>If database not found: Import setup.sql in phpMyAdmin</li>";
echo "<li>Test API: <a href='http://localhost/backend/health'>Click here</a></li>";
echo "<li>Update iOS app with: <code>http://YOUR_MAC_IP/backend</code></li>";
echo "</ol>";
?>
