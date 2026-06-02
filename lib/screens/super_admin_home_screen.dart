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
  ];

  static const _selectedIcons = <IconData>[
    Icons.dashboard,
    Icons.people,
    Icons.list_alt,
    Icons.settings,
  ];

  static const _labels = [
    'Dashboard',
    'Users',
    'Insiden',
    'Konfigurasi',
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
  final _userRepo = UserRepository();
  final _incidentRepo = IncidentRepository();
  bool _isLoading = true;

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final users = await _userRepo.getAllUsers();
    final incidents = await _incidentRepo.getAll();

    if (!mounted) return;
    setState(() {
      _studentCount = users.where((u) => u.role == 'Student').length;
      _staffCount = users.where((u) => u.role == 'Staff').length;
      _facilityAdminCount = users.where(
        (u) => u.role == 'Facility Admin' || u.role == 'Super Admin',
      ).length;
      _totalUsers = users.length;

      _totalIncidents = incidents.length;
      _openCount = incidents.where((i) => i.status == statusOpen).length;
      _assignedCount =
          incidents.where((i) => i.status == statusAssigned).length;
      _inProgressCount =
          incidents.where((i) => i.status == statusInProgress).length;
      _resolvedCount =
          incidents.where((i) => i.status == statusResolved).length;
      _closedCount =
          incidents.where((i) => i.status == statusClosed).length;
      _isLoading = false;
    });
  }

  void _showProfileSheet() {
    final user = superAdminUser;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  child: const Icon(Icons.admin_panel_settings,
                      size: 36, color: Color(0xFF8B5CF6)),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Super Admin',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout,
                        size: 18, color: Color(0xFFEF4444)),
                    label: const Text('Keluar',
                        style: TextStyle(color: Color(0xFFEF4444))),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final resolvedPct = _totalIncidents > 0
        ? ((_resolvedCount + _closedCount) / _totalIncidents * 100)
            .round()
        : 0;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Selamat Datang,',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Admin Utama',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _showProfileSheet,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                    child: const Icon(Icons.admin_panel_settings,
                        color: Color(0xFF8B5CF6), size: 26),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Ringkasan sistem CIVIC Campus.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 28),

            // Pengguna section
            const Text(
              'Pengguna Terdaftar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 14),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                      child: _MiniCard(
                          value: '$_studentCount',
                          label: 'Siswa',
                          color: const Color(0xFF3B82F6),
                          icon: Icons.school)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MiniCard(
                          value: '$_staffCount',
                          label: 'Staff',
                          color: const Color(0xFF10B981),
                          icon: Icons.build)),
                  const SizedBox(width: 10),
                  Expanded(
                      child: _MiniCard(
                          value: '$_facilityAdminCount',
                          label: 'Admin',
                          color: const Color(0xFF8B5CF6),
                          icon: Icons.shield)),
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
                  const Icon(Icons.people,
                      color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    '$_totalUsers total pengguna terdaftar',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Incident Status section
            Row(
              children: [
                const Text(
                  'Insiden',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$resolvedPct% selesai',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status progress bars
            _StatusBar(
              label: 'Terbuka',
              count: _openCount,
              total: _totalIncidents,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 10),
            _StatusBar(
              label: 'Ditugaskan',
              count: _assignedCount,
              total: _totalIncidents,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(height: 10),
            _StatusBar(
              label: 'Diproses',
              count: _inProgressCount,
              total: _totalIncidents,
              color: const Color(0xFFFBBF24),
            ),
            const SizedBox(height: 10),
            _StatusBar(
              label: 'Selesai',
              count: _resolvedCount,
              total: _totalIncidents,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 10),
            _StatusBar(
              label: 'Ditutup',
              count: _closedCount,
              total: _totalIncidents,
              color: const Color(0xFF6B7280),
            ),

            const SizedBox(height: 28),

            // Global metric card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.03),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Total Insiden',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalIncidents',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF111827),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.assignment,
                        color: Colors.white, size: 28),
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
    final users = await _repo.getAllUsers();
    if (!mounted) return;
    setState(() {
      _users = users;
      _isLoading = false;
    });
  }

  Future<void> _showUserSheet({User? user}) async {
    final isEditing = user != null;
    final originalEmail = user?.email;
    final nameController =
        TextEditingController(text: user?.name ?? '');
    final emailController =
        TextEditingController(text: user?.email ?? '');
    String selectedRole = user?.role ?? 'Student';

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
                    isEditing
                        ? 'Edit Pengguna'
                        : 'Tambah Pengguna',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Role',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                    ),
                    items: _roles
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(r),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) {
                        setSheetState(() => selectedRole = v);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        final email =
                            emailController.text.trim();
                        if (name.isEmpty || email.isEmpty) return;
                        final newUser = User(
                          name: name,
                          role: selectedRole,
                          email: email,
                        );
                        if (isEditing) {
                          await _repo.updateUser(
                              originalEmail!, newUser);
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child:
                          Text(isEditing ? 'Simpan' : 'Tambah'),
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Pengguna'),
        content: Text(
            'Hapus "$name"? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFEF4444)),
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

    return RefreshIndicator(
      onRefresh: _load,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Kelola Pengguna',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showUserSheet(),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tambah'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF3B82F6),
                        padding:
                            const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: Size.zero,
                        tapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semua pengguna terdaftar di sistem.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
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
                          Icon(Icons.people_outline,
                              size: 56,
                              color: const Color(0xFFD1D5DB)),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak ada pengguna.',
                            style: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = _users[index];
                        final roleColor = _roleColor(user.role);
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == _users.length - 1
                                ? 0
                                : 14,
                          ),
                          child: Card(
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: roleColor
                                        .withValues(alpha: 0.12),
                                    child: Icon(Icons.person,
                                        color: roleColor,
                                        size: 22),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w600,
                                            color:
                                                Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color:
                                                Color(0xFF6B7280),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets
                                                  .symmetric(
                                              horizontal: 8,
                                              vertical: 2),
                                          decoration: BoxDecoration(
                                            color: roleColor
                                                .withValues(
                                                    alpha: 0.1),
                                            borderRadius:
                                                BorderRadius
                                                    .circular(8),
                                          ),
                                          child: Text(
                                            user.role,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight:
                                                  FontWeight.w600,
                                              color: roleColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _showUserSheet(
                                      user: user,
                                    ),
                                    icon: const Icon(
                                        Icons.edit_outlined),
                                    color:
                                        const Color(0xFF3B82F6),
                                    visualDensity:
                                        VisualDensity.compact,
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        _deleteUser(user),
                                    icon: const Icon(
                                        Icons.delete_outline),
                                    color:
                                        const Color(0xFFEF4444),
                                    visualDensity:
                                        VisualDensity.compact,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: _users.length,
                    ),
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
  List<Incident> _incidents = [];
  bool _isLoading = true;
  late String _activeFilter;
  late String _activePriorityFilter;

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

  final _allStaffNames = ['Budi Teknisi'];

  @override
  void initState() {
    super.initState();
    _activeFilter = widget.initialStatusFilter;
    _activePriorityFilter = widget.initialPriorityFilter;
    _load();
  }

  Future<void> _load() async {
    final all = await _repo.getAll();
    if (!mounted) return;
    setState(() {
      _incidents = all;
      _isLoading = false;
    });
  }

  List<Incident> get _filteredIncidents {
    var filtered = List<Incident>.from(_incidents);
    if (_activeFilter != 'Semua') {
      filtered =
          filtered.where((i) => i.status == _activeFilter).toList();
    }
    if (_activePriorityFilter != 'Semua') {
      filtered = filtered
          .where((i) => i.priority == _activePriorityFilter)
          .toList();
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
                const Text(
                  'Assign Staff',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pilih staff untuk "${item.title}".',
                  style: const TextStyle(
                      fontSize: 14, color: Color(0xFF6B7280)),
                ),
                const SizedBox(height: 20),
                ...List.generate(_allStaffNames.length, (idx) {
                  final name = _allStaffNames[idx];
                  return Padding(
                    padding: EdgeInsets.only(
                        bottom:
                            idx < _allStaffNames.length - 1 ? 10 : 0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(sheetContext).pop();
                          final ok = await _repo.updateStatus(
                            item.id,
                            statusAssigned,
                            notes: 'Ditugaskan ke $name',
                            assignedTo: name,
                          );
                          if (!mounted) return;
                          if (!ok) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Laporan tidak ditemukan.'),
                              ),
                            );
                            return;
                          }
                          _load();
                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                                content:
                                    Text('Ditugaskan ke $name.')),
                          );
                        },
                        icon: const Icon(Icons.person_add, size: 20),
                        label: Text(name),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50),
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(28),
                          ),
                          foregroundColor:
                              const Color(0xFF111827),
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
    final statusColor =
        statusColors[item.status] ?? const Color(0xFF6B7280);
    final statusBg =
        statusBgColors[item.status] ?? const Color(0xFFF3F4F6);
    final categoryIcon =
        categoryIcons[item.category] ?? Icons.help_outline;
    final categoryColor =
        categoryColors[item.category] ?? const Color(0xFF9CA3AF);
    final prioColor =
        priorityColors[item.priority] ?? const Color(0xFF6B7280);
    final prioBg =
        priorityBgColors[item.priority] ?? const Color(0xFFF3F4F6);

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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                        color:
                            categoryColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(categoryIcon,
                          color: categoryColor, size: 22),
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
                          border: Border.all(
                              color: prioBg, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: Text(
                              item.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 12,
                              color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF6B7280),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.people,
                              size: 12,
                              color: const Color(0xFF9CA3AF)),
                          const SizedBox(width: 4),
                          Text(
                            '${item.confirmationCount} konfirmasi',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          if (item.assignedTo != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person,
                                size: 12,
                                color: const Color(0xFF9CA3AF)),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                item.assignedTo!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF6B7280),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
                                  color: const Color(0xFF3B82F6)
                                      .withValues(alpha: 0.12),
                                  borderRadius:
                                      BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.person_add_alt_1,
                                  size: 16,
                                  color: Color(0xFF3B82F6),
                                ),
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
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text(
                  'Daftar Insiden',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Semua insiden fasilitas kampus.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 36,
                  child: Row(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final f = _filters[index];
                            final selected = _activeFilter == f;
                            return ChoiceChip(
                              label: Text(f),
                              selected: selected,
                              onSelected: (_) =>
                                  setState(() => _activeFilter = f),
                              labelStyle: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                              backgroundColor:
                                  const Color(0xFFF3F4F6),
                              selectedColor:
                                  const Color(0xFF111827),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              visualDensity:
                                  VisualDensity.compact,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                            );
                          },
                        ),
                      ),
                      const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: Color(0xFFE5E7EB)),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (v) => setState(
                            () => _activePriorityFilter = v),
                        initialValue: _activePriorityFilter,
                        offset: const Offset(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(16),
                        ),
                        itemBuilder: (ctx) => [
                          for (final p in _priorityFilters)
                            PopupMenuItem(
                              value: p,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (p != 'Semua')
                                    Container(
                                      width: 10,
                                      height: 10,
                                      margin: const EdgeInsets
                                              .only(
                                          right: 10),
                                      decoration: BoxDecoration(
                                        color: p == 'Tinggi'
                                            ? const Color(
                                                0xFFEF4444)
                                            : p == 'Sedang'
                                                ? const Color(
                                                    0xFFFBBF24)
                                                : const Color(
                                                    0xFF10B981),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  Text(
                                    p,
                                    style: TextStyle(
                                      fontWeight: _activePriorityFilter ==
                                              p
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(20),
                            border: Border.all(
                                color:
                                    const Color(0xFFD1D5DB)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (_activePriorityFilter !=
                                  'Semua')
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets
                                          .only(
                                      right: 6),
                                  decoration: BoxDecoration(
                                    color: _activePriorityFilter ==
                                            'Tinggi'
                                        ? const Color(
                                            0xFFEF4444)
                                        : _activePriorityFilter ==
                                                'Sedang'
                                            ? const Color(
                                                0xFFFBBF24)
                                            : const Color(
                                                0xFF10B981),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              Text(
                                _activePriorityFilter == 'Semua'
                                    ? 'Prioritas'
                                    : _activePriorityFilter,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                  Icons.arrow_drop_down,
                                  size: 18,
                                  color: Color(0xFF9CA3AF)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
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
                      child: Center(
                          child: CircularProgressIndicator()),
                    ),
                  )
                : incidents.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding:
                              const EdgeInsets.only(top: 40),
                          child: Column(
                            children: [
                              Icon(Icons.inbox_outlined,
                                  size: 56,
                                  color:
                                      const Color(0xFFD1D5DB)),
                              const SizedBox(height: 16),
                              const Text(
                                'Tidak ada insiden.',
                                style: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SliverList(
                        delegate:
                            SliverChildBuilderDelegate(
                          (context, index) {
                            final item = incidents[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index ==
                                        incidents.length -
                                            1
                                    ? 0
                                    : 14,
                              ),
                              child: _buildIncidentCard(
                                  context, item),
                            );
                          },
                          childCount: incidents.length,
                        ),
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final incidents = await _incidentRepo.getAll();
    final users = await _userRepo.getAllUsers();
    final staff = users.where((u) => u.role == 'Staff').toList();
    final staffNames = staff.map((s) => s.name).toSet();
    final staffTasks =
        incidents.where((i) => staffNames.contains(i.assignedTo)).length;
    if (!mounted) return;
    setState(() {
      _totalIncidents = incidents.length;
      _staffCount = staff.length;
      _staffTasks = staffTasks;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
        children: [
          const Text(
            'Konfigurasi Sistem',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Informasi sistem dan konfigurasi global.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),

          // App Info
          const _SectionTitle('Informasi Aplikasi'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                _InfoRow('Nama Aplikasi', appName),
                const Divider(height: 24),
                _InfoRow('Versi', appVersion),
                const Divider(height: 24),
                _InfoRow('Hak Cipta', appCopyright),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Role Permissions
          const _SectionTitle('Role & Hak Akses'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
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
                _RoleRow(
                  role: 'Student',
                  description: 'Melapor dan memantau insiden',
                  color: const Color(0xFF3B82F6),
                ),
                const Divider(height: 24),
                _RoleRow(
                  role: 'Staff',
                  description: 'Mengerjakan tugas yang ditugaskan',
                  color: const Color(0xFF10B981),
                ),
                const Divider(height: 24),
                _RoleRow(
                  role: 'Facility Admin',
                  description:
                      'Kelola insiden, staff, dan master data',
                  color: const Color(0xFFF97316),
                ),
                const Divider(height: 24),
                _RoleRow(
                  role: 'Super Admin',
                  description:
                      'Kelola pengguna dan konfigurasi sistem',
                  color: const Color(0xFF8B5CF6),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Staff Workload Overview
          const _SectionTitle('Beban Kerja Staff'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.03),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Staff Aktif',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_staffCount',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Tugas Aktif',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_staffTasks',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF97316),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 60,
                  color: const Color(0xFFE5E7EB),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Insiden',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$_totalIncidents',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B82F6),
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
