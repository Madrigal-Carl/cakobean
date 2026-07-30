import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/shared/widgets/stat_chip.dart';
import '../../data/models/farm.dart';

class FarmDetail extends StatefulWidget {
  final String farmId;
  final FarmModel? farm; // passed via go_router `extra` when available

  const FarmDetail({super.key, required this.farmId, this.farm});

  @override
  State<FarmDetail> createState() => _FarmDetailState();
}

class _FarmDetailState extends State<FarmDetail> {
  late final FarmModel _farm;
  final _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _farm =
        widget.farm ??
        mockFarms.firstWhere(
          (f) => f.id == widget.farmId,
          orElse: () => mockFarms.first,
        );
  }

  bool get _hasLocation => _farm.latitude != null && _farm.longitude != null;

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: ext.cream,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
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
                    child: _hasLocation
                        ? Stack(
                            children: [
                              FlutterMap(
                                mapController: _mapController,
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    _farm.latitude!,
                                    _farm.longitude!,
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
                                          _farm.latitude!,
                                          _farm.longitude!,
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
                            _farm.address,
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
                          label: '${_farm.sizeHectares.toStringAsFixed(1)} ha',
                        ),
                        const SizedBox(width: AppSpacing.x2),
                        StatChip(
                          ext: ext,
                          icon: Icons.park_outlined,
                          label: '${_farm.cacaoTrees} trees',
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
