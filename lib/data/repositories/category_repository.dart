import '../models/category.dart';
import '../dummy_data.dart';

class CategoryRepository {
  Future<List<ReportCategory>> getAll() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(allReportCategories);
  }
}
