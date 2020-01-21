import 'package:food_ordering_app/components/Cart/CartItem.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  // Private constructor that can be used only inside the class
  DatabaseProvider._();

  static final DatabaseProvider db =  DatabaseProvider._();

  static Database _database;

  // this will return the database object, whether or not the object exist
  Future<Database> get database async {
    if(_database != null){
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  // opens the database and create the table if its not created already
  initDatabase() async {
    return await openDatabase(
      join(await getDatabasesPath(), 'customer_order.db'),
      onCreate: (db, version) async {
        return db.execute(
            "CREATE TABLE cart_items(id INTEGER PRIMARY KEY, food_id TEXT, name TEXT, name_chinese TEXT, price REAL, quantity INTEGER)");
      },
      version: 1,
    );
  }

  // ===================================
  //     CRUD
  // ===================================

  // inserting data to the database
  Future<int> insertData(CartItem cartItem) async {
    final db = await database;
    var result = await db.insert('cart_items', cartItem.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return result;
  }

  // reading the data to the database
  Future<List<CartItem>> readData() async {
    final db = await database;
    //returns a map after querying the table
    var result = await db.query('cart_items');

    //converting the map into a list
    List<CartItem> items =
      result.isNotEmpty
          ? result.map((item) => CartItem.fromJson(item)).toList()
          : [];
    return items;
  }

  // updating the data
  Future<int> updateData(CartItem cartItem) async {
    final db = await database;

    // updating the data base on the id from the object that was passed in
    var result = await db.update("cart_items", cartItem.toMap(),
      where: "id = ?", whereArgs: [cartItem.id]
    );
    print(result);
    return result;
  }


  // deleting the cart item/s
  Future<int> deleteSingleItem(int id) async {
    final db = await database;
    var result = await db.delete("cart_items", where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future deleteAllItems() async {
    final db = await database;
    var result = await db.rawDelete("Delete from cart_items");
    return result;
  }
}