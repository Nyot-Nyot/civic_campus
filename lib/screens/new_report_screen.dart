import 'package:flutter/material.dart';

import '../data/models/building.dart';
import '../data/models/incident.dart';
import '../data/dummy_data.dart';

class NewReportScreen extends StatefulWidget {
  static const routeName = '/new-report';

  final String? initialCategory;

  const NewReportScreen({super.key, this.initialCategory});

  @override
  State<NewReportScreen> createState() => _NewReportScreenState();
}

class _NewReportScreenState extends State<NewReportScreen> {
  int _currentStep = 0;
  static const _totalSteps = reportTotalSteps;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    assert(
      reportStepTitles.length == reportTotalSteps,
      'reportStepTitles.length (${reportStepTitles.length}) != reportTotalSteps ($reportTotalSteps)',
    );
    assert(
      reportStepSubtitles.length == reportTotalSteps,
      'reportStepSubtitles.length (${reportStepSubtitles.length}) != reportTotalSteps ($reportTotalSteps)',
    );
  }

  String? _selectedBuilding;
  String? _selectedFloor;
  String? _selectedArea;
  final _locationSearchController = TextEditingController();
  final _locationDetailsController = TextEditingController();

  String? _selectedCategory;

  final List<String> _photos = [];
  bool _isSubmitting = false;

  final _descriptionController = TextEditingController();

  bool _duplicateChecked = false;
  String? _duplicateAction;

  Floor? get _currentFloor {
    if (_selectedBuilding == null || _selectedFloor == null) return null;
    final building = allBuildings.firstWhere((b) => b.name == _selectedBuilding);
    return building.floors.firstWhere((f) => f.name == _selectedFloor);
  }

  List<Building> get _filteredBuildings {
    final query = _locationSearchController.text.trim().toLowerCase();
    if (query.isEmpty) return allBuildings;
    return allBuildings.where((b) {
      if (b.name.toLowerCase().contains(query)) return true;
      for (final f in b.floors) {
        if (f.name.toLowerCase().contains(query)) return true;
        for (final a in f.areas) {
          if (a.toLowerCase().contains(query)) return true;
        }
      }
      return false;
    }).toList();
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedBuilding != null &&
            _selectedFloor != null &&
            _selectedArea != null;
      case 1:
        return _selectedCategory != null;
      case 2:
        return true;
      case 3:
        return true;
      case 4:
        return _duplicateChecked && _duplicateAction != null;
      default:
        return false;
    }
  }

  String get _stepTitle {
    return reportStepTitles[_currentStep];
  }

  String get _stepSubtitle {
    return reportStepSubtitles[_currentStep];
  }

  @override
  void dispose() {
    _locationSearchController.dispose();
    _locationDetailsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _simulateDuplicateCheck() {
    setState(() {
      _duplicateChecked = true;
    });
  }

  void _handleSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _isSubmitting = true);
    try {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            _duplicateAction == 'confirm'
                ? 'Konfirmasi laporan berhasil dikirim!'
                : 'Laporan baru berhasil dibuat!',
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F7),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildStepContent(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildBottomBar(bottomInset),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 24, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stepTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _stepSubtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          for (int i = 0; i < _totalSteps; i++) ...[
            if (i > 0)
              Expanded(
                child: Container(
                  height: 2,
                  color: i <= _currentStep
                      ? const Color(0xFF111827)
                      : const Color(0xFFE5E7EB),
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: i <= _currentStep
                    ? const Color(0xFF111827)
                    : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: i < _currentStep
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == _currentStep
                              ? Colors.white
                              : const Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildLocationStep();
      case 1:
        return _buildCategoryStep();
      case 2:
        return _buildPhotoStep();
      case 3:
        return _buildDescriptionStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLocationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _locationSearchController,
          decoration: InputDecoration(
            hintText: 'Cari gedung, lantai, atau ruangan...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF9CA3AF)),
            suffixIcon: _locationSearchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      _locationSearchController.clear();
                      setState(() {});
                    },
                  )
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 20),
        if (_selectedArea != null && _selectedFloor != null && _selectedBuilding != null) ...[
          _buildLocationPath(),
          const SizedBox(height: 20),
        ],
        if (_selectedBuilding == null)
          _buildChipSection(
            title: 'Pilih Gedung / Area',
            chips: _filteredBuildings.map((b) => b.name).toList(),
            selected: null,
            onSelect: (v) {
              setState(() {
                _selectedBuilding = v;
              });
              _locationSearchController.clear();
            },
          ),
        if (_selectedBuilding != null && _selectedFloor == null)
          _buildChipSection(
            title: 'Pilih Lantai',
            hint: _selectedBuilding == 'Lokasi Luar Gedung' ? 'Pilih kategori area luar' : null,
            chips: allBuildings
                .firstWhere((b) => b.name == _selectedBuilding)
                .floors
                .map((f) => f.name)
                .toList(),
            selected: null,
            onSelect: (v) => setState(() => _selectedFloor = v),
          ),
        if (_selectedFloor != null && _selectedArea == null)
          _buildChipSection(
            title: 'Pilih Ruangan / Area',
            chips: _currentFloor?.areas ?? [],
            selected: null,
            onSelect: (v) => setState(() => _selectedArea = v),
          ),
        if (_selectedArea != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => setState(() {
              _selectedArea = null;
            }),
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Ubah pilihan lokasi'),
          ),
          const SizedBox(height: 16),
          const Text(
            'Detail lokasi tambahan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _locationDetailsController,
            decoration: const InputDecoration(
              hintText: 'Contoh: di sebelah pintu masuk, dekat jendela...',
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
            ),
            maxLines: 2,
          ),
        ],
      ],
    );
  }

  Widget _buildLocationPath() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, size: 18, color: Color(0xFF3B82F6)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_selectedBuilding › $_selectedFloor › $_selectedArea',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    String? hint,
    required List<String> chips,
    required String? selected,
    required ValueChanged<String> onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 4),
          Text(
            hint,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
        const SizedBox(height: 10),
        if (chips.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Tidak ada hasil',
              style: TextStyle(color: Color(0xFF9CA3AF), fontStyle: FontStyle.italic),
            ),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: chips.map((chip) {
              final isSel = chip == selected;
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => onSelect(chip),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF111827) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSel ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Text(
                      chip,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSel ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildCategoryStep() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: allReportCategories.length,
      itemBuilder: (context, index) {
        final category = allReportCategories[index];
        final isSelected = _selectedCategory == category.name;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => setState(() => _selectedCategory = category.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF111827)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF111827)
                      : const Color(0xFFE5E7EB),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category.icon,
                    color: isSelected ? Colors.white : category.color,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : const Color(0xFF111827),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto bukti (min. 1 foto)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Ambil foto kerusakan sebagai bukti. Foto akan dikompresi otomatis.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _photos.length + 1,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index == _photos.length) {
                return _buildAddPhotoButton();
              }
              return _buildPhotoItem(index);
            },
          ),
        ),
        if (_photos.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Belum ada foto. Ketuk + untuk menambah.',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF9CA3AF),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _showPhotoPicker(BuildContext context) {
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
                  'Tambah Foto',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: Color(0xFF1D4ED8)),
                  ),
                  title: const Text('Kamera'),
                  subtitle: const Text('Ambil foto langsung'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() {
                      _photos.add('mock_photo_${_photos.length + 1}');
                    });
                  },
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: Color(0xFF374151)),
                  ),
                  title: const Text('Galeri'),
                  subtitle: const Text('Pilih dari galeri'),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    setState(() {
                      _photos.add('mock_photo_${_photos.length + 1}');
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddPhotoButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showPhotoPicker(context),
        child: Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
              width: 2,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate_outlined, size: 32, color: Color(0xFF9CA3AF)),
              SizedBox(height: 6),
              Text(
                'Tambah Foto',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoItem(int index) {
    return Stack(
      children: [
        Container(
          width: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 36, color: const Color(0xFF9CA3AF)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Foto ${index + 1}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: GestureDetector(
            onTap: () => setState(() => _photos.removeAt(index)),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFFEF4444),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Deskripsi masalah (opsional)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Jelaskan masalah yang Anda lihat agar petugas lebih mudah memahami.',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            hintText:
                'Contoh: AC tidak mengeluarkan udara dingin sama sekali, sudah dicek remote dan baterai...',
            hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
          ),
          maxLines: 6,
          maxLength: 500,
          textInputAction: TextInputAction.newline,
        ),
        const SizedBox(height: 20),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFF3B82F6), size: 20),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Deskripsi yang jelas membantu petugas menyiapkan peralatan yang tepat.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ringkasan Laporan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 16),
                _buildSummaryRow(Icons.location_on, 'Lokasi',
                    '$_selectedBuilding / $_selectedFloor / $_selectedArea'),
                if (_locationDetailsController.text.isNotEmpty)
                  _buildSummaryRow(Icons.edit_location, 'Detail Lokasi',
                      _locationDetailsController.text),
                const SizedBox(height: 10),
                _buildSummaryRow(Icons.category, 'Kategori', _selectedCategory ?? ''),
                const SizedBox(height: 10),
                _buildSummaryRow(
                    Icons.photo_library, 'Foto', '${_photos.length} foto'),
                if (_descriptionController.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _buildSummaryRow(
                      Icons.description, 'Deskripsi', _descriptionController.text),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (!_duplicateChecked) ...[
          const Text(
            'Pemeriksaan Duplikat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Sistem akan memeriksa apakah masalah serupa sudah dilaporkan.',
            style: TextStyle(fontSize: 13, color: Color(0xFF6B7280), height: 1.5),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _simulateDuplicateCheck,
              icon: const Icon(Icons.search, size: 20),
              label: const Text('Periksa Sekarang'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
        if (_duplicateChecked) ...[
          const Text(
            'Hasil Pemeriksaan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 12),
          _buildDuplicateSuggestion(),
          const SizedBox(height: 20),
          _buildConfirmRadio(),
        ],
      ],
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9CA3AF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Scoring constants in dummy_data.dart:
  // scoreCategoryMatch=60, scoreBuildingMatch=20, scoreFloorMatch=20
  // scoreStrongMatchThreshold=70

  int _computeMatchScore(String category, String? building, String? floor) {
    int score = 0;
    if (_selectedCategory == category) score += scoreCategoryMatch;
    if (_selectedBuilding != null && _selectedBuilding == building) {
      score += scoreBuildingMatch;
    }
    if (_selectedFloor != null && _selectedFloor == floor) {
      score += scoreFloorMatch;
    }
    return score;
  }

  Widget _buildDuplicateSuggestion() {
    final suggestions = duplicateSuggestions;

    final scored = suggestions.map((s) {
      final score = _computeMatchScore(s.category, s.building, s.floor);
      return (suggestion: s, score: score);
    }).toList()
      ..sort((a, b) => b.score.compareTo(a.score));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E0),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Color(0xFFF97316), size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Kami menemukan masalah serupa',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...scored.map((item) {
          final s = item.suggestion;
          final score = item.score;
          final isStrong = score >= scoreStrongMatchThreshold;
          return Padding(
            padding: EdgeInsets.only(
                bottom: s != scored.last.suggestion ? 10 : 0),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isStrong
                      ? const Color(0xFFF97316)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isStrong
                              ? const Color(0xFFFFEDD5)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isStrong ? 'Sangat Mirip' : 'Mirip',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isStrong
                                ? const Color(0xFFC2410C)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE5E7EB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.image_outlined,
                            size: 18, color: Color(0xFF9CA3AF)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 12, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 4),
                                Text(
                                  s.location,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF6B7280)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: s.status == statusInProgress
                                        ? const Color(0xFFFFEDD5)
                                        : const Color(0xFFEFF6FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    s.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: s.status == statusInProgress
                                          ? const Color(0xFFC2410C)
                                          : const Color(0xFF1D4ED8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.people,
                                    size: 12, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 4),
                                Text(
                                  'Dikonfirmasi ${s.confirmCount} mahasiswa',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF9CA3AF)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConfirmRadio() {
    return Column(
      children: [
        _buildRadioOption(
          value: 'confirm',
          title: 'Ini masalah yang sama',
          subtitle: 'Tambah konfirmasi dan ikuti perkembangan insiden',
          icon: Icons.verified_outlined,
        ),
        const SizedBox(height: 12),
        _buildRadioOption(
          value: 'new',
          title: 'Buat laporan baru',
          subtitle: 'Masalah ini berbeda dan perlu insiden baru',
          icon: Icons.add_circle_outline,
        ),
      ],
    );
  }

  Widget _buildRadioOption({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _duplicateAction == value;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => setState(() => _duplicateAction = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF3F4F6) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF111827)
                    : const Color(0xFF9CA3AF),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF111827)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF111827)
                        : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  color: isSelected ? const Color(0xFF111827) : Colors.transparent,
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset > 0 ? bottomInset : 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFF3F4F6)),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: Color(0xFFE5E7EB)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  foregroundColor: const Color(0xFF111827),
                ),
                child: const Text('Kembali'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _isSubmitting
                  ? null
                  : _currentStep == _totalSteps - 1
                      ? (_canProceed ? _handleSubmit : null)
                      : (_canProceed ? _nextStep : null),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                backgroundColor: _canProceed
                    ? const Color(0xFF111827)
                    : const Color(0xFFD1D5DB),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _currentStep == _totalSteps - 1
                          ? 'Kirim Laporan'
                          : 'Lanjut',
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
