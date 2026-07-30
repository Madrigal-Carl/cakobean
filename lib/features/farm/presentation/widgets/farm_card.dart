import 'package:flutter/material.dart';

import 'package:cakobean/app/theme/app_theme.dart';
import 'package:cakobean/features/farm/data/models/farm.dart';
import 'package:cakobean/shared/widgets/stat_chip.dart';

class FarmCard extends StatelessWidget {
  final FarmModel farm;
  final AppThemeExtension ext;

  const FarmCard({super.key, required this.farm, required this.ext});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: () {
          // TODO: navigate to farm detail, e.g. context.push('/farm/${farm.id}')
        },
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.x4,
            AppSpacing.x4,
            AppSpacing.x4,
            AppSpacing.x3,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
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
            ],
          ),
        ),
      ),
    );
  }
}
