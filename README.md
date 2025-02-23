# E-commerce User App

## 📌 Overview
The **E-commerce User App** is a Flutter-based mobile application that provides a seamless online shopping experience. The app integrates **Firebase** for backend services, **Stripe API** for secure payments, and real-time updates to ensure a smooth user experience.

## 🚀 Features
- 🔐 **User Authentication** (Email/Password, Google Sign-In)
- 🛍 **Product Listing with Search & Filtering**
- 🛒 **Cart Management & Wishlist**
- 💳 **Secure Payment via Stripe**
- 📦 **Order Tracking & History**
- 🔔 **Push Notifications for Offers & Order Updates**
- 🌙 **Dark Mode Support**

## 🖥 Tech Stack
- **Frontend:** Flutter, Dart
- **Backend:** Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **Payment Gateway:** Stripe API
- **State Management:** Provider / Riverpod / GetX
- **Other Tools:** Git, REST API, Cloud Messaging

## 📸 Screenshots
# E-commerce User App

## 📌 Overview
The **E-commerce User App** is a Flutter-based mobile application that provides a seamless online shopping experience. The app integrates **Firebase** for backend services, **Stripe API** for secure payments, and real-time updates to ensure a smooth user experience.

## 🚀 Features
- 🔐 **User Authentication** (Email/Password, Google Sign-In)
- 🛍 **Product Listing with Search & Filtering**
- 🛒 **Cart Management & Wishlist**
- 💳 **Secure Payment via Stripe**
- 📦 **Order Tracking & History**
- 🔔 **Push Notifications for Offers & Order Updates**
- 🌙 **Dark Mode Support**

## 🖥 Tech Stack
- **Frontend:** Flutter, Dart
- **Backend:** Firebase (Authentication, Firestore, Storage, Cloud Functions)
- **Payment Gateway:** Stripe API
- **State Management:** Provider / Riverpod / GetX
- **Other Tools:** Git, REST API, Cloud Messaging

## 📸 Screenshots

![](screenshots/Screenshot_20250223_182800.png)
![](screenshots/Screenshot_20250223_182812.png)
![](screenshots/Screenshot_20250223_182843.png)
![](screenshots/Screenshot_20250223_183915.png)
![](screenshots/Screenshot_20250223_183922.png)
![](screenshots/Screenshot_20250223_183926.png)
![](screenshots/Screenshot_20250223_183944.png)
![](screenshots/Screenshot_20250223_184015.png)
![](screenshots/Screenshot_20250223_184042.png)
![](screenshots/Screenshot_20250223_184046.png)
![](screenshots/Screenshot_20250223_184054.png)
## 🛠 Setup & Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/sbfrusho/UTM_clothing_app.git
   cd UTM_clothing_app
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Configure Firebase:
   - Create a Firebase project.
   - Enable Authentication & Firestore.
   - Download and place `google-services.json` (Android) & `GoogleService-Info.plist` (iOS) in respective directories.
4. Run the app:
   ```sh
   flutter run
   ```

## 💡 Challenges & Solutions
### 🔄 Real-time Inventory Management
- **Issue:** Keeping product stock updated in real-time.
- **Solution:** Used Firestore triggers and Cloud Functions to update stock immediately after an order is placed.

### 🛒 Optimizing Checkout Flow
- **Issue:** Users dropping off before completing purchases.
- **Solution:** Reduced steps, pre-filled address info, and added a "Buy Now" option.

### 🔐 Secure Payment Handling
- **Issue:** Ensuring safe and fast payment processing.
- **Solution:** Integrated Stripe API with tokenized transactions and PCI-compliant workflows.

## 📄 License
This project is licensed under the MIT License.

## 👨‍💻 Author
Developed by **Sakib Bin Faruque Rusho**

📧 Contact: [rushocseru28@gmail.com](mailto:rushocseru28@gmail.com)

🔗 GitHub: [sbfrusho](https://github.com/sbfrusho)

Feel free to contribute and report any issues! 🚀
