import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/features/farm/data/models/farm.dart';
import 'package:cakobean/features/farm/presentation/widgets/farm_card.dart';
import 'package:cakobean/features/farm/presentation/widgets/farm_sheet.dart';
import 'package:cakobean/shared/widgets/add_button.dart';
import 'package:cakobean/shared/widgets/empty_state.dart';
import 'package:cakobean/shared/widgets/page_header.dart';
import 'package:cakobean/shared/widgets/stagger_in.dart';

class FarmPage extends StatefulWidget {
  const FarmPage({super.key});

  @override
  State<FarmPage> createState() => _FarmPageState();
}

class _FarmPageState extends State<FarmPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FarmModel> get _filteredFarms {
    if (_query.trim().isEmpty) return mockFarms;
    final q = _query.toLowerCase();
    return mockFarms.where((f) => f.address.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final ext = Theme.of(context).extension<AppThemeExtension>()!;
    final farms = _filteredFarms;

    return Scaffold(
      backgroundColor: ext.cream,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AddButton(
        ext: ext,
        onTap: () async {
          final result = await showFarmSheet(context);
          if (result == null) return;
        },
      ),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Cap the content width on tablets/desktop so the header and
            // cards don't stretch edge-to-edge on large screens.
            final width = constraints.maxWidth;
            final maxContentWidth = width >= 900
                ? 760.0
                : width >= 600
                ? 560.0
                : double.infinity;

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
                Expanded(
                  child: farms.isEmpty
                      ? EmptyState(
                          ext: ext,
                          icon: Icons.search_off_rounded,
                          message: 'No farms match your search',
                        )
                      : Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: maxContentWidth,
                            ),
                            child: GridView.builder(
                              padding: const EdgeInsets.fromLTRB(
                                AppSpacing.x5,
                                AppSpacing.x4,
                                AppSpacing.x5,
                                AppSpacing.x8,
                              ),
                              // Auto-fits 1 column on phones, 2+ on wider
                              // screens — no manual breakpoints needed.
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
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
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
