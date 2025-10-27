# 🏥 Septalyze PHP Backend API

Professional medical CT scan analysis backend for the Septalyze iOS app.

---

## 📋 Requirements

- PHP 7.4 or higher
- MySQL 5.7 or higher
- Apache with mod_rewrite enabled
- PHP extensions:
  - mysqli
  - gd (for image processing)
  - json
  - mbstring

---

## 🚀 Installation

### Step 1: Setup Database

1. Open phpMyAdmin or MySQL command line
2. Run the SQL file:
```bash
mysql -u root -p < setup.sql
```

Or import `setup.sql` through phpMyAdmin

### Step 2: Configure Database Connection

Edit `config.php` and update these lines:

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');          // Your MySQL username
define('DB_PASS', '');              // Your MySQL password
define('DB_NAME', 'septalyze');
```

### Step 3: Deploy to Web Server

**Option A: Local Development (XAMPP/MAMP)**

1. Copy the `backend` folder to your web server directory:
   - XAMPP: `/Applications/XAMPP/htdocs/backend/`
   - MAMP: `/Applications/MAMP/htdocs/backend/`

2. Start Apache and MySQL

3. Access: `http://localhost/backend/health`

**Option B: Production Server**

1. Upload files to your server (e.g., `/var/www/html/backend/`)
2. Set proper permissions:
```bash
chmod 755 backend/
chmod 777 backend/uploads/
chmod 777 backend/logs/
```

3. Ensure `.htaccess` is enabled in Apache config

### Step 4: Test the API

Visit: `http://your-server/backend/health`

You should see:
```json
{
    "status": "healthy",
    "service": "Septalyze API",
    "version": "1.0.0"
}
```

---

## 📱 Update iOS App

Update the API URL in your iOS app:

**File:** `ViewModels/UploadViewModel.swift`

```swift
// Change this line:
private let baseURL = "http://localhost:5000"

// To your server URL:
private let baseURL = "http://your-server.com/backend"
// Or for local testing:
private let baseURL = "http://192.168.1.100/backend"  // Your Mac's IP
```

---

## 🔌 API Endpoints

### Health Check
```
GET /backend/health
```

### Authentication

**Login**
```
POST /backend/auth/login
Body: {"email": "demo@septalyze.com", "password": "password123"}
```

**Signup**
```
POST /backend/auth/signup
Body: {"name": "John Doe", "email": "john@example.com", "password": "password123"}
```

**Logout**
```
POST /backend/auth/logout
```

### CT Scan Analysis

**Analyze Image**
```
POST /backend/analyze
Content-Type: multipart/form-data
Body: image file
```

### Patients

**Get All Patients**
```
GET /backend/patients
```

**Create Patient**
```
POST /backend/patients
Body: {
    "name": "John Doe",
    "age": "45",
    "gender": "Male",
    "patientID": "P001",
    "referringDoctor": "Dr. Smith",
    "notes": "Regular checkup"
}
```

### History

**Get Scan History**
```
GET /backend/history
```

### Reports

**Get All Reports**
```
GET /backend/reports
```

**Get Single Report**
```
GET /backend/reports?id=1
```

---

## 🧪 Testing

### Test with cURL

**Health Check:**
```bash
curl http://localhost/backend/health
```

**Login:**
```bash
curl -X POST http://localhost/backend/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@septalyze.com","password":"password123"}'
```

**Upload Image:**
```bash
curl -X POST http://localhost/backend/analyze \
  -F "image=@/path/to/scan.jpg"
```

---

## 📂 File Structure

```
backend/
├── index.php           # Main API router
├── config.php          # Configuration
├── database.php        # Database functions
├── auth.php            # Authentication functions
├── .htaccess           # Apache configuration
├── setup.sql           # Database setup
├── README.md           # This file
├── uploads/            # Uploaded images
├── logs/               # Error logs
└── temp/               # Temporary files
```

---

## 🔐 Security

### Change These in Production:

1. **JWT Secret** (`config.php`):
```php
define('JWT_SECRET', 'your_strong_random_secret_here');
```

2. **API Key** (`config.php`):
```php
define('API_KEY', 'your_api_key_here');
```

3. **Database Password** (`config.php`):
```php
define('DB_PASS', 'strong_password_here');
```

### Recommended:
- Use HTTPS in production
- Enable firewall
- Regular backups
- Update PHP regularly

---

## 🐛 Troubleshooting

### "Database connection failed"
- Check MySQL is running
- Verify credentials in `config.php`
- Ensure database exists

### "404 Not Found"
- Check `.htaccess` is in place
- Ensure mod_rewrite is enabled
- Verify file permissions

### "Failed to save image"
- Check `uploads/` directory exists
- Verify write permissions: `chmod 777 uploads/`

### "CORS errors"
- Check `.htaccess` CORS headers
- Verify Apache headers module is enabled

---

## 📊 Demo Credentials

**Email:** demo@septalyze.com  
**Password:** password123

---

## 🎯 Next Steps

1. ✅ Setup database
2. ✅ Configure `config.php`
3. ✅ Deploy to web server
4. ✅ Test API endpoints
5. ✅ Update iOS app URL
6. ✅ Test complete flow

---

## 📞 Support

For issues or questions, check the logs:
- Error log: `backend/logs/error.log`
- Apache log: `/var/log/apache2/error.log`

---

**Your Septalyze PHP backend is ready!** 🎉
