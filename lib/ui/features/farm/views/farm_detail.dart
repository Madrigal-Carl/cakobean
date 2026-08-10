import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/cacao_tree.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/core/widgets/app_snackbar.dart';
import 'package:cakobean/ui/core/widgets/confirm_dialog.dart';
import 'package:cakobean/ui/core/widgets/empty_state.dart';
import 'package:cakobean/ui/core/widgets/pressable_scale.dart';
import 'package:cakobean/ui/core/widgets/stat_chip.dart';
import 'package:cakobean/ui/features/farm/view_models/farm_viewmodel.dart';
import 'package:cakobean/ui/features/farm/widgets/farm_sheet.dart';
import 'package:cakobean/ui/features/farm/widgets/tree_sheet.dart';
import 'package:cakobean/ui/features/farm/widgets/tree_status.dart';

class FarmDetail extends ConsumerStatefulWidget {
  final String farmId;
  final FarmModel? farm; // passed via go_router `extra` when available

  const FarmDetail({super.key, required this.farmId, this.farm});

  @override
  ConsumerState<FarmDetail> createState() => _FarmDetailState();
}

class _FarmDetailState extends ConsumerState<FarmDetail> {
  final _mapController = MapController();

  Future<void> _edit(FarmModel farm) async {
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
      if (mounted) {
        showAppSnackbar(
          context,
          'Farm updated.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t update farm: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  Future<void> _addTree(FarmModel farm) async {
    final result = await showTreeSheet(context);
    if (result == null) return;
    try {
      await ref.read(farmRepositoryProvider).addTree(
            farmId: farm.id,
            name: result.name,
            variety: result.variety,
            plantedOn: result.plantedOn,
            status: result.status,
          );
      if (mounted) {
        showAppSnackbar(
          context,
          'Tree added.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t add tree: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  Future<void> _editTree(CacaoTree tree) async {
    final result = await showTreeSheet(context, tree: tree);
    if (result == null) return;
    try {
      await ref.read(farmRepositoryProvider).updateTree(
        tree.copyWith(
          name: result.name,
          variety: result.variety,
          plantedOn: result.plantedOn,
          status: result.status,
        ),
      );
      if (mounted) {
        showAppSnackbar(
          context,
          'Tree updated.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t update tree: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  Future<void> _changeTreeStatus(CacaoTree tree) async {
    final next = await showTreeStatusPicker(context, current: tree.status);
    if (next == null || next == tree.status) return;
    try {
      await ref
          .read(farmRepositoryProvider)
          .updateTree(tree.copyWith(status: next));
      if (mounted) {
        showAppSnackbar(
          context,
          'Status updated.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t update status: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  Future<void> _deleteTree(CacaoTree tree) async {
    final confirmed = await showConfirmDialog(
      context,
      icon: Icons.eco_outlined,
      title: 'Remove tree?',
      message: '"${tree.name}" will be removed from this farm.',
      confirmLabel: 'Remove',
    );
    if (confirmed != true) return;
    try {
      await ref
          .read(farmRepositoryProvider)
          .deleteTree(tree.farmId, tree.id);
      if (mounted) {
        showAppSnackbar(
          context,
          'Tree removed.',
          kind: SnackbarKind.success,
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        showAppSnackbar(
          context,
          'Couldn\'t remove tree: $e',
          kind: SnackbarKind.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final farmAsync = ref.watch(farmProvider(widget.farmId));
    final fallback = widget.farm;

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: farmAsync.when(
          loading: () => fallback == null
              ? const Center(child: CircularProgressIndicator())
              : _buildContent(context, fallback),
          error: (error, _) => fallback == null
              ? _buildUnavailable(context, ext)
              : _buildContent(context, fallback),
          data: (farm) => farm == null
              ? _buildUnavailable(context, ext)
              : _buildContent(context, farm),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FarmModel farm) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;
    final hasLocation = farm.latitude != null && farm.longitude != null;
    final uid = ref.watch(farmCurrentUserIdProvider);
    final canManage = uid != null && farm.ownerId == uid;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ext, farm, canManage)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x5,
              AppSpacing.x4,
              AppSpacing.x5,
              0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: SizedBox(
                height: 200,
                child: hasLocation
                    ? Stack(
                        children: [
                          FlutterMap(
                            mapController: _mapController,
                            options: MapOptions(
                              initialCenter: LatLng(
                                farm.latitude!,
                                farm.longitude!,
                              ),
                              initialZoom: 15,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.all,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.cakobean.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: LatLng(
                                      farm.latitude!,
                                      farm.longitude!,
                                    ),
                                    width: 40,
                                    height: 40,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: AppColors.ember,
                                      size: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          // Small zoom controls — same reasoning as the
                          // picker: useful on emulators, and plenty of
                          // real users like explicit buttons too.
                          Positioned(
                            right: AppSpacing.x2,
                            bottom: AppSpacing.x2,
                            child: Column(
                              children: [
                                _MapZoomButton(
                                  icon: Icons.add,
                                  onTap: () {
                                    final z = _mapController.camera.zoom;
                                    _mapController.move(
                                      _mapController.camera.center,
                                      z + 1,
                                    );
                                  },
                                ),
                                const SizedBox(height: 6),
                                _MapZoomButton(
                                  icon: Icons.remove,
                                  onTap: () {
                                    final z = _mapController.camera.zoom;
                                    _mapController.move(
                                      _mapController.camera.center,
                                      z - 1,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        color: ext.sand,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.location_off_outlined,
                              color: ext.cocoa50,
                              size: 28,
                            ),
                            const SizedBox(height: AppSpacing.x2),
                            Text(
                              'No location pinned yet',
                              style: TextStyle(
                                fontSize: 12,
                                color: ext.cocoa50,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x5,
              AppSpacing.x4,
              AppSpacing.x5,
              AppSpacing.x5,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: ext.cocoa50,
                    ),
                    const SizedBox(width: AppSpacing.x1),
                    Expanded(
                      child: Text(
                        farm.address,
                        style: textTheme.headlineSmall?.copyWith(
                          color: ext.cocoa,
                          fontSize: 19,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x4),
                Row(
                  children: [
                    StatChip(
                      ext: ext,
                      icon: Icons.straighten_rounded,
                      label: '${farm.sizeHectares.toStringAsFixed(1)} ha',
                    ),
                    const SizedBox(width: AppSpacing.x2),
                    _TreeCountChip(ext: ext, farmId: farm.id),
                  ],
                ),
                if (!canManage) ...[
                  const SizedBox(height: AppSpacing.x3),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.x3,
                      vertical: AppSpacing.x2,
                    ),
                    decoration: BoxDecoration(
                      color: ext.sand,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.visibility_outlined,
                            size: 15, color: ext.cocoa50),
                        const SizedBox(width: AppSpacing.x1),
                        Text(
                          'Read-only view',
                          style: TextStyle(fontSize: 12, color: ext.cocoa50),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.x5),
                Divider(color: ext.hairline, height: 1),
                const SizedBox(height: AppSpacing.x5),
                _buildTreesSection(context, ext, farm, canManage),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x6)),
      ],
    );
  }

  Widget _buildTreesSection(
    BuildContext context,
    AppThemeExtension ext,
    FarmModel farm,
    bool canManage,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final treesAsync = ref.watch(farmTreesProvider(farm.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.forest_outlined, size: 20, color: ext.cocoa50),
            const SizedBox(width: AppSpacing.x2),
            Expanded(
              child: Text(
                'Cacao Trees',
                style: textTheme.headlineSmall?.copyWith(
                  fontSize: 17,
                  color: ext.cocoa,
                ),
              ),
            ),
            if (canManage)
              FilledButton.icon(
                onPressed: () => _addTree(farm),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.ember,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.x3,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                label: const Text(
                  'Add Tree',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.x3),
        treesAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.x6),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          error: (error, _) => Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.x5),
            decoration: BoxDecoration(
              color: ext.sand,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_off_outlined, size: 28, color: ext.cocoa50),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'Couldn\'t load trees.',
                  style: TextStyle(fontSize: 13, color: ext.cocoa50),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(farmTreesProvider(farm.id)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (trees) {
            if (trees.isEmpty) return const _TreesEmpty();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${trees.length} ${trees.length == 1 ? 'tree' : 'trees'} on '
                  'this farm',
                  style: TextStyle(fontSize: 13, color: ext.cocoa50),
                ),
                const SizedBox(height: AppSpacing.x3),
                for (var i = 0; i < trees.length; i++) ...[
                  _TreeCard(
                    ext: ext,
                    tree: trees[i],
                    canManage: canManage,
                    onEdit: () => _editTree(trees[i]),
                    onDelete: () => _deleteTree(trees[i]),
                    onStatusTap: () => _changeTreeStatus(trees[i]),
                  ),
                  if (i < trees.length - 1) const SizedBox(height: AppSpacing.x2),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppThemeExtension ext,
    FarmModel farm,
    bool canManage,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.x5,
        AppSpacing.x3,
        AppSpacing.x5,
        0,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.pop(),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.x2),
              decoration: BoxDecoration(
                color: ext.sand,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_back,
                color: ext.cocoa,
                size: 20,
              ),
            ),
          ),
          const Spacer(),
          if (canManage)
            InkWell(
              onTap: () => _edit(farm),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.x2),
                decoration: BoxDecoration(
                  color: ext.sand,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.edit_rounded, color: ext.cocoa, size: 20),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x3,
                vertical: AppSpacing.x2,
              ),
              decoration: BoxDecoration(
                color: ext.sand,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Row(
                children: [
                  Icon(Icons.visibility_outlined, size: 15, color: ext.cocoa50),
                  const SizedBox(width: AppSpacing.x1),
                  Text(
                    'Read-only',
                    style: TextStyle(fontSize: 12, color: ext.cocoa50),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUnavailable(BuildContext context, AppThemeExtension ext) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x5,
              AppSpacing.x3,
              AppSpacing.x5,
              0,
            ),
            child: Row(
              children: [
                InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.x2),
                    decoration: BoxDecoration(
                      color: ext.sand,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: ext.cocoa,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: EmptyState(
            ext: ext,
            icon: Icons.location_off_outlined,
            message: 'This farm is no longer available.',
          ),
        ),
      ],
    );
  }
}

/// Live tree count chip for a farm. Derives the count from the actual tree
/// records instead of a stored number, so it stays accurate as trees are
/// added/removed.
class _TreeCountChip extends ConsumerWidget {
  final AppThemeExtension ext;
  final String farmId;

  const _TreeCountChip({required this.ext, required this.farmId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trees = ref.watch(farmTreesProvider(farmId));
    final count = trees.maybeWhen(
      data: (t) => t.length,
      orElse: () => null,
    );
    final label = count == null
        ? '— trees'
        : '$count ${count == 1 ? 'tree' : 'trees'}';
    return StatChip(ext: ext, icon: Icons.park_outlined, label: label);
  }
}

class _TreesEmpty extends StatelessWidget {
  const _TreesEmpty();

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x4,
        vertical: AppSpacing.x6,
      ),
      decoration: BoxDecoration(
        color: ext.sand,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: ext.cream,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(Icons.eco_outlined, size: 28, color: ext.cocoa50),
          ),
          const SizedBox(height: AppSpacing.x3),
          Text(
            'No cacao trees yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: ext.cocoa,
            ),
          ),
          const SizedBox(height: AppSpacing.x1),
          Text(
            'Tap "Add Tree" to register your first tree and start tracking '
            'its health.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5, color: ext.cocoa50, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _TreeCard extends StatelessWidget {
  final CacaoTree tree;
  final AppThemeExtension ext;
  final bool canManage;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onStatusTap;

  const _TreeCard({
    required this.tree,
    required this.ext,
    this.canManage = true,
    required this.onEdit,
    required this.onDelete,
    required this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = treeStatusMeta(context, tree.status);
    return PressableScale(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: canManage ? onEdit : null,
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(meta.icon, color: meta.color, size: 22),
                ),
                const SizedBox(width: AppSpacing.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tree.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: ext.cocoa,
                              ),
                            ),
                          ),
                          if (canManage) ...[
                            _TreeCardIconButton(
                              icon: Icons.edit_outlined,
                              color: ext.cocoa50,
                              tooltip: 'Edit tree',
                              onTap: onEdit,
                            ),
                            const SizedBox(width: AppSpacing.x1),
                            _TreeCardIconButton(
                              icon: Icons.delete_outline_rounded,
                              color: Colors.redAccent,
                              tooltip: 'Remove tree',
                              onTap: onDelete,
                            ),
                          ],
                        ],
                      ),
                      if (tree.variety != null && tree.variety!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x1),
                        Text(
                          tree.variety!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, color: ext.cocoa50),
                        ),
                      ],
                      if (tree.plantedOn != null) ...[
                        const SizedBox(height: AppSpacing.x1),
                        Row(
                          children: [
                            Icon(
                              Icons.event_outlined,
                              size: 13,
                              color: ext.cocoa50,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Planted ${formatTreeDate(tree.plantedOn!)}',
                              style: TextStyle(fontSize: 12, color: ext.cocoa50),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: AppSpacing.x2),
                      TreeStatusPill(
                        ext: ext,
                        status: tree.status,
                        onTap: canManage ? onStatusTap : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small square icon button (edit/delete) with a subtle sand background,
/// matching the header icon buttons on this page.
class _TreeCardIconButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  const _TreeCardIconButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: ext.sand,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }
}

class _MapZoomButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapZoomButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: Colors.black87),
        ),
      ),
    );
  }
}
