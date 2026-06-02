class Floor {
  final String name;
  final List<String> areas;
  const Floor({required this.name, required this.areas});

  Floor copyWith({String? name, List<String>? areas}) {
    return Floor(
      name: name ?? this.name,
      areas: areas ?? this.areas,
    );
  }
}

class Building {
  final String name;
  final List<Floor> floors;
  const Building({required this.name, required this.floors});

  Building copyWith({String? name, List<Floor>? floors}) {
    return Building(
      name: name ?? this.name,
      floors: floors ?? this.floors,
    );
  }
}
