import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
class DBHelper {
  static Database? _db;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await initDB();
    return _db!;
  }

  initDB() async {
    String path = join(await getDatabasesPath(), 'app.db');
    return await openDatabase(path, version: 3, onCreate: _onCreate);
  }

  _onCreate(Database db, int version) async {
    await db.execute('''
  CREATE TABLE users (
  user_id INTEGER PRIMARY KEY AUTOINCREMENT,
  first_name TEXT NOT NULL,
  last_name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  phone TEXT NOT NULL,
  password TEXT NOT NULL
)
  ''');

    await db.execute('''
  CREATE TABLE plans (
    plan_id INTEGER PRIMARY KEY AUTOINCREMENT,
    plan_name TEXT NOT NULL,
    price REAL NOT NULL,
    payment_periodicity TEXT NOT NULL,
    discount_applied INTEGER NOT NULL
  )
  ''');

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

    await db.execute('''
  CREATE TABLE workspace (
    resource_id INTEGER PRIMARY KEY,
    space_type TEXT,
    capacity INTEGER,
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
  )
  ''');

    await db.execute('''
  CREATE TABLE amenity (
    resource_id INTEGER PRIMARY KEY,
    amenity_type TEXT,
    FOREIGN KEY (resource_id) REFERENCES resources(resource_id)
  )
  ''');

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

    await db.execute('''
  CREATE TABLE invoice (
    invoice_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    issue_date TEXT,
    due_date TEXT,
    discount REAL,
    total REAL,
    status TEXT,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
  )
  ''');

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

    await db.insert('plans', {
      'plan_name': 'Weekly',
      'price': 70.0,
      'payment_periodicity': 'Weekly',
      'discount_applied': 8
    });

    await db.insert('plans', {
      'plan_name': 'Standard',
      'price': 220.0,
      'payment_periodicity': 'Monthly',
      'discount_applied': 10
    });

    await db.insert('plans', {
      'plan_name': 'Premium',
      'price': 750.0,
      'payment_periodicity': 'Yearly',
      'discount_applied': 15
    });

    // Workspaces
    await db.insert('resources', {
      'name': 'Hot Desk A1',
      'resource_type': 'Workspace',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 15
    });
    await db.insert('resources', {
      'name': 'Hot Desk A2',
      'resource_type': 'Workspace',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 15
    });
    await db.insert('resources', {
      'name': 'Dedicated Desk D1',
      'resource_type': 'Workspace',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 25
    });
    await db.insert('resources', {
      'name': 'Meeting Room M1',
      'resource_type': 'Workspace',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 50
    });
    await db.insert('resources', {
      'name': 'Conference Room C1',
      'resource_type': 'Workspace',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 120
    });

// Amenities
    await db.insert('resources', {
      'name': 'Color Printer',
      'resource_type': 'Amenity',
      'availability_status': 'Available',
      'unit_type': 'Page',
      'rate': 0.25
    });
    await db.insert('resources', {
      'name': '4K Projector',
      'resource_type': 'Amenity',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 20
    });
    await db.insert('resources', {
      'name': 'Coffee Machine',
      'resource_type': 'Amenity',
      'availability_status': 'Available',
      'unit_type': 'Unit',
      'rate': 3
    });
    await db.insert('resources', {
      'name': 'Locker Medium',
      'resource_type': 'Amenity',
      'availability_status': 'Available',
      'unit_type': 'Hour',
      'rate': 5
    });

    await db.insert('workspace',
        {'resource_id': 1, 'space_type': 'Hot Desk', 'capacity': 1});
    await db.insert('workspace',
        {'resource_id': 2, 'space_type': 'Hot Desk', 'capacity': 1});
    await db.insert('workspace',
        {'resource_id': 3, 'space_type': 'Dedicated Desk', 'capacity': 1});
    await db.insert('workspace',
        {'resource_id': 4, 'space_type': 'Meeting Room', 'capacity': 6});
    await db.insert('workspace',
        {'resource_id': 5, 'space_type': 'Conference Hall', 'capacity': 30});

    await db.insert('amenity', {'resource_id': 6, 'amenity_type': 'Printer'});
    await db.insert('amenity', {'resource_id': 7, 'amenity_type': 'Projector'});
    await db.insert('amenity', {'resource_id': 8, 'amenity_type': 'Kitchen'});
    await db.insert('amenity', {'resource_id': 9, 'amenity_type': 'Locker'});

    await db.insert('invoice', {
      'user_id': null,
      'issue_date': '2025-12-01',
      'due_date': '2025-12-15',
      'discount': 10,
      'total': 450,
      'status': 'Paid'
    });

    await db.insert('payment', {
      'invoice_id': 1,
      'payment_date': '2025-12-03',
      'method': 'Credit Card',
      'status': 'Completed'
    });

    Future<String> insertUser(Map<String, dynamic> user) async {
      final dbClient = await db;
      try {
        await dbClient.insert('users', user);
        return "success";
      } catch (e) {
        return "User already exists";
      }
    }
    Future<List<Map<String, dynamic>>> getUsers() async {
      final dbClient = await db;
      return await dbClient.query('users');
    }
    Future<int> insertPlan(Map<String, dynamic> plan) async {
      final dbClient = await db;
      return await dbClient.insert('plans', plan);
    }
    Future<List<Map<String, dynamic>>> getPlans() async {
      final dbClient = await db;
      return await dbClient.query('plans');
    }
    Future<int> insertMembership(Map<String, dynamic> membership) async {
      final dbClient = await db;
      return await dbClient.insert('membership', membership);
    }
    Future<List<Map<String, dynamic>>> getMembershipByUser(int userId) async {
      final dbClient = await db;
      return await dbClient.query(
        'membership',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    Future<int> insertResource(Map<String, dynamic> resource) async {
      final dbClient = await db;
      return await dbClient.insert('resources', resource);
    }
    Future<int> insertWorkspace(Map<String, dynamic> workspace) async {
      final dbClient = await db;
      return await dbClient.insert('workspace', workspace);
    }
    Future<int> insertAmenity(Map<String, dynamic> amenity) async {
      final dbClient = await db;
      return await dbClient.insert('amenity', amenity);
    }
    Future<List<Map<String, dynamic>>> getWorkspaces() async {
      final dbClient = await db;
      return await dbClient.rawQuery('''
    SELECT * FROM resources r
    JOIN workspace w ON r.resource_id = w.resource_id
  ''');
    }
    Future<List<Map<String, dynamic>>> getAmenities() async {
      final dbClient = await db;
      return await dbClient.rawQuery('''
    SELECT * FROM resources r
    JOIN amenity a ON r.resource_id = a.resource_id
  ''');
    }
    Future<int> insertBooking(Map<String, dynamic> booking) async {
      final dbClient = await db;
      return await dbClient.insert('booking', booking);
    }
    Future<List<Map<String, dynamic>>> getBookings(int userId) async {
      final dbClient = await db;
      return await dbClient.query(
        'booking',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }
    Future<int> cancelBooking(int bookingId) async {
      final dbClient = await db;
      return await dbClient.update(
        'booking',
        {'booking_status': 'cancelled'},
        where: 'booking_id = ?',
        whereArgs: [bookingId],
      );
    }
    Future<int> insertInvoice(Map<String, dynamic> invoice) async {
      final dbClient = await db;
      return await dbClient.insert('invoice', invoice);
    }
    Future<int> insertPayment(Map<String, dynamic> payment) async {
      final dbClient = await db;
      return await dbClient.insert('payment', payment);
    }
    Future<List<Map<String, dynamic>>> getPayments() async {
      final dbClient = await db;
      return await dbClient.query('payment');
    }
    Future<int> insertFeedback(Map<String, dynamic> feedback) async {
      final dbClient = await db;
      return await dbClient.insert('feedback', feedback);
    }
  }
}

