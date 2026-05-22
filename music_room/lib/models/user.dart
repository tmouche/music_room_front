class User {
  final String _id;
  final String _username;
  final String? _email;
  final bool? _emailConfirmed;
  final String? _googleId;
  final List<String>? _favoriteGenres;
  final String _privacyLevel;

  User({
    required this._id,
    required this._username,
    required this._email,
    this._emailConfirmed = false,
    this._googleId,
    this._favoriteGenres,
    this._privacyLevel = 'Friends',
  });

  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? emailConfirmed,
    String? googleId,
    List<String>? favoriteGenres,
    String? privacyLevel,
  }) {
    return User(
      id: id ?? _id,
      username: username ?? _username,
      email: email ?? _email,
      emailConfirmed: emailConfirmed ?? _emailConfirmed,
      googleId: googleId ?? _googleId,
      favoriteGenres: favoriteGenres ?? _favoriteGenres,
      privacyLevel: privacyLevel ?? _privacyLevel,
    );
  }
}
