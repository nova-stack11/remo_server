
import '../../../database/database.dart';
import 'datasource.dart';
import 'package:postgres/postgres.dart';

class DbDatasource extends Datasource {
  DbDatasource(this.db);
  final DatabaseService db;

  @override
  Future<Map<String, dynamic>?> insert({
    required String document,
    required Map<String, dynamic> data,
  }) async {
    final columns = data.keys.join(', ');
    final parameters = <String, dynamic>{ for (var e in data.entries) e.key: e.value };

    final query = '''
    INSERT INTO $document ($columns)
    VALUES (${data.keys.map((k) => '@$k').join(', ')})
    RETURNING *
  ''';

    final result = await db.connection.execute(Sql.named(query), parameters: parameters);

    if (result.isEmpty) return null;

    // Trả về row đầu tiên dưới dạng map
    final insertedRow = result.first.toColumnMap();

    print("✅ Inserted record: $insertedRow");

    return insertedRow;
  }

  @override
  Future<void> deleteDocument({required String document}) async {
    await db.connection.execute('DELETE FROM $document');
  }

  @override
  Future<List<Map<String, dynamic>>> loadDocument({required String document}) async {
    final result = await db.connection.execute('SELECT * FROM $document');
    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<void> saveDocument({
    required String document,
    required List<Map<String, dynamic>> data,
  }) async {
    // Clears existing table and re-inserts data
    await db.connection.execute('DELETE FROM $document');
    for (final row in data) {
      await insert(document: document, data: row);
    }
  }

  @override
  Future<bool> update({
    required String document,
    required Map<String, dynamic> data,
  }) async {
    // Not easily implemented with arbitrary predicate; requires key
    if (!data.containsKey('id')) return false;
    final updateFields = data.keys.where((k) => k != 'id').toList();
    if (updateFields.isEmpty) return false;

    final updates = updateFields.map((k) => '$k=@$k').join(', ');
    final query = 'UPDATE $document SET $updates WHERE id=@id';
    await db.connection.execute(
      Sql.named(query),
      parameters: data,
    );
    return true;
  }

  @override
  Future<Map<String, dynamic>?> getFirst({
    required String document,
  }) async {
    final result = await db.connection.execute('SELECT * FROM $document LIMIT 1');
    if (result.isEmpty) return null;
    return result.first.toColumnMap();
  }

  @override
  Future<List<Map<String, dynamic>>> get({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  }) async {
    final result = await db.connection.execute('SELECT * FROM $document');
    final rows = result.map((r) => r.toColumnMap()).toList();
    return rows.where(test).toList();
  }

  @override
  Future<void> delete({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  }) async {
    final rows = await get(document: document, test: test);
    for (final row in rows) {
      if (row.containsKey('id')) {
        await db.connection.execute(
          Sql.named('DELETE FROM $document WHERE id=@id'),
          parameters: {'id': row['id']},
        );
      }
    }
  }
}
