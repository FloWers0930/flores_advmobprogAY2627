# Lawrenz Dave Z. Flores

## INF233 MWA

## CTADMOBL Advanced Mobile Programming

This repository contains my Flutter laboratory activities for Advanced Mobile Programming. The project focuses on working with APIs, organizing Flutter code using models, services, providers, screens, and reusable widgets, and adding features that make the application more interactive.

---

## Lab Activity 2: Discussion

### Implemented Enhancements

For Lab Activity 2, I improved the product application by adding search, a product details screen, and a separate settings page.

**Enhancement 1 - Search Bar**

I added a search bar above the product list in `ProductScreen`. It allows the user to search for products based on their title, brand, or category.

The products are already loaded from the API, so the search only filters the existing list instead of sending another API request every time the user types something. This makes the search faster and simpler.

**Enhancement 2 - Product Details Screen**

I made each product card clickable using `InkWell`. When a product is selected, the application opens `ProductDetailScreen` using `Navigator.push()`.

The selected `Product` object is passed directly to the details screen. The screen then shows information such as the product name, price, category, rating, description, availability, tags, specifications, return policy, and reviews.

I also customized the products to follow the NU Bulldogs Exchange theme.

**Enhancement 3 - Settings Page**

I moved the dark and light mode switch into its own `SettingsScreen`.

The Settings page can be opened using the settings icon in the Home screen. `ThemeProvider` stores the current theme setting and uses `notifyListeners()` whenever the user changes it.

Because the application listens to `ThemeProvider`, the theme changes immediately throughout the app.

### Bulldog Exchange / NU Manila Theme

Instead of showing only generic products, I customized the project to look like a Bulldog Exchange application for National University Manila.

The sample products include NU shirts, ID lace, hoodie, varsity socks, basketball jersey, Bulldog pin, and cap.

The product images are saved inside:

`assets/images/products/`

I also used Philippine peso (`₱`) prices and campus pickup information to make the application fit the NU Bulldogs Exchange concept.

### How the Model, Service, and Screen Work Together

The project separates the API data, networking logic, and user interface into different parts.

`ProductService` is responsible for requesting product data from the API.

It sends a GET request to the product endpoint and processes the JSON response.

`Product.fromJson()` converts the JSON data into a `Product` object. This means the UI does not need to manually read JSON values.

`ProductScreen` calls `ProductService().getAllProducts()` and uses `FutureBuilder` to wait for the response.

While the request is still loading, the application displays a loading indicator. If the request fails, an error message is displayed. If it succeeds, the product cards are shown.

When a product is selected, the same `Product` object is passed to `ProductDetailScreen`.

The general flow is:

`REST API -> ProductService -> Product.fromJson() -> ProductScreen -> ProductDetailScreen`

### Design Pattern Used

For this activity, I used separation of concerns.

Instead of putting everything inside one Dart file, the project separates responsibilities into models, services, providers, screens, and widgets.

The model handles the structure of the data.

The service handles API requests.

The screens handle what the user sees and interacts with.

Provider is also used for shared application state. For example, `ThemeProvider` manages the dark and light mode of the application.

This structure makes the code easier to read, maintain, and update.

### Source-Code Comments

I added comments in the source code showing where each required enhancement was implemented.

`Enhancement 1:` is used for the search feature.

`Enhancement 2:` is used for the product details feature.

`Enhancement 3:` is used for the Settings page and theme feature.

---

## Lab Activity 3: Discussion

### Implemented Enhancements

For Lab Activity 3, I extended the previous project by adding a shopping cart system, reusing the existing product details screen, and changing the Chat navigation into a FloatingActionButton.

**Enhancement 1 - Cart Screen and Reusable Detail Screen**

I created a new `CartScreen` that displays the products inside the cart.

The Cart screen shows the product image, title, price, quantity, subtotal, total number of products, total quantity, and the total cart amount.

Each cart item is also clickable.

When I tap a product inside the cart, the application opens the same `ProductDetailScreen` that is already used in `ProductScreen`.

I reused the existing details screen instead of creating another details page just for the cart. This keeps the project cleaner and avoids repeating the same UI code.

**Enhancement 2 - Chat FloatingActionButton**

In the previous activity, Chat was part of the bottom navigation.

For Lab Activity 3, I removed Chat from the bottom navigation and changed it into a `FloatingActionButton`.

The main navigation now contains Shop, Cart, and Profile.

The Chat button appears while the user is on the Shop or Profile screen. When the Cart screen is selected, the Chat FloatingActionButton is hidden as required by the activity.

**Enhancement 3 - Cart by User ID and Add to Cart**

I integrated the DummyJSON Cart API using a specific user ID.

`CartService.getCartByUserId()` sends a GET request to:

`/carts/user/{userId}`

This allows the application to load the cart that belongs to a particular user.

I also added an Add to Cart button inside `ProductDetailScreen`.

The user can choose a quantity and press Add to Cart. The product ID, quantity, and user ID are passed to `CartProvider`, which then calls `CartService.addToCart()`.

The service sends a POST request to:

`/carts/add`

DummyJSON only simulates adding a cart and does not permanently save the changes. Because of this, I also used `CartProvider` to keep the added Bulldog Exchange products in the application's local state while the app is running.

