abstract class User {
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String username;
  final String createdAt;
  final bool isArtist;
  final int total_songs;
  final String? token;
  final String? refreshToken;
  final String? bio;
  final String? profile_image;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.isArtist,
    required this.total_songs,
    required this.token,
    required this.refreshToken,
    this.bio,
    this.profile_image,
    
  });

  @override
  String toString() {
    return 'User{userId: $userId, firstName: $firstName, lastName: $lastName, email: $email, username: $username, createdAt: $createdAt, isArtist: $isArtist, total_songs: $total_songs, token: $token, refreshToken: $refreshToken, bio: $bio, profile_Image: $profile_image}';
  }
}
