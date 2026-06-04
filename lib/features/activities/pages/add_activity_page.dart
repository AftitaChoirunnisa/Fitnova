import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/activity_model.dart';
import '../services/activity_service.dart';

class AddActivityPage extends StatefulWidget {
  final ActivityModel? activity;

  const AddActivityPage({
    super.key,
    this.activity,
  });

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final ActivityService _activityService = ActivityService();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  final List<String> _sportTypes = [
    'Lari',
    'Jalan Kaki',
    'Bersepeda',
    'Renang',
    'Gym',
    'Yoga',
    'Futsal',
    'Badminton',
    'Basket',
    'Workout Rumah',
  ];

  String? _selectedSportType;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  bool get _isEditMode => widget.activity != null;

  @override
  void initState() {
    super.initState();

    final activity = widget.activity;

    if (activity != null) {
      _selectedSportType = activity.sportType;
      _durationController.text = activity.duration.toString();
      _caloriesController.text = activity.calories.toString();
      _noteController.text = activity.note;
      _selectedDate = activity.activityDate;
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _selectActivityDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
    });
  }

  Future<void> _saveActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedSportType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jenis olahraga terlebih dahulu.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final duration = int.parse(_durationController.text.trim());
      final calories = int.parse(_caloriesController.text.trim());

      if (_isEditMode) {
        final oldActivity = widget.activity!;

        final updatedActivity = oldActivity.copyWith(
          sportType: _selectedSportType,
          duration: duration,
          calories: calories,
          activityDate: _selectedDate,
          note: _noteController.text.trim(),
          updatedAt: DateTime.now(),
        );

        await _activityService.updateActivity(updatedActivity);
      } else {
        await _activityService.addActivity(
          sportType: _selectedSportType!,
          duration: duration,
          calories: calories,
          activityDate: _selectedDate,
          note: _noteController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditMode
                ? 'Aktivitas berhasil diperbarui.'
                : 'Aktivitas berhasil ditambahkan.',
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

  @override
  Widget build(BuildContext context) {
    final title = _isEditMode ? 'Edit Aktivitas' : 'Tambah Aktivitas';

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
            AppColors.primary,
            AppColors.secondary,
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
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isEditMode
                  ? 'Perbarui data aktivitas olahraga kamu.'
                  : 'Catat olahraga hari ini agar progress kamu lebih terpantau.',
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
              DropdownButtonFormField<String>(
                initialValue: _selectedSportType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Olahraga',
                  prefixIcon: Icon(Icons.sports_gymnastics_rounded),
                ),
                items: _sportTypes.map((sport) {
                  return DropdownMenuItem<String>(
                    value: sport,
                    child: Text(sport),
                  );
                }).toList(),
                onChanged: _isLoading
                    ? null
                    : (value) {
                        setState(() {
                          _selectedSportType = value;
                        });
                      },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jenis olahraga wajib dipilih';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _durationController,
                label: 'Durasi Olahraga',
                hint: 'Contoh: 30',
                prefixIcon: Icons.timer_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return _validatePositiveNumber(value, 'Durasi');
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _caloriesController,
                label: 'Kalori Terbakar',
                hint: 'Contoh: 150',
                prefixIcon: Icons.local_fire_department_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return _validatePositiveNumber(value, 'Kalori');
                },
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _isLoading ? null : _selectActivityDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Aktivitas',
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                  ),
                  child: Text(
                    DateFormatter.formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _noteController,
                label: 'Catatan',
                hint: 'Contoh: Lari pagi di taman',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
                validator: (value) {
                  return Validators.required(value, 'Catatan');
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: _isEditMode ? 'Simpan Perubahan' : 'Tambah Aktivitas',
                isLoading: _isLoading,
                onPressed: _saveActivity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}