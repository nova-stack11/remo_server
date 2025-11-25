// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:shared_events/shared_events.dart';

class GardenModel {
  final int? x;
  final int? y;
  final String? plot_state;

  GardenModel({required this.x, required this.y, required this.plot_state});

  GardenPlotState toState() {
    return GardenPlotStateExt.fromString(plot_state.orEmpty());
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'plot_state': plot_state,
    };
  }

  factory GardenModel.fromMap(Map<String, dynamic> map) {
    return GardenModel(
      x: map['x'] as int?,
      y: map['y'] as int?,
      plot_state: map['plot_state'] as String?,
    );
  }
}
