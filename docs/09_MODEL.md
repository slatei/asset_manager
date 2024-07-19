# Data Model

- [Data Model](#data-model)
  - [Data Model for Household Items Inventory](#data-model-for-household-items-inventory)
    - [1. **Items Table**](#1-items-table)
    - [2. **Categories Table**](#2-categories-table)
    - [3. **Locations Table**](#3-locations-table)
    - [4. **Suppliers Table**](#4-suppliers-table)
    - [5. **Maintenance and Repair Table**](#5-maintenance-and-repair-table)
  - [Relationships](#relationships)
  - [SQL Schema Example](#sql-schema-example)
  - [Flutter Model](#flutter-model)
    - [Step-by-Step Guide](#step-by-step-guide)
    - [Putting It All Together](#putting-it-all-together)
    - [Example Usage in Flutter](#example-usage-in-flutter)
  - [Switching Databases](#switching-databases)
    - [Step-by-Step Guide](#step-by-step-guide-1)
    - [Summary](#summary)

---

> I am creating a database of all my items around the home to keep track of what I own, and how much it costs etc. Construct for me a data model that could be used to build out a list of all the items I own

---

Below is a data model that you can use to build out your list. The model includes essential fields to capture details about each item.

## Data Model for Household Items Inventory

### 1. **Items Table**

This is the main table where all items are listed.

- **ItemID** (Primary Key): Unique identifier for each item.
- **Name**: Name of the item.
- **Description**: Detailed description of the item.
- **CategoryID** (Foreign Key): Links to the Category table to categorize the item (e.g., electronics, furniture).
- **PurchaseDate**: Date when the item was purchased.
- **PurchasePrice**: Cost of the item at the time of purchase.
- **CurrentValue**: Current estimated value of the item.
- **Quantity**: Number of units owned.
- **LocationID** (Foreign Key): Links to the Location table to specify where the item is stored.
- **Condition**: Current condition of the item (e.g., new, used, damaged).
- **WarrantyExpiry**: Date when the warranty expires (if applicable).
- **SupplierID** (Foreign Key): Links to the Supplier table for details about where the item was purchased.

### 2. **Categories Table**

This table categorizes each item.

- **CategoryID** (Primary Key): Unique identifier for each category.
- **CategoryName**: Name of the category.

### 3. **Locations Table**

This table specifies where items are stored.

- **LocationID** (Primary Key): Unique identifier for each location.
- **LocationName**: Name of the location (e.g., living room, kitchen, garage).

### 4. **Suppliers Table**

This table holds information about suppliers or stores where items were purchased.

- **SupplierID** (Primary Key): Unique identifier for each supplier.
- **SupplierName**: Name of the supplier.
- **ContactInformation**: Contact details of the supplier.
- **Website**: Website of the supplier (if applicable).

### 5. **Maintenance and Repair Table**

(Optional) This table keeps track of any maintenance or repairs performed on items.

- **MaintenanceID** (Primary Key): Unique identifier for each maintenance record.
- **ItemID** (Foreign Key): Links to the Items table.
- **Date**: Date when maintenance or repair was performed.
- **Description**: Description of the maintenance or repair work.
- **Cost**: Cost of the maintenance or repair work.
- **ServiceProvider**: Name of the service provider or person who performed the work.

## Relationships

- **Items** table is linked to **Categories**, **Locations**, and **Suppliers** tables via foreign keys.
- **Maintenance and Repair** table is linked to the **Items** table via a foreign key.

## SQL Schema Example

Here is an example SQL schema based on the above data model:

```sql
CREATE TABLE Categories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

CREATE TABLE Locations (
    LocationID INT PRIMARY KEY,
    LocationName VARCHAR(100) NOT NULL
);

CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    SupplierName VARCHAR(100) NOT NULL,
    ContactInformation VARCHAR(255),
    Website VARCHAR(255)
);

CREATE TABLE Items (
    ItemID INT PRIMARY KEY,
    Name VARCHAR(100) NOT NULL,
    Description TEXT,
    CategoryID INT,
    PurchaseDate DATE,
    PurchasePrice DECIMAL(10, 2),
    CurrentValue DECIMAL(10, 2),
    Quantity INT,
    LocationID INT,
    Condition VARCHAR(50),
    WarrantyExpiry DATE,
    SupplierID INT,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

CREATE TABLE MaintenanceAndRepair (
    MaintenanceID INT PRIMARY KEY,
    ItemID INT,
    Date DATE,
    Description TEXT,
    Cost DECIMAL(10, 2),
    ServiceProvider VARCHAR(100),
    FOREIGN KEY (ItemID) REFERENCES Items(ItemID)
);
```

## Flutter Model

To implement this data model in a Flutter project, you would typically use a SQLite database for local storage. Flutter has a plugin called `sqflite` which is commonly used for this purpose. Below is an outline on how to set up the data model using `sqflite` in Flutter.

### Step-by-Step Guide

1. **Add Dependencies**
   Add the `sqflite` and `path` packages to your `pubspec.yaml` file.

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     sqflite: ^2.0.3
     path: ^1.8.1
   ```

2. **Create Database Helper Class**
   Create a class to handle database operations.

   ```dart
   import 'package:sqflite/sqflite.dart';
   import 'package:path/path.dart';

   class DatabaseHelper {
     static final DatabaseHelper _instance = DatabaseHelper._internal();
     factory DatabaseHelper() => _instance;
     DatabaseHelper._internal();

     static Database? _database;

     Future<Database> get database async {
       if (_database != null) return _database!;
       _database = await _initDatabase();
       return _database!;
     }

     Future<Database> _initDatabase() async {
       String path = join(await getDatabasesPath(), 'household_inventory.db');
       return await openDatabase(
         path,
         version: 1,
         onCreate: _onCreate,
       );
     }

     Future _onCreate(Database db, int version) async {
       await db.execute('''
         CREATE TABLE Categories (
           CategoryID INTEGER PRIMARY KEY,
           CategoryName TEXT NOT NULL
         )
       ''');

       await db.execute('''
         CREATE TABLE Locations (
           LocationID INTEGER PRIMARY KEY,
           LocationName TEXT NOT NULL
         )
       ''');

       await db.execute('''
         CREATE TABLE Suppliers (
           SupplierID INTEGER PRIMARY KEY,
           SupplierName TEXT NOT NULL,
           ContactInformation TEXT,
           Website TEXT
         )
       ''');

       await db.execute('''
         CREATE TABLE Items (
           ItemID INTEGER PRIMARY KEY,
           Name TEXT NOT NULL,
           Description TEXT,
           CategoryID INTEGER,
           PurchaseDate TEXT,
           PurchasePrice REAL,
           CurrentValue REAL,
           Quantity INTEGER,
           LocationID INTEGER,
           Condition TEXT,
           WarrantyExpiry TEXT,
           SupplierID INTEGER,
           FOREIGN KEY (CategoryID) REFERENCES Categories (CategoryID),
           FOREIGN KEY (LocationID) REFERENCES Locations (LocationID),
           FOREIGN KEY (SupplierID) REFERENCES Suppliers (SupplierID)
         )
       ''');

       await db.execute('''
         CREATE TABLE MaintenanceAndRepair (
           MaintenanceID INTEGER PRIMARY KEY,
           ItemID INTEGER,
           Date TEXT,
           Description TEXT,
           Cost REAL,
           ServiceProvider TEXT,
           FOREIGN KEY (ItemID) REFERENCES Items (ItemID)
         )
       ''');
     }
   }
   ```

3. **Create Model Classes**
   Define the model classes for each entity.

   ```dart
   class Category {
     int? categoryID;
     String categoryName;

     Category({this.categoryID, required this.categoryName});

     Map<String, dynamic> toMap() {
       return {
         'CategoryID': categoryID,
         'CategoryName': categoryName,
       };
     }
   }

   class Location {
     int? locationID;
     String locationName;

     Location({this.locationID, required this.locationName});

     Map<String, dynamic> toMap() {
       return {
         'LocationID': locationID,
         'LocationName': locationName,
       };
     }
   }

   class Supplier {
     int? supplierID;
     String supplierName;
     String? contactInformation;
     String? website;

     Supplier({
       this.supplierID,
       required this.supplierName,
       this.contactInformation,
       this.website,
     });

     Map<String, dynamic> toMap() {
       return {
         'SupplierID': supplierID,
         'SupplierName': supplierName,
         'ContactInformation': contactInformation,
         'Website': website,
       };
     }
   }

   class Item {
     int? itemID;
     String name;
     String? description;
     int? categoryID;
     String? purchaseDate;
     double? purchasePrice;
     double? currentValue;
     int? quantity;
     int? locationID;
     String? condition;
     String? warrantyExpiry;
     int? supplierID;

     Item({
       this.itemID,
       required this.name,
       this.description,
       this.categoryID,
       this.purchaseDate,
       this.purchasePrice,
       this.currentValue,
       this.quantity,
       this.locationID,
       this.condition,
       this.warrantyExpiry,
       this.supplierID,
     });

     Map<String, dynamic> toMap() {
       return {
         'ItemID': itemID,
         'Name': name,
         'Description': description,
         'CategoryID': categoryID,
         'PurchaseDate': purchaseDate,
         'PurchasePrice': purchasePrice,
         'CurrentValue': currentValue,
         'Quantity': quantity,
         'LocationID': locationID,
         'Condition': condition,
         'WarrantyExpiry': warrantyExpiry,
         'SupplierID': supplierID,
       };
     }
   }

   class MaintenanceAndRepair {
     int? maintenanceID;
     int itemID;
     String date;
     String? description;
     double? cost;
     String? serviceProvider;

     MaintenanceAndRepair({
       this.maintenanceID,
       required this.itemID,
       required this.date,
       this.description,
       this.cost,
       this.serviceProvider,
     });

     Map<String, dynamic> toMap() {
       return {
         'MaintenanceID': maintenanceID,
         'ItemID': itemID,
         'Date': date,
         'Description': description,
         'Cost': cost,
         'ServiceProvider': serviceProvider,
       };
     }
   }
   ```

4. **CRUD Operations**
   Implement CRUD operations for each table in the `DatabaseHelper` class.

   ```dart
   class DatabaseHelper {
     // Previous code...

     // Insert Category
     Future<int> insertCategory(Category category) async {
       Database db = await database;
       return await db.insert('Categories', category.toMap());
     }

     // Get all Categories
     Future<List<Category>> getCategories() async {
       Database db = await database;
       List<Map<String, dynamic>> result = await db.query('Categories');
       return result.map((e) => Category(categoryID: e['CategoryID'], categoryName: e['CategoryName'])).toList();
     }

     // Insert Location
     Future<int> insertLocation(Location location) async {
       Database db = await database;
       return await db.insert('Locations', location.toMap());
     }

     // Get all Locations
     Future<List<Location>> getLocations() async {
       Database db = await database;
       List<Map<String, dynamic>> result = await db.query('Locations');
       return result.map((e) => Location(locationID: e['LocationID'], locationName: e['LocationName'])).toList();
     }

     // Insert Supplier
     Future<int> insertSupplier(Supplier supplier) async {
       Database db = await database;
       return await db.insert('Suppliers', supplier.toMap());
     }

     // Get all Suppliers
     Future<List<Supplier>> getSuppliers() async {
       Database db = await database;
       List<Map<String, dynamic>> result = await db.query('Suppliers');
       return result.map((e) => Supplier(
         supplierID: e['SupplierID'],
         supplierName: e['SupplierName'],
         contactInformation: e['ContactInformation'],
         website: e['Website'],
       )).toList();
     }

     // Insert Item
     Future<int> insertItem(Item item) async {
       Database db = await database;
       return await db.insert('Items', item.toMap());
     }

     // Get all Items
     Future<List<Item>> getItems() async {
       Database db = await database;
       List<Map<String, dynamic>> result = await db.query('Items');
       return result.map((e) => Item(
         itemID: e['ItemID'],
         name: e['Name'],
         description: e['Description'],
         categoryID: e['CategoryID'],
         purchaseDate: e['PurchaseDate'],
         purchasePrice: e['PurchasePrice'],
         currentValue: e['CurrentValue'],
         quantity: e['Quantity'],
         locationID: e['LocationID'],
         condition: e['Condition'],
         warrantyExpiry: e['WarrantyExpiry'],
         supplierID: e['SupplierID'],
       )).toList();
     }

     // Insert MaintenanceAndRepair
     Future<int> insertMaintenance(MaintenanceAndRepair maintenance) async {
       Database db = await database;
       return await db.insert('MaintenanceAndRepair', maintenance.toMap());
     }

     // Get all MaintenanceAndRepairs
     Future<List<MaintenanceAndRepair>> getMaintenances() async {
       Database db = await database;
       List<Map<String, dynamic>> result = await db.query('MaintenanceAndRepair');
       return result.map((e) => MaintenanceAndRepair(
         maintenanceID: e['MaintenanceID'],
         itemID: e['ItemID'],
         date: e['Date'],
         description: e['Description'],
         cost: e['Cost'],
         serviceProvider: e['ServiceProvider'],
       )).toList();
     }
   }
   ```

### Putting It All Together

You can now use these classes and methods in your Flutter application to manage your household inventory. For instance, you can create a form to add new items, display lists of items, and manage categories, locations, suppliers, and maintenance records.

### Example Usage in Flutter

Here is an example of how you might use the `DatabaseHelper` in a Flutter widget to

display a list of items:

```dart
import 'package:flutter/material.dart';
import 'database_helper.dart';
import 'models/item.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ItemListScreen(),
    );
  }
}

class ItemListScreen extends StatefulWidget {
  @override
  _ItemListScreenState createState() => _ItemListScreenState();
}

class _ItemListScreenState extends State<ItemListScreen> {
  late DatabaseHelper dbHelper;
  late Future<List<Item>> items;

  @override
  void initState() {
    super.initState();
    dbHelper = DatabaseHelper();
    items = dbHelper.getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Household Inventory'),
      ),
      body: FutureBuilder<List<Item>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text('No items found');
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Item item = snapshot.data![index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text(item.description ?? ''),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add navigation to a new item form
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

This example demonstrates how to display a list of items using the `DatabaseHelper` to fetch data from the SQLite database. You can extend this to include forms for adding and editing items, as well as managing categories, locations, suppliers, and maintenance records.

## Switching Databases

To enable switching between SQLite and Firestore databases based on environment configuration in your Flutter project, you can use a configuration file to define which database to use, and then create an abstract data access object (DAO) pattern to interact with the database. This way, you can dynamically choose the appropriate implementation (SQLite or Firestore) at runtime.

### Step-by-Step Guide

1. **Add Dependencies**

   Add the necessary dependencies for `sqflite`, `path`, and `cloud_firestore` in your `pubspec.yaml`.

   ```yaml
   dependencies:
     flutter:
       sdk: flutter
     sqflite: ^2.0.3
     path: ^1.8.1
     cloud_firestore: ^4.6.3
   ```

2. **Define Environment Configuration**

   Create an environment configuration class to manage environment-specific settings.

   ```dart
   class AppConfig {
     final bool useFirestore;

     AppConfig({required this.useFirestore});

     static AppConfig? _instance;

     static void initialize({required bool useFirestore}) {
       _instance = AppConfig(useFirestore: useFirestore);
     }

     static AppConfig get instance {
       if (_instance == null) {
         throw Exception('AppConfig is not initialized');
       }
       return _instance!;
     }
   }
   ```

   Initialize the configuration in your `main.dart` file.

   ```dart
   void main() {
     bool useFirestore = false; // Set this based on your environment
     AppConfig.initialize(useFirestore: useFirestore);
     runApp(MyApp());
   }
   ```

3. **Create Data Access Object (DAO) Interface**

   Define an abstract class to outline the methods for data access.

   ```dart
   abstract class DatabaseDao {
     Future<int> insertItem(Item item);
     Future<List<Item>> getItems();
     // Add other methods as needed
   }
   ```

4. **Implement SQLite DAO**

   Implement the SQLite version of the DAO.

   ```dart
   class SQLiteDao implements DatabaseDao {
     final DatabaseHelper dbHelper = DatabaseHelper();

     @override
     Future<int> insertItem(Item item) async {
       return await dbHelper.insertItem(item);
     }

     @override
     Future<List<Item>> getItems() async {
       return await dbHelper.getItems();
     }

     // Add other methods as needed
   }
   ```

5. **Implement Firestore DAO**

   Implement the Firestore version of the DAO.

   ```dart
   import 'package:cloud_firestore/cloud_firestore.dart';

   class FirestoreDao implements DatabaseDao {
     final CollectionReference itemsCollection = FirebaseFirestore.instance.collection('items');

     @override
     Future<int> insertItem(Item item) async {
       DocumentReference docRef = await itemsCollection.add(item.toMap());
       return docRef.id.hashCode; // Use the hashCode of the document ID as a unique identifier
     }

     @override
     Future<List<Item>> getItems() async {
       QuerySnapshot snapshot = await itemsCollection.get();
       return snapshot.docs.map((doc) => Item.fromMap(doc.data() as Map<String, dynamic>)).toList();
     }

     // Add other methods as needed
   }
   ```

6. **Create Database Service**

   Create a service class to manage the selection of the appropriate DAO based on the configuration.

   ```dart
   class DatabaseService {
     static DatabaseDao getDao() {
       if (AppConfig.instance.useFirestore) {
         return FirestoreDao();
       } else {
         return SQLiteDao();
       }
     }
   }
   ```

7. **Update the Item Model**

   Ensure the `Item` model has a `fromMap` method for Firestore.

   ```dart
   class Item {
     int? itemID;
     String name;
     String? description;
     int? categoryID;
     String? purchaseDate;
     double? purchasePrice;
     double? currentValue;
     int? quantity;
     int? locationID;
     String? condition;
     String? warrantyExpiry;
     int? supplierID;

     Item({
       this.itemID,
       required this.name,
       this.description,
       this.categoryID,
       this.purchaseDate,
       this.purchasePrice,
       this.currentValue,
       this.quantity,
       this.locationID,
       this.condition,
       this.warrantyExpiry,
       this.supplierID,
     });

     Map<String, dynamic> toMap() {
       return {
         'itemID': itemID,
         'name': name,
         'description': description,
         'categoryID': categoryID,
         'purchaseDate': purchaseDate,
         'purchasePrice': purchasePrice,
         'currentValue': currentValue,
         'quantity': quantity,
         'locationID': locationID,
         'condition': condition,
         'warrantyExpiry': warrantyExpiry,
         'supplierID': supplierID,
       };
     }

     factory Item.fromMap(Map<String, dynamic> map) {
       return Item(
         itemID: map['itemID'],
         name: map['name'],
         description: map['description'],
         categoryID: map['categoryID'],
         purchaseDate: map['purchaseDate'],
         purchasePrice: map['purchasePrice'],
         currentValue: map['currentValue'],
         quantity: map['quantity'],
         locationID: map['locationID'],
         condition: map['condition'],
         warrantyExpiry: map['warrantyExpiry'],
         supplierID: map['supplierID'],
       );
     }
   }
   ```

8. **Update the UI to Use Database Service**

   Use the `DatabaseService` in your Flutter widgets to interact with the database.

   ```dart
   import 'package:flutter/material.dart';
   import 'database_service.dart';
   import 'models/item.dart';

   void main() {
     bool useFirestore = false; // Set this based on your environment
     AppConfig.initialize(useFirestore: useFirestore);
     runApp(MyApp());
   }

   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         home: ItemListScreen(),
       );
     }
   }

   class ItemListScreen extends StatefulWidget {
     @override
     _ItemListScreenState createState() => _ItemListScreenState();
   }

   class _ItemListScreenState extends State<ItemListScreen> {
     late Future<List<Item>> items;

     @override
     void initState() {
       super.initState();
       items = DatabaseService.getDao().getItems();
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(
           title: Text('Household Inventory'),
         ),
         body: FutureBuilder<List<Item>>(
           future: items,
           builder: (context, snapshot) {
             if (snapshot.connectionState == ConnectionState.waiting) {
               return CircularProgressIndicator();
             } else if (snapshot.hasError) {
               return Text('Error: ${snapshot.error}');
             } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return Text('No items found');
             } else {
               return ListView.builder(
                 itemCount: snapshot.data!.length,
                 itemBuilder: (context, index) {
                   Item item = snapshot.data![index];
                   return ListTile(
                     title: Text(item.name),
                     subtitle: Text(item.description ?? ''),
                   );
                 },
               );
             }
           },
         ),
         floatingActionButton: FloatingActionButton(
           onPressed: () {
             // Add navigation to a new item form
           },
           child: Icon(Icons.add),
         ),
       );
     }
   }
   ```

### Summary

By following these steps, you can create a flexible Flutter application that can switch between SQLite and Firestore based on the environment configuration. This approach leverages an abstract DAO pattern, making it easy to extend and maintain.


