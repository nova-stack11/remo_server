import 'package:postgres/postgres.dart';
import '../../../database/database.dart';

/// Datasource cho garden plots
abstract class GardenDatasource {
  Future<void> createGardenPlot({
    required String userId,
    required String plotCode,
    required String plotState,
  });

  Future<void> updateGardenPlot({
    required String userId,
    required String plotCode,
    required String plotState,
  });

  Future<void> deleteGardenPlot({
    required String userId,
    required String plotCode,
  });

  Future<List<Map<String, dynamic>>> getGardenPlots(String userId);
}

/// Triển khai datasource cho garden
class GardenDatasourceImpl implements GardenDatasource {
  final DatabaseService db;
  GardenDatasourceImpl(this.db);

  @override
  Future<void> createGardenPlot({
    required String userId,
    required String plotCode,
    required String plotState,
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
    required String plotState,
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
}