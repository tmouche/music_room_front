class ApiPath {
  static const String authLogin = '/auth/login';
  static const String authGoogleLogin = '/auth/google-login';
  static const String authLogout = '/auth/logout';
  static const String authPasswordReset = '/auth/reset-password';
  static const String authPasswordForgot = '/auth/forgot-password';
  static const String authRegister = '/auth/register';

  static const String users = "/users";
  static const String userMe = '$users/me';
  static const String userPasswordUpdate = '$userMe/password';
  static const String userEmailConfirm = '$userMe/send-confirmation-email'; 
  static const String userEmailUpdate = '$userMe/email';
  static const String userFavoriteGenreUpdate = '$userMe/favorite-genres';
  static const String userPrivacyUpdate = '$userMe/privacy';
  static String usersGet(String userId) => '$users/$userId';

  static const String rooms = '/rooms';
  static String roomsTrackManage(String roomId) => '$rooms/$roomId/queue';
  static String roomsPrivatize(String roomId) => '$rooms/$roomId/privatize';
  static String roomsPublish(String roomId) => '$rooms/$roomId/publish';
  static String roomsLicenceDisable(String roomId) => '$rooms/$roomId/disable-licence';
  static String roomsLicenceEnable(String roomId) => '$rooms/$roomId/enable-licence';
  static String roomsInvite(String roomId, String inviteeId) => '$rooms/$roomId/invite/$inviteeId';
  static String roomsOwnershipTransfert(String roomId) => '$rooms/$roomId/transfer-ownership';
  static String roomsWebSocket(String roomId) => '$rooms/$roomId/ws';

  static const String hifi = "/hifi";
  static String hifiSearchTrack(String encodedQuery) => '$hifi/search/$encodedQuery';
  static String hifiTrackStream(int trackId) => '$hifi/track/$trackId/stream-url';
  static String hifiTrackInfo(int trackId) => '$hifi/track/$trackId';

  static const String friends = "/friends";

  static String friendsDelete(String friendId) => '$friends/$friendId';
  static String friendsInviteAccept(String friendId) => '$friends/$friendId/accept'; 
  static String friendsInviteReject(String friendId) => '$friends/$friendId/reject'; 

}