# Lawrenz Dave Z. Flores
## INF 233 MWA
## CTADMOBL Advanced Mobile Programming

A Flutter project that focuses on advanced mobile programming topics and mobile-to-web/API transactions.

## Lab Activity 2: discussion

### Implemented Enhancements

1. **Enhancement 1 - Search bar above the article/product list.**  
   A search field was added above the product cards in `ProductScreen`. The application keeps the API result in memory and filters the displayed cards using the user's search text. Matching is case-insensitive and checks the product title, brand, and category. The search therefore updates the UI immediately without sending a new HTTP request for every character typed.

2. **Enhancement 2 - Details page when a card is clicked.**  
   Each product card is wrapped with an `InkWell`. When the user taps a card, Flutter uses `Navigator.push` to open `ProductDetailScreen` and passes the selected `Product` object to it. The details page displays Bulldog Exchange / NU Manila merchandise with local product images, Philippine peso pricing, title, category, rating, availability, description, tags, product specifications, pickup information, return policy, and reviews.

3. **Enhancement 3 - Settings page for the dark/light mode switch.**  
   Theme selection was moved to a dedicated `SettingsScreen`. The settings icon in the Home screen opens the page. `ThemeProvider` stores whether dark mode is enabled and calls `notifyListeners()` when the switch changes. Because `MaterialApp` watches `ThemeProvider`, the selected light or dark theme is applied immediately throughout the application.


### Bulldog Exchange / NU Manila Catalog Theme

For the final laboratory presentation, the generic demo catalog was replaced with a National University Manila theme. The sample catalog includes NU Bulldogs shirts, an ID lace, hoodie, varsity socks, basketball jersey, Bulldog enamel pin, and cap. Product photos are bundled under `assets/images/products/` so the cards and details screen display the intended NU merchandise consistently. The catalog uses Philippine peso (`₱`) pricing and campus-pickup wording to better match the Bulldogs Exchange context.

### How the Model, Service, and Screen Interact to Render the API Endpoint

The API flow follows a clear separation of responsibilities:

1. **Screen (`ProductScreen`)** - The screen starts the data request by calling `ProductService().getAllProducts()` in `initState()`. A `FutureBuilder<List<Product>>` listens to that request and renders loading, error, empty, or successful UI states. When data is available, the screen builds the product cards. The screen does not call the `http` package directly.

2. **Service (`ProductService`)** - The service is responsible for communication with the REST API. It reads the API host from `assets/.env`, sends a `GET` request to `https://dummyjson.com/products?limit=10`, checks the HTTP status code, and decodes the response. Because the public laboratory endpoint contains generic demo products, the service then adapts the successful response into a National University Manila / Bulldogs Exchange sample catalog. The endpoint still controls the asynchronous success/error flow and supplies stable item IDs, while the presentation data is themed for the laboratory output.

3. **Model (`Product`)** - `Product.fromJson()` converts each adapted JSON map into strongly typed Dart properties such as `id`, `title`, `price`, `rating`, `images`, `reviews`, and dimensions. Nested model classes also convert nested data. This keeps JSON parsing out of the UI and allows the same model to be reused by the list and details screens.

4. **Rendering and navigation** - The service returns `Future<List<Product>>` to `ProductScreen`. `FutureBuilder` receives the `List<Product>` and renders the Bulldog Exchange cards using bundled local images and Philippine peso prices. The search enhancement filters this list locally. When a card is selected, the same typed `Product` object is passed to `ProductDetailScreen`, so the details page renders the selected item without repeating the request.

The data flow can be summarized as:

`REST API -> ProductService -> Bulldog Exchange catalog adaptation -> Product.fromJson() -> List<Product> -> ProductScreen -> ProductDetailScreen`

### New Design Pattern Used in This Activity

The activity uses a **Service Layer pattern with separation of concerns**. Instead of placing networking code, JSON conversion, and UI rendering inside one widget, each layer has one main responsibility:

- **Model layer** represents and converts application data.
- **Service layer** handles API/network operations.
- **Screen/UI layer** handles presentation, user interaction, loading states, searching, and navigation.

This structure is repository-style because the UI receives application objects from a separate data-access layer, although this project currently uses a concrete service directly rather than a separate repository interface. The advantage is maintainability: if the API endpoint or HTTP implementation changes, most changes stay inside `ProductService`; if the JSON structure changes, parsing is updated in the model; and UI changes remain in the screens.

For theme state, the project also uses **Provider with `ChangeNotifier`**, which follows an observer-style state-management approach. `SettingsScreen` changes the state in `ThemeProvider`, `notifyListeners()` informs listening widgets, and `MaterialApp` rebuilds with the selected `ThemeMode`.

### Source-Code Comments

The implementation is marked in the Dart source files using comments beginning with:

- `Enhancement 1:` for the search feature
- `Enhancement 2:` for card-to-details navigation and the details screen
- `Enhancement 3:` for the Settings page and theme switch

## Git Instructions for Lab Activity 2

Run these commands from the repository root folder after verifying the application:

```bash
git checkout -b lab_act2
git add .
git commit -m "lab_act2"
git push origin lab_act2
```
