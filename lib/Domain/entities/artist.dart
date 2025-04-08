class Artist {
  final int artistId;
  final String name;
  final String username;

  Artist({
    required this.artistId,
    required this.name,
    required this.username,
  });

  @override
  String toString() {
    return 'Artist{artistId: $artistId, name: $name, username: $username}';
  }
}

