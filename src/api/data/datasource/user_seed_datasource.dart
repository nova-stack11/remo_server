import 'package:postgres/postgres.dart';
import '../../../database/database.dart';

/// Datasource cho garden plots
abstract class UserSeedDatasource {
  Future<void> createGardenPlot({
    required String userId,
    required String plotCode,
    required int plotState,
  });

  Future<void> updateGardenPlot({
    required String userId,
    required String plotCode,
    required int plotState,
  });

  Future<void> deleteGardenPlot({
    required String userId,
    required String plotCode,
  });

  Future<List<Map<String, dynamic>>> getGardenPlots(String userId);

  Future<Map<String, dynamic>?> getPlot(String userId, String plotCode);

  Future<void> unlockPlot(String userId, String plotCode);

  Future<bool> isPlotEmpty(String userId, String plotCode);

  Future<String?> getFirstSeedId();
}

/// Triển khai datasource cho garden
class UserSeedDatasourceImpl implements UserSeedDatasource {
  final DatabaseService db;
  UserSeedDatasourceImpl(this.db);

  @override
  Future<void> createGardenPlot({
    required String userId,
    required String plotCode,
    required int plotState,
  }) async {
    final query = Sql.named('''
      INSERT INTO user_garden_plots (user_id, plot_code, plot_state)
      VALUES (@user_id, @plot_code, @plot_state)
      ON CONFLICT (user_id, plot_code) DO NOTHING
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'user_id': userId,
        'plot_code': plotCode,
        'plot_state': plotState,
      },
    );
  }

  @override
  Future<void> updateGardenPlot({
    required String userId,
    required String plotCode,
    required int plotState,
  }) async {
    final query = Sql.named('''
      UPDATE user_garden_plots
      SET plot_state = @plot_state
      WHERE user_id = @user_id AND plot_code = @plot_code
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'user_id': userId,
        'plot_code': plotCode,
        'plot_state': plotState,
      },
    );
  }

  @override
  Future<void> deleteGardenPlot({
    required String userId,
    required String plotCode,
  }) async {
    final query = Sql.named('''
      DELETE FROM user_garden_plots
      WHERE user_id = @user_id AND plot_code = @plot_code
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'user_id': userId,
        'plot_code': plotCode,
      },
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getGardenPlots(String userId) async {
    final query = Sql.named('''
      SELECT * FROM user_garden_plots
      WHERE user_id = @user_id
      ORDER BY plot_code ASC
    ''');

    final result = await db.connection.execute(
      query,
      parameters: { 'user_id': userId },
    );

    return result.map((row) => row.toColumnMap()).toList();
  }

  @override
  Future<Map<String, dynamic>?> getPlot(String userId, String plotCode) async {
    final query = Sql.named('''
      SELECT *
      FROM user_garden_plots
      WHERE user_id = @user_id AND plot_code = @plot_code
      LIMIT 1
    ''');

    final res = await db.connection.execute(
      query,
      parameters: {
        'user_id': userId,
        'plot_code': plotCode,
      },
    );

    if (res.isEmpty) return null;
    return res.first.toColumnMap();
  }

  @override
  Future<void> unlockPlot(String userId, String plotCode) async {
    final query = Sql.named('''
      UPDATE user_garden_plots
      SET plot_state = 1
      WHERE user_id = @user_id AND plot_code = @plot_code
    ''');

    await db.connection.execute(
      query,
      parameters: {
        'user_id': userId,
        'plot_code': plotCode,
      },
    );
  }

  @override
  Future<bool> isPlotEmpty(String userId, String plotCode) async {
    // Kiểm tra plot có tồn tại không
    final plot = await getPlot(userId, plotCode);
    if (plot == null) return false;

    // Kiểm tra xem có cây trồng trong plot này không
    final query = Sql.named('''
      SELECT 1
      FROM user_farm_plants
      WHERE user_id = @user_id AND tile_x = @x AND tile_y = @y
      LIMIT 1
    ''');

    // tách x/y từ plotCode: dạng x1y3
    final code = plotCode.toLowerCase().replaceAll('x', '').split('y');
    final x = int.tryParse(code[0]) ?? 0;
    final y = int.tryParse(code[1]) ?? 0;

    final res = await db.connection.execute(
      query,
      parameters: {
        'user_id': userId,
        'x': x,
        'y': y,
      },
    );

    return res.isEmpty; // empty = không có cây = plot trống
  }

  @override
  Future<String?> getFirstSeedId() async {
    final query = Sql.named('''
      SELECT id
      FROM seed
      ORDER BY name ASC
      LIMIT 1
    ''');

    final res = await db.connection.execute(query);

    if (res.isEmpty) return null;
    return res.first.toColumnMap()['id'] as String;
  }
}