This allows the product to immediately appear in the Cart screen while still demonstrating the required API request.

### How the Cart Model, Service, Provider, and Screen Work Together

The Cart feature follows the same organized structure used by the product feature.

The `Cart` model represents the whole cart. It stores values such as the cart ID, user ID, products, totals, total products, and total quantity.

The `CartProduct` model represents each product inside the cart. It stores the product ID, title, price, quantity, discount, subtotal, and thumbnail.

`CartService` handles the API requests for carts. It contains methods for getting a cart by user ID, getting a cart by cart ID, and adding products to a cart.

`CartProvider` is used between the service and the screens. It stores the current cart and manages changes such as adding products, increasing quantity, decreasing quantity, removing products, and recalculating totals.

Whenever the cart changes, `CartProvider` calls `notifyListeners()` so the Cart screen can automatically update.

`CartScreen` listens to `CartProvider` and displays the latest cart information.

When a cart item is tapped, the selected product is passed to the existing `ProductDetailScreen`.

The cart data flow is:

`Cart API -> CartService -> Cart.fromJson() -> CartProvider -> CartScreen -> ProductDetailScreen`

The Add to Cart flow is:

`ProductDetailScreen -> CartProvider -> CartService -> /carts/add -> CartProvider -> CartScreen`

### Using getById in the Cart Endpoint

I also added a `getCartById()` method inside `CartService`.

The method receives a cart ID:

`getCartById(int cartId)`

It then sends a GET request to:

`$host/carts/$cartId`

For example, if the cart ID is `1`, the request becomes:

`https://dummyjson.com/carts/1`

After the API returns the response, `jsonDecode()` converts the JSON into a Dart map.

The map is then passed to `Cart.fromJson()` to create a `Cart` object that can be used by the application.

The difference between `getCartById()` and `getCartByUserId()` is simple.

`getCartById()` searches for one specific cart using its cart ID.

`getCartByUserId()` searches for the carts that belong to a specific user.

For this activity, I used the user ID endpoint to display only one user's cart.

### Updated Design Pattern

Lab Activity 3 keeps the same organized structure from Lab Activity 2 but adds another Provider for the cart.

The project now contains several layers:

- **Model Layer** - contains `Product`, `Cart`, and `CartProduct`, which represent the application's data.
- **Service Layer** - contains `ProductService` and `CartService`, which handle API communication.
- **Provider Layer** - contains `ThemeProvider` for the theme and `CartProvider` for cart state.
- **Screen Layer** - contains screens such as `ProductScreen`, `ProductDetailScreen`, `CartScreen`, `SettingsScreen`, and `HomeScreen`.
- **Widget Layer** - contains reusable widgets that can be used by different screens.

Using this structure makes the project easier to understand because each part of the application has its own responsibility.

The API code stays inside the services, data conversion stays inside the models, shared state is handled by Provider, and the UI stays inside the screens.

### Source-Code Comments

I also added comments in the Dart files to identify the Lab Activity 3 enhancements.

`Enhancement 1:` is used for the Cart screen and reusable detail screen.

`Enhancement 2:` is used for the Chat FloatingActionButton and hiding it on the Cart screen.

`Enhancement 3:` is used for cart-by-user-ID and Add to Cart API integration.

---

## Git Instructions for Lab Activity 3

After checking that the application works correctly, I used:

```bash
git add .
git commit -m "lab_act3"
git push origin lab_act3
```


## Lab Activity 5: discussion

The authentication workflow begins in "signin_screen.dart", where a "ChoiceChip" toggle determines the login path. If the user selects Firebase, the form triggers "UserService().signIn()", calling "signInWithEmailAndPassword". If DummyJSON is selected, it routes to "UserService().loginUser()", sending a POST request to the mocked API. Both paths culminate by setting the "LoginType" enum and calling "saveUserData()", which persists the response (including tokens) to "SharedPreferences". The signup flow, handled exclusively in "signup_screen.dart", only applies to Firebase; it collects user details, calls "UserService().createAccount()", sets the user's "displayName", and manually saves additional fields like "age" and "contactNo" to "SharedPreferences" since the project does not currently use Firestore for custom data modeling.

The primary idea behind the "UserService" implementation is to provide a single, unified abstraction layer that hides the underlying differences between the DummyJSON API and Firebase Auth. By wrapping both authentication providers behind common interfaces and maintaining a shared "SharedPreferences" contract for the "User" model, the rest of the app remains largely agnostic to the backend. The "LoginType" enum is crucial here; it allows screens like "profile_screen.dart" to branch behavior—such as rendering action tiles for updating the username, changing passwords, and deleting accounts only for Firebase users—without duplicating the core UI logic or user data fetching.

Implementing Firebase Auth provides tangible benefits over the mocked DummyJSON API in this app. Firebase enables real session and token lifecycle management natively, whereas the DummyJSON API only provided static token responses. Furthermore, Firebase provides built-in mechanisms for secure re-authentication, which we leverage in "UserService().resetPasswordFromCurrentPassword()" and "UserService().deleteAccount()" to securely prompt the user before destructive actions. These native security flows and account management capabilities are something the read-only DummyJSON API fundamentally cannot support, transforming the app's authentication from a simple simulation into a production-ready implementation.

