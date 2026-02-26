import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/ingredient_provider.dart';
import '../providers/recipe_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/loading_indicator.dart';

class AddEditRecipeScreen extends StatefulWidget {
  final Recipe? recipe;

  const AddEditRecipeScreen({super.key, this.recipe});

  @override
  State<AddEditRecipeScreen> createState() => _AddEditRecipeScreenState();
}

class _AddEditRecipeScreenState extends State<AddEditRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  bool _isSaving = false;
  Set<int> _selectedIngredientIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IngredientProvider>().loadIngredients();
    });

    if (widget.recipe != null) {
      _nameController.text = widget.recipe!.name;
      _imagePath = widget.recipe!.imagePath;
      if (widget.recipe!.ingredients != null) {
        _selectedIngredientIds = widget.recipe!.ingredients!
            .map((i) => i.id!)
            .toSet();
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedIngredientIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one ingredient.'),
          backgroundColor: AppColors.sketchRed,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final ingredientProvider = context.read<IngredientProvider>();
      final recipeProvider = context.read<RecipeProvider>();

      final selectedIngredients = ingredientProvider.ingredients
          .where((i) => _selectedIngredientIds.contains(i.id))
          .toList();

      final newRecipe = Recipe(
        id: widget.recipe?.id,
        name: _nameController.text.trim(),
        imagePath: _imagePath,
        ingredients: selectedIngredients,
      );

      if (widget.recipe == null) {
        await recipeProvider.addRecipe(newRecipe);
      } else {
        await recipeProvider.updateRecipe(newRecipe);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving recipe: $e'),
            backgroundColor: AppColors.sketchRed,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.recipe != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Recipe' : 'Add Recipe')),
      body: _isSaving
          ? const Center(child: SketchyLoadingIndicator(message: 'Saving...'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Picker Section
                    GestureDetector(
                      onTap: _showImagePickerModal,
                      child: Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: ShapeDecoration(
                            shape: const SketchyBorder(radius: 16.0),
                            color: AppColors.paperWhite,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: _imagePath != null && _imagePath!.isNotEmpty
                                ? Image.file(
                                    File(_imagePath!),
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const SketchyImagePlaceholder(
                                              width: 150,
                                              height: 150,
                                              icon: Icons.broken_image_outlined,
                                            ),
                                  )
                                : const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add_a_photo_outlined,
                                        size: 40,
                                        color: AppColors.charcoal,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Add Photo',
                                        style: TextStyle(
                                          color: AppColors.charcoal,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Name Input
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Recipe Name',
                        hintText: 'e.g., Spaghetti Bolognese, Chicken Curry',
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.charcoal,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.charcoal,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.charcoal,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: AppColors.sketchRed,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a name for the recipe.';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 32),
                    // Ingredients Selection
                    const Text(
                      'Required Ingredients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.charcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: ShapeDecoration(
                        shape: const SketchyBorder(radius: 12.0),
                        color: Colors.transparent,
                      ),
                      child: Consumer<IngredientProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: SketchyLoadingIndicator(
                                  message: 'Loading ingredients...',
                                ),
                              ),
                            );
                          }

                          if (provider.ingredients.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Center(
                                child: Text(
                                  'No ingredients available.\nPlease add some ingredients first.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.graphite,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }

                          return ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: provider.ingredients.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.charcoal,
                              height: 1,
                              thickness: 1,
                            ),
                            itemBuilder: (context, index) {
                              final ingredient = provider.ingredients[index];
                              final isSelected = _selectedIngredientIds
                                  .contains(ingredient.id);

                              return CheckboxListTile(
                                title: Text(
                                  ingredient.name,
                                  style: const TextStyle(
                                    color: AppColors.charcoal,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                secondary:
                                    ingredient.imagePath != null &&
                                        ingredient.imagePath!.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: Image.file(
                                          File(ingredient.imagePath!),
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  const SketchyImagePlaceholder(
                                                    width: 40,
                                                    height: 40,
                                                    icon: Icons
                                                        .broken_image_outlined,
                                                  ),
                                        ),
                                      )
                                    : const SketchyImagePlaceholder(
                                        width: 40,
                                        height: 40,
                                      ),
                                value: isSelected,
                                activeColor: AppColors.charcoal,
                                checkColor: AppColors.paperWhite,
                                side: const BorderSide(
                                  color: AppColors.charcoal,
                                  width: 2,
                                ),
                                onChanged: (bool? value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedIngredientIds.add(
                                        ingredient.id!,
                                      );
                                    } else {
                                      _selectedIngredientIds.remove(
                                        ingredient.id,
                                      );
                                    }
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Save Button
                    SketchyButton(
                      onPressed: _saveRecipe,
                      backgroundColor: AppColors.charcoal,
                      child: const Text(
                        'Save Recipe',
                        style: TextStyle(
                          color: AppColors.paperWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}
