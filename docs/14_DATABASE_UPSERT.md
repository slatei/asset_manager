# Firebase Firestore Upsert

## Firestore "set()" Function

---

> Is it possible in a Flutter application integrated with Firebase Firestore > to perform an upsert operation? I would like to use the following function > to both add or update a function in my database
>
> ```dart
>   static Future<void> updateAsset(Asset asset) async {
>     await ref.doc(asset.id).update(asset.toFirestore());
>   }
> ```
>
> However if the collection or asset doesn't already exist, the database > throws a 404, and I'd prefer it just create the record

---

In Firestore, performing an "upsert" operation (update if exists, create if not) can be achieved by using the `set` method with the `SetOptions` parameter. This allows you to set the data at a specific document path, creating the document if it doesn't exist, or updating the existing document.

You can modify your `updateAsset` function as follows:

```dart
static Future<void> updateAsset(Asset asset) async {
  await ref.doc(asset.id).set(
    asset.toFirestore(),
    SetOptions(merge: true), // This will merge fields, effectively performing an upsert
  );
}
```

### Explanation:

- **`set` Method**: The `set` method writes data to a document at the specified path. If the document does not exist, it will be created.
- **`SetOptions(merge: true)`**: The `merge: true` option allows you to merge the new data with the existing data in the document. If the document doesn't exist, it will be created with the provided data.

This approach ensures that your operation will not throw a 404 error if the document doesn't exist, but instead, it will create the document or update it as needed.
