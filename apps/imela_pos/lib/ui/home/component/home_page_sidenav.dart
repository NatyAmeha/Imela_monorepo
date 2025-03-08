import 'package:flutter/material.dart';
import 'package:imela_core/shared/utils/navigation_destination.dart';
import 'package:imela_pos/app/app_viewmodel.dart';
import 'package:imela_ui_kit/components/list/listview.component.dart';

class HomePageSidenav extends StatelessWidget {
  final List<AppNavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const HomePageSidenav({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  // Group destinations by category
  Map<String, List<AppNavigationDestination>> _groupDestinations() {
    final grouped = <String, List<AppNavigationDestination>>{};
    
    // Add uncategorized items first
    grouped[''] = destinations.where((d) => d.category == null).toList();
    
    // Group the rest by category
    for (var destination in destinations.where((d) => d.category != null)) {
      final category = destination.category!;
      grouped.putIfAbsent(category, () => []);
      grouped[category]!.add(destination);
    }
    
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final widgetFactory = AppViewmodel.getWidgetFactory(context);
    final groupedDestinations = _groupDestinations();
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          // Drawer Header
          widgetFactory.createCard(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              width: double.infinity,
              child: Column(
                children: [
                  const Icon(Icons.point_of_sale, size: 40),
                  const SizedBox(height: 12),
                  widgetFactory.createText(
                    context, 
                    'Imela POS',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Navigation Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupedDestinations.length,
              itemBuilder: (context, index) {
                final category = groupedDestinations.keys.elementAt(index);
                final categoryItems = groupedDestinations[category]!;
                
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show category header if it exists
                    if (category.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: widgetFactory.createText(
                          context,
                          category.toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    
                    // Category items
                    ...categoryItems.asMap().entries.map((entry) {
                      final destination = entry.value;
                      final itemIndex = destinations.indexOf(destination);
                      final isSelected = itemIndex == selectedIndex;
                      
                      return ListTile(
                        leading: Icon(
                          destination.icon,
                          color: isSelected ? theme.colorScheme.primary : null,
                        ),
                        title: widgetFactory.createText(
                          context,
                          destination.name,
                          style: isSelected 
                            ? TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )
                            : null,
                        ),
                        selected: isSelected,
                        selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        onTap: () {
                          onDestinationSelected(itemIndex);
                          Navigator.pop(context); // Close the drawer
                        },
                      );
                    }).toList(),
                    
                    // Add divider after each category except the last one
                    if (index < groupedDestinations.length - 1)
                      const Divider(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
