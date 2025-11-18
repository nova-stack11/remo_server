import '../../../database/database.dart';
import 'package:postgres/postgres.dart';

abstract class InventoryDatasource {
  Future<void> createInventory({required String userId});

  Future<void> addItem({
    required String userId,
    required String itemId,
    required int quantity,
  });
}

class InventoryDatasourceImpl implements InventoryDatasource {
  final DatabaseService db;
  InventoryDatasourceImpl(this.db);

  @override
  Future<void> createInventory({required String userId}) async {
    final query = Sql.named('''
      INSERT INTO user_inventory (user_id)
      VALUES (@user_id)
      ON CONFLICT (user_id) DO NOTHING
    ''');

    await db.connection.execute(query, parameters: {
      'user_id': userId,
    });
  }

  @override
  Future<void> addItem({
    required String userId,
    required String itemId,
    required int quantity,
  }) async {
    final query = Sql.named('''
      INSERT INTO user_inventory_items (user_id, item_id, quantity)
      VALUES (@user_id, @item_id, @quantity)
      ON CONFLICT (user_id, item_id)
      DO UPDATE SET quantity = user_inventory_items.quantity + @quantity
    ''');

    await db.connection.execute(query, parameters: {
      'user_id': userId,
      'item_id': itemId,
      'quantity': quantity,
    });
  }
}