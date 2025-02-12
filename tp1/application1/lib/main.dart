import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'joueurs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Application1',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
          seedColor : const Color.fromARGB(255, 45, 45, 1),
          brightness: Brightness.dark,
          )
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  static List<Joueurs> Liste_joueurs = [];

   Future<void> chargerJoueurs() async {
    try {
      // Lire le fichier JSON
      String jsonString = await rootBundle.loadString('assets/data.json');

      // Décoder le JSON en une liste dynamique
      List<dynamic> jsonData = json.decode(jsonString);
      // Convertir en une liste de Joueurs
      Liste_joueurs = jsonData.map((json) => Joueurs.fromJson(json)).toList();

      // Notifier les widgets que les données ont changé
      notifyListeners();
    } catch (e) {
      print("Erreur lors du chargement des joueurs: $e");
    }
  }

  //var current = WordPair.random();

  void getNext(var current) {
    current = WordPair.random();
    notifyListeners();
  }
  var favorites = <String>[];

  void toggleFavorite(String current) {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(String pair) {
    favorites.remove(pair);
    notifyListeners();
  }

  void actualiser(){
    notifyListeners();
    
  }
  void nomjoueur(String pair, int J){
    int n = Liste_joueurs.length;
    for (int j=0;j<n;j++){
      if ("${MyAppState.Liste_joueurs[j].prenom}" " ${MyAppState.Liste_joueurs[j].nom}"==pair){
        int J = j;
      }
    }
  }


}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var selectedIndex = 0;


  @override

  void initState() {
    super.initState();
    
    // Récupérer MyAppState et charger les joueurs
    Future.delayed(Duration.zero, () {
      final state = context.read<MyAppState>();
      state.chargerJoueurs();
    });
  }

  Widget build(BuildContext context) {
    Widget page;
switch (selectedIndex+Categorie.cat) {
  case 1:
    page = FavoritesPage();
    break;
  case 0:
    page = Fiche();
    break;
  case 2:
    page = Categorie();
    break;
  case 3:
    page = Cat1();
    break;
    
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 800,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.favorite),
                      label: Text('Favorites'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.library_add),
                      label: Text('Média'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.library_books),
                      label: Text('Catégorie'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}
/*
class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }
    

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  icon: Icon(icon),
                  label: Text('Like'),
                ),
                SizedBox(width: 10),

              ElevatedButton( 
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
              SizedBox(width: 10),
            ],
          ),
        ],
      ),
    );
  }
}
*/

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    
    IconData icon;
    icon = Icons.favorite;
    int n = MyAppState.Liste_joueurs.length;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            appState.favorites.length>1
            ? 'Vous avez ${appState.favorites.length} joueurs préférés:'
            : 'Vous avez ${appState.favorites.length} joueur préféré:',
        ),
        ),

        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
              //color: const Color.fromARGB(255, 1, 1, 1),
              onPressed: (){
                appState.removeFavorite(pair);
              },
            ),
            title: TextButton(
              onPressed: (){
                int J=0;
                appState.nomjoueur(pair,J);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      J: J
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                //foregroundColor: Colors.white, // Couleur du texte
                //backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Couleur de fond
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                textStyle: TextStyle(fontSize: 18), // Taille du texte
  ),
              child: Text("$pair"),
          ),
          ),
      ],
    );
  }
}


class Fiche extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    int n = MyAppState.Liste_joueurs.length;
    IconData icon2 ;
    
    
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            appState.favorites.length>1
            ? 'Vous avez ${appState.favorites.length} joueurs préférés:'
            : 'Vous avez ${appState.favorites.length} joueur préféré:',
        ),
        ),
        for (int j=0;j<n;j++)
          ListTile(
            leading: IconButton(
              icon: Icon(
                appState.favorites.contains("${MyAppState.Liste_joueurs[j].prenom} ${MyAppState.Liste_joueurs[j].nom}")
                    ? Icons.favorite
                    : Icons.favorite_border,
                semanticLabel: 'like',

                ),
                //color: const Color.fromARGB(255, 0, 0, 0),
              onPressed: (){
                appState.toggleFavorite("${MyAppState.Liste_joueurs[j].prenom}" " ${MyAppState.Liste_joueurs[j].nom}");
              },
            ),
            
            title: TextButton(
              onPressed: (){
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      J: j,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                //foregroundColor: Colors.white, // Couleur du texte
                //backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Couleur de fond
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                textStyle: TextStyle(fontSize: 18), // Taille du texte
                      ),
              child: Row(
                children: [ 
                  SizedBox(width: 10),
                  Image.asset(
                    MyAppState.Liste_joueurs[j].image,
                    width: 120,
                    height: 80,),
                  SizedBox(width: 10),
                  Text("${MyAppState.Liste_joueurs[j].prenom}" " ${MyAppState.Liste_joueurs[j].nom}")
              ],
              ),
          ),
          ),
      ],
    );
  }
}



