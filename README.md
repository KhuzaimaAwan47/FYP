# UnityGig

A Flutter app Empowering Freshers/Beginners Developers through interactive real-life projects.

## 📖 About the Project

UnityGig is a Flutter-based mobile application designed to bridge the gap between freshers/beginner developers and clients by simulating a freelance marketplace.
Users can sign up as Freelancers or Clients, collaborate on real‑world projects, bid, chat, and build portfolios.
The goal is to provide hands‑on experience, enhance skills, and foster community learning.

## ✨ Features

- **Authentication**: Users register on App as a `freelancer` or `client`.
  
- **Projects**: Clients and freelancers both can post projects.
  
- **Groups**: Freelancers can create groups and join others, but clients only able to join them.
  
- **Biiding**: Freelancers can bid on available projects.
  
- **ProjectOffers**: Both Freelancers and clients can offer a project directly to a user.
  
- **Chat**: Freelancers and clients both can chat with eachother.
  
- **GroupChat**: Freelancers and client can be able to chat in groups.
  
- **Dashboard**: Both Freelancers and Client and have different dashboards.
  
- **Feed**: Both Freelancers and Clients can post pics and videos, also able to react and comment on other posts.
  
- **AdvancedSearch**: Both Freelancers and Clients can search freelancers by `hourly rate`, projects by `budget`, and groups by `group members`.


## 🔧 Installation & Setup

1. **⚙️Prerequisites**:
    1. [Flutter SDK](https://flutter.dev/docs/get-started/install ) (v3.0+)
    2. [Dart SDK](https://dart.dev/get-dart ) (v3.0+)
    3. Firebase Project with:
       - Authentication enabled
       - Cloud Firestore database
       - Firebase Storage bucket

2. **Clone the repository**:
   ```bash
   git clone https://github.com/KhuzaimaAwan47/FYP.git
   cd FYP

3. **Packages used**
    - Authentication : firebase_auth
    -  UI/UX : custom_navigation_bar, badges, flutter_rating_bar, shimmer, auto_size_text
    -  Media Handling : image_picker, image_cropper, flutter_image_compress, video_player
    -  Cloud Integration : firebase_core, cloud_firestore, firebase_storage
    -  Utilities : http (API calls), intl (localization), visibility_detector (feed engagement)

4. **Install Dependencies**
   ```bash
   flutter pub get
   
5. **Configure Firebase**
    - Create a Firebase project in the Firebase Console .
    - Enable Authentication (Email/Password provider).
    - Set up Cloud Firestore and Storage.
    - Add platform-specific config files:
    - Android : app/src/main/res/values/google-services.json
    - iOS : ios/Runner/GoogleService-Info.plist
    - Update firebase_options.dart with your Firebase project credentials.

6. **Run the App**
   ```bash
   flutter run

## 📁 Project Structure
1.    
    ```bash
   lib/
   ├── main.dart            # App entry point
   ├── widget_tree.dart     # Check login status
   ├── Splash_page.dart     # App Splash Screen
   ├── auth/                # login and signup pages
   ├── pages/               # UI screens by feature
   ├── widgets/             # Reusable components              
   └── utils/               # Helpers (formatters, snackabrs)

   assets/
   ├── images/              # Icons & static images

## 🛠️ Technologies Used

- **Flutter**: UI framework for building cross-platform applications.
- **Dart**: Programming language used for Flutter development.
- **Firebase**: Backend-as-a-Service (BaaS) for:
  - **Authentication**: Email/password, Google, and social logins.
  - **Cloud Firestore**: Real-time NoSQL database for projects, chats, and groups.
  - **Firebase Storage**: Secure media storage for images/videos.
  - **Cloud Functions**: (Optional) For notifications and background tasks.

## 🤝 Contributing
Contributions are welcome! Please follow these steps:

- Fork the repo
- Create a feature branch (git checkout -b feature/new-feature)
- Commit your changes (git commit -m 'Add feature')
- Push to the branch (git push origin feature/new-feature)
- Open a Pull Request



    
 
  






