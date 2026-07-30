import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

import 'package:cakobean/app/theme/app_theme.dart';

class PickedLocation {
  final LatLng latLng;
  final String? address;
  const PickedLocation({required this.latLng, this.address});
}

class LocationPickerMap extends StatefulWidget {
  final LatLng? initial;

  const LocationPickerMap({super.key, this.initial});

  @override
  State<LocationPickerMap> createState() => _LocationPickerMapState();
}

class _LocationPickerMapState extends State<LocationPickerMap> {
  static const _marinduqueFallback = LatLng(13.3800, 121.8500);

  final _mapController = MapController();
  final _geocoding = Geocoding();
  late LatLng _center;
  String? _resolvedAddress;
  bool _resolving = false;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _center = widget.initial ?? _marinduqueFallback;
    _resolveAddress(_center);
    if (widget.initial == null) _useCurrentLocation();
  }

  Future<void> _resolveAddress(LatLng point) async {
    setState(() => _resolving = true);
    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        point.latitude,
        point.longitude,
      );
      if (!mounted) return;
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[
          if (p.street != null && p.street!.trim().isNotEmpty) p.street!,
          if (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
            p.subLocality!,
          if (p.locality != null && p.locality!.trim().isNotEmpty) p.locality!,
          if (p.administrativeArea != null &&
              p.administrativeArea!.trim().isNotEmpty)
            p.administrativeArea!,
        ];
        setState(() => _resolvedAddress = parts.join(', '));
      }
    } catch (_) {
      if (mounted) setState(() => _resolvedAddress = null);
    } finally {
      if (mounted) setState(() => _resolving = false);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _locating = true);
    try {
      final permission = await Geolocator.checkPermission();
      var granted = permission;
      if (granted == LocationPermission.denied) {
        granted = await Geolocator.requestPermission();
      }
      if (granted == LocationPermission.denied ||
          granted == LocationPermission.deniedForever) {
        return; // user declined — keep the fallback/initial center
      }
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final point = LatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() => _center = point);
      _mapController.move(point, 16);
      _resolveAddress(point);
    } catch (_) {
      // Silently fall back to the default/initial center.
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventMoveEnd) {
      final point = _mapController.camera.center;
      setState(() => _center = point);
      _resolveAddress(point);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;

    return Scaffold(
      backgroundColor: ext.cream,
      appBar: AppBar(
        backgroundColor: ext.cream,
        elevation: 0,
        foregroundColor: ext.cocoa,
        title: const Text('Pin Farm Location'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _center,
              initialZoom: 15,
              onMapEvent: _onMapEvent,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.cakobean.app',
              ),
            ],
          ),
          // Fixed center pin — the map moves underneath it, matches the
          // "drop a pin" pattern from Google/Uber-style pickers.
          IgnorePointer(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 36),
                child: Icon(
                  Icons.location_on,
                  size: 44,
                  color: AppColors.ember,
                ),
              ),
            ),
          ),
          Positioned(
            right: AppSpacing.x4,
            bottom: 160,
            child: FloatingActionButton.small(
              heroTag: 'use-current-location',
              backgroundColor: Colors.white,
              foregroundColor: ext.cocoa,
              onPressed: _locating ? null : _useCurrentLocation,
              child: _locating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location_rounded, size: 20),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.x4),
                padding: const EdgeInsets.all(AppSpacing.x4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: ext.cardShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pinned location',
                      style: TextStyle(fontSize: 11.5, color: ext.cocoa50),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _resolving
                          ? 'Resolving address…'
                          : (_resolvedAddress ??
                                '${_center.latitude.toStringAsFixed(5)}, '
                                    '${_center.longitude.toStringAsFixed(5)}'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: ext.cocoa,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.x3),
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
                        onPressed: () => Navigator.of(context).pop(
                          PickedLocation(
                            latLng: _center,
                            address: _resolvedAddress,
                          ),
                        ),
                        child: const Text('Confirm location'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
