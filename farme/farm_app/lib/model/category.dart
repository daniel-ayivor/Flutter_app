import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String color;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int productCount;

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.color,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.productCount = 0,
  });

  factory Category.fromMap(Map<String, dynamic>? map, String id) {
    if (map == null) {
      return Category(
        id: id,
        name: 'Unknown',
        description: '',
        iconUrl: '',
        color: '#4CAF50',
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }

    return Category(
      id: id,
      name: map['name'] ?? 'Unknown',
      description: map['description'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      color: map['color'] ?? '#4CAF50',
      isActive: map['isActive'] ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      productCount: map['productCount'] ?? 0,
    );
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Category.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'color': color,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'productCount': productCount,
    };
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconUrl,
    String? color,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? productCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, description: $description, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
