import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/user.dart';
import 'package:civic_campus/data/repositories/user_repository.dart';
import 'package:civic_campus/widgets/state_views.dart';

class SuperAdminUsersTab extends StatefulWidget {
  const SuperAdminUsersTab({super.key});

  @override
  State<SuperAdminUsersTab> createState() => _SuperAdminUsersTabState();
}

class _SuperAdminUsersTabState extends State<SuperAdminUsersTab> {
  final _repo = UserRepository();
  List<User> _users = [];
  bool _isLoading = true;
  bool _hasError = false;

  static const _roles = [
    'Student',
    'Staff',
    'Facility Admin',
    'Super Admin',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final users = await _repo.getAllUsers();
      if (!mounted) return;
      setState(() {
        _users = users;
      });
    } catch (e) {
      debugPrint('SuperAdminUsersTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showUserSheet({User? user}) async {
    final isEditing = user != null;
    final originalEmail = user?.email;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    String selectedRole = user?.role ?? 'Student';
    bool activeStatus = user?.isActive ?? true;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEditing ? 'Edit Pengguna' : 'Tambah Pengguna',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setSheetState(() => selectedRole = v);
                      }
                    },
                  ),
                  if (isEditing) ...[
                    const SizedBox(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(activeStatus ? 'Aktif' : 'Non-aktif',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                      subtitle: Text(activeStatus ? 'Pengguna dapat login.' : 'Pengguna tidak dapat login.',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                      value: activeStatus,
                      activeThumbColor: const Color(0xFF10B981),
                      onChanged: (v) => setSheetState(() => activeStatus = v),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email = emailController.text.trim();
                        if (name.isEmpty || email.isEmpty) return;
                        final newUser = User(
                          name: name,
                          role: selectedRole,
                          email: email,
                          isActive: activeStatus,
                        );
                        if (isEditing) {
                          await _repo.updateUser(originalEmail!, newUser);
                        } else {
                          await _repo.addUser(newUser);
                        }
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx, true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111827),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      ),
                      child: Text(isEditing ? 'Simpan' : 'Tambah'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    if (saved == true) {
      _load();
    }
  }

  Future<void> _deleteUser(User user) async {
    final name = user.name;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Pengguna'),
        content: Text('Hapus "$name"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _repo.deleteUser(user.email);
      if (!mounted) return;
      _load();
    }
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'Student':
        return const Color(0xFF3B82F6);
      case 'Staff':
        return const Color(0xFF10B981);
      case 'Facility Admin':
        return const Color(0xFFF97316);
      case 'Super Admin':
        return const Color(0xFF8B5CF6);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingView();
    if (_hasError) return ErrorView(message: 'Gagal memuat pengguna.', onRetry: _load);

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    const Expanded(
                      child: Text('Kelola Pengguna',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                    ),
                    TextButton.icon(
                      onPressed: () => _showUserSheet(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Semua pengguna terdaftar di sistem.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _users.isEmpty
                ? SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Column(
                        children: [
                          const Icon(Icons.people_outline, size: 56, color: Color(0xFFD1D5DB)),
                          const SizedBox(height: 16),
                          const Text('Tidak ada pengguna.',
                              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final user = _users[index];
                      final roleColor = _roleColor(user.role);
                      return Padding(
                        padding: EdgeInsets.only(bottom: index == _users.length - 1 ? 0 : 14),
                        child: Card(
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: roleColor.withValues(alpha: 0.12),
                                  child: Icon(Icons.person, color: roleColor, size: 22),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(user.name,
                                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                          if (!user.isActive)
                                            const Padding(
                                              padding: EdgeInsets.only(left: 6),
                                              child: Icon(Icons.block, size: 14, color: Color(0xFFEF4444)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: roleColor.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(user.role,
                                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: roleColor)),
                                          ),
                                          const SizedBox(width: 10),
                                          Flexible(
                                            child: Text(user.email,
                                                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                                                overflow: TextOverflow.ellipsis),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                PopupMenuButton<String>(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  offset: const Offset(0, 40),
                                  onSelected: (action) async {
                                    switch (action) {
                                      case 'edit':
                                        _showUserSheet(user: user);
                                        break;
                                      case 'toggle':
                                        await _repo.toggleUserActive(user.email);
                                        if (!mounted) return;
                                        _load();
                                        break;
                                      case 'delete':
                                        _deleteUser(user);
                                        break;
                                    }
                                  },
                                  itemBuilder: (ctx) => [
                                    const PopupMenuItem(value: 'edit', child: ListTile(
                                      leading: Icon(Icons.edit_outlined, color: Color(0xFF3B82F6), size: 20),
                                      title: Text('Edit', style: TextStyle(fontSize: 14)),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                    )),
                                    PopupMenuItem(value: 'toggle', child: ListTile(
                                      leading: Icon(user.isActive ? Icons.block : Icons.check_circle_outline,
                                          color: user.isActive ? const Color(0xFFF97316) : const Color(0xFF10B981), size: 20),
                                      title: Text(user.isActive ? 'Non-aktifkan' : 'Aktifkan', style: const TextStyle(fontSize: 14)),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                    )),
                                    const PopupMenuItem(value: 'delete', child: ListTile(
                                      leading: Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                                      title: Text('Hapus', style: TextStyle(fontSize: 14)),
                                      dense: true,
                                      contentPadding: EdgeInsets.zero,
                                    )),
                                  ],
                                  child: const Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.more_vert, color: Color(0xFF9CA3AF), size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }, childCount: _users.length),
                  ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionTitle('Matriks Hak Akses'),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.03), blurRadius: 10, offset: Offset(0, 2)),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _MatrixHeader(),
                      ),
                      _PermissionRow('Laporkan Insiden', '✓', '✓', '✓', '✓'),
                      const Divider(height: 24),
                      _PermissionRow('Konfirmasi Insiden', '✓', '—', '✓', '✓'),
                      const Divider(height: 24),
                      _PermissionRow('Ambil Tugas', '—', '✓', '—', '—'),
                      const Divider(height: 24),
                      _PermissionRow('Assign Staff', '—', '—', '✓', '✓'),
                      const Divider(height: 24),
                      _PermissionRow('Tutup Insiden', '—', '—', '✓', '✓'),
                      const Divider(height: 24),
                      _PermissionRow('Kelola Data Master', '—', '—', '✓', '✓'),
                      const Divider(height: 24),
                      _PermissionRow('Kelola Pengguna', '—', '—', '—', '✓'),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827)));
  }
}

class _PermissionRow extends StatelessWidget {
  final String permission;
  final String student;
  final String staff;
  final String facilityAdmin;
  final String superAdmin;

  const _PermissionRow(
    this.permission,
    this.student,
    this.staff,
    this.facilityAdmin,
    this.superAdmin,
  );

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(permission, style: const TextStyle(fontSize: 13, color: Color(0xFF374151)))),
        Expanded(child: Center(child: _RoleCheck(student))),
        Expanded(child: Center(child: _RoleCheck(staff))),
        Expanded(child: Center(child: _RoleCheck(facilityAdmin))),
        Expanded(child: Center(child: _RoleCheck(superAdmin))),
      ],
    );
  }
}

class _RoleCheck extends StatelessWidget {
  final String value;
  const _RoleCheck(this.value);

  @override
  Widget build(BuildContext context) {
    final isCheck = value == '✓';
    return Icon(
      isCheck ? Icons.check_circle : Icons.remove_circle_outline,
      size: 18,
      color: isCheck ? const Color(0xFF10B981) : const Color(0xFFD1D5DB),
    );
  }
}

class _MatrixHeader extends StatelessWidget {
  const _MatrixHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(flex: 3, child: SizedBox.shrink()),
        Expanded(child: Center(child: Text('Siswa', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))))),
        Expanded(child: Center(child: Text('Staff', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B7280))))),
        Expanded(child: Center(child: Text('Admin\nFasilitas', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), height: 1.3)))),
        Expanded(child: Center(child: Text('Super\nAdmin', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF6B7280), height: 1.3)))),
      ],
    );
  }
}
