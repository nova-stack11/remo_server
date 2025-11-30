// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/extension/list_ext.dart';
import 'package:shared_events/src/model/garden_model.dart';

class GardenDataRequest {
  GardenDataRequest({
    this.gardentId,
    this.userSeedId,
    this.seedId,
    this.farmId,
  });

  final String? gardentId;
  final String? userSeedId;
  final String? seedId;
  final String? farmId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'garden_id': gardentId,
      'user_seed_id': userSeedId,
      'seed_id': seedId,
      'farm_id': farmId,
    };
  }

  factory GardenDataRequest.fromMap(Map<String, dynamic> map) {
    return GardenDataRequest(
      gardentId: map['garden_id'] as String?,
      userSeedId: map['user_seed_id'] as String?,
      seedId: map['seed_id'] as String?,
      farmId: map['farm_id'] as String?,
    );
  }

  bool validated() {
    return gardentId != null &&
        gardentId!.isNotEmpty &&
        userSeedId != null &&
        userSeedId!.isNotEmpty &&
        seedId != null &&
        seedId!.isNotEmpty;
  }
}
