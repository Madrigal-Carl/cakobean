import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/domain/models/farm.dart';
import 'package:cakobean/ui/core/widgets/add_button.dart';
import 'package:cakobean/ui/core/widgets/empty_state.dart';
import 'package:cakobean/ui/core/widgets/page_header.dart';
import 'package:cakobean/ui/core/widgets/stagger_in.dart';
import 'package:cakobean/ui/features/farm/view_models/farm_viewmodel.dart';
import 'package:cakobean/ui/features/farm/widgets/farm_card.dart';
import 'package:cakobean/ui/features/farm/widgets/farm_sheet.dart';

class FarmPage extends ConsumerStatefulWidget {
  const FarmPage({super.key});

  @override
  ConsumerState<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends ConsumerState<FarmPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmModel> _filteredFarms(List<FarmModel> farms) {
    if (_query.trim().isEmpty) return farms;
    final q = _query.toLowerCase();
    return farms
        .where((f) => f.address.toLowerCase().contains(q))
        .toList();
  }

  Future<void> _addFarm() async {
    final result = await showFarmSheet(context);
    if (result == null) return;
    try {
      await ref.read(farmRepositoryProvider).addFarm(
            address: result.address,
            sizeHectares: result.sizeHectares,
            latitude: result.location?.latitude,
            longitude: result.location?.longitude,
          );
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Couldn\'t add farm: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final farmsAsync = ref.watch(farmsProvider);

    return Scaffold(
      backgroundColor: ext.cream,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AddButton(ext: ext, onTap: _addFarm),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Cap the content width on tablets/desktop so the header and
            // cards don't stretch edge-to-edge on large screens.
            final width = constraints.maxWidth;
            final maxContentWidth = switch (width) {
              >= 900 => 760.0,
              >= 600 => 560.0,
              _ => double.infinity,
            };

            return Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: PageHeader(
                      ext: ext,
                      title: 'My Farms',
                      subtitle: 'Manage your registered farms',
                      showSearch: true,
                      searchController: _searchController,
                      searchHint: 'Search farms by address',
                      onSearchChanged: (value) =>
                          setState(() => _query = value),
                    ),
                  ),
                ),
                Expanded(child: _buildBody(ext, farmsAsync, maxContentWidth)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    AppThemeExtension ext,
    AsyncValue<List<FarmModel>> farmsAsync,
    double maxContentWidth,
  ) {
    return farmsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        ext: ext,
        icon: Icons.cloud_off_rounded,
        message: 'Couldn\'t load your farms. Please try again.',
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(farmsProvider),
      ),
      data: (allFarms) {
        final farms = _filteredFarms(allFarms);
        if (allFarms.isEmpty) {
          return EmptyState(
            ext: ext,
            icon: Icons.agriculture_rounded,
            message: 'No farms yet.\nAdd your first farm to get started.',
          );
        }
        if (farms.isEmpty) {
          return EmptyState(
            ext: ext,
            icon: Icons.search_off_rounded,
            message: 'No farms match your search',
          );
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x5,
                AppSpacing.x4,
                AppSpacing.x5,
                AppSpacing.x8,
              ),
              // Auto-fits 1 column on phones, 2+ on wider
              // screens — no manual breakpoints needed.
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 460,
                mainAxisExtent: 115,
                crossAxisSpacing: AppSpacing.x3,
                mainAxisSpacing: AppSpacing.x3,
              ),
              itemCount: farms.length,
              itemBuilder: (context, i) {
                return StaggerIn(
                  index: i,
                  child: FarmCard(farm: farms[i], ext: ext),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
