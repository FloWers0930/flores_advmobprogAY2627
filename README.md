# Lawrenz Dave Z. Flores

## INF233 MWA

## CTADMOBL Advanced Mobile Programming

This repository contains my Flutter laboratory activities for Advanced Mobile Programming. The project focuses on working with APIs, organizing Flutter code using models, services, providers, screens, and reusable widgets, and adding features that make the application more interactive.

---

## Lab Activity 2: Discussion

For Lab Activity 2, I focused on improving the application's user interface and overall user experience. I implemented a search bar that filters the products retrieved from the API locally. I also built a detailed product screen that users can navigate to by tapping on any product card, displaying information like price, description, and ratings. Finally, I added a settings screen with a theme toggle (light/dark mode) managed via `ThemeProvider` to instantly change the app's appearance.

---

## Lab Activity 3: Discussion

For Lab Activity 3, the main goal was to integrate a functional shopping cart feature. I created a dedicated Cart screen to display added products and their calculated subtotals. To keep the UI clean, I changed the Chat navigation from the bottom navigation bar into a FloatingActionButton. For the backend integration, I connected the app to the DummyJSON API's cart endpoints, specifically using the "Get Cart by User ID" and "Add to Cart" endpoints, managing the state dynamically with a `CartProvider`.

---


## Lab Activity 4: Discussion

### 1. API Integration & Architecture Separation
The core objective of Lab Activity 4 was to introduce standard software architecture practices into the Flutter application—specifically separating business logic from UI components.
*   **UserService & CartService:** Instead of executing HTTP requests directly within the UI widgets, API interactions are now encapsulated inside dedicated service classes (`UserService`, `CartService`). This provides a single source of truth for backend communication, making the codebase cleaner, testable, and significantly easier to maintain.
*   **Data Models (`User`):** To avoid working with raw JSON maps (`Map<String, dynamic>`) throughout the app, I created a strictly typed `User` model. This model parses the raw JSON returned from the DummyJSON API via factory constructors (`User.fromJson`). This approach eliminates runtime errors caused by typos in map keys and provides IDE autocomplete support when accessing user properties (e.g., `user.email`, `user.firstName`).

### 2. State Persistence with `shared_preferences`
A major UX requirement for modern mobile applications is persistent authentication—users shouldn't have to log in every time they launch the app.
*   Upon successful authentication with the API, the app receives a response containing the user's unique identifiers and token.
*   I utilized the `shared_preferences` package to write the `userId`, `token`, and other critical session data to the device's local storage.
*   When the application bootstraps (or when checking authentication state), the app reads from `shared_preferences`. If a valid token/userId exists, the user is automatically navigated to the Home screen, bypassing the Login screen entirely.

### 3. Dynamic Data Rendering (Profile & Cart)
The integration of API data and persistent storage enables dynamic, user-specific views.
*   **Profile Screen:** The app retrieves the logged-in user's data and displays their personal information (name, email, profile picture) fetched directly from the DummyJSON `/users/me` or specific user endpoints.
*   **Cart Screen:** The cart functionality relies heavily on the persisted `userId`. When navigating to the cart, the application sends a request to the `/carts/user/{userId}` endpoint. This ensures that the cart data rendered is exclusively tied to the currently authenticated user.

This activity provided a comprehensive understanding of how modern Flutter applications communicate with REST APIs, handle asynchronous operations (`Future`, `async`/`await`), and persist lightweight state locally.

---

## Lab Activity 5: Discussion

The authentication workflow begins in `signin_screen.dart`. Initially implemented with a toggle, it now features a "Smart Login" system. When a user logs in, the app automatically attempts to authenticate with Firebase using `UserService().signIn()`. If the Firebase authentication fails (for example, if the user doesn't exist in Firebase or if the credentials are not formatted as an email), the app seamlessly falls back to DummyJSON via `UserService().loginUser()`. Both paths culminate by setting the `LoginType` enum and calling `saveUserData()`, which persists the response (including tokens) to `SharedPreferences`. The signup flow, handled exclusively in `signup_screen.dart`, only applies to Firebase; it collects user details, calls `UserService().createAccount()`, sets the user's `displayName`, and manually saves additional fields like `age` and `contactNo` to `SharedPreferences` since the project does not currently use Firestore for custom data modeling.

The primary idea behind the `UserService` implementation is to provide a single, unified abstraction layer that hides the underlying differences between the DummyJSON API and Firebase Auth. By wrapping both authentication providers behind common interfaces and maintaining a shared `SharedPreferences` contract for the `User` model, the rest of the app remains largely agnostic to the backend. The `LoginType` enum is crucial here; it allows screens like `profile_screen.dart` to branch behavior—such as rendering action tiles for updating the username, changing passwords, and deleting accounts only for Firebase users—without duplicating the core UI logic or user data fetching.

Implementing Firebase Auth provides tangible benefits over the mocked DummyJSON API in this app. Firebase enables real session and token lifecycle management natively, whereas the DummyJSON API only provided static token responses. Furthermore, Firebase provides built-in mechanisms for secure re-authentication, which we leverage in `UserService().resetPasswordFromCurrentPassword()` and `UserService().deleteAccount()` to securely prompt the user before destructive actions. These native security flows and account management capabilities are something the read-only DummyJSON API fundamentally cannot support, transforming the app's authentication from a simple simulation into a production-ready implementation.
