import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  Future<Database> initDB() async {
    String path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(
      path,
      version: 5, // 🔥 IMPORTANT (updated)
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {

    // ================= USERS =================
    await db.execute('''
      CREATE TABLE users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        first_name TEXT,
        last_name TEXT,
        email TEXT UNIQUE,
        phone TEXT,
        password TEXT
      )
    ''');

    // ================= PLANS =================
    await db.execute('''
      CREATE TABLE plans (
        plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
        plan_name TEXT,
        price REAL,
        payment_periodicity TEXT,
        discount_applied INTEGER
      )
    ''');

    // ================= MEMBERSHIP =================
    await db.execute('''
      CREATE TABLE membership (
        membership_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        plan_id INTEGER,
        start_date TEXT,
        end_date TEXT,
        status TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (plan_id) REFERENCES plans(plan_id)
      )
    ''');

    // ================= RESOURCES =================
    await db.execute('''
      CREATE TABLE resources (
        resource_id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        resource_type TEXT,
        availability_status TEXT,
        unit_type TEXT,
        rate REAL
      )
    ''');

    // ================= WORKSPACE =================
    await db.execute('''
      CREATE TABLE workspace (
        resource_id INTEGER PRIMARY KEY,
        space_type TEXT,
        capacity INTEGER,
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
      )
    ''');

    // ================= AMENITY =================
    await db.execute('''
      CREATE TABLE amenity (
        resource_id INTEGER PRIMARY KEY,
        amenity_type TEXT,
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
      )
    ''');

    // ================= BOOKING =================
    await db.execute('''
      CREATE TABLE booking (
        booking_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        resource_id INTEGER,
        start_time TEXT,
        end_time TEXT,
        booking_status TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
      )
    ''');

    // ================= INVOICE =================
    await db.execute('''
      CREATE TABLE invoice (
        invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        booking_id INTEGER,
        issue_date TEXT,
        due_date TEXT,
        discount REAL,
        total REAL,
        status TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (booking_id) REFERENCES booking(booking_id)
      )
    ''');

    // ================= PAYMENT =================
    await db.execute('''
      CREATE TABLE payment (
        payment_id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER,
        payment_date TEXT,
        method TEXT,
        status TEXT,
        FOREIGN KEY (invoice_id) REFERENCES invoice(invoice_id)
      )
    ''');

    // ================= FEEDBACK =================
    await db.execute('''
      CREATE TABLE feedback (
        feedback_id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        resource_id INTEGER,
        rating REAL,
        message TEXT,
        submitted_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(user_id),
        FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
      )
    ''');

    // ================= PLANS DATA =================
    await db.insert('plans', {'plan_name': 'Weekly', 'price': 70, 'payment_periodicity': 'Weekly', 'discount_applied': 8});
    await db.insert('plans', {'plan_name': 'Standard', 'price': 220, 'payment_periodicity': 'Monthly', 'discount_applied': 10});
    await db.insert('plans', {'plan_name': 'Premium', 'price': 750, 'payment_periodicity': 'Yearly', 'discount_applied': 15});

    // ================= WORKSPACES =================

    // 5 Hot Desks
    for (int i = 1; i <= 5; i++) {
      int id = await db.insert('resources', {
        'name': 'Hot Desk $i',
        'resource_type': 'Workspace',
        'availability_status': 'Available',
        'unit_type': 'Hour',
        'rate': 15,
      });
      await db.insert('workspace', {'resource_id': id, 'space_type': 'Hot Desk', 'capacity': 1});
    }

    // 4 Dedicated Rooms
    for (int i = 1; i <= 4; i++) {
      int id = await db.insert('resources', {
        'name': 'Dedicated Room $i',
        'resource_type': 'Workspace',
        'availability_status': 'Available',
        'unit_type': 'Hour',
        'rate': 40,
      });
      await db.insert('workspace', {'resource_id': id, 'space_type': 'Dedicated Room', 'capacity': 2});
    }

    // 3 Meeting Rooms
    for (int i = 1; i <= 3; i++) {
      int id = await db.insert('resources', {
        'name': 'Meeting Room $i',
        'resource_type': 'Workspace',
        'availability_status': 'Available',
        'unit_type': 'Hour',
        'rate': 60,
      });
      await db.insert('workspace', {'resource_id': id, 'space_type': 'Meeting Room', 'capacity': 6});
    }

    // 2 Conference Halls
    for (int i = 1; i <= 2; i++) {
      int id = await db.insert('resources', {
        'name': 'Conference Hall $i',
        'resource_type': 'Workspace',
        'availability_status': 'Available',
        'unit_type': 'Hour',
        'rate': 120,
      });
      await db.insert('workspace', {'resource_id': id, 'space_type': 'Conference Hall', 'capacity': 30});
    }

    // ================= AMENITIES =================

    List amenities = [
      {'name': 'Color Printer', 'type': 'Printer', 'rate': 0.25},
      {'name': '4K Projector', 'type': 'Projector', 'rate': 20},
      {'name': 'Coffee Machine', 'type': 'Coffee', 'rate': 3},
      {'name': 'Locker Medium', 'type': 'Locker', 'rate': 5},
    ];

    for (var a in amenities) {
      int id = await db.insert('resources', {
        'name': a['name'],
        'resource_type': 'Amenity',
        'availability_status': 'Available',
        'unit_type': 'Unit',
        'rate': a['rate'],
      });

      await db.insert('amenity', {
        'resource_id': id,
        'amenity_type': a['type'],
      });
    }
  }
}