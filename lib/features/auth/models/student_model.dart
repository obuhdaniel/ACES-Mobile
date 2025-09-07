class AcesStudent {
  final String id;
  final String name;
  final String email;
  final String matNo;
  final String? uniEmail;
  final String level;

  AcesStudent({
    required this.id,
    required this.name,
    required this.email,
    required this.matNo,
    this.uniEmail,
    required this.level,
  });

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'matNo': matNo,
      'uniEmail': uniEmail,
      'level': level,
    };
  }

  // Create from Map
  factory AcesStudent.fromMap(Map<String, dynamic> map) {
    return AcesStudent(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      matNo: map['matNo'] as String,
      uniEmail: map['uniEmail'] as String?,
      level: map['level'] as String,
    );
  }

  // Your existing JSON methods (kept for reference)
  factory AcesStudent.fromJson(Map<String, dynamic> json) {
    return AcesStudent(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      matNo: json['matNo'],
      uniEmail: json['uniEmail'], 
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'matNo': matNo,
      'uniEmail': uniEmail,
      'level': level,
    };
  }
}