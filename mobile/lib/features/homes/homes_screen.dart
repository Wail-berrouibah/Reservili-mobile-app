import 'package:flutter/material.dart';
import 'package:reservili/generated/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/homes_provider.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/home_card.dart';

class HomesScreen extends ConsumerWidget {
  const HomesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final homesAsync = ref.watch(homesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.homes)),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(homesProvider),
        child: homesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (homes) {
            if (homes.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  EmptyState(
                    icon: Icons.home_outlined,
                    title: t.noHomes,
                    message: t.addFirstHome,
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: homes.length,
              separatorBuilder: (_, __) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (_, i) {
                final home = homes[i];
                return HomeCard(
                  home: home,
                  onTap: () => context.push(
                    AppRoutes.homeDetails,
                    extra: home.id,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => context.push(AppRoutes.addHome),
        child: const Icon(Icons.add),
      ),
    );
  }
}
