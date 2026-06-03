import 'package:flutter/material.dart';

import 'package:civic_campus/data/constants/app_constants.dart';
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

  void _showPhotoPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => PhotoPickerSheet(
        onCamera: () => setState(() => _photos.add('mock_photo_${_photos.length + 1}')),
        onGallery: () => setState(() => _photos.add('mock_photo_${_photos.length + 1}')),
      ),
    );
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

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return LocationStep(
          selectedBuilding: _selectedBuilding,
          selectedFloor: _selectedFloor,
          selectedArea: _selectedArea,
          searchController: _locationSearchController,
          detailsController: _locationDetailsController,
          onBuildingSelected: (v) => setState(() => _selectedBuilding = v),
          onFloorSelected: (v) => setState(() => _selectedFloor = v),
          onAreaSelected: (v) => setState(() => _selectedArea = v),
          onClearArea: () => setState(() => _selectedArea = null),
          onSearchChanged: () => setState(() {}),
        );
      case 1:
        return CategoryStep(
          selectedCategory: _selectedCategory,
          onCategorySelected: (v) => setState(() => _selectedCategory = v),
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
          onCheckDuplicates: () => setState(() => _duplicateChecked = true),
          onDuplicateAction: (v) => setState(() => _duplicateAction = v),
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
