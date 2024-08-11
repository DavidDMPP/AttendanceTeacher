class Teacher {
  final String id;
  final String nip;
  final String name;
  final String email;

  Teacher({required this.id, required this.nip, required this.name, required this.email});

  factory Teacher.fromMap(Map<String, dynamic> data, String id) {
    return Teacher(
      id: id,
      nip: data['nip'],
      name: data['name'],
      email: data['email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nip': nip,
      'name': name,
      'email': email,
    };
  }
}