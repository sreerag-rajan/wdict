import 'package:flutter/material.dart';
import 'package:wdict/screens/ingredient_management_screen.dart';
import 'package:wdict/screens/recipe_management_screen.dart';
import 'package:wdict/screens/wdict_engine_screen.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WDICT Dashboard'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 5,
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildRouteCard(
                  context,
                  title: 'WDICT\n(Recommendation Engine)',
                  imagePath: 'assets/images/wdict_asset.jpeg',
                  isLarge: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WdictEngineScreen(),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              flex: 4,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildRouteCard(
                        context,
                        title: 'Ingredients\n(Digital Pantry)',
                        imagePath: 'assets/images/ingredient_asset.jpeg',
                        isLarge: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const IngredientManagementScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Flexible(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: _buildRouteCard(
                        context,
                        title: 'Recipes\n(Personal Cookbook)',
                        imagePath: 'assets/images/recipe_asset.jpeg',
                        isLarge: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const RecipeManagementScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required String title,
    required String imagePath,
    required VoidCallback onTap,
    required bool isLarge,
  }) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Center(child: Icon(Icons.broken_image, size: 50)),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isLarge ? 16.0 : 12.0),
              child: Text(
                title,
                style: isLarge
                    ? Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      )
                    : Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
