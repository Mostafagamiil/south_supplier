

![iPhone 13 Pro](https://github.com/Mostafagamiil/south_supplier/assets/74520574/c2fc477b-f9fa-4ee4-be4f-0f634ddcaeba)
![Galaxy Note 20 Ultra-2](https://github.com/Mostafagamiil/south_supplier/assets/74520574/39932c9d-d395-4831-9202-ab723097d2ed)



main.dart:

    This file imports several packages and files required for the application.
    It defines a method _firebaseMessagingBackgroundHandler that handles background messages for Firebase Cloud Messaging.
    The main function is the entry point of the application.
    In the main function, Firebase is initialized, notification services are set up, date formatting is initialized, and the runApp function is called to start the application.
    The MyApp class is a stateless widget that sets up the main MaterialApp and defines the home and routes for the application.
    The newSplashScreen class is a stateless widget that shows an animated splash screen with a logo and transitions to the MainPage widget.

main_page.dart:

    This file imports several packages and files required for the application.
    The MainPage class is a stateful widget that builds the main scaffold of the application.
    Inside the build method, a stream builder is used to check the user's authentication state.
    If the user is authenticated, the appropriate home page (AdminHome or SuperVisorHomePage) is displayed based on the user's email domain.
    If the user is not authenticated, the login screen (AdminloginScreen) is displayed.

loginScreen.dart :  

    The widget imports necessary packages such as cloud_firestore, firebase_auth, firebase_messaging, and flutter/material.
    It also imports custom widgets and constants required for the UI.
    The AdminloginScreen class is a stateful widget that represents the login screen for admins and supervisors.
    Inside the class, it defines several variables, including text controllers for email and password, a form key, and a list of roles.
    The _signIn method is used to handle the sign-in process when the user taps the "تسجيل دخول" button.
    The _signIn method performs form validation, constructs the email based on the selected role, and attempts to sign in using FirebaseAuth.
    Upon successful sign-in, it determines if the user is an admin or supervisor, retrieves the FCM token, and saves the user's email and token in the respective   
    Firebase collection.
    If sign-in fails, it displays an error dialog with an appropriate message.
    The build method constructs the UI of the login screen using various Flutter widgets, including Scaffold, Form, TextFormField, Padding, Container, and more.
    The UI consists of an image, welcome text, text fields for email and password, radio buttons to select the role, and a "تسجيل دخول" button. 

AdminHomePage.dart :     

    Properties:
      _firebaseMessaging: An instance of FirebaseMessaging used for handling push notifications.
        user: The currently logged-in user obtained from FirebaseAuth.
        _customerId: A reference to the CustomerId collection in Firestore.
        _customersStream: A stream of QuerySnapshot representing the customers' data from Firestore.
        _notificationsStream: A stream of QuerySnapshot representing the notifications data from Firestore.
        _query: A string used to filter the customers based on their name or national ID.

 Methods:
 
        initState(): Overrides the initState method to initialize the streams for customers and notifications.
        build(BuildContext context): Overrides the build method to construct the UI for the admin home screen.
        The UI includes an AppBar with buttons for navigation, logout, and notifications.
        The body of the screen consists of a Column widget.
        The column contains a TextFormField for entering a national ID to filter the customers
        The customers' data is displayed in a ListView.builder, where each customer is represented by a Card.
        Tapping on a customer card shows a bottom sheet with detailed information about the customer.

Add_Item.dart :     

    The HomePage class extends StatefulWidget and represents the home screen of the app.
    The class has several properties and methods:
        Properties:
            user: Represents the currently logged-in user obtained from FirebaseAuth.
            _auth: An instance of FirebaseAuth used for authentication.
            _items: A reference to the items collection in Firestore.
            _searchString: A string used for searching and filtering items based on their name.
            _nameController, _priceController, _quantityController: TextEditingController instances used for managing input fields.
            _selectedQuantity: A string representing the selected quantity unit for an item.
            _selectedSortMethod: A string representing the selected sort method for the items.
            _sortAscendingDate, _sortAscendingPrice: Boolean values representing the sort order (ascending or descending) for date and price.
            _autoCompleteKey: A key used for managing an AutoCompleteTextField.
        Methods:
            build(BuildContext context): Overrides the build method to construct the UI for the home screen.
                The UI includes an AppBar with a search bar, sort buttons, and a back button.
                The body of the screen contains a ListView.builder widget that displays a list of items.
                The items are obtained from Firestore and filtered based on the search string.
                Each item is represented by a Card widget in the list, showing its name, price, quantity, and add date.
                Tapping on an item card shows a bottom sheet with detailed information about the item.
                The user can edit or delete an item using the corresponding buttons in each item's ListTile.
                The user can add a new item using a floating action button.
            _toggleSortAscendingDate(): Toggles the sort order for items based on the add date.
            _toggleSortAscendingPrice(): Toggles the sort order for items based on the price.
            _setSearchString(String value): Sets the search string based on the input from the search bar.
            _sortItems(List<DocumentSnapshot> items): Sorts the list of items based on the selected sort method and sort order.
            _update(DocumentSnapshot item): Updates an existing item.
            _delete(String itemId): Deletes an item.
            _create(): Creates a new item.



notification.dart :     

    The NotificationScreen class extends StatefulWidget and represents the screen for displaying notifications.
    The class has several properties and methods:
        Properties:
            _notificationsStream: A stream of NotificationModel objects representing the notifications.
            dateFormat: An instance of intl.DateFormat used for formatting the date.
            hourMinuteFormat: An instance of intl.DateFormat used for formatting the hour and minute.
            _lastLoadedDocument: A variable to store the last loaded document from Firestore.
            _isLoadingMore: A boolean flag to track if more data is being loaded.
            _scrollController: A ScrollController used to listen for scroll events.
            notifications: A list to store the notifications.
        Methods:
            initState(): Overrides the initState method to initialize the stream and scroll controller.
            getNotificationsStream(): Retrieves the notifications stream from Firestore.
            loadMoreNotifications(): Loads more notifications from Firestore.
            _scrollListener(): Listens to scroll events and loads more data when scrolled to the bottom.
            _loadMoreData(): Loads more data when triggered by _scrollListener().
            _buildNotificationCard(NotificationModel notification): Builds a card widget for displaying a single notification.
            _buildLoadingCard(): Builds a card widget with a loading indicator.
            build(BuildContext context): Overrides the build method to construct the UI for the notification screen.
            The UI includes an AppBar at the top with the title "الإشعارات".
            The body of the screen displays a ListView.builder widget that shows the notifications.
            The notifications are obtained from the _notificationsStream and displayed as cards with the title, body, and timestamp.
            As the user scrolls to the bottom, more notifications are loaded and displayed.
                A loading card is shown while more data is being loaded.

    The code uses the cloud_firestore, flutter/material, and intl packages. It interacts with Firestore to retrieve notifications and displays them in a scrollable list. When the user scrolls to the bottom, more notifications are loaded and displayed. The UI provides a smooth scrolling experience and shows a loading indicator while loading more data.


SVHomePage.dart :     

    The code imports necessary packages and dependencies.

    The SuperVisorHomePage class is defined as a stateful widget.

    The user variable is assigned the current user using FirebaseAuth.instance.currentUser.

    The _nationalIdController is a controller for the national ID text field.

    The _searchText variable is used to store the search text entered by the user.

    The _customerId variable represents the Firestore collection for customer IDs.

    The _formKey is a GlobalKey used to validate the form.

    The _performSearch function is called when the user clicks the search button. It performs a query on the Firestore collection to search for a customer with a 
    matching national ID. If a customer is found, an alert dialog is displayed. Otherwise, the user is navigated to the AddCustomerScreen to add a new customer.

    The build method returns a Scaffold with an AppBar and body.

    The body consists of a Column widget containing a Form with a TextFormField for entering the national ID, and a search button.

    The TextFormField is configured with a validator to check the format and length of the national ID entered.

    When the search button is pressed, the form is validated, and if valid, the _performSearch function is called.

    The StreamBuilder widget is used to listen to changes in the Firestore collection based on the search query.

    Inside the StreamBuilder, a ListView.builder is used to display the list of customers that match the search query.

    Each customer entry in the ListView is wrapped in a GestureDetector to allow tapping on the entry.

    When a customer entry is tapped, a bottom sheet modal is shown, displaying the details of the customer using the CustomerDetailsScreen.

    The bottom portion of the body is an expanded ListView.builder that displays the search results.



AddCustomerScreen.dart : 

    Import necessary packages from Flutter and Firebase.
    Define a stateful widget called AddCustomerScreen that takes in customerId, nationalId, and token as parameters.
    Inside the widget, initialize necessary variables and controllers.
    Implement lifecycle methods dispose and initState.
    Implement a method to retrieve admin tokens from Firestore.
    Build the UI using Directionality, Scaffold, AppBar, and Form widgets.
    Add form fields for name and national ID.
    Stream data from a Firestore collection called "items" and display a list of items with corresponding quantity fields.
    Handle form submission, validate inputs, and update Firestore documents based on user input.
    Show a loading indicator while performing asynchronous operations.

Note:

    The code relies on external files, such as firebase_helper.dart, local_notification_service.dart, const.dart, and item_model.dart, which are not included in the provided code.
