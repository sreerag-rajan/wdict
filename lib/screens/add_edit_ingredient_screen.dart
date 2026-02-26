import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/ingredient.dart';
import '../providers/ingredient_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_decorations.dart';
import '../widgets/custom_button.dart';
import '../widgets/image_placeholder.dart';
import '../widgets/loading_indicator.dart';

class AddEditIngredientScreen extends StatefulWidget {
  final Ingredient? ingredient;

  const AddEditIngredientScreen({super.key, this.ingredient});

  @override
  State<AddEditIngredientScreen> createState() =>
      _AddEditIngredientScreenState();
}

class _AddEditIngredientScreenState extends State<AddEditIngredientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  String? _imagePath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.ingredient != null) {
      _nameController.text = widget.ingredient!.name;
      _imagePath = widget.ingredient!.imagePath;
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

  Future<void> _saveIngredient() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final provider = context.read<IngredientProvider>();
      final newIngredient = Ingredient(
        id: widget.ingredient?.id,
        name: _nameController.text.trim(),
        imagePath: _imagePath,
      );

      if (widget.ingredient == null) {
        await provider.addIngredient(newIngredient);
      } else {
        await provider.updateIngredient(newIngredient);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving ingredient: $e')));
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ingredient != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Ingredient' : 'Add Ingredient'),
      ),
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
                        labelText: 'Ingredient Name',
                        hintText: 'e.g., Rice, Tomato, Chicken',
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
                          return 'Please enter a name for the ingredient.';
                        }
                        return null;
                      },
                      textCapitalization: TextCapitalization.words,
                    ),
                    const SizedBox(height: 48),
                    // Save Button
                    SketchyButton(
                      onPressed: _saveIngredient,
                      backgroundColor: AppColors.charcoal,
                      child: Text(
                        'Save Ingredient',
                        style: const TextStyle(
                          color: AppColors.paperWhite,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
