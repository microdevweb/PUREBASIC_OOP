; ============================================================================
; PureBasic OOP - Contact SQLite Repository
; Author:      MicrodevWeb
; ============================================================================

XIncludeFile "../models/Contact.pbi"

Namespace ContactApp {

  Class ContactRepository {
    Protected dbHandle.i
    Protected dbFilePath.s

    Public Method Init() {
      This\dbHandle = 0
      This\dbFilePath = "contacts.db"
    }

    Public Method.i GetDbHandle() {
      ProcedureReturn This\dbHandle
    }

    Public Method.b OpenDB(filePath.s = "contacts.db") {
      This\dbFilePath = filePath
      UseSQLiteDatabase()

      If (FileSize(filePath) <= 0)
        Protected f = CreateFile(#PB_Any, filePath)
        If (f)
          CloseFile(f)
        EndIf
      EndIf

      This\dbHandle = OpenDatabase(#PB_Any, filePath, "", "")
      If (This\dbHandle)
        This\CreateSchema()
        ProcedureReturn #True
      EndIf
      ProcedureReturn #False
    }

    Public Method CreateSchema() {
      If (Not This\dbHandle) : ProcedureReturn : EndIf

      Protected sql.s = "CREATE TABLE IF NOT EXISTS contacts (" +
                        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                        "first_name TEXT, " +
                        "last_name TEXT, " +
                        "email TEXT, " +
                        "phone TEXT, " +
                        "company TEXT, " +
                        "notes TEXT" +
                        ");"
      DatabaseUpdate(This\dbHandle, sql)
    }

    Public Method.i GetTotalCount() {
      If (Not This\dbHandle) : ProcedureReturn 0 : EndIf
      Protected count.i = 0
      If (DatabaseQuery(This\dbHandle, "SELECT COUNT(*) FROM contacts;"))
        If (NextDatabaseRow(This\dbHandle))
          count = GetDatabaseLong(This\dbHandle, 0)
        EndIf
        FinishDatabaseQuery(This\dbHandle)
      EndIf
      ProcedureReturn count
    }

    Public Method.i Add(*c.ContactApp::Contact) {
      If (Not This\dbHandle Or Not *c) : ProcedureReturn 0 : EndIf

      Protected fn.s = ReplaceString(*c\GetFirstName(), "'", "''")
      Protected ln.s = ReplaceString(*c\GetLastName(), "'", "''")
      Protected em.s = ReplaceString(*c\GetEmail(), "'", "''")
      Protected ph.s = ReplaceString(*c\GetPhone(), "'", "''")
      Protected co.s = ReplaceString(*c\GetCompany(), "'", "''")
      Protected nt.s = ReplaceString(*c\GetNotes(), "'", "''")

      Protected sql.s = "INSERT INTO contacts (first_name, last_name, email, phone, company, notes) VALUES (" +
                        "'" + fn + "', " +
                        "'" + ln + "', " +
                        "'" + em + "', " +
                        "'" + ph + "', " +
                        "'" + co + "', " +
                        "'" + nt + "');"

      If (DatabaseUpdate(This\dbHandle, sql))
        If (DatabaseQuery(This\dbHandle, "SELECT last_insert_rowid();"))
          If (NextDatabaseRow(This\dbHandle))
            *c\SetId(GetDatabaseLong(This\dbHandle, 0))
          EndIf
          FinishDatabaseQuery(This\dbHandle)
        EndIf
        ProcedureReturn *c\GetId()
      EndIf
      ProcedureReturn 0
    }

    Public Method.b Update(*c.ContactApp::Contact) {
      If (Not This\dbHandle Or Not *c Or *c\GetId() <= 0) : ProcedureReturn #False : EndIf

      Protected fn.s = ReplaceString(*c\GetFirstName(), "'", "''")
      Protected ln.s = ReplaceString(*c\GetLastName(), "'", "''")
      Protected em.s = ReplaceString(*c\GetEmail(), "'", "''")
      Protected ph.s = ReplaceString(*c\GetPhone(), "'", "''")
      Protected co.s = ReplaceString(*c\GetCompany(), "'", "''")
      Protected nt.s = ReplaceString(*c\GetNotes(), "'", "''")

      Protected sql.s = "UPDATE contacts SET " +
                        "first_name = '" + fn + "', " +
                        "last_name = '" + ln + "', " +
                        "email = '" + em + "', " +
                        "phone = '" + ph + "', " +
                        "company = '" + co + "', " +
                        "notes = '" + nt + "' " +
                        "WHERE id = " + Str(*c\GetId()) + ";"

      ProcedureReturn DatabaseUpdate(This\dbHandle, sql)
    }

    Public Method.b Delete(id.i) {
      If (Not This\dbHandle Or id <= 0) : ProcedureReturn #False : EndIf
      Protected sql.s = "DELETE FROM contacts WHERE id = " + Str(id) + ";"
      ProcedureReturn DatabaseUpdate(This\dbHandle, sql)
    }

    Public Method.i GetById(id.i) {
      If (Not This\dbHandle Or id <= 0) : ProcedureReturn 0 : EndIf

      Protected sql.s = "SELECT id, first_name, last_name, email, phone, company, notes FROM contacts WHERE id = " + Str(id) + ";"
      Protected *contact.ContactApp::Contact = 0

      If (DatabaseQuery(This\dbHandle, sql))
        If (NextDatabaseRow(This\dbHandle))
          *contact = New ContactApp::Contact(GetDatabaseLong(This\dbHandle, 0), GetDatabaseString(This\dbHandle, 1), GetDatabaseString(This\dbHandle, 2), GetDatabaseString(This\dbHandle, 3), GetDatabaseString(This\dbHandle, 4), GetDatabaseString(This\dbHandle, 5), GetDatabaseString(This\dbHandle, 6))
        EndIf
        FinishDatabaseQuery(This\dbHandle)
      EndIf

      ProcedureReturn *contact
    }

    Public Method SeedDefaultContacts() {
      If (This\GetTotalCount() = 0)
        Protected *c1.ContactApp::Contact = New ContactApp::Contact(0, "John", "Doe", "john.doe@example.com", "+1-555-0100", "Acme Corp", "Key client account")
        This\Add(*c1)
        *c1\Free()

        Protected *c2.ContactApp::Contact = New ContactApp::Contact(0, "Alice", "Smith", "alice.smith@techvision.org", "+1-555-0200", "TechVision Inc", "Lead UI Architect")
        This\Add(*c2)
        *c2\Free()

        Protected *c3.ContactApp::Contact = New ContactApp::Contact(0, "Robert", "Johnson", "r.johnson@globalsolutions.com", "+44-20-7946-0912", "Global Solutions", "Project Director")
        This\Add(*c3)
        *c3\Free()

        Protected *c4.ContactApp::Contact = New ContactApp::Contact(0, "Emma", "Watson", "emma.w@creativemedia.io", "+33-1-42-68-55-00", "Creative Media", "Design Consultant")
        This\Add(*c4)
        *c4\Free()
      EndIf
    }

    Public Method CloseDB() {
      If (This\dbHandle)
        CloseDatabase(This\dbHandle)
        This\dbHandle = 0
      EndIf
    }

    Public Method Free() {
      This\CloseDB()
    }
  }

}
