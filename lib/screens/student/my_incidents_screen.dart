import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/providers/incident_provider.dart';
import 'package:civic_campus/widgets/incident_card.dart';
import 'package:civic_campus/widgets/state_views.dart';
import 'package:civic_campus/screens/shared/incident/detail/incident_detail_screen.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentProvider>().loadAll();
    });
  }

  List<Incident> get _incidents {
    final provider = context.read<IncidentProvider>();
    return provider.incidents.map((m) => Incident.fromJson(m)).toList();
  }

  List<Incident> get _filtered {
    final all = _incidents;
    if (all.isEmpty) return [];
    switch (_selectedFilter) {
      case 1:
        return all
            .where((i) => !_isClosedOrResolved(i.status))
            .toList();
      case 2:
        return all
            .where((i) => _isClosedOrResolved(i.status))
            .toList();
      default:
        return all;
    }
  }

  bool _isClosedOrResolved(String status) {
    return status == statusClosed || status == statusResolved;
  }

  Future<void> _refresh() async {
    await context.read<IncidentProvider>().loadAll();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IncidentProvider>();
    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _refresh,
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
            child: provider.isLoading
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
