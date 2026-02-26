import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ingredient_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_list_tile.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/loading_indicator.dart';
import '../utils/debouncer.dart';
import 'add_edit_ingredient_screen.dart';

class IngredientManagementScreen extends StatefulWidget {
  const IngredientManagementScreen({super.key});

  @override
  State<IngredientManagementScreen> createState() =>
      _IngredientManagementScreenState();
}

class _IngredientManagementScreenState
    extends State<IngredientManagementScreen> {
  String _searchQuery = '';
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientProvider>().loadIngredients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingredients')),
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
                'Your pantry is empty.\nLet\'s add some ingredients!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.graphite,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final filteredIngredients = provider.ingredients.where((ingredient) {
            return ingredient.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search ingredients...',
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
                child: filteredIngredients.isEmpty
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
                        padding: const EdgeInsets.only(bottom: 100),
                        itemCount: filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = filteredIngredients[index];
                          return Dismissible(
                            key: ValueKey(ingredient.id),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sketchRed,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 20),
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.paperWhite,
                                size: 28,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Confirm Deletion'),
                                    content: Text(
                                      'Are you sure you want to delete "${ingredient.name}"?\n\nThis will remove it from any recipes that use it.',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text('CANCEL'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        style: TextButton.styleFrom(
                                          foregroundColor: AppColors.sketchRed,
                                        ),
                                        child: const Text('DELETE'),
                                      ),
                                    ],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: const BorderSide(
                                        color: AppColors.charcoal,
                                        width: 2,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            onDismissed: (_) {
                              if (ingredient.id != null) {
                                provider.deleteIngredient(ingredient.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${ingredient.name} deleted'),
                                  ),
                                );
                              }
                            },
                            child: SketchyListTile(
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
                                            (
                                              context,
                                              error,
                                              stackTrace,
                                            ) => const SketchyImagePlaceholder(
                                              width: 50,
                                              height: 50,
                                              icon: Icons.broken_image_outlined,
                                            ),
                                      ),
                                    )
                                  : const SketchyImagePlaceholder(
                                      width: 50,
                                      height: 50,
                                    ),
                              title: Text(
                                ingredient.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.charcoal,
                                ),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddEditIngredientScreen(
                                          ingredient: ingredient,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddEditIngredientScreen(),
              ),
            );
          },
          backgroundColor: AppColors.paperWhite,
          foregroundColor: AppColors.charcoal,
          elevation: 0,
          shape: const CircleBorder(
            side: BorderSide(color: AppColors.charcoal, width: 2),
          ),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
