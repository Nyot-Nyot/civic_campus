import '../models/category.dart';
import '../dummy_data.dart';

class CategoryRepository {
  Future<List<ReportCategory>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(allReportCategories);
  }

  Future<void> add(ReportCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    allReportCategories.add(category);
  }

  Future<void> update(int index, ReportCategory category) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (index >= 0 && index < allReportCategories.length) {
      allReportCategories[index] = category;
    }
  }

  Future<void> delete(int index) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (index >= 0 && index < allReportCategories.length) {
      allReportCategories.removeAt(index);
    }
  }
}
