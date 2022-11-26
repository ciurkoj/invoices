import 'package:invoices/models/invoice.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class InvoiceDatabase {
  static InvoiceDatabase instance = InvoiceDatabase.init();
  static bool opened = false;
  static Database? _database;

  InvoiceDatabase.init({bool? reopen}){
    if(reopen ==true){
      opened = reopen!;
    }
  }

  Future<Database> get database async {
    if (_database != null && !opened) return _database!;

    _database = await _initDB('invoices.db');
    opened = false;
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const doubleType = 'DOUBLE NOT NULL';

    await db.execute('''
    CREATE TABLE $tableInvoice (
    ${InvoiceFields.id} $idType, 
    ${InvoiceFields.invoiceId} $textType, 
    ${InvoiceFields.businessPartner} $textType,  
    ${InvoiceFields.netAmount} $integerType,  
    ${InvoiceFields.grossAmount} $textType,  
    ${InvoiceFields.vat} $doubleType,
    ${InvoiceFields.file} $textType
    )
    ''');
  }

  Future<Invoice> create(Invoice invoice) async {
    final db = await instance.database;

    final id = await (db.insert(tableInvoice, invoice.toJson(invoice)));
    return invoice.copy(id: id);
  }

  Future<Invoice> readInvoice(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableInvoice,
      columns: InvoiceFields.values,
      where: '${InvoiceFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Invoice.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Invoice>> readAllInvoices() async {
    final db = await instance.database;

    const orderBy = '${InvoiceFields.id} DESC';
    final result = await db.query(tableInvoice, orderBy: orderBy);
    return result.map((json) => Invoice.fromJson(json)).toList();
  }

  Future<int> update(Invoice invoice) async {
    final db = await instance.database;

    return db.update(
      tableInvoice,
      invoice.toJson(invoice),
      where: '${InvoiceFields.id} = ?',
      whereArgs: [invoice.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableInvoice,
      where: '${InvoiceFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
