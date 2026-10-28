import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../config/theme.dart';
import '../../../../config/routes.dart';
import '../../../../shared/widgets/group_card.dart';
import '../bloc/group_bloc.dart';

class GroupsListScreen extends StatefulWidget {
  const GroupsListScreen({super.key});

  @override
  State<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends State<GroupsListScreen> {
  String _selectedCategory = 'Semua';
  final List<String> _categories = ['Semua', 'Makanan', 'Liburan', 'Rumah Tangga', 'Kantor'];

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final isDark = context.isDark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Grup Saya',
          style: AppText.headlineSm.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.group_add_rounded),
            onPressed: () => Navigator.pushNamed(context, AppRoutes.createGroup),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Category horizontal chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryContainer
                            : (isDark ? AppColors.darkSurfaceContainerLow : AppColors.surfaceContainerLow),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        cat,
                        style: AppText.labelSm.copyWith(
                          color: isSelected ? Colors.white : palette.onSurfaceVariant,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),

            // Groups List
            Expanded(
              child: BlocBuilder<GroupBloc, GroupState>(
                builder: (context, state) {
                  if (state is GroupLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is GroupLoaded) {
                    final filtered = _selectedCategory == 'Semua'
                        ? state.groups
                        : state.groups.where((g) => g.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.groups_outlined, size: 64, color: palette.outline),
                            const SizedBox(height: 12),
                            Text(
                              'Belum ada grup dalam kategori ini',
                              style: AppText.bodyMedium.copyWith(color: palette.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final g = filtered[index];
                        return GroupCard(
                          group: g,
                          onTap: () {
                            context.read<GroupBloc>().add(SelectGroupEvent(g.id));
                            Navigator.pushNamed(
                              context,
                              AppRoutes.groupDetail,
                              arguments: g,
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createGroup),
        backgroundColor: AppColors.primaryContainer,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Grup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
