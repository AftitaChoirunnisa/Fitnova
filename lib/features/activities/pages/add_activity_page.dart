import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/soft_card.dart';
import '../../../core/widgets/soft_gradient_card.dart';
import '../../../models/activity_model.dart';
import '../services/activity_service.dart';

class AddActivityPage extends StatefulWidget {
  final ActivityModel? activity;

  const AddActivityPage({super.key, this.activity});

  @override
  State<AddActivityPage> createState() => _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  final ActivityService _activityService = ActivityService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _caloriesController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  final List<Map<String, dynamic>> _sportTypes = [
    {'name': 'Lari', 'icon': Icons.directions_run_rounded, 'label': 'Running'},
    {
      'name': 'Jalan Kaki',
      'icon': Icons.directions_walk_rounded,
      'label': 'Walking',
    },
    {
      'name': 'Bersepeda',
      'icon': Icons.directions_bike_rounded,
      'label': 'Cycling',
    },
    {'name': 'Renang', 'icon': Icons.pool_rounded, 'label': 'Swimming'},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded, 'label': 'Gym'},
    {'name': 'Yoga', 'icon': Icons.self_improvement_rounded, 'label': 'Yoga'},
    {'name': 'Futsal', 'icon': Icons.sports_soccer_rounded, 'label': 'Futsal'},
    {
      'name': 'Badminton',
      'icon': Icons.sports_tennis_rounded,
      'label': 'Badminton',
    },
    {
      'name': 'Basket',
      'icon': Icons.sports_basketball_rounded,
      'label': 'Basket',
    },
    {
      'name': 'Workout Rumah',
      'icon': Icons.home_work_rounded,
      'label': 'Home Workout',
    },
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
    _dateController.text = DateFormatter.formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectActivityDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryGreen,
              onPrimary: AppColors.darkGreen,
              surface: AppColors.softCard,
              onSurface: AppColors.textPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: AppColors.softCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedDate = pickedDate;
      _dateController.text = DateFormatter.formatDate(pickedDate);
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
          backgroundColor: AppColors.danger,
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
          backgroundColor: AppColors.danger,
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
    final title = _isEditMode ? 'Edit Activity' : 'Add Activity';

    return AppScaffold(
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: AppColors.textPrimary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      appBarTitle: title,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return SoftGradientCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isEditMode
                  ? 'Update your activity logs to keep your streaks alive.'
                  : 'Log your workouts today to track your steps toward fitness goals.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return SoftCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Sport Type',
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _sportTypes.map((sport) {
                final isSelected = _selectedSportType == sport['name'];
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        sport['icon'] as IconData,
                        size: 16,
                        color: isSelected
                            ? AppColors.darkGreen
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(sport['label'] as String),
                    ],
                  ),
                  selected: isSelected,
                  onSelected: _isLoading
                      ? null
                      : (selected) {
                          setState(() {
                            _selectedSportType = selected
                                ? (sport['name'] as String)
                                : null;
                          });
                        },
                  backgroundColor: AppColors.darkGreen,
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    color: isSelected
                        ? AppColors.darkGreen
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.borderSoft,
                    width: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  showCheckmark: false,
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            AppTextField(
              controller: _durationController,
              label: 'Duration (minutes)',
              hint: 'e.g. 30',
              prefixIcon: Icons.timer_outlined,
              keyboardType: TextInputType.number,
              validator: (value) => _validatePositiveNumber(value, 'Duration'),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _caloriesController,
              label: 'Calories Burned (kcal)',
              hint: 'e.g. 150',
              prefixIcon: Icons.local_fire_department_outlined,
              keyboardType: TextInputType.number,
              validator: (value) => _validatePositiveNumber(value, 'Calories'),
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _dateController,
              label: 'Activity Date',
              hint: 'Select Date',
              prefixIcon: Icons.calendar_today_outlined,
              readOnly: true,
              onTap: _isLoading ? null : _selectActivityDate,
            ),
            const SizedBox(height: 18),
            AppTextField(
              controller: _noteController,
              label: 'Notes',
              hint: 'e.g. Morning run around the park',
              prefixIcon: Icons.notes_rounded,
              maxLines: 3,
              validator: (value) => Validators.required(value, 'Notes'),
            ),
            const SizedBox(height: 28),
            PrimaryButton(
              text: _isEditMode ? 'Save Changes' : 'Save Activity',
              isLoading: _isLoading,
              onPressed: _saveActivity,
            ),
          ],
        ),
      ),
    );
  }
}
