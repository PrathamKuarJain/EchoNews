# EchoNews: Comprehensive Project Guide

This guide provides a detailed technical and theoretical walkthrough of the EchoNews application. It is designed to help students understand the underlying architecture and present the project effectively to instructors or peers.

---

## 1. System Architecture & Tech Stack

### Theoretical Foundation
EchoNews follows a **Layered Architecture** (Clean Architecture principles) combined with a **Unidirectional Data Flow (UDF)**. This ensures that the UI is always a reflection of the state, making the app predictable and easy to debug.

### Technical Stack
- **Framework:** Flutter (Material 3)
- **Language:** Dart
- **Backend:** Firebase (Authentication & Cloud Firestore)
- **State Management:** Riverpod (Functional & Reactive approach)
- **Storage:** ImgBB API (External Image Hosting)
- **Intelligence:** Google Perspective API (Safety) & Gemini 2.5 Flash (Analysis)

---

## 2. Authentication & Session Management

### How it Works
The app uses a "Splash-to-Home" routing logic. Upon launch, the app initializes Firebase and immediately listens to the authentication state.

### Implementation Details
- **Provider:** `authStateProvider` watches `FirebaseAuth.instance.authStateChanges()`.
- **Username Generation:** When a user signs up with their "Full Name", the system automatically generates a unique lowercase username (e.g., "John Doe" -> "johndoe123") by checking Firestore for existing names.
- **Persistence:** Local persistence is enabled to ensure users stay logged in even after closing the app.

---

## 3. Real-time Post Feed & interactions

### Theoretical Concept
To provide a "Twitter-like" experience, the feed must be real-time and sorted by date. We use **Firestore Streams** instead of one-time fetches.

### Implementation Details
- **Streams:** The `postsProvider` uses a `StreamProvider` that listens to the `posts` collection in Firestore.
- **Complexity Management:**
  - **Likes:** Stored as an array of UIDs inside each post. This allows for simple "Contains" checks to determine if the current user has liked a post without needing complex join queries.
  - **Comments:** Implemented as a sub-collection under each post to ensure scalability.
  - **Cascading Updates:** When a user updates their profile (name or image), a **Firestore Batch Operation** is executed to update all their previous posts simultaneously.

---

## 4. AI-Powered Content Moderation (Safety First)

### Why it’s Used
In a community-driven app, manual moderation is impossible. We integrated **Google’s Perspective API** (by Jigsaw) to automate safety.

### Technical Workflow (Sequential Pipeline)
1. **The Safety Gate (Perspective API):** Before analyzing context, the system scans for toxicity, insults, and threats. These scores are combined into a single "Max Score" for unified filtering.
2. **The Intelligence Phase (Gemini Flash):** Once cleared, the text is passed to Gemini 2.5 Flash to generate a JSON analysis.
3. **Threshold Logic:** If the safety score exceeds **0.6 (60%)**, the post is blocked. Otherwise, it proceeds with categorization and truth verification.
4. **Interactive UI Logs:** In the feed, users can tap AI chips to open a **Modal Bottom Sheet**, revealing the specific reasoning Gemini provided for its scores. This creates a transparent "White Box" AI experience.

---

## 5. Dynamic Configuration & Remote Control

### The "Hidden" Feature
The app includes a specialized mechanism to control features remotely without redeploying the app. This is managed via the `app_config` collection in Firestore.

### Technical Details
- **Toggle System:** The system can enable/disable Reactions, Comments, and Share buttons globally in real-time.
- **Access:** A "backdoor" is built into the `FeedPage`. Tapping the app logo 5 times within a short window opens a configuration panel where these features can be toggled.
- **Provider Pattern:** The `appSettingsProvider` listens to this config. Every widget in the app watches this provider and updates its UI instantly when a setting changes.

---

## 6. Advanced Media Management

### Image Hosting & Compression
Since we avoid storing binary data in databases, we use **ImgBB** for storage.
- **Compression:** Before uploading, images are compressed and converted to **WebP** format using `flutter_image_compress`.
- **Optimization:** If an image is too large (>100KB), the system recursively compresses it until it fits the budget, saving bandwidth and improving load times.

### UX Features
- **Interactive Viewer:** Users can tap any image to enter a full-screen mode using `InteractiveViewer`, which supports pinch-to-zoom and panning.
- **Cached Images:** Uses `CachedNetworkImage` to prevent repeated downloads of the same image.

---

## 7. Intelligent Post Analysis (Word Tracking)

### Feature Implementation (Word Tracking)
The post creation screen (`AddPostPage`) features a real-time word analyzer.
- **Logic:** It uses Regular Expressions (`RegExp(r'\s+')`) to count words as the user types.
- **Visual Feedback:** A character limit of 500 words is enforced. The counter turns red and the "Post" button disables if the limit is exceeded.

### Modern UX: Glassmorphism Blur
During the multi-stage AI analysis, the `AddPostPage` implements a high-quality **Backdrop Blur** effect.
- **BackdropFilter:** Uses `ImageFilter.blur` to create a "locked" processing state that keeps the focus entirely on the AI progress messages.
- **Dynamic Messaging:** The UI cycles through descriptive states (*"Scanning..."*, *"Verifying..."*) to maintain user engagement during API latency.

---

## 8. Summary for Presentation

### Key Technical Achievements to Showcase:
1.  **Reactive State Management:** Demonstrating how any change in Firestore is instantly reflected across all screens using Riverpod.
2.  **API Integration:** Successful communication with multiple RESTful APIs (ImgBB, Perspective API).
3.  **Data Denormalization:** Using array-based likes and sub-collections to optimize read speeds in a NoSQL environment.
4.  **UI/UX Polish:** Use of Shimmer loading effects, WebP compression for speed, and interactive media viewers.
5.  **Batched Operations:** Handling data consistency (Profile Sync) using high-performance atomic batches.
