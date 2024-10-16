import 'dart:convert';

import 'package:namer_app/models/member_model.dart';

class HostingSchedule {
  final String id;
  // final String hcId;
  final DateTime date;
  // final DateTime createdAt;
  // final DateTime updatedAt;
  final Member hostId;
  // final List<String> attendeeIds;

  HostingSchedule({
    required this.id,
    // required this.hcId,
    required this.date,
    // required this.createdAt,
    // required this.updatedAt,
    required this.hostId,
    // required this.attendeeIds,
  });

  factory HostingSchedule.fromJson(Map<String, dynamic> json) {
    return HostingSchedule(
      id: json['_id'],
      // hcId: json['hcId'],
      date: DateTime.parse(json['date']),
      // createdAt: DateTime.parse(json['createdAt']),
      // updatedAt: DateTime.parse(json['updatedAt']),
      hostId: Member.fromJson(json['hostId']),
      // attendeeIds: List<String>.from(json['attendeeIds']),
    );
  }
}
