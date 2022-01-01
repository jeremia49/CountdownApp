// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'datum.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CountdownDatum _$CountdownDatumFromJson(Map<String, dynamic> json) =>
    CountdownDatum(
      json['title'] as String,
      targetDuration:
          json['targetDuration'] as int? ?? Countdown.initialTimerValue,
    )
      ..spendDuration = json['spendDuration'] as int
      ..createdAt = DateTime.parse(json['createdAt'] as String)
      ..done = json['done'] as bool;

Map<String, dynamic> _$CountdownDatumToJson(CountdownDatum instance) =>
    <String, dynamic>{
      'title': instance.title,
      'targetDuration': instance.targetDuration,
      'spendDuration': instance.spendDuration,
      'createdAt': instance.createdAt.toIso8601String(),
      'done': instance.done,
    };
