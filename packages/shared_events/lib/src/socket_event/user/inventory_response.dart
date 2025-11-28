// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/extension/list_ext.dart';
import 'package:shared_events/src/model/garden_model.dart';

class InventoryResponse {
  InventoryResponse({
    this.seed,
  });

  final Iterable<SeedModel>? seed;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'seed': seed?.map((x) => x.toMap()).toList(),
    };
  }

  factory InventoryResponse.fromMap(Map<String, dynamic> map) {
    return InventoryResponse(
      seed: map.parseList('seed', SeedModel.fromMap),
    );
  }
}
