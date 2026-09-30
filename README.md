# Lawrenz Dave Z. Flores

## INF233

## CTADMOBL Advance Mobile Programming

A Flutter project focused on API integration, authentication, and displaying user data in a mobile application.

## Lab Activity 4

This activity focuses on connecting the Flutter app to an API and organizing the project using services, models, and screens. I implemented persistent authentication using `shared_preferences`, created a `UserService` for handling API requests, and added a `User` model for managing user information. The profile screen displays the saved user data, while the cart uses the user's `userId` to show the correct cart information.

## Discussion

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
