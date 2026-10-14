class Playlist {
  final String id;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int sortOrder;
  final int songCount;

  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.sortOrder = 0,
    this.songCount = 0,
  });

  Playlist copyWith({
    String? id,
    String? name,
    int? createdAt,
    int? updatedAt,
    int? sortOrder,
    int? songCount,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sortOrder: sortOrder ?? this.sortOrder,
      songCount: songCount ?? this.songCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sort_order': sortOrder,
    };
  }

  factory Playlist.fromMap(Map<String, dynamic> map, {int songCount = 0}) {
    return Playlist(
      id: map['id'] as String,
      name: map['name'] as String,
      createdAt: (map['created_at'] as num).toInt(),
      updatedAt: (map['updated_at'] as num).toInt(),
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 0,
      songCount: songCount,
    );
  }
}
