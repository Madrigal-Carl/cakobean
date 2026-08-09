import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:cakobean/ui/features/farm/widgets/form_field.dart';
import 'package:cakobean/ui/features/farm/widgets/tree_status.dart';

/// Result handed back to the caller when the user saves the tree form.
class TreeSheetResult {
  final String name;
  final String? variety;
  final DateTime? plantedOn;
  final TreeStatus status;

  const TreeSheetResult({
    required this.name,
    this.variety,
    this.plantedOn,
    required this.status,
  });
}

/// Bottom-sheet form for adding or editing a cacao tree. Shown via
/// [showTreeSheet]. Pass [tree] to pre-fill for editing; omit it to add.
class TreeSheet extends StatefulWidget {
  final CacaoTree? tree;

  const TreeSheet({super.key, this.tree});

  @override
  State<TreeSheet> createState() => _TreeSheetState();
}

class _TreeSheetState extends State<TreeSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  DateTime? _plantedOn;
  TreeStatus _status = TreeStatus.healthy;

  bool get _isEditing => widget.tree != null;

  @override
  void initState() {
    super.initState();
    final tree = widget.tree;
    if (tree != null) {
      _nameController.text = tree.name;
      _varietyController.text = tree.variety ?? '';
      _plantedOn = tree.plantedOn;
      _status = tree.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    super.dispose();
  }

  Future<void> _pickPlantedDate() async {
    final now = DateTime.now();
    final initial = _plantedOn ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isAfter(now) ? now : initial,
      firstDate: DateTime(now.year - 100),
      lastDate: now,
      helpText: 'When was this tree planted?',
    );
    if (picked == null) return;
    setState(() => _plantedOn = picked);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TreeSheetResult(
        name: _nameController.text.trim(),
        variety: _varietyController.text.trim().isEmpty
            ? null
            : _varietyController.text.trim(),
        plantedOn: _plantedOn,
        status: _status,
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
        constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
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
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: ext.sand,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Icon(
                            Icons.park_outlined,
                            color: AppColors.ember,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.x3),
                        Text(
                          _isEditing ? 'Edit Tree' : 'Add Tree',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(color: ext.cocoa),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x4),
                    FarmFieldLabel(ext: ext, text: 'Name'),
                    const SizedBox(height: AppSpacing.x1),
                    FarmFormField(
                      ext: ext,
                      controller: _nameController,
                      hint: 'e.g. Tree 1',
                      prefixIcon: Icons.park_outlined,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    FarmFieldLabel(ext: ext, text: 'Variety (optional)'),
                    const SizedBox(height: AppSpacing.x1),
                    FarmFormField(
                      ext: ext,
                      controller: _varietyController,
                      hint: 'e.g. UF18, Trinitario',
                      prefixIcon: Icons.science_outlined,
                    ),
                    const SizedBox(height: AppSpacing.x3),
                    FarmFieldLabel(ext: ext, text: 'Planted on'),
                    const SizedBox(height: AppSpacing.x1),
                    InkWell(
                      onTap: _pickPlantedDate,
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
                              Icons.event_outlined,
                              size: 18,
                              color: ext.cocoa50,
                            ),
                            const SizedBox(width: AppSpacing.x2),
                            Expanded(
                              child: Text(
                                _plantedOn == null
                                    ? 'Select date'
                                    : formatTreeDate(_plantedOn!),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: _plantedOn == null
                                      ? FontWeight.w400
                                      : FontWeight.w600,
                                  color: _plantedOn == null
                                      ? ext.cocoa50
                                      : ext.cocoa,
                                ),
                              ),
                            ),
                            if (_plantedOn != null)
                              GestureDetector(
                                onTap: () =>
                                    setState(() => _plantedOn = null),
                                child: Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 16,
                                    color: ext.cocoa50,
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
                    const SizedBox(height: AppSpacing.x3),
                    FarmFieldLabel(ext: ext, text: 'Status'),
                    const SizedBox(height: AppSpacing.x1),
                    Wrap(
                      spacing: AppSpacing.x2,
                      runSpacing: AppSpacing.x2,
                      children: [
                        for (final status in TreeStatus.values)
                          _StatusSelectChip(
                            status: status,
                            selected: status == _status,
                            onTap: () => setState(() => _status = status),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.x5),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _save,
                        child: Text(_isEditing ? 'Update Tree' : 'Save Tree'),
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

/// Selectable status chip used inside [TreeSheet]. Selected state tints the
/// chip with the status color and adds a matching border.
class _StatusSelectChip extends StatelessWidget {
  final TreeStatus status;
  final bool selected;
  final VoidCallback onTap;

  const _StatusSelectChip({
    required this.status,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final meta = treeStatusMeta(context, status);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x3,
          vertical: AppSpacing.x1,
        ),
        decoration: BoxDecoration(
          color: selected
              ? meta.color.withValues(alpha: 0.12)
              : ext.sand,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? meta.color : ext.hairline,
            width: selected ? 1.2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(meta.icon, size: 14, color: selected ? meta.color : ext.cocoa50),
            const SizedBox(width: 6),
            Text(
              meta.label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: selected ? ext.cocoa : ext.cocoa50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Convenience opener. Pass [tree] to pre-fill the form for editing;
/// omit it to add a new tree.
Future<TreeSheetResult?> showTreeSheet(
  BuildContext context, {
  CacaoTree? tree,
}) {
  return showModalBottomSheet<TreeSheetResult>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TreeSheet(tree: tree),
  );
}
