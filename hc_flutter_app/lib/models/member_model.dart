class Member {
  String id;
  String name;
  String hcId;
  String address;
  String? email;
  String createdAt;
  String updatedAt;

  Member({
    required this.id,
    required this.name,
    required this.hcId,
    required this.address,
    this.email,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['_id'],
      name: json['name'],
      hcId: json['hcId'],
      address: json['address'],
      email: json['email'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}
