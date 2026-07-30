import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/features/farm/data/models/farm.dart';
import 'location_picker_map.dart';

/// Result handed back to the caller when the user saves the form.
class FarmSheetResult {
  final String address;
  final double sizeHectares;
  final LatLng? location;

  const FarmSheetResult({
    required this.address,
    required this.sizeHectares,
    this.location,
  });
}

/// Bottom-sheet form for adding or editing a farm. Shown via [showFarmSheet].
/// Pass [farm] to pre-fill the form for editing; omit it to add a new farm.
class FarmSheet extends StatefulWidget {
  final FarmModel? farm;

  const FarmSheet({super.key, this.farm});

  @override
  State<FarmSheet> createState() => _FarmSheetState();
}

class _FarmSheetState extends State<FarmSheet> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _sizeController = TextEditingController();
  LatLng? _pickedLatLng;

  bool get _isEditing => widget.farm != null;

  @override
  void initState() {
    super.initState();
    final farm = widget.farm;
    if (farm != null) {
      _addressController.text = farm.address;
      _sizeController.text = farm.sizeHectares.toString();
      if (farm.latitude != null && farm.longitude != null) {
        _pickedLatLng = LatLng(farm.latitude!, farm.longitude!);
      }
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  Future<void> _pickLocation() async {
    final result = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerMap(initial: _pickedLatLng),
      ),
    );
    if (result == null) return;
    setState(() {
      _pickedLatLng = result.latLng;
      // Only overwrite the address field if the user hasn't typed their
      // own — avoids clobbering manual edits after re-opening the picker.
      if (_addressController.text.trim().isEmpty && result.address != null) {
        _addressController.text = result.address!;
      }
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      FarmSheetResult(
        address: _addressController.text.trim(),
        sizeHectares: double.parse(_sizeController.text.trim()),
        location: _pickedLatLng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: screenHeight * 0.9),
        child: Container(
          decoration: BoxDecoration(
            color: ext.cream,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.lg),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x3,
                AppSpacing.x5,
                AppSpacing.x5,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: AppSpacing.x4),
                        decoration: BoxDecoration(
                          color: ext.hairline,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                      ),
                    ),
                    Text(
                      _isEditing ? 'Edit Farm' : 'Add Farm',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(color: ext.cocoa),
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    _FieldLabel(ext: ext, text: 'Address'),
                    const SizedBox(height: AppSpacing.x1),
                    _FormField(
                      ext: ext,
                      controller: _addressController,
                      hint: 'Sitio, Barangay, City/Municipality',
                      maxLines: 2,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    _FieldLabel(ext: ext, text: 'Size (hectares)'),
                    const SizedBox(height: AppSpacing.x1),
                    _FormField(
                      ext: ext,
                      controller: _sizeController,
                      hint: 'e.g. 3.2',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        final n = double.tryParse(v.trim());
                        if (n == null || n <= 0) return 'Enter a valid size';
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    _FieldLabel(ext: ext, text: 'Farm location'),
                    const SizedBox(height: AppSpacing.x1),
                    InkWell(
                      onTap: _pickLocation,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.x3,
                          vertical: AppSpacing.x3,
                        ),
                        decoration: BoxDecoration(
                          color: ext.sand,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                          border: Border.all(color: ext.hairline),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _pickedLatLng == null
                                  ? Icons.map_outlined
                                  : Icons.check_circle,
                              size: 18,
                              color: _pickedLatLng == null
                                  ? ext.cocoa50
                                  : AppColors.ember,
                            ),
                            const SizedBox(width: AppSpacing.x2),
                            Expanded(
                              child: Text(
                                _pickedLatLng == null
                                    ? 'Pin location on map'
                                    : '${_pickedLatLng!.latitude.toStringAsFixed(5)}, '
                                          '${_pickedLatLng!.longitude.toStringAsFixed(5)}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  color: _pickedLatLng == null
                                      ? ext.cocoa50
                                      : ext.cocoa,
                                  fontWeight: _pickedLatLng == null
                                      ? FontWeight.w400
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: ext.cocoa50,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x5),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.ember,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.x3,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                        ),
                        onPressed: _save,
                        child: Text(_isEditing ? 'Update Farm' : 'Save Farm'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final AppThemeExtension ext;
  final String text;

  const _FieldLabel({required this.ext, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: ext.cocoa50,
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final AppThemeExtension ext;
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _FormField({
    required this.ext,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(fontSize: 14, color: ext.cocoa),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: ext.cocoa50),
        filled: true,
        fillColor: ext.sand,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x3,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

/// Convenience opener. Pass [farm] to pre-fill the form for editing;
/// omit it to add a new farm.
Future<FarmSheetResult?> showFarmSheet(
  BuildContext context, {
  FarmModel? farm,
}) {
  return showModalBottomSheet<FarmSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FarmSheet(farm: farm),
  );
}
