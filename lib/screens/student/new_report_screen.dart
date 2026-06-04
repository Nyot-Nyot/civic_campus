import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:civic_campus/data/constants/app_constants.dart';
import 'package:civic_campus/data/models/category.dart';
import 'package:civic_campus/data/providers/category_provider.dart';
import 'package:civic_campus/data/providers/location_provider.dart';
import 'package:civic_campus/data/providers/report_provider.dart';
import 'package:civic_campus/screens/student/steps/category_step.dart';
import 'package:civic_campus/screens/student/steps/description_step.dart';
import 'package:civic_campus/screens/student/steps/location_step.dart';
import 'package:civic_campus/screens/student/steps/photo_step.dart';
import 'package:civic_campus/widgets/photo_picker_sheet.dart';
import 'package:civic_campus/screens/student/steps/review_step.dart';

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
  List<Map<String, dynamic>> _duplicateResults = [];

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialCategory;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().loadBuildings();
      context.read<CategoryProvider>().load();
    });
    assert(
      reportStepTitles.length == reportTotalSteps,
      'reportStepTitles.length (${reportStepTitles.length}) != reportTotalSteps ($reportTotalSteps)',
    );
    assert(
      reportStepSubtitles.length == reportTotalSteps,
      'reportStepSubtitles.length (${reportStepSubtitles.length}) != reportTotalSteps ($reportTotalSteps)',
    );
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _selectedBuilding != null && _selectedFloor != null && _selectedArea != null;
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

  String get _stepTitle => reportStepTitles[_currentStep];
  String get _stepSubtitle => reportStepSubtitles[_currentStep];

  @override
  void dispose() {
    _locationSearchController.dispose();
    _locationDetailsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) setState(() => _currentStep++);
  }

  void _previousStep() {
    if (_currentStep > 0) setState(() => _currentStep--);
  }

  void _handleBuildingSelected(String name) {
    final provider = context.read<LocationProvider>();
    final building = provider.buildings.firstWhere((b) => b['name'] == name);
    provider.selectBuilding(building);
    setState(() {
      _selectedBuilding = name;
      _selectedFloor = null;
      _selectedArea = null;
    });
  }

  void _handleFloorSelected(String name) {
    final provider = context.read<LocationProvider>();
    final floor = provider.floors.firstWhere((f) => f['name'] == name);
    provider.selectFloor(floor);
    setState(() {
      _selectedFloor = name;
      _selectedArea = null;
    });
  }

  void _handleAreaSelected(String name) {
    final provider = context.read<LocationProvider>();
    final area = provider.areas.firstWhere((a) => a['name'] == name);
    provider.selectArea(area);
    setState(() => _selectedArea = name);
  }

  void _handleClearArea() {
    final provider = context.read<LocationProvider>();
    provider.clearSelection();
    setState(() {
      _selectedBuilding = null;
      _selectedFloor = null;
      _selectedArea = null;
    });
  }

  Future<void> _handleCheckDuplicates() async {
    final reportProvider = context.read<ReportProvider>();
    final locationProvider = context.read<LocationProvider>();
    final categoryProvider = context.read<CategoryProvider>();

    final locationId = locationProvider.getSelectedLocationId() ?? '';
    final categoryMap = categoryProvider.categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
    );
    final categoryId = categoryMap['id'] as String;

    final results = await reportProvider.checkDuplicates(
      locationId: locationId,
      categoryId: categoryId,
      description: _descriptionController.text,
    );

    if (!mounted) return;
    setState(() {
      _duplicateChecked = true;
      _duplicateResults = results;
    });
  }

  void _handleSubmit() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final reportProvider = context.read<ReportProvider>();
    final locationProvider = context.read<LocationProvider>();

    setState(() => _isSubmitting = true);

    final locationId = locationProvider.getSelectedLocationId() ?? '';
    final locationDetails = _locationDetailsController.text;
    final categoryProvider = context.read<CategoryProvider>();
    final categoryMap = categoryProvider.categories.firstWhere(
      (c) => c['name'] == _selectedCategory,
    );
    final categoryId = categoryMap['id'] as String;
    final description = _descriptionController.text;

    List<int>? photoBytes;
    String? photoFileName;
    if (_photos.isNotEmpty) {
      final file = File(_photos.first);
      photoBytes = await file.readAsBytes();
      photoFileName = _photos.first.split('/').last;
    }

    final error = await reportProvider.submit(
      locationId: locationId,
      locationDetails: locationDetails.isEmpty ? null : locationDetails,
      categoryId: categoryId,
      description: description.isEmpty ? null : description,
      photoBytes: photoBytes,
      photoFileName: photoFileName,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (error == null) {
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
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $error'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _showPhotoPicker() async {
    final picker = ImagePicker();
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (ctx) => PhotoPickerSheet(
        onCamera: () {
          Navigator.pop(ctx);
          Future.microtask(() async {
            final XFile? image = await picker.pickImage(source: ImageSource.camera);
            if (image != null && mounted) {
              setState(() => _photos.add(image.path));
            }
          });
        },
        onGallery: () {
          Navigator.pop(ctx);
          Future.microtask(() async {
            final XFile? image = await picker.pickImage(source: ImageSource.gallery);
            if (image != null && mounted) {
              setState(() => _photos.add(image.path));
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final locationProvider = context.watch<LocationProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final buildingNames = locationProvider.buildings
        .map((b) => b['name'] as String)
        .toList();
    final floorNames = locationProvider.floors
        .map((f) => f['name'] as String)
        .toList();
    final areaNames = locationProvider.areas
        .map((a) => a['name'] as String)
        .toList();

    final categories = categoryProvider.categories
        .map((c) => ReportCategory.fromJson(c))
        .toList();

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
                    _buildStepContent(
                      buildingNames: buildingNames,
                      floorNames: floorNames,
                      areaNames: areaNames,
                      categories: categories,
                      isLoading: locationProvider.isLoading,
                      locationError: locationProvider.error,
                      onRetry: () => locationProvider.loadBuildings(),
                    ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_stepTitle,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                Text(_stepSubtitle,
                    style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
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
                  color: i <= _currentStep ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                ),
              ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: i <= _currentStep ? const Color(0xFF111827) : const Color(0xFFE5E7EB),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: i < _currentStep
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : Text('${i + 1}',
                        style: TextStyle(
                            color: i == _currentStep ? Colors.white : const Color(0xFF9CA3AF),
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent({
    required List<String> buildingNames,
    required List<String> floorNames,
    required List<String> areaNames,
    required List<ReportCategory> categories,
    bool isLoading = false,
    String? locationError,
    VoidCallback? onRetry,
  }) {
    switch (_currentStep) {
      case 0:
        return LocationStep(
          selectedBuilding: _selectedBuilding,
          selectedFloor: _selectedFloor,
          selectedArea: _selectedArea,
          searchController: _locationSearchController,
          detailsController: _locationDetailsController,
          onBuildingSelected: _handleBuildingSelected,
          onFloorSelected: _handleFloorSelected,
          onAreaSelected: _handleAreaSelected,
          onClearArea: _handleClearArea,
          onSearchChanged: () => setState(() {}),
          buildings: buildingNames,
          floors: floorNames,
          areas: areaNames,
          isLoading: isLoading,
          errorMessage: locationError,
          onRetry: onRetry,
        );
      case 1:
        return CategoryStep(
          selectedCategory: _selectedCategory,
          onCategorySelected: (v) => setState(() => _selectedCategory = v),
          categories: categories,
        );
      case 2:
        return PhotoStep(
          photos: _photos,
          onAddPhoto: _showPhotoPicker,
          onRemovePhoto: (i) => setState(() => _photos.removeAt(i)),
        );
      case 3:
        return DescriptionStep(controller: _descriptionController);
      case 4:
        return ReviewStep(
          selectedBuilding: _selectedBuilding,
          selectedFloor: _selectedFloor,
          selectedArea: _selectedArea,
          selectedCategory: _selectedCategory,
          detailsController: _locationDetailsController,
          descriptionController: _descriptionController,
          photoCount: _photos.length,
          duplicateChecked: _duplicateChecked,
          duplicateAction: _duplicateAction,
          onCheckDuplicates: _handleCheckDuplicates,
          onDuplicateAction: (v) => setState(() => _duplicateAction = v),
          duplicateResults: _duplicateResults,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildBottomBar(double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomInset > 0 ? bottomInset : 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                backgroundColor: _canProceed ? const Color(0xFF111827) : const Color(0xFFD1D5DB),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    )
                  : Text(_currentStep == _totalSteps - 1 ? 'Kirim Laporan' : 'Lanjut'),
            ),
          ),
        ],
      ),
    );
  }
}
