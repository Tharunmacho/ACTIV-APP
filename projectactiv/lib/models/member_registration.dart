class MemberRegistration {
  final String? profilePhotoUrl;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final DateTime dateOfBirth;
  final String memberType;
  final String category;
  final String address;
  final String state;
  final String city;
  final String pinCode;
  final String panNumber;
  final DateTime registrationDate;
  final String userId;

  MemberRegistration({
    this.profilePhotoUrl,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    required this.dateOfBirth,
    required this.memberType,
    required this.category,
    required this.address,
    required this.state,
    required this.city,
    required this.pinCode,
    required this.panNumber,
    required this.registrationDate,
    required this.userId,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'profilePhotoUrl': profilePhotoUrl,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'memberType': memberType,
      'category': category,
      'address': address,
      'state': state,
      'city': city,
      'pinCode': pinCode,
      'panNumber': panNumber,
      'registrationDate': registrationDate.toIso8601String(),
      'userId': userId,
      'status': 'pending', // Default status
    };
  }

  factory MemberRegistration.fromFirestore(Map<String, dynamic> data) {
    return MemberRegistration(
      profilePhotoUrl: data['profilePhotoUrl'],
      fullName: data['fullName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      gender: data['gender'] ?? '',
      dateOfBirth: DateTime.parse(data['dateOfBirth']),
      memberType: data['memberType'] ?? '',
      category: data['category'] ?? '',
      address: data['address'] ?? '',
      state: data['state'] ?? '',
      city: data['city'] ?? '',
      pinCode: data['pinCode'] ?? '',
      panNumber: data['panNumber'] ?? '',
      registrationDate: DateTime.parse(data['registrationDate']),
      userId: data['userId'] ?? '',
    );
  }
}
