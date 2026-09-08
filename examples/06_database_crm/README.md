# 06 - Database CRM Demo

This example demonstrates the **PureBasic OOP Alpha 1.4 ORM Engine** with a simple Customer/Contact CRM.

## What It Shows

| Feature | How |
|---|---|
| Auto table creation | `ORM::AutoMigrate()` creates `clients` and `contacts` tables on first run |
| Schema migration | Adding a new field to `Client` class adds the column on next startup |
| 1-N relation | `Client` owns `List Contacts.Contact()` — save client = save all contacts |
| Non-blocking save | `SaveAsync()` runs in a background thread, UI stays at 60 FPS |
| Record locking | `ORM_LockManager::Lock()` blocks other stations from editing same record |
| Auto-expire locks | If a station crashes, lock expires in 60 seconds (no permanent deadlock) |
| Restrict delete | Cannot delete a client that still has contacts (configurable) |

## How to Run

1. Open `main.pb` in the PureBasic OOP IDE
2. Press **F5** (Run)
3. A file `crm_demo.db` is created in the same folder
4. Use the buttons to add, save, lock, and unlock client records

## Files

- `main.pb` — Full demo application
- `crm_demo.db` — SQLite database (created at runtime, not in version control)

## Cascade Rules Configured in This Demo

```purebasic
relations()\cascadeSave  = #True            ; SaveAsync(client) saves all contacts
relations()\deletePolicy = #ORM_Restrict_Delete  ; Cannot delete client with contacts
```

To allow cascade delete instead, change to:
```purebasic
relations()\deletePolicy = #ORM_Cascade_Delete
```

## Testing Multi-Station Locking

To simulate two workstations:
1. Run the application twice simultaneously
2. In window 1: add a client, save it, then click **Lock Record**
3. In window 2: select the same client id and click **Lock Record**
4. Window 2 should display: _"This record is being edited by [user] on [station]"_
5. Close window 1 without clicking Unlock
6. Wait 60 seconds
7. In window 2: click **Lock Record** again — it now succeeds (lease expired)
