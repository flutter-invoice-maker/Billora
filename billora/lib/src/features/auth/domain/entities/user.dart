class User {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;

  User({
    required this.id, 
    required this.email, 
    this.displayName,
    this.photoURL,
  });
} 