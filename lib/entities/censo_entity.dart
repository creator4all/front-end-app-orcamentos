class CensoGroupItem {
  final String name;
  final int value;

  CensoGroupItem({required this.name, required this.value});

  factory CensoGroupItem.fromJson(Map<String, dynamic> json) {
    final v = json['value'] ?? json['quantidade'] ?? 0;
    return CensoGroupItem(
      name: (json['name'] ?? json['nome'] ?? '').toString(),
      value: v is int ? v : int.tryParse('$v') ?? 0,
    );
  }
}

class CensoGroup {
  final String name;
  final List<CensoGroupItem> items;

  CensoGroup({required this.name, required this.items});

  factory CensoGroup.fromJson(Map<String, dynamic> json) {
    final items = (json['items'] ?? json['itens'] ?? []) as List;
    return CensoGroup(
      name: (json['name'] ?? json['nome'] ?? '').toString(),
      items: items
          .map((e) => CensoGroupItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CensoData {
  final int totalStudents;
  final String censusYear;
  final List<CensoGroup> groups;

  CensoData(
      {required this.totalStudents,
      required this.censusYear,
      required this.groups});

  factory CensoData.fromJson(Map<String, dynamic> json) {
    final groups = (json['groups'] ?? json['grupos'] ?? []) as List;
    final total = json['totalStudents'] ?? json['total_alunos'] ?? 0;
    return CensoData(
      totalStudents: total is int ? total : int.tryParse('$total') ?? 0,
      censusYear: (json['censusYear'] ?? json['ano'] ?? '').toString(),
      groups: groups
          .map((e) => CensoGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
