# MySQL/MariaDB Schema Fixes

## Issues Fixed

### 1. Array Types Not Supported
**Problem:** MySQL/MariaDB doesn't support arrays of primitive types like `String[]`.

**Solution:** Changed `String[]` to `Json` type for:
- `Unit.images` - Now `Json?` with default `[]`
- `Maintenance.images` - Now `Json?` with default `[]`

**Code Changes:**
- Prisma automatically serializes/deserializes JSON
- Arrays passed to Prisma are automatically converted to JSON
- When reading, Prisma returns the JSON as a JavaScript object/array

### 2. Missing Relation Field
**Problem:** `PropertyCaretaker` model had a relation to `User`, but `User` model was missing the opposite relation field.

**Solution:** Added `propertyCaretaker PropertyCaretaker[]` to the `User` model.

### 3. onDelete: SetNull with Required Field
**Problem:** `USSDSession.user` relation used `onDelete: SetNull` but referenced a required field (`phone`).

**Solution:** Changed `onDelete: SetNull` to `onDelete: Cascade` since the relation is already optional (`User?`).

## Usage Notes

### Working with JSON Images Field

When creating/updating records with images:

```javascript
// Prisma automatically handles JSON conversion
const unit = await prisma.unit.create({
  data: {
    // ... other fields
    images: ['url1', 'url2', 'url3'], // Array is automatically converted to JSON
  },
});

// When reading, images is returned as an array
const unit = await prisma.unit.findUnique({ where: { id } });
console.log(unit.images); // ['url1', 'url2', 'url3']
```

### API Usage

The API accepts images as an array in the request body:

```json
{
  "name": "Unit A1",
  "images": ["https://example.com/image1.jpg", "https://example.com/image2.jpg"]
}
```

Prisma will automatically:
1. Convert the array to JSON when saving
2. Convert JSON back to array when reading

## Migration

If you have existing data, you'll need to migrate:

```sql
-- For existing units table
ALTER TABLE units MODIFY COLUMN images JSON DEFAULT ('[]');

-- For existing maintenance table  
ALTER TABLE maintenance MODIFY COLUMN images JSON DEFAULT ('[]');
```

Or use Prisma migrations:
```bash
npx prisma migrate dev --name convert_images_to_json
```


