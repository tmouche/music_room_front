class User {
  final String _id;
  final String _username;
  final String? _email;
  final bool _emailConfirmed;
  final String? _googleId;
  final List<String>? _favoriteGenres;
  final String _privacyLevel;
  final bool  _premiumUser;

  User({
    required this._id,
    required this._username,
    required this._email,
    this._emailConfirmed = false,
    this._googleId,
    this._favoriteGenres,
    this._privacyLevel = 'Friends',
    this._premiumUser = false,
  });

  String        get id => _id;
  String?       get email => _email;
  String        get username => _username;
  bool          get isEmailConfirmed => _emailConfirmed;
  List<String>  get favoriteGenres => _favoriteGenres ?? [];
  String        get privacyLevel => _privacyLevel; 
  bool          get premiumUser => _premiumUser;

  User copyWith({
    String? id,
    String? username,
    String? email,
    bool? emailConfirmed,
    String? googleId,
    List<String>? favoriteGenres,
    String? privacyLevel,
    bool? premiumUser
  }) {
    return User(
      id: id ?? _id,
      username: username ?? _username,
      email: email ?? _email,
      emailConfirmed: emailConfirmed ?? _emailConfirmed,
      googleId: googleId ?? _googleId,
      favoriteGenres: favoriteGenres ?? _favoriteGenres,
      privacyLevel: privacyLevel ?? _privacyLevel,
      premiumUser: premiumUser ?? _premiumUser
    );
  }
}
