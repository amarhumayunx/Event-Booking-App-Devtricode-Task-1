# Firebase में Data Storage Flow (اردو/हिंदी)

## 📊 Complete Data Flow Diagram

```
User Input (UI)
    ↓
TicketBookingScreen
    ↓
PaymentScreen
    ↓
ApiService.createBooking()
    ↓
FirebaseService.createBooking()
    ↓
Firebase Realtime Database (/bookings)
    ↓
Payment Data
    ↓
ApiService.createPayment()
    ↓
FirebaseService.createPayment()
    ↓
Firebase Realtime Database (/payments)
```

---

## 🔄 Step-by-Step Flow (تفصیلی فلو)

### **Step 1: User Input (یوزر ان پٹ)**
**File:** `lib/screens/ticket_booking_screen.dart`

- User ticket booking screen پر form fill کرتا ہے:
  - Full Name
  - Email
  - Phone Number
  - Number of Tickets (increment/decrement buttons se)

- User "Confirm Booking" button press کرتا ہے
- Data `PaymentScreen` کو pass ہوتا ہے

---

### **Step 2: Payment Processing (پیمنٹ پروسیسنگ)**
**File:** `lib/screens/payment_screen.dart`

**Function:** `_processPayment()` (line 190)

```dart
// Step 2.1: Booking object create hota hai
final booking = _createBooking();  // Line 203

// Step 2.2: Firebase mein booking save hoti hai
final createdBooking = await ApiService.createBooking(booking);  // Line 204

// Step 2.3: Payment object create hota hai (booking ID ke saath)
final payment = _createPayment(createdBooking.id!);  // Line 210

// Step 2.4: Firebase mein payment save hoti hai
await ApiService.createPayment(payment);  // Line 211
```

---

### **Step 3: API Service Layer (API سروس لیئر)**
**File:** `lib/services/api_service.dart`

**Function:** `createBooking()` (line 43)
```dart
static Future<Booking> createBooking(Booking booking) async {
  return await FirebaseService.createBooking(booking);  // Line 45
}
```

**Function:** `createPayment()` (line 79)
```dart
static Future<Payment> createPayment(Payment payment) async {
  return await FirebaseService.createPayment(payment);  // Line 81
}
```

**Note:** API Service sirf wrapper hai jo FirebaseService ko call karta hai.

---

### **Step 4: Firebase Service Layer (فائربیس سروس لیئر)**
**File:** `lib/services/firebase_service.dart`

#### **4.1: Booking Create (بکنگ بنانا)**

**Function:** `createBooking()` (line 11)

```dart
static Future<Booking> createBooking(Booking booking) async {
  // Step 4.1.1: Booking object ko JSON mein convert karo
  final bookingData = booking.toJson();  // Line 13
  
  // Step 4.1.2: ID remove karo (Firebase khud generate karega)
  bookingData.remove('id');  // Line 15
  
  // Step 4.1.3: Firebase Database reference get karo
  final bookingsRef = _database.child(bookingsPath);  // Line 17
  // bookingsPath = 'bookings'
  
  // Step 4.1.4: Naya unique key generate karo aur data save karo
  final newBookingRef = bookingsRef.push();  // Line 18
  await newBookingRef.set(bookingData);  // Line 19
  
  // Step 4.1.5: Saved data ko fetch karo aur ID add karo
  final snapshot = await newBookingRef.get();  // Line 22
  final data = Map<String, dynamic>.from(snapshot.value as Map);
  data['id'] = newBookingRef.key;  // Line 25
  
  // Step 4.1.6: Booking object return karo
  return Booking.fromJson(data);  // Line 26
}
```

**Firebase Structure:**
```
/bookings
  └── {auto-generated-key-1}
      ├── eventId: "1"
      ├── eventTitle: "Concert"
      ├── eventDate: "2024-01-15"
      ├── eventTime: "7:00 PM"
      ├── eventLocation: "Lahore"
      ├── numberOfTickets: 2
      ├── totalPrice: 2000
      ├── userName: "John Doe"
      ├── userEmail: "john@example.com"
      ├── userPhone: "1234567890"
      └── bookingDate: "2024-01-10T10:30:00.000Z"
```

#### **4.2: Payment Create (پیمنٹ بنانا)**

**Function:** `createPayment()` (line 102)

```dart
static Future<Payment> createPayment(Payment payment) async {
  // Step 4.2.1: Payment object ko JSON mein convert karo
  final paymentData = payment.toJson();  // Line 104
  
  // Step 4.2.2: ID remove karo
  paymentData.remove('id');  // Line 106
  
  // Step 4.2.3: Firebase Database reference get karo
  final paymentsRef = _database.child(paymentsPath);  // Line 108
  // paymentsPath = 'payments'
  
  // Step 4.2.4: Naya unique key generate karo aur data save karo
  final newPaymentRef = paymentsRef.push();  // Line 109
  await newPaymentRef.set(paymentData);  // Line 110
  
  // Step 4.2.5: Saved data ko fetch karo aur ID add karo
  final snapshot = await newPaymentRef.get();  // Line 113
  final data = Map<String, dynamic>.from(snapshot.value as Map);
  data['id'] = newPaymentRef.key;  // Line 116
  
  // Step 4.2.6: Payment object return karo
  return Payment.fromJson(data);  // Line 117
}
```