class DetailPage extends StatelessWidget {
  final int J;

  DetailPage({required this.J});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du joueur'),
      ),
        body: Padding(
          padding : const EdgeInsets.all(16.0),
          child : Column(
          children: [/*
            Container(
              width: double.infinity,
              height: 200,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [const Color.fromARGB(255, 255, 255, 255), const Color.fromARGB(255, 28, 31, 28)],
                ),
            ),
          ),*/
            Image.asset(
              MyAppState.Liste_joueurs[J].image,
              width: 500,
              height: 300,),
            SizedBox(height: 30),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                '${MyAppState.Liste_joueurs[J].prenom} ${MyAppState.Liste_joueurs[J].nom}',
                style: TextStyle(
                  fontSize: 30
                )),
              ],
            ),
            SizedBox(height: 20),
            Flexible(
              child:
              Text('Description : ${MyAppState.Liste_joueurs[J].description}',
              overflow: TextOverflow.ellipsis,),
              
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  children : [
                  Text('Prénom : ${MyAppState.Liste_joueurs[J].prenom}'),
                  SizedBox(height: 20),
                  Text('Poste : ${MyAppState.Liste_joueurs[J].poste}'),
                  SizedBox(height: 20),
                  Text('Nombre de buts : ${MyAppState.Liste_joueurs[J].but}'),
                  SizedBox(height: 20),
                  Text('Pays : ${MyAppState.Liste_joueurs[J].pays}'),
                  ]  
                ),
                SizedBox(width: 50),
                Column(
                  children : [
                  Text('Nom : ${MyAppState.Liste_joueurs[J].nom}'),
                  SizedBox(height: 20),
                  Text('Saison : ${MyAppState.Liste_joueurs[J].saison}'),
                  SizedBox(height: 20),
                  Text('Nombre de match : ${MyAppState.Liste_joueurs[J].match}'),
                  SizedBox(height: 20),
                  Text('Numéro : ${MyAppState.Liste_joueurs[J].numero}'),
                  ]  
                )
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              IconButton(
                icon: Icon(
                appState.favorites.contains("${MyAppState.Liste_joueurs[J].prenom} ${MyAppState.Liste_joueurs[J].nom}")
                    ? Icons.favorite
                    : Icons.favorite_border,
                semanticLabel: 'like',
                ),
                color: const Color.fromARGB(255, 13, 12, 12),
                onPressed: (){
                  appState.toggleFavorite("${MyAppState.Liste_joueurs[J].prenom}" " ${MyAppState.Liste_joueurs[J].nom}");
              },
            ),
            ]
            ),
          ]
      ),
      ),
    );
  }
}
  
class Categorie extends StatelessWidget {
  static int cat = 0;

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var cate = <String>["cat1","cat2","cat3","cat4","cat5","cat6"];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 150 / 90,
            ),
            children: [
              for (var pair in cate)
                ListTile(
                  title: TextButton(
              onPressed: (){
                print(cat);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Couleur du texte
                backgroundColor: const Color.fromARGB(255, 153, 68, 43), // Couleur de fond
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40), // Padding
                textStyle: TextStyle(fontSize: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ) // Taille du texte
  ),
              child: Text(pair
                  ),
                  ),
                ),
              
            ],
          ),
        ),
      ],
    );
  }
}


class Cat1 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var cate = <String>["cat1"];


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(30),
          child: Text('You have '
              '${appState.favorites.length} favorites:'),
        ),
        Expanded(
          // Make better use of wide windows with a grid.
          child: GridView(
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350,
              childAspectRatio: 150 / 90,
            ),
            children: [
              for (var pair in cate)
                ListTile(
                  title: TextButton(
              onPressed: (){
                print('bouton');
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // Couleur du texte
                backgroundColor: const Color.fromARGB(255, 153, 68, 43), // Couleur de fond
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40), // Padding
                textStyle: TextStyle(fontSize: 25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)
                ) // Taille du texte
  ),
              child: Text(pair
                  ),
                  ),
                ),
              
            ],
          ),
        ),
      ],
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: "${pair.first} ${pair.second}",
        ),
      ),
    );
  }
}
