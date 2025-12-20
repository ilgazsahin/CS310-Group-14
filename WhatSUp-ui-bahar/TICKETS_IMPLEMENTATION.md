# Tickets System Implementation

## Overview
This document describes the complete ticket system implementation for the WhatSUp event management app.

## ✅ Completed Features

### 1. Data Model (`lib/models/data_models.dart`)
- **TicketModel** created with Firestore fields:
  - `id`: Unique Firestore document ID
  - `eventId`: Reference to the event
  - `eventTitle`, `eventLocation`, `eventDate`, `eventTime`: Denormalized event data for easy display
  - `eventImageUrl`, `eventCategory`, `eventHosts`: Additional event info
  - `ticketPrice`: Price from event
  - `userId`: User who owns the ticket
  - `createdAt`: Timestamp when ticket was created
  - `isFavorite`: User's favorite status
- Methods: `fromFirestore()`, `toFirestore()`, `copyWith()`

### 2. Firestore Service (`lib/services/firestore_service.dart`)
Complete CRUD operations for tickets:

#### CREATE
- `createTicket()`: Creates a ticket for an event
  - Checks if user already has a ticket for the event
  - Denormalizes event data into ticket document
  - Sets `userId` and `createdAt` automatically

#### READ
- `getUserTicketsStream()`: Real-time stream of current user's tickets
- `userHasTicket()`: Checks if user has a ticket for a specific event

#### UPDATE
- `toggleTicketFavorite()`: Updates favorite status of a ticket
  - Verifies ownership before allowing update

#### DELETE
- `deleteTicket()`: Deletes a ticket
  - Verifies ownership before allowing delete

### 3. UI Integration

#### EventDetailPage
- Added "Get Ticket" button at the bottom of event details
- Button shows "You have a ticket" if user already has one
- Checks ticket status on page load
- Creates ticket when button is clicked

#### TicketsPage
- Updated to use Firestore data via `StreamBuilder`
- Shows real-time list of user's tickets
- Favorite toggle functionality
- Cancel ticket functionality
- Handles loading and error states

### 4. Security Rules (`firestore.rules`)
- **Read**: Users can only read their own tickets
- **Create**: Only authenticated users, must set `userId` to their own UID
- **Update**: Only the ticket owner can update their own tickets
- **Delete**: Only the ticket owner can delete their own tickets

## Firestore Collection Structure

### Collection: `tickets`

Document structure:
```json
{
  "eventId": "string (required, reference to event)",
  "eventTitle": "string (required, denormalized)",
  "eventLocation": "string (required, denormalized)",
  "eventDate": "string (required, denormalized)",
  "eventTime": "string (required, denormalized)",
  "eventImageUrl": "string (optional, denormalized)",
  "eventCategory": "string (optional, denormalized)",
  "eventHosts": ["array of strings (required, denormalized)"],
  "ticketPrice": "string (optional, from event)",
  "userId": "string (user UID, required)",
  "createdAt": "timestamp (required)",
  "isFavorite": "boolean (default: false)"
}
```

## Setting Up the Tickets Collection in Firebase

### Step 1: Create the Collection
The collection will be created automatically when the first ticket is created. No manual setup needed!

### Step 2: Create Composite Index (Required)
You need to create a composite index for the `getUserTicketsStream()` query:

1. Go to Firebase Console → Firestore Database → Indexes
2. Click "Create Index"
3. Collection ID: `tickets`
4. Add fields:
   - `userId` (Ascending)
   - `createdAt` (Descending)
5. Click "Create"

**OR** Firebase will show you a link in the error message when you first try to use the tickets page - click that link to create the index automatically.

### Step 3: Deploy Security Rules
Deploy the updated security rules:

```bash
firebase deploy --only firestore:rules
```

Or manually copy the `firestore.rules` content to Firebase Console → Firestore Database → Rules

## How It Works

1. **Creating a Ticket:**
   - User clicks "Get Ticket" on an event detail page
   - System checks if user already has a ticket for that event
   - If not, creates a new ticket document with denormalized event data
   - Ticket appears in user's tickets list immediately (real-time)

2. **Viewing Tickets:**
   - Tickets page shows all tickets for the logged-in user
   - Updates in real-time when tickets are added/removed
   - Each ticket shows event details (title, location, date, time, image, etc.)

3. **Managing Tickets:**
   - Users can favorite/unfavorite tickets
   - Users can cancel (delete) their tickets
   - All operations are restricted to the ticket owner

## Benefits of Denormalization

Event data is denormalized (copied) into ticket documents because:
- Faster reads (no need to join with events collection)
- Works even if event is deleted
- Simpler queries
- Better performance for ticket list display

## Testing Checklist

- [x] Create ticket from event detail page
- [x] Tickets appear in tickets page in real-time
- [x] Cannot create duplicate tickets for same event
- [x] Favorite toggle works
- [x] Cancel ticket works
- [x] Security rules prevent unauthorized access
- [x] Real-time updates work correctly

