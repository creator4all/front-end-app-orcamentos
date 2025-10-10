class BreadcrumbItem {
  final int? id;
  final String name;
  final bool isRoot;

  const BreadcrumbItem({
    this.id,
    required this.name,
    this.isRoot = false,
  });

  factory BreadcrumbItem.root() {
    return const BreadcrumbItem(
      name: 'Início',
      isRoot: true,
    );
  }

  factory BreadcrumbItem.fromFolder({
    required int id,
    required String name,
  }) {
    return BreadcrumbItem(
      id: id,
      name: name,
      isRoot: false,
    );
  }

  BreadcrumbItem copyWith({
    int? id,
    String? name,
    bool? isRoot,
  }) {
    return BreadcrumbItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isRoot: isRoot ?? this.isRoot,
    );
  }

  @override
  String toString() {
    return 'BreadcrumbItem(id: $id, name: $name, isRoot: $isRoot)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is BreadcrumbItem &&
        other.id == id &&
        other.name == name &&
        other.isRoot == isRoot;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ isRoot.hashCode;
  }
}
