import 'countdown.dart';
import 'package:json_annotation/json_annotation.dart';

part 'datum.g.dart';

@JsonSerializable()
class CountdownDatum {
  final String title;
  late int duration;
  late DateTime createdAt;
  late bool done;

  CountdownDatum(this.title, {this.duration = Countdown.initialTimerValue}) {
    createdAt = DateTime.now();
    done = false;
  }

  factory CountdownDatum.fromJson(Map<String, dynamic> json) =>
      _$CountdownDatumFromJson(json);

  Map<String, dynamic> toJson() => _$CountdownDatumToJson(this);
}
