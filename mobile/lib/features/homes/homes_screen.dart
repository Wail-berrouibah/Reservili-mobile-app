import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/home_card.dart';
import '../../shared/widgets/empty_state.dart';
import '../../providers/homes_provider.dart';

class HomesScreen extends StatefulWidget {
  const HomesScreen({super.key});

  @override
  State<HomesScreen> createState() => _HomesScreenState();
}

class _HomesScreenState extends State<HomesScreen> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search by name or address...',
                    border: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: AppTextStyles.body,
                  onChanged: (_) => setState(() {}),
                )
              : const Text('Homes'),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
              icon: Icon(_isSearching ? Icons.close : Icons.search_outlined),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.push<bool>('/homes/add');
            if (result == true && mounted) setState(() {});
          },
          child: const Icon(Icons.add),
        ),
        body: Consumer<HomesProvider>(
          builder: (context, provider, _) {
            final query = _searchController.text.trim();
            final homes = _isSearching && query.isNotEmpty
                ? provider.searchHomes(query)
                : provider.homes;

            if (provider.homes.isEmpty) {
              return EmptyState(
                icon: Icons.home_outlined,
                title: 'No homes yet',
                subtitle: 'Add your first home to get started',
                actionLabel: 'Add Home',
                onAction: () async {
                  final result = await context.push<bool>('/homes/add');
                  if (result == true && mounted) setState(() {});
                },
              );
            }

            if (homes.isEmpty) {
              return EmptyState(
                icon: Icons.search_off_outlined,
                title: 'No results',
                subtitle: 'Try a different search term',
              );
            }

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView.builder(
                padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 80),
                itemCount: homes.length,
                itemBuilder: (context, index) {
                  final home = homes[index];
                  return HomeCard(
                    home: home,
                    onTap: () => context.push('/homes/${home.id}'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
