// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/challenge_model.dart';
import '../services/challenge_service.dart';

class AddChallengePage extends StatefulWidget {
  final ChallengeModel? challenge;

  const AddChallengePage({
    super.key,
    this.challenge,
  });

  @override
  State<AddChallengePage> createState() => _AddChallengePageState();
}

class _AddChallengePageState extends State<AddChallengePage> {
  final ChallengeService _challengeService = ChallengeService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetDurationController =
      TextEditingController();
  final TextEditingController _targetDaysController = TextEditingController();

  final List<String> _categories = [
    'Cardio',
    'Strength',
    'Yoga',
    'Running',
    'Cycling',
    'General Fitness',
  ];

  String? _selectedCategory;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  bool _isLoading = false;

  bool get _isEditMode => widget.challenge != null;

  @override
  void initState() {
    super.initState();

    final challenge = widget.challenge;

    if (challenge != null) {
      _titleController.text = challenge.title;
      _descriptionController.text = challenge.description;
      _targetDurationController.text = challenge.targetDuration.toString();
      _targetDaysController.text = challenge.targetDays.toString();
      _selectedCategory = challenge.category;
      _startDate = challenge.startDate;
      _endDate = challenge.endDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetDurationController.dispose();
    _targetDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    setState(() {
      _startDate = pickedDate;

      if (_endDate.isBefore(_startDate)) {
        _endDate = _startDate.add(const Duration(days: 7));
      }
    });
  }

  Future<void> _pickEndDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) return;

    setState(() {
      _endDate = pickedDate;
    });
  }

  String? _validatePositiveNumber(String? value, String fieldName) {
    final baseValidation = Validators.number(value, fieldName);

    if (baseValidation != null) {
      return baseValidation;
    }

    final number = int.tryParse(value!.trim());

    if (number == null || number <= 0) {
      return '$fieldName harus lebih dari 0';
    }

    return null;
  }

  Future<void> _saveChallenge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih kategori challenge terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final targetDuration = int.parse(_targetDurationController.text.trim());
      final targetDays = int.parse(_targetDaysController.text.trim());

      if (_isEditMode) {
        final oldChallenge = widget.challenge!;

        final updatedChallenge = oldChallenge.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory,
          targetDuration: targetDuration,
          targetDays: targetDays,
          startDate: _startDate,
          endDate: _endDate,
          updatedAt: DateTime.now(),
        );

        await _challengeService.updateChallenge(updatedChallenge);
      } else {
        await _challengeService.addChallenge(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          category: _selectedCategory!,
          targetDuration: targetDuration,
          targetDays: targetDays,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Challenge berhasil diperbarui.'
                : 'Challenge berhasil dibuat.',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Challenge' : 'Buat Challenge';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeaderCard(context),
              const SizedBox(height: 18),
              _buildForm(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            AppColors.secondary,
            AppColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isEditMode
                  ? 'Perbarui challenge agar targetnya lebih sesuai.'
                  : 'Buat challenge olahraga agar pengguna lebih termotivasi.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: 'Judul Challenge',
                hint: 'Contoh: 7 Hari Lari Pagi',
                prefixIcon: Icons.title_rounded,
                validator: (value) => Validators.required(value, 'Judul'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                label: 'Deskripsi',
                hint: 'Jelaskan challenge ini',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                validator: (value) => Validators.required(value, 'Deskripsi'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedCategory = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kategori wajib dipilih';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _targetDurationController,
                label: 'Target Durasi',
                hint: 'Contoh: 150',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return _validatePositiveNumber(value, 'Target durasi');
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _targetDaysController,
                label: 'Target Hari',
                hint: 'Contoh: 7',
                prefixIcon: Icons.calendar_month_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return _validatePositiveNumber(value, 'Target hari');
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _isLoading ? null : _pickStartDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Mulai',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(DateFormatter.formatDate(_startDate)),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _isLoading ? null : _pickEndDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Selesai',
                    prefixIcon: Icon(Icons.event_available_outlined),
                  ),
                  child: Text(DateFormatter.formatDate(_endDate)),
                ),
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEditMode ? 'Simpan Perubahan' : 'Buat Challenge',
                isLoading: _isLoading,
                onPressed: _saveChallenge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}