import '../models/user.dart';
import '../dummy_data.dart';

class UserRepository {
  Future<User> getCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return currentUser;
  }

  Future<List<User>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(allUsers);
  }

  Future<void> addUser(User user) async {
    await Future.delayed(const Duration(milliseconds: 100));
    allUsers.add(user);
  }

  Future<bool> updateUser(String email, User updated) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = allUsers.indexWhere((u) => u.email == email);
    if (index == -1) return false;
    allUsers[index] = updated;
    return true;
  }

  Future<bool> deleteUser(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = allUsers.indexWhere((u) => u.email == email);
    if (index == -1) return false;
    allUsers.removeAt(index);
    return true;
  }

  Future<bool> toggleUserActive(String email) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = allUsers.indexWhere((u) => u.email == email);
    if (index == -1) return false;
    final user = allUsers[index];
    allUsers[index] = user.copyWith(isActive: !user.isActive);
    return true;
  }
}
