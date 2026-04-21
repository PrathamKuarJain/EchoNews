# EchoNews

A community-driven news sharing Flutter app where users can sign up, post updates with optional images, interact through likes and comments, and manage their profile.

## Working Prototype

The current codebase is a working prototype with these core flows implemented:

- **Authentication**: Secure sign up, login, and logout using Firebase Authentication.
- **Dynamic Post Feed**: Real-time feed with support for creating, editing, and deleting posts.
- **AI News Hub**: A dedicated dashboard showcasing the app's intelligent features and providing high-speed AI post creation.
- **Enhanced Content Moderation**: Advanced safety filtering combining toxicity, insult, and threat analysis into a single unified risk score.
- **Smart News Analysis**: Automated, multi-step AI pipeline with:
  - **Auto-Categorization**: Intelligent single-word tagging (e.g., #Tech, #Politics).
  - **Authenticity Verification**: Credibility-based scoring with detailed AI reasoning.
- **Premium UX Processing**: High-end visual feedback during AI analysis, featuring progress-driven messaging and backdrop blur effects.
- **Interactive AI Insights**: Tap-to-view mechanism allowing users to see the "Logic" behind AI scores through sleek bottom sheets.
- **Word Tracking**: Built-in word counter and posting limits for concise content creation.
- **Remote Configuration**: Flexible feature toggles to dynamically enable/disable likes, comments, and sharing.
- **Media Support**: Full image upload support for posts and profile pictures, including a high-quality image viewer.
- **Global Engagement**: Real-time interactions through likes and nested comments.
- **Rich Sharing**: Advanced sharing capabilities including image-plus-text sharing across platforms.

## Application Overview And Feature Walkthrough

1. **App Launch (`SplashScreen`)**
- Initializes Firebase and intelligently routes users based on their authentication status.
- Seamless transition to `HomeScreen` or `LoginScreen`.

2. **Authentication (`LoginScreen`, `SignupScreen`)**
- Email-based registration with automatic unique username generation to simplify onboarding.

3. **Home (`HomeScreen`)**
- Responsive navigation system with:
  - **Feed Tab**: Real-time global conversation.
  - **Profile Tab**: Personal dashboard and settings.
  - **Quick Action**: Central button for rapid post creation.

4. **Feed & Interactions (`FeedPage`, `PostCard`)**
- High-performance scrolling list with cached images and lazy loading.
- **Expandable Text**: Clean UI that handles long-form content gracefully.
- **Interactive Viewer**: Tap any image to enter a full-screen, zoomable viewer.
- **Live Counters**: Real-time reflection of likes and comments.

5. **Post Creation (`AddPostPage`)**
- **Word Intelligence**: Live word counter with visual feedback for word limits.
- **AI Shield**: Automatic background scan for offensive content before publication.
- **Image Preview**: Instant visualization of chosen media before uploading.

6. **Profile Management (`ProfilePage`)**
- Personalized space displaying user history and metadata.
- Dynamic profile editing including real-time avatar updates and name changes.

## CRUD Implementation

### Users
- **Create**: Automatic document provisioning in `users/{uid}` at signup.
- **Read**: Real-time profile streams via `userProfileProvider`.
- **Update**: Robust profile synchronization ensuring name changes reflect across all historic posts.

### Posts
- **Create**: Secure publication in `posts/{postId}` with optional media.
- **Read**: Optimized queries with reverse chronological ordering and real-time updates.
- **Update**: Inline editing for post text content.
- **Delete**: One-tap deletion with confirmation dialogs.

### Comments
- **Create**: Instant subcollection updates in `posts/{postId}/comments`.
- **Read**: Dedicated comment streams for isolated real-time updates.
- **Delete**: Cascading logic that updates post-level comment counts.

## Technology Stack

- **Core**: Flutter (Material 3) & Dart
- **Backend**: Firebase (Auth, Firestore)
- **State Management**: Riverpod (Reactive Architecture)
- **AI/Moderation**: Perspective API (Google Jigsaw) & Gemini 2.5 Flash (Google Vertex AI)
- **Image Handling**: ImgBB API, `cached_network_image`, `image_picker`
- **Utilities**: `share_plus`, `uuid`, `timeago`, `shimmer`

## System Architecture

EchoNews follows a scalable, layered architecture:

- **Presentation Layer**: Feature-driven organization (auth, feed, post, profile) using reactive providers.
- **Domain Layer**: Clean data models (`UserModel`, `PostModel`, `CommentModel`) with strict type safety.
- **Data Layer**: Specialized services for Firestore, Authentication, and Cloud Storage.
- **AI Layer**: Moderation service for automated content clearing.

## Database Design

### Firestore Strategy

1. **`users` Collection**: Stores identity and preference data.
2. **`posts` Collection**: Root collection for global reach; contains denormalized author data for performance.
4. **Subcollections**: Nested comments within post documents for logical grouping.

## Setup And Run

### Prerequisites

- Flutter SDK (Dart `>=3.4.3 <4.0.0`)
- A Firebase project with Auth and Firestore enabled.
- Perspective API Key (configured in `ModerationService`).

### Steps

1. **Install dependencies**:
```bash
flutter pub get
```

2. **Configuration**:
- Initialize Firebase via `flutterfire configure`.
- Ensure `lib/firebase_options.dart` is present.

3. **Execute**:
```bash
flutter run
```