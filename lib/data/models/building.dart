class Floor {
  final String name;
  final List<String> areas;
  const Floor({required this.name, required this.areas});
}

class Building {
  final String name;
  final List<Floor> floors;
  const Building({required this.name, required this.floors});
}