**Firebase Structure:**
```
/payments
  └── {auto-generated-key-1}
      ├── bookingId: "{booking-id}"
      ├── eventId: "1"
      ├── eventName: "Concert"
      ├── amount: "2000"
      ├── currency: "PKR"
      ├── paymentMethod: "VISA"
      ├── transactionId: "TXN1234567890"
      ├── paymentStatus: "success"
      ├── paymentDate: "2024-01-10T10:30:00.000Z"
      └── isTestPayment: true
```

---

## 📦 Data Models (ڈیٹا ماڈل)

### **Booking Model**
**File:** `lib/models/booking.dart`

**Fields:**
- `id` (optional) - Firebase auto-generate karta hai
- `eventId` - Event ka ID
- `eventTitle` - Event ka naam
- `eventDate` - Event ki date
- `eventTime` - Event ka time
- `eventLocation` - Event ki location
- `numberOfTickets` - Kitne tickets
- `totalPrice` - Total amount
- `userName` - User ka naam
- `userEmail` - User ka email
- `userPhone` - User ka phone
- `bookingDate` - Booking ki date/time

### **Payment Model**
**File:** `lib/models/payment.dart`

**Fields:**
- `id` (optional) - Firebase auto-generate karta hai
- `bookingId` - Related booking ka ID
- `eventId` - Event ka ID
- `eventName` - Event ka naam
- `amount` - Payment amount
- `currency` - Currency (PKR)
- `paymentMethod` - Payment method (VISA)
- `transactionId` - Unique transaction ID
- `paymentStatus` - Status (success/failed)
- `paymentDate` - Payment ki date/time
- `isTestPayment` - Test payment hai ya nahi

---

## 🔍 Data Retrieval (ڈیٹا حاصل کرنا)

### **Get All Bookings**
**File:** `lib/services/firebase_service.dart`
**Function:** `getBookings()` (line 36)

```dart
// Firebase se saari bookings fetch karo
final snapshot = await _database.child(bookingsPath).get();

// Har booking ko parse karo aur list mein add karo
// Sort by bookingDate (newest first)
```

**Usage:**
- `BookingHistoryViewModel` isse use karta hai
- User ki bookings filter karke dikhata hai (email ke basis par)

---

## 🗑️ Data Deletion (ڈیٹا ڈیلیٹ کرنا)

### **Delete Single Booking**
**Function:** `deleteBooking(String bookingId)` (line 70)

```dart
await _database.child(bookingsPath).child(bookingId).remove();
```

### **Delete All Bookings**
**Function:** `deleteAllBookings()` (line 80)

```dart
await _database.child(bookingsPath).remove();
```

---

## 🔑 Key Points (اہم نکات)

1. **Firebase Realtime Database** use ho raha hai (Firestore nahi)
2. **Auto-generated Keys:** Firebase `push()` method se unique keys generate karta hai
3. **Two Main Paths:**
   - `/bookings` - Saari bookings
   - `/payments` - Saari payments
4. **Data Flow:**
   - UI → ViewModel → API Service → Firebase Service → Firebase Database
5. **Error Handling:** Har step par try-catch blocks hain
6. **ID Management:** Firebase auto-generate karta hai, phir hum manually add karte hain response mein

---

## 📱 Complete User Journey

1. User event select karta hai
2. Ticket booking screen par details fill karta hai
3. Payment screen par card details enter karta hai
4. "Pay Now" button press karta hai
5. **Booking Firebase mein save hoti hai** ✅
6. **Payment Firebase mein save hoti hai** ✅
7. Confirmation screen dikhata hai

---

## 🛠️ Technical Details

**Firebase Package:** `firebase_database`
**Database Reference:** `FirebaseDatabase.instance.ref()`
**Method:** `push()` - Auto-generate unique key
**Method:** `set()` - Data save karna
**Method:** `get()` - Data fetch karna
**Method:** `remove()` - Data delete karna

---

## 📝 Summary (خلاصہ)

**Data Firebase mein is tarah store hota hai:**

1. **Booking Data:**
   - Path: `/bookings/{auto-generated-key}`
   - Method: `FirebaseService.createBooking()`
   - Trigger: Payment screen se "Pay Now" button

2. **Payment Data:**
   - Path: `/payments/{auto-generated-key}`
   - Method: `FirebaseService.createPayment()`
   - Trigger: Booking create hone ke baad

**Flow:** UI → API Service → Firebase Service → Firebase Realtime Database

