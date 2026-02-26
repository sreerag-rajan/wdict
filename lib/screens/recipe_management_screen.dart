import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_list_tile.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/loading_indicator.dart';
import '../utils/debouncer.dart';
import 'add_edit_recipe_screen.dart';

class RecipeManagementScreen extends StatefulWidget {
  const RecipeManagementScreen({super.key});

  @override
  State<RecipeManagementScreen> createState() => _RecipeManagementScreenState();
}

class _RecipeManagementScreenState extends State<RecipeManagementScreen> {
  String _searchQuery = '';
  final _debouncer = Debouncer(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeProvider>().loadRecipes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipes')),
      body: Consumer<RecipeProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: SketchyLoadingIndicator(
                message: 'Loading your recipes...',
              ),
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

          if (provider.recipes.isEmpty) {
            return const Center(
              child: Text(
                'No recipes yet.\nLet\'s cook something up!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.graphite,
                  fontStyle: FontStyle.italic,
                ),
              ),
            );
          }

          final filteredRecipes = provider.recipes.where((recipe) {
            return recipe.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search recipes...',
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
                child: filteredRecipes.isEmpty
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
                        itemCount: filteredRecipes.length,
                        itemBuilder: (context, index) {
                          final recipe = filteredRecipes[index];
                          return Dismissible(
                            key: ValueKey(recipe.id),
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
                                      'Are you sure you want to delete "${recipe.name}"?',
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
                              if (recipe.id != null) {
                                provider.deleteRecipe(recipe.id!);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${recipe.name} deleted'),
                                  ),
                                );
                              }
                            },
                            child: SketchyListTile(
                              leading:
                                  recipe.imagePath != null &&
                                      recipe.imagePath!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        File(recipe.imagePath!),
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
                                recipe.name,
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
                                        AddEditRecipeScreen(recipe: recipe),
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
                builder: (context) => const AddEditRecipeScreen(),
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
