import 'package:namer_app/models/member_model.dart';

class PrayerRequest {
  // String id;
  // String hcId;
  Member member;
  String request;
  // String createdAt;
  // String updatedAt;

  PrayerRequest({
    // required this.id,
    // required this.hcId,
    required this.member,
    required this.request,
    // required this.createdAt,
    // required this.updatedAt,
  });

  factory PrayerRequest.fromJson(Map<String, dynamic> json) {
    return PrayerRequest(
      // id: json['_id'],
      // hcId: json['hcId'],
      member: Member.fromJson(json['memberId']),
      request: json['request'],
      // createdAt: json['createdAt'],
      // updatedAt: json['updatedAt'],
    );
  }
}
