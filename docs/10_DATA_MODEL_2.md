# Data Model

- [Data Model](#data-model)
  - [Fields/Properties for Each Asset](#fieldsproperties-for-each-asset)
  - [Data Model](#data-model-1)
  - [Asset View](#asset-view)
  - [Essential Information to Display on an Asset Card](#essential-information-to-display-on-an-asset-card)
  - [Card Layout Ideas](#card-layout-ideas)
    - [Idea 1: Basic Card](#idea-1-basic-card)
    - [Idea 2: Icon-Based Card](#idea-2-icon-based-card)
  - [Detailed Information Card (on Click)](#detailed-information-card-on-click)
  - [Design Considerations](#design-considerations)
  - [Implementation Example in Flutter](#implementation-example-in-flutter)

---

> I want to build a new application which stores a list of all of my personal assets for the purposes of: stocktake, understanding the cost of all assets for insurance purposes, and general categorisation and organisation
>
> At this point, I would just like to define what the data model would be for these assets, and would like to know, before I start building anything, what fields/properties or other pieces of information about household items I should collect for this project
>
> Can you please help me list out the list of data to be captured for each asset, and create an associated data model?

---

Certainly! To build a comprehensive and organized inventory of personal assets, it’s important to capture detailed information about each item. Here's a list of fields/properties you might want to include for each asset, along with an associated data model.

## Fields/Properties for Each Asset

1. **Basic Information**

   - **Name**: The name of the asset (e.g., "Laptop", "Sofa").
   - **Category**: The type of asset (e.g., Electronics, Furniture, Appliances).
   - **Description**: A detailed description of the asset.

2. **Purchase Information**

   - **Purchase Date**: The date when the asset was purchased.
   - **Purchase Price**: The cost of the asset at the time of purchase.
   - **Purchase Location**: The store or place where the asset was bought.
   - **Receipt/Image**: An image of the receipt or the asset.

3. **Valuation Information**

   - **Current Value**: The current estimated value of the asset.
   - **Depreciation Rate**: The annual depreciation rate, if applicable.
   - **Depreciated Value**: The value after accounting for depreciation.

4. **Identification Information**

   - **Serial Number**: The serial number of the asset, if applicable.
   - **Model Number**: The model number of the asset, if applicable.
   - **Manufacturer**: The manufacturer of the asset.

5. **Location Information**

   - **Location**: Where the asset is located in your home (e.g., Living Room, Kitchen).
   - **Room**: Specific room where the asset is kept.

6. **Insurance Information**

   - **Insured**: Whether the asset is insured (Yes/No).
   - **Insurance Policy Number**: The policy number under which the asset is insured.
   - **Insurance Value**: The value for which the asset is insured.

7. **Maintenance Information**

   - **Maintenance Schedule**: The schedule for maintaining or servicing the asset.
   - **Last Maintenance Date**: The date when the asset was last maintained.
   - **Maintenance Notes**: Any notes related to maintenance.

8. **Additional Information**
   - **Warranty Information**: Details about any warranty (warranty period, expiry date).
   - **Notes**: Any additional notes or remarks about the asset.
   - **Tags**: Tags or keywords to help with categorization and search.

## Data Model

Here is a basic data model in JSON format:

```json
{
  "assets": [
    {
      "id": "unique-asset-id",
      "name": "string",
      "category": "string",
      "description": "string",
      "purchase_info": {
        "purchase_date": "date",
        "purchase_price": "number",
        "purchase_location": "string",
        "receipt_image_url": "string"
      },
      "images": [
        {
          "image_url": "string"
        }
      ],
      "valuation_info": {
        "current_value": "number",
        "depreciation_rate": "number",
        "depreciated_value": "number"
      },
      "identification_info": {
        "serial_number": "string",
        "model_number": "string",
        "manufacturer": "string"
      },
      "location_info": {
        "location": "string",
        "room": "string"
      },
      "insurance_info": {
        "insured": "boolean",
        "insurance_policy_number": "string",
        "insurance_value": "number"
      },
      "maintenance_info": {
        "maintenance_schedule": "string",
        "last_maintenance_date": "date",
        "maintenance_notes": "string"
      },
      "additional_info": {
        "warranty_info": {
          "warranty_period": "string",
          "warranty_expiry_date": "date"
        },
        "notes": "string",
        "tags": ["string"]
      }
    }
  ]
}
```

This model can be expanded or modified based on specific requirements or additional features you may want to include in your application.

## Asset View

---

> Now, when I build out a mobile application that shows these items, I would like some ideas for displaying these items
>
> In a mobile view, I will have limited space to display info, and I think a card or table would be a good way of displaying the information about an asset, however at this point I'm not sure what the best information would be to show on a non-detail specific view. (For example, if I clicked on the asset I would be taken to a page which shows all the above information, but for now I just want a minimal card)

---

For a minimal and effective display of asset information on a mobile application, a card or compact table layout is indeed a good choice. Here are some ideas for what essential information to display on each asset card:

## Essential Information to Display on an Asset Card

1. **Asset Name**
2. **Category**
3. **Current Value**
4. **Purchase Date**
5. **Location**

## Card Layout Ideas

### Idea 1: Basic Card

```plaintext
-------------------------------------------------
| Laptop                                       |
| Category: Electronics                        |
| Current Value: $800                          |
| Purchase Date: 2023-01-15                    |
| Location: Office                             |
-------------------------------------------------
```

### Idea 2: Icon-Based Card

```plaintext
-------------------------------------------------
| [Icon: Laptop]   Laptop                       |
| [Icon: Category] Electronics                  |
| [Icon: Value] $800                            |
| [Icon: Date] 2023-01-15                       |
| [Icon: Location] Office                       |
-------------------------------------------------
```

## Detailed Information Card (on Click)

Once the user clicks on a card, they can be taken to a detailed view that includes all the information fields defined in the data model.

## Design Considerations

- **Clickable Area**: Ensure the entire card is clickable to enhance user experience.
- **Icons**: Use icons to visually represent categories, which can make the card more engaging and easier to scan.
- **Fonts and Colors**: Use clear fonts and a consistent color scheme that aligns with the app’s overall design.
- **Images**: If you have images of the assets, a small thumbnail on the card can be very effective.

## Implementation Example in Flutter

Here’s an example of an enhanced enum which can be used to manage categories in Flutter:

```dart
import 'package:flutter/material.dart';

enum Category {
  electronics(icon: Icons.devices, name: "Electronics"),
  furniture(icon: Icons.weekend, name: "Furniture"),
  appliance(icon: Icons.kitchen, name: "Appliances"),
  clothing(icon: Icons.checkroom, name: "Clothing"),
  jewelry(icon: Icons.diamond, name: "Jewelry"),
  tools(icon: Icons.build, name: "Tools"),
  books(icon: Icons.book, name: "Books"),
  toys(icon: Icons.toys, name: "Toys"),
  vehicle(icon: Icons.directions_car, name: "Vehicles"),
  sports(icon: Icons.sports_soccer, name: "Sports Equipment"),
  art(icon: Icons.brush, name: "Art"),
  music(icon: Icons.music_note, name: "Musical Instruments"),
  office(icon: Icons.work, name: "Office Supplies"),
  kitchen(icon: Icons.restaurant, name: "Kitchenware"),
  garden(icon: Icons.grass, name: "Garden Equipment"),
  pets(icon: Icons.pets, name: "Pet Supplies");

  final IconData icon;
  final String name;

  const Category({
    required this.icon,
    required this.name,
  });
}
```

s
