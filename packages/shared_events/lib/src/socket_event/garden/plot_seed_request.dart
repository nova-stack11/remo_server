// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:shared_events/shared_events.dart';
import 'package:shared_events/src/extension/list_ext.dart';
import 'package:shared_events/src/model/garden_model.dart';

class PlotSeedRequest {
  PlotSeedRequest({
    required this.plotId,
    required this.userSeedId,
    required this.seedId,
  });

  final String? plotId;
  final String? userSeedId;
  final String? seedId;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'plot_id': plotId,
      'user_seed_id': userSeedId,
      'seed_id': seedId,
    };
  }

  factory PlotSeedRequest.fromMap(Map<String, dynamic> map) {
    return PlotSeedRequest(
      plotId: map['plot_id'] as String?,
      userSeedId: map['user_seed_id'] as String?,
      seedId: map['seed_id'] as String?,
    );
  }

  bool validated() {
    return plotId != null &&
        plotId!.isNotEmpty &&
        userSeedId != null &&
        userSeedId!.isNotEmpty &&
        seedId != null &&
        seedId!.isNotEmpty;
  }
}
