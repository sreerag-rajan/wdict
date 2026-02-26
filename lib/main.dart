import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wdict/theme/app_theme.dart';
import 'package:wdict/repositories/ingredient_repository.dart';
import 'package:wdict/repositories/recipe_repository.dart';
import 'package:wdict/providers/ingredient_provider.dart';
import 'package:wdict/providers/recipe_provider.dart';
import 'package:wdict/screens/home_dashboard_screen.dart';
import 'package:wdict/screens/wdict_result_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        Provider<IngredientRepository>(create: (_) => IngredientRepository()),
        Provider<RecipeRepository>(create: (_) => RecipeRepository()),
        ChangeNotifierProxyProvider<IngredientRepository, IngredientProvider>(
          create: (context) =>
              IngredientProvider(context.read<IngredientRepository>()),
          update: (context, repository, previous) =>
              previous ?? IngredientProvider(repository),
        ),
        ChangeNotifierProxyProvider<RecipeRepository, RecipeProvider>(
          create: (context) => RecipeProvider(context.read<RecipeRepository>()),
          update: (context, repository, previous) =>
              previous ?? RecipeProvider(repository),
        ),
      ],
      child: const WdictApp(),
    ),
  );
}

class WdictApp extends StatelessWidget {
  const WdictApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WDICT',
      theme: AppTheme.getTheme(context),
      home: const HomeDashboardScreen(),
      onGenerateRoute: (settings) {
        if (settings.name == '/wdict-results') {
          final selectedIngredientIds = settings.arguments as List<int>;
          return MaterialPageRoute(
            builder: (context) =>
                WdictResultScreen(selectedIngredientIds: selectedIngredientIds),
          );
        }
        return null;
      },
    );
  }
}
