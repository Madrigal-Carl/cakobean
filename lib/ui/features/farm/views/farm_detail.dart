import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/core/widgets/empty_state.dart';
import 'package:cakobean/ui/core/widgets/stat_chip.dart';
import 'package:cakobean/ui/features/farm/view_models/farm_viewmodel.dart';
import 'package:cakobean/ui/features/farm/widgets/farm_sheet.dart';

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
          cacaoTrees: result.cacaoTrees,
          latitude: result.location?.latitude,
          longitude: result.location?.longitude,
        ),
      );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Couldn\'t update farm: $e')));
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

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader(context, ext, farm)),
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
                                fontSize: 12.5,
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
                    StatChip(
                      ext: ext,
                      icon: Icons.park_outlined,
                      label: '${farm.cacaoTrees} trees',
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.x5),
                Divider(color: ext.hairline, height: 1),
                const SizedBox(height: AppSpacing.x5),
                Text(
                  'More coming soon',
                  style: textTheme.headlineSmall?.copyWith(
                    fontSize: 17,
                    color: ext.cocoa,
                  ),
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'This is where farm activity, yield tracking, or tasks will go.',
                  style: TextStyle(fontSize: 13, color: ext.cocoa50),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: SizedBox(height: AppSpacing.x6)),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, AppThemeExtension ext, FarmModel farm) {
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
