import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const DinnerIdeasApp());
}

class DinnerIdeasApp extends StatelessWidget {
  // Using the 'super' parameter for the 'key' parameter
  const DinnerIdeasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinner Ideas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  // Using the 'super' parameter for the 'key' parameter
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String recipeTitle = "Press the button for a recipe!";
  List<String> ingredients = [];
  List<String> instructions = [];

  Future<void> loadRandomRecipe() async {
    try {
      // Load the recipes JSON file
      final String jsonString = await rootBundle.loadString('Assets/recipes.json');
      final List<dynamic> recipes = jsonDecode(jsonString);

      if (recipes.isEmpty) {
        throw Exception("No recipes found!");
      }

      // Pick a random recipe
      final random = Random();
      final recipe = recipes[random.nextInt(recipes.length)];

      setState(() {
        recipeTitle = recipe['name'];
        ingredients = List<String>.from(recipe['ingredients']);
        instructions = List<String>.from(recipe['instructions']);
      });
    } catch (error) {
      setState(() {
        recipeTitle = "Error loading recipe!";
        ingredients = [];
        instructions = [];
      });
      // Using `debugPrint` instead of `print` for better control in production
      debugPrint("Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinner Ideas'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Wrap the Column with SingleChildScrollView
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipeTitle,
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.deepOrange),
              ),
              const SizedBox(height: 16.0),
              if (ingredients.isNotEmpty) ...[
                Text(
                  'Ingredients:',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                for (String ingredient in ingredients)
                  Text('• $ingredient', style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 16.0),
              if (instructions.isNotEmpty) ...[
                Text(
                  'Instructions:',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                for (int i = 0; i < instructions.length; i++)
                  Text('${i + 1}. ${instructions[i]}', style: Theme.of(context).textTheme.bodyLarge),
              ],
              const SizedBox(height: 20.0), // Optional spacing for aesthetics
              Center(
                child: ElevatedButton(
                  onPressed: loadRandomRecipe,
                  child: const Text('Show Random Recipe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
