# Lawrenz Dave Z. Flores

## INF233

## CTADMOBL Advance Mobile Programming

A Flutter project focused on API integration, authentication, and displaying user data in a mobile application.

## Lab Activity 4

This activity focuses on connecting the Flutter app to an API and organizing the project using services, models, and screens. I implemented persistent authentication using `shared_preferences`, created a `UserService` for handling API requests, and added a `User` model for managing user information. The profile screen displays the saved user data, while the cart uses the user's `userId` to show the correct cart information.

## Discussion

The `UserService`, `User` model, and screens work together to handle and display data from the API. The service handles API requests and authentication, the model organizes the user data, and the screens display the information to the user.

Using `shared_preferences` allows the app to remember the logged-in user even after restarting the application. The saved `userId` is also used to load the user's cart, making sure the correct cart data is displayed for each user.

This activity helped me understand how API integration, authentication, models, services, and screens work together in a Flutter application.
