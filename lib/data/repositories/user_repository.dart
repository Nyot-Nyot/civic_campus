import '../models/user.dart';
import '../dummy_data.dart';

class UserRepository {
  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return currentUser;
  }
}
