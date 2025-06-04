class Genre {
  final String id;
  final String name;
  final String created_at;
  final String updated_at;
  final String? deleted_at;

  Genre({
   required this.id,
   required this.name,
   required this.created_at,
   required this.updated_at,
   required this.deleted_at
  });

  @override
  String toString() {
    return 'Genre{id: $id, name: $name, created_at: $created_at,updated_at: $updated_at,deleted_at: $deleted_at}';
  }

}