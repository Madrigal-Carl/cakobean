import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/core/widgets/app_snackbar.dart';
import 'package:cakobean/ui/core/widgets/confirm_dialog.dart';
import 'package:cakobean/ui/core/widgets/pressable_scale.dart';
import 'package:cakobean/ui/core/widgets/stat_chip.dart';
import 'package:cakobean/ui/features/farm/view_models/farm_viewmodel.dart';
import 'package:cakobean/ui/features/farm/widgets/farm_sheet.dart';

class FarmCard extends ConsumerWidget {
  final FarmModel farm;
  final AppThemeExtension ext;
  final bool canManage;

  const FarmCard({
    super.key,
    required this.farm,
    required this.ext,
    this.canManage = true,
  });

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final result = await showFarmSheet(context, farm: farm);
    if (result == null) return;
    try {
      await ref.read(farmRepositoryProvider).updateFarm(
        FarmModel(
          id: farm.id,
          address: result.address,
          sizeHectares: result.sizeHectares,
          latitude: result.location?.latitude,
          longitude: result.location?.longitude,
        ),
      );
      if (context.mounted) {
        showAppSnackbar(
          context,
          'Farm updated.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t update farm: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.delete_outline_rounded,
      title: 'Delete farm?',
      message: '"${farm.address}" will be permanently removed from your '
          'farms.',
      confirmLabel: 'Delete',
    );
    if (confirmed != true) return;
    try {
      await ref.read(farmRepositoryProvider).deleteFarm(farm.id);
      if (context.mounted) {
        showAppSnackbar(
          context,
          'Farm deleted.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (context.mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t delete farm: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PressableScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: () => context.push('/farm/${farm.id}', extra: farm),
          child: Container(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x4,
              AppSpacing.x3,
            ),
            decoration: BoxDecoration(
              color: ext.cardSurface,
              borderRadius: BorderRadius.circular(AppRadius.md),
              boxShadow: ext.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ext.sand,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        Icons.location_on_rounded,
                        color: AppColors.ember,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.x3),
                    Expanded(
                      child: Text(
                        farm.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: ext.cocoa,
                          height: 1.35,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: ext.cocoa50),
                  ],
                ),
                const SizedBox(height: AppSpacing.x3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StatChip(
                      ext: ext,
                      icon: Icons.straighten_rounded,
                      label: '${farm.sizeHectares.toStringAsFixed(1)} ha',
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    FarmTreeCountChip(ext: ext, farmId: farm.id),
                    if (canManage) ...[
                      const SizedBox(width: AppSpacing.x2),
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () => _edit(context, ref),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: ext.cocoa50,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x2),
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () => _delete(context, ref),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            size: 18,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Live tree count chip shown on a farm card. The count comes from the
/// farm's actual tree records, so it stays accurate as trees are added or
/// removed on the detail page.
class FarmTreeCountChip extends ConsumerWidget {
  final AppThemeExtension ext;
  final String farmId;

  const FarmTreeCountChip({super.key, required this.ext, required this.farmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trees = ref.watch(farmTreesProvider(farmId));
    final count = trees.maybeWhen(data: (t) => t.length, orElse: () => null);
    final label = count == null
        ? '— trees'
        : '$count ${count == 1 ? 'tree' : 'trees'}';
    return StatChip(ext: ext, icon: Icons.park_outlined, label: label);
  }
}
