import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/model/farm_model.dart';

class GardenEventResponse {
  GardenEventResponse({
    required this.type,
    this.extras,
    this.farms,
    this.gardenPlots,
    this.seeds,
  });

  final String type;
  final Map<String, dynamic>? extras;
  final List<FarmModel>? farms;
  final List<GardenModel>? gardenPlots;
  final List<SeedModel>? seeds;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type,
      'extras': extras,
      'farms': farms?.map((e) => e.toMap()).toList(),
      'garden_plots': gardenPlots?.map((e) => e.toMap()).toList(),
      'seeds': seeds?.map((e) => e.toMap()).toList(),
    };
  }

  factory GardenEventResponse.fromMap(Map<String, dynamic> map) {
    return GardenEventResponse(
      type: map['type'] ?? '',
      extras: map['extras'],
      farms: (map['farms'] as List<dynamic>?)
          ?.map((e) => FarmModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      gardenPlots: (map['garden_plots'] as List<dynamic>?)
          ?.map((e) => GardenModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      seeds: (map['seeds'] as List<dynamic>?)
          ?.map((e) => SeedModel.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  GardenEventType toType() {
    return GardenEventTypeExt.fromString(type);
  }
}
