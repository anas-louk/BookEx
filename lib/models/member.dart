class Member {
  int? id;
  String name;
  String? email;
  String? phone;

  Member({
    this.id,
    required this.name,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
    );
  }
}