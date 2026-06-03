import 'package:flutter/material.dart';

import 'package:civic_campus/data/models/incident.dart';
import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/widgets/incident_card.dart';
import 'package:civic_campus/widgets/state_views.dart';

class StudentHomeTab extends StatelessWidget {
  final bool isLoading;
  final List<Incident> activeIncidents;
  final int unreadNotificationCount;
  final Future<void> Function() onRefresh;
  final void Function({String? initialCategory}) onNewReport;
  final VoidCallback onOpenNotification;
  final void Function(Incident incident) onIncidentTap;

  const StudentHomeTab({
    super.key,
    required this.isLoading,
    required this.activeIncidents,
    required this.unreadNotificationCount,
    required this.onRefresh,
    required this.onNewReport,
    required this.onOpenNotification,
    required this.onIncidentTap,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader(context),
                const SizedBox(height: 28),
                _buildCtaCard(context),
                const SizedBox(height: 28),
                _buildCategorySection(context),
                const SizedBox(height: 28),
                const Text('Laporan aktif saya',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 14),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: _buildIncidentsSliver(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Halo, Mahasiswa',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Lihat status laporan atau laporkan masalah baru dari sini.',
                  style: TextStyle(color: Color(0xFF6B7280), fontSize: 16, height: 1.5)),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton(
              tooltip: 'Notifikasi',
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFF111827),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
                minimumSize: const Size(52, 52),
              ),
              onPressed: onOpenNotification,
            ),
            if (unreadNotificationCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildCtaCard(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Butuh laporan cepat?',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            const Text(
                'Laporkan masalah fasilitas kampus dengan foto dan lokasi cepat.',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 15, height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () => onNewReport(),
              child: const Text('Laporkan Masalah'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Kategori populer',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 14),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: homeCategoryNames.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final category = homeCategoryNames[index];
              return ActionChip(
                label: Text(category),
                onPressed: () {
                  String? initialCategory;
                  if (category == 'Toilet' || category == 'WiFi') {
                    initialCategory = category;
                  }
                  onNewReport(initialCategory: initialCategory);
                },
                backgroundColor: const Color(0xFFF3F4F6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildIncidentsSliver(BuildContext context) {
    if (isLoading) return const SliverLoadingView();
    if (activeIncidents.isEmpty) {
      return const SliverToBoxAdapter(
        child: SizedBox(
          height: 200,
          child: Center(
            child: Text('Tidak ada laporan aktif.',
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14)),
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final item = activeIncidents[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == activeIncidents.length - 1 ? 0 : 14,
          ),
          child: IncidentCard(
            incident: item,
            variant: IncidentCardVariant.compact,
            onTap: () => onIncidentTap(item),
          ),
        );
      }, childCount: activeIncidents.length),
    );
  }
}
