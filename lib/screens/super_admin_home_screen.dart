import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/models/user.dart';
import '../data/repositories/incident_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/dummy_data.dart';
import 'incident_detail_screen.dart';
import 'login_screen.dart';

class SuperAdminHomeScreen extends StatefulWidget {
  static const routeName = '/super-admin-home';

  const SuperAdminHomeScreen({super.key});

  @override
  State<SuperAdminHomeScreen> createState() => _SuperAdminHomeScreenState();
}

class _SuperAdminHomeScreenState extends State<SuperAdminHomeScreen> {
  int _selectedIndex = 0;

  static const _icons = <IconData>[
    Icons.dashboard_outlined,
    Icons.people_outline,
    Icons.list_alt_outlined,
    Icons.settings_outlined,
    Icons.person_outline,
  ];

  static const _selectedIcons = <IconData>[
    Icons.dashboard,
    Icons.people,
    Icons.list_alt,
    Icons.settings,
    Icons.person,
  ];

  static const _labels = [
    'Dashboard',
    'Users',
    'Insiden',
    'Konfigurasi',
    'Profile',
  ];

  Widget _buildBody() {
    return IndexedStack(
      index: _selectedIndex,
      children: const [
        _DashboardTab(),
        _UsersTab(),
        _IncidentListTab(
          initialStatusFilter: 'Semua',
          initialPriorityFilter: 'Semua',
        ),
        _SystemConfigTab(),
        _ProfileTab(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 78,
            decoration: BoxDecoration(
              color: const Color(0xFF111827),
              borderRadius: BorderRadius.circular(42),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.18),
                  blurRadius: 18,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_icons.length, (index) {
                final selected = _selectedIndex == index;
                final icon = selected
                    ? _selectedIcons[index]
                    : _icons[index];
                return Expanded(
                  child: Tooltip(
                    message: _labels[index],
                    child: InkWell(
                      borderRadius: BorderRadius.circular(34),
                      onTap: () =>
                          setState(() => _selectedIndex = index),
                      child: Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 10),
                        child: Semantics(
                          label: _labels[index],
                          button: true,
                          selected: selected,
                          child: Center(
                            child: Container(
                              width: selected ? 60 : 44,
                              height: selected ? 60 : 44,
                              decoration: selected
                                  ? const BoxDecoration(
                                      color: Colors.white24,
                                      shape: BoxShape.circle,
                                    )
                                  : null,
                              child: Icon(
                                icon,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF9CA3AF),
                                size: selected ? 28 : 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// DASHBOARD TAB
// =============================================================================

class _DashboardTab extends StatefulWidget {
  const _DashboardTab();

  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
  final _incidentRepo = IncidentRepository();
  final _userRepo = UserRepository();
  bool _isLoading = true;
  bool _hasError = false;

  int _studentCount = 0;
  int _staffCount = 0;
  int _facilityAdminCount = 0;
  int _totalUsers = 0;

  int _totalIncidents = 0;
  int _openCount = 0;
  int _assignedCount = 0;
  int _inProgressCount = 0;
  int _resolvedCount = 0;
  int _closedCount = 0;
  int _highPriorityCount = 0;
  int _unassignedCount = 0;
  int _overdueCount = 0;
  int _activeStaffCount = 0;

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
      final results = await Future.wait([
        _userRepo.getAllUsers(),
        _incidentRepo.getAll(),
      ]);
      if (!mounted) return;
      final users = results[0] as List<User>;
      final incidents = results[1] as List<Incident>;

      setState(() {
        _studentCount = users.where((u) => u.role == 'Student').length;
        _staffCount = users.where((u) => u.role == 'Staff').length;
        _facilityAdminCount = users.where(
          (u) => u.role == 'Facility Admin' || u.role == 'Super Admin',
        ).length;
        _totalUsers = users.length;

        _totalIncidents = incidents.length;
        _openCount = incidents.where((i) => i.status == statusOpen).length;
        _assignedCount = incidents.where((i) => i.status == statusAssigned).length;
        _inProgressCount = incidents.where((i) => i.status == statusInProgress).length;
        _resolvedCount = incidents.where((i) => i.status == statusResolved).length;
        _closedCount = incidents.where((i) => i.status == statusClosed).length;
        _highPriorityCount = incidents.where((i) => i.priority == 'Tinggi' && i.status != statusClosed).length;
        _unassignedCount = incidents.where((i) => i.status == statusOpen && i.assignedTo == null).length;
        _overdueCount = incidents.where((i) => i.isOverdue()).length;
        final activeStaff = <String>{};
        for (final i in incidents) {
          if (i.assignedTo != null &&
              i.status != statusResolved &&
              i.status != statusClosed) {
            activeStaff.add(i.assignedTo!);
          }
        }
        _activeStaffCount = activeStaff.length;
      });
    } catch (e) {
      debugPrint('_DashboardTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              'Gagal memuat dashboard.',
              style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    final resolvedPct = _totalIncidents > 0
        ? ((_resolvedCount + _closedCount) / _totalIncidents * 100).round()
        : 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang,',
                        style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.2),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Admin Utama',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Ringkasan sistem CIVIC Campus.',
              style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
            ),
            const SizedBox(height: 28),

            const Text(
              'Pengguna Terdaftar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _MiniCard(value: '$_studentCount', label: 'Siswa', color: const Color(0xFF3B82F6), icon: Icons.school)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniCard(value: '$_staffCount', label: 'Staff', color: const Color(0xFF10B981), icon: Icons.build)),
                  const SizedBox(width: 10),
                  Expanded(child: _MiniCard(value: '$_facilityAdminCount', label: 'Admin', color: const Color(0xFF8B5CF6), icon: Icons.shield)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF111827),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people, color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text('$_totalUsers total pengguna terdaftar',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                ],
              ),
            ),

            const SizedBox(height: 28),

            Row(
              children: [
                const Text('Insiden', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('$resolvedPct% selesai',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF10B981))),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _StatusBar(label: 'Terbuka', count: _openCount, total: _totalIncidents, color: const Color(0xFF3B82F6)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Ditugaskan', count: _assignedCount, total: _totalIncidents, color: const Color(0xFFF97316)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Diproses', count: _inProgressCount, total: _totalIncidents, color: const Color(0xFFFBBF24)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Selesai', count: _resolvedCount, total: _totalIncidents, color: const Color(0xFF10B981)),
            const SizedBox(height: 10),
            _StatusBar(label: 'Ditutup', count: _closedCount, total: _totalIncidents, color: const Color(0xFF6B7280)),

            const SizedBox(height: 28),

            const Text('Ringkasan Cepat', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _MiniCard(value: '$_highPriorityCount', label: 'Prioritas Tinggi', color: const Color(0xFFEF4444), icon: Icons.warning)),
                const SizedBox(width: 10),
                Expanded(child: _MiniCard(value: '$_unassignedCount', label: 'Belum Ditugaskan', color: const Color(0xFFF97316), icon: Icons.person_add_alt_1)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _MiniCard(value: '$_overdueCount', label: 'Terlambat', color: const Color(0xFFEF4444), icon: Icons.access_time)),
                const SizedBox(width: 10),
                Expanded(child: _MiniCard(value: '$_activeStaffCount', label: 'Staff Aktif', color: const Color(0xFF3B82F6), icon: Icons.engineering)),
              ],
            ),

            const SizedBox(height: 28),

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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Insiden',
                            style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                        const SizedBox(height: 4),
                        Text('$_totalIncidents',
                            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.1)),
                      ],
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(18)),
                    child: const Icon(Icons.assignment, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// USERS TAB
// =============================================================================

class _UsersTab extends StatefulWidget {
  const _UsersTab();

  @override
  State<_UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<_UsersTab> {
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
      debugPrint('_UsersTab._load error: $e');
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Gagal memuat pengguna.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

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
                          Icon(Icons.people_outline, size: 56, color: const Color(0xFFD1D5DB)),
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
                                      // Role badge + email in one row
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
          // Role Matrix section
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const _SectionTitle('Matriks Hak Akses'),
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
                      // Column headers
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

// =============================================================================
// INCIDENT LIST TAB
// =============================================================================

class _IncidentListTab extends StatefulWidget {
  final String initialStatusFilter;
  final String initialPriorityFilter;

  const _IncidentListTab({
    required this.initialStatusFilter,
    required this.initialPriorityFilter,
  });

  @override
  State<_IncidentListTab> createState() => _IncidentListTabState();
}

class _IncidentListTabState extends State<_IncidentListTab> {
  final _repo = IncidentRepository();
  final _userRepo = UserRepository();
  List<Incident> _incidents = [];
  List<String> _staffNames = [];
  bool _isLoading = true;
  bool _hasError = false;
  late String _activeFilter;
  late String _activePriorityFilter;
  String _searchQuery = '';
  String _staffFilter = 'Semua';

  static const _statusLabels = {
    'Semua': 'Semua',
    statusOpen: 'Menunggu Penanganan',
    statusAssigned: 'Sudah Ditugaskan',
    statusInProgress: 'Sedang Dikerjakan',
    statusResolved: 'Selesai Dikerjakan',
    statusClosed: 'Ditutup',
  };

  final _filters = [
    'Semua',
    statusOpen,
    statusAssigned,
    statusInProgress,
    statusResolved,
    statusClosed,
  ];

  static const _priorityFilters = [
    'Semua',
    'Tinggi',
    'Sedang',
    'Rendah',
  ];

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialStatusFilter;
    _activePriorityFilter = widget.initialPriorityFilter;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    try {
      final results = await Future.wait([
        _repo.getAll(),
        _userRepo.getAllUsers(),
      ]);
      if (!mounted) return;
      final users = results[1] as List<User>;
      setState(() {
        _incidents = results[0] as List<Incident>;
        _staffNames = users.where((u) => u.role == 'Staff').map((u) => u.name).toList();
      });
    } catch (e) {
      debugPrint('_IncidentListTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Incident> get _filteredIncidents {
    var filtered = List<Incident>.from(_incidents);
    if (_activeFilter != 'Semua') {
      filtered = filtered.where((i) => i.status == _activeFilter).toList();
    }
    if (_activePriorityFilter != 'Semua') {
      filtered = filtered.where((i) => i.priority == _activePriorityFilter).toList();
    }
    if (_staffFilter != 'Semua') {
      filtered = filtered.where((i) => i.assignedTo == _staffFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      filtered = filtered.where((i) =>
        i.title.toLowerCase().contains(q) ||
        i.location.toLowerCase().contains(q) ||
        i.description.toLowerCase().contains(q)
      ).toList();
    }
    filtered.sort((a, b) {
      const rank = {'Tinggi': 0, 'Sedang': 1, 'Rendah': 2};
      final pa = rank[a.priority] ?? 999;
      final pb = rank[b.priority] ?? 999;
      if (pa != pb) return pa.compareTo(pb);
      return b.createdAt.compareTo(a.createdAt);
    });
    return filtered;
  }

  void _quickAssign(Incident item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Assign Staff',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 8),
                Text('Pilih staff untuk "${item.title}".',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                const SizedBox(height: 20),
                ...List.generate(_staffNames.length, (idx) {
                  final name = _staffNames[idx];
                  return Padding(
                    padding: EdgeInsets.only(bottom: idx < _staffNames.length - 1 ? 10 : 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Menugaskan ke $name...')),
                          );
                          final ok = await _repo.updateStatus(
                            item.id,
                            statusAssigned,
                            notes: 'Ditugaskan ke $name',
                            assignedTo: name,
                          );
                          if (!mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Laporan tidak ditemukan.')),
                            );
                            return;
                          }
                          _load();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Ditugaskan ke $name.')),
                          );
                        },
                        icon: const Icon(Icons.person_add, size: 20),
                        label: Text(name),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                          foregroundColor: const Color(0xFF111827),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident item) {
    final statusColor = statusColors[item.status] ?? const Color(0xFF6B7280);
    final statusBg = statusBgColors[item.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon = categoryIcons[item.category] ?? Icons.help_outline;
    final categoryColor = categoryColors[item.category] ?? const Color(0xFF9CA3AF);
    final prioColor = priorityColors[item.priority] ?? const Color(0xFF6B7280);
    final prioBg = priorityBgColors[item.priority] ?? const Color(0xFFF3F4F6);

    final canAssign = item.status == statusOpen;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => IncidentDetailScreen(
                incident: item,
                showAdminActions: true,
              ),
            ),
          );
          if (!mounted) return;
          _load();
        },
        child: Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(categoryIcon, color: categoryColor, size: 22),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: prioColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: prioBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(item.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF111827)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(12)),
                            child: Text(
                              _statusLabels[item.status] ?? item.status,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(item.location,
                                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.people, size: 12, color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text('${item.confirmationCount} konfirmasi',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                          if (item.assignedTo != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person, size: 12, color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(item.assignedTo!,
                                  style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ),
                          ],
                          if (canAssign) ...[
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _quickAssign(item),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.person_add_alt_1, size: 16, color: Color(0xFF3B82F6)),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incidents = _filteredIncidents;

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text('Daftar Insiden',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 8),
                const Text('Semua insiden fasilitas kampus.',
                    style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),
                SizedBox(
                  height: 42,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari insiden...',
                      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF9CA3AF)),
                      filled: true,
                      fillColor: const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(22),
                        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _filters[index];
                      final selected = _activeFilter == f;
                      return ChoiceChip(
                        label: Text(_statusLabels[f] ?? f),
                        selected: selected,
                        onSelected: (_) => setState(() => _activeFilter = f),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: selected ? Colors.white : const Color(0xFF6B7280),
                        ),
                        backgroundColor: const Color(0xFFF3F4F6),
                        selectedColor: const Color(0xFF111827),
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown(
                        label: 'Prioritas',
                        value: _activePriorityFilter == 'Semua' ? null : _activePriorityFilter,
                        items: _priorityFilters,
                        icon: _activePriorityFilter == 'Semua'
                            ? null
                            : Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: priorityColors[_activePriorityFilter] ?? const Color(0xFF6B7280),
                                  shape: BoxShape.circle,
                                ),
                              ),
                        onSelected: (v) => setState(() => _activePriorityFilter = v),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (_staffNames.isNotEmpty)
                      Expanded(
                        child: _FilterDropdown(
                          label: 'Staff',
                          value: _staffFilter == 'Semua' ? null : _staffFilter,
                          items: ['Semua', ..._staffNames],
                          onSelected: (v) => setState(() => _staffFilter = v),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _isLoading
                ? SliverToBoxAdapter(
                    child: SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  )
                : _hasError
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
                              const SizedBox(height: 16),
                              const Text('Gagal memuat insiden.',
                                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 8),
                              TextButton(onPressed: _load, child: const Text('Coba lagi')),
                            ],
                          ),
                        ),
                      )
                    : incidents.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 40),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox_outlined, size: 56, color: const Color(0xFFD1D5DB)),
                                  const SizedBox(height: 16),
                                  const Text('Tidak ada insiden.',
                                      style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, index) {
                              final item = incidents[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: index == incidents.length - 1 ? 0 : 14),
                                child: _buildIncidentCard(context, item),
                              );
                            }, childCount: incidents.length),
                          ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SYSTEM CONFIG TAB
// =============================================================================

class _SystemConfigTab extends StatefulWidget {
  const _SystemConfigTab();

  @override
  State<_SystemConfigTab> createState() => _SystemConfigTabState();
}

class _SystemConfigTabState extends State<_SystemConfigTab> {
  final _incidentRepo = IncidentRepository();
  final _userRepo = UserRepository();

  int _totalIncidents = 0;
  int _staffCount = 0;
  int _staffTasks = 0;
  bool _isLoading = true;
  bool _hasError = false;

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
      final results = await Future.wait([
        _incidentRepo.getAll(),
        _userRepo.getAllUsers(),
      ]);
      if (!mounted) return;
      final incidents = results[0] as List<Incident>;
      final users = results[1] as List<User>;
      final staff = users.where((u) => u.role == 'Staff').toList();
      final staffNames = staff.map((s) => s.name).toSet();
      final staffTasks = incidents.where((i) => staffNames.contains(i.assignedTo)).length;
      setState(() {
        _totalIncidents = incidents.length;
        _staffCount = staff.length;
        _staffTasks = staffTasks;
      });
    } catch (e) {
      debugPrint('_SystemConfigTab._load error: $e');
      if (!mounted) return;
      setState(() => _hasError = true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text('Gagal memuat konfigurasi.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            TextButton(onPressed: _load, child: const Text('Coba lagi')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text('Konfigurasi Sistem',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 8),
          const Text('Informasi sistem dan konfigurasi global.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
          const SizedBox(height: 28),

          const _SectionTitle('Informasi Aplikasi'),
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
                _InfoRow('Nama Aplikasi', appName),
                const Divider(height: 24),
                _InfoRow('Versi', appVersion),
                const Divider(height: 24),
                _InfoRow('Hak Cipta', appCopyright),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const _SectionTitle('Role & Hak Akses'),
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
                _RoleRow(role: 'Student', description: 'Melapor dan memantau insiden', color: const Color(0xFF3B82F6)),
                const Divider(height: 24),
                _RoleRow(role: 'Staff', description: 'Mengerjakan tugas yang ditugaskan', color: const Color(0xFF10B981)),
                const Divider(height: 24),
                _RoleRow(role: 'Facility Admin', description: 'Kelola insiden, staff, dan master data', color: const Color(0xFFF97316)),
                const Divider(height: 24),
                _RoleRow(role: 'Super Admin', description: 'Kelola pengguna dan konfigurasi sistem', color: const Color(0xFF8B5CF6)),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const _SectionTitle('Beban Kerja Staff'),
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
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Staff Aktif', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('$_staffCount',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.1)),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Tugas Aktif', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('$_staffTasks',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFF97316), height: 1.1)),
                    ],
                  ),
                ),
                Container(width: 1, height: 60, color: const Color(0xFFE5E7EB)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Total Insiden', style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF))),
                      const SizedBox(height: 4),
                      Text('$_totalIncidents',
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6), height: 1.1)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          const _SectionTitle('Riwayat Audit'),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AuditEntry(action: 'INS-001 dibuat', user: 'Budi Santoso', time: '10 menit lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'INS-002 ditugaskan ke Budi Teknisi', user: 'Admin Utama', time: '1 jam lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'INS-003 status diubah ke Diproses', user: 'Budi Teknisi', time: '2 jam lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'INS-001 ditutup', user: 'Admin Utama', time: '3 jam lalu'),
                const Divider(height: 20),
                _AuditEntry(action: 'Pengguna baru: Siti Nurlela ditambahkan', user: 'Admin Utama', time: '5 jam lalu'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// PROFILE TAB
// =============================================================================

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    final user = superAdminUser;
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
            child: const Icon(Icons.admin_panel_settings, size: 48, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 16),
          Text(user.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('Super Admin',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6))),
          ),
          const SizedBox(height: 40),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pengaturan Akun', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                const SizedBox(height: 16),
                _ProfileMenuItem(icon: Icons.notifications_outlined, title: 'Notifikasi', trailing: 'Aktif'),
                const Divider(height: 24),
                _ProfileMenuItem(icon: Icons.language_outlined, title: 'Bahasa', trailing: 'Indonesia'),
                const Divider(height: 24),
                _ProfileMenuItem(icon: Icons.info_outline, title: 'Versi Aplikasi', trailing: appVersion),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              },
              icon: const Icon(Icons.logout, size: 18, color: Color(0xFFEF4444)),
              label: const Text('Keluar', style: TextStyle(color: Color(0xFFEF4444))),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                side: const BorderSide(color: Color(0xFFE5E7EB)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 22, color: const Color(0xFF6B7280)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: const TextStyle(fontSize: 15, color: Color(0xFF111827))),
        ),
        Text(trailing, style: const TextStyle(fontSize: 14, color: Color(0xFF9CA3AF))),
      ],
    );
  }
}

