import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe.dart';
import '../repositories/recipe_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_list_tile.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/loading_indicator.dart';

class WdictResultScreen extends StatelessWidget {
  final List<int> selectedIngredientIds;

  const WdictResultScreen({super.key, required this.selectedIngredientIds});

  @override
  Widget build(BuildContext context) {
    final recipeRepository = context.read<RecipeRepository>();

    return Scaffold(
      appBar: AppBar(title: const Text('Matched Recipes')),
      body: FutureBuilder<List<Recipe>>(
        future: recipeRepository.getRecommendations(selectedIngredientIds),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: SketchyLoadingIndicator(
                message: 'Finding perfect matches...',
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Oops! Something went wrong:\n${snapshot.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.sketchRed),
              ),
            );
          }

          final recipes = snapshot.data ?? [];

          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SketchyImagePlaceholder(
                    width: 120,
                    height: 120,
                    icon: Icons.search_off_rounded,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No perfect matches found.',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Try selecting different ingredients\nor adding more recipes!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.graphite,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 200,
                    child: SketchyButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Go Back'),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0).copyWith(
              bottom: 100, // Space for bottom button
            ),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: SketchyListTile(
                  leading:
                      recipe.imagePath != null && recipe.imagePath!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(recipe.imagePath!),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const SketchyImagePlaceholder(
                                  width: 60,
                                  height: 60,
                                  icon: Icons.broken_image_outlined,
                                ),
                          ),
                        )
                      : const SketchyImagePlaceholder(width: 60, height: 60),
                  title: Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoal,
                    ),
                  ),
                  subtitle: Text(
                    '${recipe.ingredients?.length ?? 0} ingredients',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.graphite,
                    ),
                  ),
                  onTap: () {
                    // Could navigate to a recipe detail screen here later
                  },
                ),
              );
            },
          );
        },
      ),
      bottomSheet: Container(
        color: AppColors.paperWhite,
        padding: const EdgeInsets.all(16.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: SketchyButton(
                  onPressed: () {
                    // Pop back to home dashboard (pop until first route)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  backgroundColor: AppColors.paperWhite,
                  child: const Text(
                    'Back to Dashboard',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
