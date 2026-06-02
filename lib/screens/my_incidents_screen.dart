import 'package:flutter/material.dart';

import '../data/models/incident.dart';
import '../data/dummy_data.dart';
import '../data/repositories/incident_repository.dart';
import '../widgets/incident_card.dart';
import '../widgets/state_views.dart';
import 'incident_detail_screen.dart';

class MyIncidentsScreen extends StatelessWidget {
  const MyIncidentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MyIncidentsBody();
  }
}

class _MyIncidentsBody extends StatefulWidget {
  const _MyIncidentsBody();

  @override
  State<_MyIncidentsBody> createState() => _MyIncidentsBodyState();
}

class _MyIncidentsBodyState extends State<_MyIncidentsBody> {
  int _selectedFilter = 0;
  static const _filters = reportFilters;
  List<Incident> _allIncidents = [];
  bool _isLoading = true;

  final _incidentRepo = IncidentRepository();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final incidents = await _incidentRepo.getAll();
      if (!mounted) return;
      setState(() {
        _allIncidents = incidents;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('_loadData error: $e');
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Incident> get _filtered {
    if (_isLoading) return [];
    switch (_selectedFilter) {
      case 1:
        return _allIncidents
            .where((i) => !_isClosedOrResolved(i.status))
            .toList();
      case 2:
        return _allIncidents
            .where((i) => _isClosedOrResolved(i.status))
            .toList();
      default:
        return _allIncidents;
    }
  }

  bool _isClosedOrResolved(String status) {
    return status == statusClosed || status == statusResolved;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _loadData,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Insiden Saya',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pantau status laporan yang telah Anda buat.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final isSelected = _selectedFilter == index;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(19),
                          onTap: () =>
                              setState(() => _selectedFilter = index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF111827)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(19),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF111827)
                                    : const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _isLoading
                ? const LoadingView()
                : filtered.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: 300,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined,
                                      size: 56, color: Color(0xFFD1D5DB)),
                                  SizedBox(height: 16),
                                  Text(
                                    'Belum ada laporan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _buildIncidentCard(context, filtered[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentCard(BuildContext context, Incident item) {
    return IncidentCard(
      incident: item,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => IncidentDetailScreen(incident: item),
          ),
        );
      },
    );
  }
}