// =============================================================================
// SHARED WIDGETS
// =============================================================================

class _MiniCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _MiniCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.03),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _StatusBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? count / total : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.02),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF374151),
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: const Color(0xFFF3F4F6),
                valueColor:
                    AlwaysStoppedAnimation<Color>(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
      ],
    );
  }
}

class _RoleRow extends StatelessWidget {
  final String role;
  final String description;
  final Color color;

  const _RoleRow({
    required this.role,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              role[0],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                role,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF111827),
      ),
    );
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
        Expanded(
          flex: 3,
          child: Text(permission, style: const TextStyle(fontSize: 13, color: Color(0xFF374151))),
        ),
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

class _AuditEntry extends StatelessWidget {
  final String action;
  final String user;
  final String time;

  const _AuditEntry({
    required this.action,
    required this.user,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.only(top: 6),
          decoration: const BoxDecoration(
            color: Color(0xFFD1D5DB),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(action, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF111827))),
              const SizedBox(height: 2),
              Text('$user • $time', style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
            ],
          ),
        ),
      ],
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final Widget? icon;
  final ValueChanged<String> onSelected;

  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    this.icon,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final displayText = value ?? label;
    return PopupMenuButton<String>(
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (ctx) => [
        for (final item in items)
          PopupMenuItem(
            value: item,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item != 'Semua' && label == 'Prioritas')
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: priorityColors[item] ?? const Color(0xFF6B7280),
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  item == 'Semua' ? 'Semua $label' : item,
                  style: TextStyle(
                    fontWeight: value == item ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: value != null ? const Color(0xFF111827) : const Color(0xFFD1D5DB)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: value != null ? FontWeight.w600 : FontWeight.w500,
                  color: value != null ? const Color(0xFF111827) : const Color(0xFF6B7280),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}
