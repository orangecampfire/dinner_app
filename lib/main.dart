import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const DinnerIdeasApp());
}

class DinnerIdeasApp extends StatelessWidget {
  const DinnerIdeasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dinner Ideas',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String recipeTitle = "Press the button for a recipe!";
  List<String> ingredients = [];
  List<String> instructions = [];
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> allRecipes = [];
  bool isSearching = false; // To toggle search bar visibility

  Future<void> loadRecipes() async {
    try {
      final String jsonString = await rootBundle.loadString('Assets/recipes.json');
      final List<dynamic> recipes = jsonDecode(jsonString);
      setState(() {
        allRecipes = recipes;
      });
    } catch (error) {
      setState(() {
        recipeTitle = "Error loading recipes!";
        ingredients = [];
        instructions = [];
      });
      debugPrint("Error: $error");
    }
  }

  Future<void> loadRandomRecipe() async {
    try {
      final random = Random();
      final recipe = allRecipes[random.nextInt(allRecipes.length)];

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
      debugPrint("Error: $error");
    }
  }

  Future<void> searchRecipe(String query) async {
    try {
      final searchResults = allRecipes.where((recipe) {
        final name = recipe['name'].toLowerCase();
        return name.contains(query.toLowerCase()); // Case-insensitive search
      }).toList();

      if (searchResults.isEmpty) {
        setState(() {
          recipeTitle = "No recipes found!";
          ingredients = [];
          instructions = [];
        });
      } else {
        setState(() {
          recipeTitle = searchResults[0]['name']; // Display the first result
          ingredients = List<String>.from(searchResults[0]['ingredients']);
          instructions = List<String>.from(searchResults[0]['instructions']);
        });
      }
    } catch (error) {
      setState(() {
        recipeTitle = "Error loading recipe!";
        ingredients = [];
        instructions = [];
      });
      debugPrint("Error: $error");
    }
  }

  @override
  void initState() {
    super.initState();
    loadRecipes(); // Load all recipes when the app starts
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dinner Ideas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching; // Toggle search bar visibility
              });
            },
          ),
        ],
        bottom: isSearching
            ? PreferredSize(
          preferredSize: Size.fromHeight(56.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a recipe...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searchRecipe(_searchController.text);
                  },
                ),
              ),
              onSubmitted: (query) {
                searchRecipe(query);
              },
            ),
          ),
        )
            : null, // Hide search bar when not searching
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(  // Make the body scrollable
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
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: loadRandomRecipe,
              child: const Text('Show Random Recipe'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllRecipesScreen(recipes: allRecipes),
                  ),
                );
              },
              child: const Text('Show All Recipes'),
            ),
          ],
        ),
      ),
    );
  }
}

class AllRecipesScreen extends StatelessWidget {
  final List<dynamic> recipes;

  const AllRecipesScreen({super.key, required this.recipes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("All Recipes"),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return ListTile(
            title: Text(recipe['name']),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeDetailScreen(recipe: recipe),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecipeDetailScreen extends StatelessWidget {
  final dynamic recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe['name'],
                style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.deepOrange),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Ingredients:',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              for (String ingredient in recipe['ingredients'])
                Text('• $ingredient', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 16.0),
              Text(
                'Instructions:',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              for (int i = 0; i < recipe['instructions'].length; i++)
                Text('${i + 1}. ${recipe['instructions'][i]}', style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}
