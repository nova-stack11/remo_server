// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/extension/list_ext.dart';
import 'package:shared_events/src/model/garden_model.dart';

class PlotSeedRequest {
  PlotSeedRequest({
    required this.plotId,
    required this.seedId,
  });

  final String plotId;
  final String seedId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'plotId': plotId,
      'seedId': seedId,
    };
  }

  factory PlotSeedRequest.fromMap(Map<String, dynamic> map) {
    return PlotSeedRequest(
      plotId: map['plotId'] as String,
      seedId: map['seedId'] as String,
    );
  }
}
