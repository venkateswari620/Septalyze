# 🚀 Septalyze PHP Backend - Quick Setup Guide

## ✅ All PHP Files Created!

Your complete PHP backend is ready in: `/Users/sail/Desktop/cb/backend/`

---

## 📂 Files Created:

1. ✅ **index.php** - Main API router with all endpoints
2. ✅ **config.php** - Configuration (database, JWT, uploads)
3. ✅ **database.php** - Database connection and functions
4. ✅ **auth.php** - Authentication (login, signup, JWT)
5. ✅ **.htaccess** - Apache configuration (CORS, routing)
6. ✅ **setup.sql** - Database setup with demo data
7. ✅ **README.md** - Complete documentation

---

## 🎯 Quick Setup (3 Steps):

### Step 1: Install MAMP (if not installed)

Download from: https://www.mamp.info/en/downloads/

Or use XAMPP: https://www.apachefriends.org/

### Step 2: Setup Database

1. **Start MAMP** → Click "Start"
2. **Open phpMyAdmin**: http://localhost:8888/phpMyAdmin
3. **Import Database**:
   - Click "Import" tab
   - Choose file: `/Users/sail/Desktop/cb/backend/setup.sql`
   - Click "Go"

### Step 3: Deploy Backend

**Copy backend folder to MAMP:**

```bash
cp -r /Users/sail/Desktop/cb/backend /Applications/MAMP/htdocs/
```

**Test it works:**

Open browser: http://localhost:8888/backend/health

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

### Find Your Mac's IP Address:

```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

Example output: `inet 192.168.1.100`

### Update UploadViewModel.swift:

**File:** `/Users/sail/Desktop/NS/ViewModels/UploadViewModel.swift`

Change:
```swift
private let baseURL = "http://localhost:5000"
```

To:
```swift
private let baseURL = "http://192.168.1.100:8888/backend"
// Replace 192.168.1.100 with YOUR Mac's IP
```

---

## 🧪 Test the Complete Flow:

### 1. Test Backend API:

**Health Check:**
```bash
curl http://localhost:8888/backend/health
```

**Login:**
```bash
curl -X POST http://localhost:8888/backend/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"demo@septalyze.com","password":"password123"}'
```

### 2. Test iOS App:

1. **Build & Run** app in Xcode
2. **Login** with:
   - Email: demo@septalyze.com
   - Password: password123
3. **Upload CT scan**
4. **See results!**

---

## 🔧 Configuration

### Database Settings (config.php):

```php
define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', 'root');  // MAMP default password
define('DB_NAME', 'septalyze');
```

### MAMP Ports:
- Apache: 8888
- MySQL: 8889

---

## 📊 Demo Data Included:

### Users:
- **Email:** demo@septalyze.com
- **Password:** password123

### Patients:
- John Doe (P001)
- Jane Smith (P002)
- Mike Wilson (P003)

### Scan Results:
- 3 demo scans with different diagnoses

---

## 🎯 API Endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/backend/health` | GET | Health check |
| `/backend/auth/login` | POST | User login |
| `/backend/auth/signup` | POST | User registration |
| `/backend/analyze` | POST | Analyze CT scan |
| `/backend/patients` | GET/POST | Manage patients |
| `/backend/history` | GET | Get scan history |
| `/backend/reports` | GET | Get reports |

---

## ⚠️ Troubleshooting:

### "Database connection failed"
→ Check MAMP MySQL is running
→ Verify password in `config.php` (default: 'root')

### "404 Not Found"
→ Ensure backend folder is in `/Applications/MAMP/htdocs/`
→ Check MAMP Apache is running

### "CORS error in iOS app"
→ Use your Mac's IP, not localhost
→ Check `.htaccess` file exists

### "Can't connect from iPhone"
→ Ensure iPhone and Mac are on same WiFi
→ Use Mac's IP address, not localhost

---

## 📱 Complete Setup Checklist:

- [ ] Install MAMP
- [ ] Start MAMP (Apache + MySQL)
- [ ] Import setup.sql in phpMyAdmin
- [ ] Copy backend folder to htdocs
- [ ] Test http://localhost:8888/backend/health
- [ ] Find Mac's IP address
- [ ] Update UploadViewModel.swift with IP
- [ ] Build & run iOS app
- [ ] Login with demo credentials
- [ ] Upload CT scan
- [ ] See results!

---

## 🎉 You're Ready!

Your Septalyze app now has a complete PHP backend with:
- ✅ User authentication
- ✅ Patient management
- ✅ CT scan analysis
- ✅ Scan history
- ✅ PDF reports
- ✅ Database storage

**Start MAMP and test your app!** 🚀
