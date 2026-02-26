import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingredient_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_list_tile.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/loading_indicator.dart';
import '../utils/debouncer.dart';

class WdictEngineScreen extends StatefulWidget {
  const WdictEngineScreen({super.key});

  @override
  State<WdictEngineScreen> createState() => _WdictEngineScreenState();
}

class _WdictEngineScreenState extends State<WdictEngineScreen> {
  final Set<int> _selectedIngredientIds = {};
  String _searchQuery = '';
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientProvider>().loadIngredients();
    });
  }

  void _toggleIngredient(int id) {
    setState(() {
      if (_selectedIngredientIds.contains(id)) {
        _selectedIngredientIds.remove(id);
      } else {
        _selectedIngredientIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('What\'s in your pantry?')),
      body: Consumer<IngredientProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: SketchyLoadingIndicator(message: 'Loading your pantry...'),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Text(
                'Oops! ${provider.error}',
                style: const TextStyle(color: AppColors.sketchRed),
              ),
            );
          }

          if (provider.ingredients.isEmpty) {
            return const Center(
              child: Text(
                'Your pantry is empty.\nGo to Ingredients to add some!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.graphite,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final selectedIngredients = provider.ingredients.where((ingredient) {
            return ingredient.id != null &&
                _selectedIngredientIds.contains(ingredient.id);
          }).toList();

          final unselectedIngredients = provider.ingredients.where((
            ingredient,
          ) {
            return !(ingredient.id != null &&
                _selectedIngredientIds.contains(ingredient.id));
          }).toList();

          final filteredUnselectedIngredients = unselectedIngredients.where((
            ingredient,
          ) {
            return ingredient.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          final displayIngredients = [
            ...selectedIngredients,
            ...filteredUnselectedIngredients,
          ];

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search pantry...',
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.charcoal,
                    ),
                    filled: true,
                    fillColor: AppColors.paperWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.charcoal,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.charcoal,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(
                        color: AppColors.charcoal,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    _debouncer.run(() {
                      setState(() {
                        _searchQuery = value;
                      });
                    });
                  },
                ),
              ),
              Expanded(
                child: displayIngredients.isEmpty
                    ? const Center(
                        child: Text(
                          'No matches found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.graphite,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(
                          bottom: 120,
                        ), // Space for bottom button
                        itemCount: displayIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = displayIngredients[index];
                          final isSelected = _selectedIngredientIds.contains(
                            ingredient.id,
                          );

                          return SketchyListTile(
                            leading:
                                ingredient.imagePath != null &&
                                    ingredient.imagePath!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(ingredient.imagePath!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const SketchyImagePlaceholder(
                                                width: 50,
                                                height: 50,
                                                icon:
                                                    Icons.broken_image_outlined,
                                              ),
                                    ),
                                  )
                                : const SketchyImagePlaceholder(
                                    width: 50,
                                    height: 50,
                                  ),
                            title: Text(
                              ingredient.name,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: AppColors.charcoal,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.charcoal,
                                    size: 28,
                                  )
                                : const Icon(
                                    Icons.circle_outlined,
                                    color: AppColors.graphite,
                                    size: 28,
                                  ),
                            onTap: () {
                              if (ingredient.id != null) {
                                _toggleIngredient(ingredient.id!);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SizedBox(
            width: double.infinity,
            child: SketchyButton(
              onPressed: _selectedIngredientIds.isEmpty
                  ? () {}
                  : () {
                      Navigator.pushNamed(
                        context,
                        '/wdict-results',
                        arguments: _selectedIngredientIds.toList(),
                      );
                    },
              backgroundColor: _selectedIngredientIds.isEmpty
                  ? AppColors.graphite.withValues(alpha: 0.3)
                  : AppColors.paperWhite,
              child: const Text(
                'What can I cook?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
