abstract class Datasource {
  Future<void> saveDocument({
    required String document,
    required List<Map<String, dynamic>> data,
  });
  Future<List<Map<String, dynamic>>> loadDocument({
    required String document,
  });
  Future<void> deleteDocument({
    required String document,
  });
  Future<Map<String, dynamic>?> insert({
    required String document,
    required Map<String, dynamic> data,
  });
  Future<Map<String, dynamic>?> getFirst({
    required String document,
  });

  Future<List<Map<String, dynamic>>> get({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  });
  Future<void> delete({
    required String document,
    required bool Function(Map<String, dynamic> element) test,
  });
  Future<bool> update({
    required String document,
    required Map<String, dynamic> data,
  });
}
