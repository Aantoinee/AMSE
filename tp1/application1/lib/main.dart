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
          brightness: Brightness.dark,        //thème sombre pour l'application
          )
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  static List<Joueurs> Liste_joueurs = [];      //liste avec toutes les informations sur les joueurs

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
  var favorites = <String>[];   //liste des favoris
  var  criteres = <bool>[];       //liste des critères pour la recherche de joueurs


  void toggleFavorite(String current) {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }


  //lorsqu'on appuie sur un critère, celui-ci change d'état
  void critere(int i){    
    if (criteres[i]){
      criteres[i]=false;
    }
    else{
      criteres[i]=true;
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
switch (selectedIndex) {
  case 1:
    page = FavoritesPage();
    break;
  case 0:
    page = Categorie();
    break;
  case 2:
    page = About();
    break;  
  default:
    throw UnimplementedError('no widget for $selectedIndex');
}
    return LayoutBuilder(
      builder: (context, constraints) {
            return Scaffold(
      body: page,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        unselectedItemColor: Theme.of(context).colorScheme.primaryContainer,
        selectedItemColor: Theme.of(context).colorScheme.primaryContainer,
        onTap: (value) {
          setState(() {
            selectedIndex = value;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_add),
            label: 'About',
          ),
        ],
      ),
    );
  }
  );
}
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    int nomjoueur(String pair, int J){
      int n = MyAppState.Liste_joueurs.length;
      for (int j=0;j<n;j++){
        if ("${MyAppState.Liste_joueurs[j].prenom}" " ${MyAppState.Liste_joueurs[j].nom}"==pair){
          J = j;
        }
     }
    return J;
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            appState.favorites.length>1
            ? 'Vous avez ${appState.favorites.length} joueurs préférés:'
            : 'Vous avez ${appState.favorites.length} joueur préféré:',
        style : TextStyle(
          fontSize: 20
                )
              ),
            ),
        Expanded (
          child: GridView(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 400,
            childAspectRatio: 400 /100
            ),
        children: [    
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.delete_outline, semanticLabel: 'Delete'),
              onPressed: (){
                appState.removeFavorite(pair);
              },
            ),
            title: TextButton(
              onPressed: (){
                int J=0;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailPage(
                      J: nomjoueur(pair,J)
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                textStyle: TextStyle(fontSize: 18),
                ),
              child: Text("$pair"),
                ),
              ),
            ],
          ),
        )
      ]
    );
  }
}



class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Column(
      children: [
          Text('Cette application a été développée par Antoine Gueudet.'),
          Text('Elle y référence les joueurs emblématiques du SCO de Angers.'),
          SizedBox(height: 20),
          Text("Pour rechercher des joueurs, j'ai mis seulement deux critères qui me semblaient être les plus pertinents. Cependant, il est tout a fait possible d'en ajouter plus.")
      ]
    );
  }
}

class DetailPage extends StatelessWidget {
  final int J;

  DetailPage({required this.J});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    //la taille de la police varie en fonction de la taille de l'écran
    double taille_police = 4.9+10/(1180-800)*MediaQuery.of(context).size.width;

    //la taille de l'image du joueur varie en fonction de la taille de l'écran
    double hauteur_img(double taille){
      if (taille>450){
        return taille/2;
      }
      return taille/3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du joueur'),
      ),
        body: SingleChildScrollView(
          padding : const EdgeInsets.all(16.0),
          child : 
          Center (
            child:
          Column(
          children: [
            Image.asset(
              MyAppState.Liste_joueurs[J].image,
              width: MediaQuery.of(context).size.width,
              height: hauteur_img(MediaQuery.of(context).size.height)
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
              Text(
                '${MyAppState.Liste_joueurs[J].prenom} ${MyAppState.Liste_joueurs[J].nom}',
                style: TextStyle(
                  fontSize: 23+10/(1180-800)*MediaQuery.of(context).size.width
                )),
              ],
            ),
            Padding(padding: const EdgeInsets.all(20),
              child: Text('Description : ${MyAppState.Liste_joueurs[J].description}',
            textAlign: TextAlign.center,
            style: TextStyle(
                  fontSize: taille_police+2,
                )),
                ),
            SizedBox(height: 20),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children : [
                  Text('Prénom : ${MyAppState.Liste_joueurs[J].prenom}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  SizedBox(height: 20),
                  Text('Poste : ${MyAppState.Liste_joueurs[J].poste}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  SizedBox(height: 20),
                  Text('Nombre de buts : ${MyAppState.Liste_joueurs[J].but}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  SizedBox(height: 20),
                  if (MyAppState.Liste_joueurs[J].saison.length<9)
                  Text('Saison : ${MyAppState.Liste_joueurs[J].saison}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  if (MyAppState.Liste_joueurs[J].saison.length>=9)
                  Text('Saison : ${MyAppState.Liste_joueurs[J].saison.substring(0,9)}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  if (MyAppState.Liste_joueurs[J].saison.length>11)
                  Text(MyAppState.Liste_joueurs[J].saison.substring(10,22),
                  style: TextStyle(
                  fontSize: taille_police,
                ))
                  ]  
                ),
                SizedBox(width: 14+1/20*MediaQuery.of(context).size.width),
                Column(
                  children : [
                  Text('Nom : ${MyAppState.Liste_joueurs[J].nom}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  SizedBox(height: 20),
                  Text('Pays : ${MyAppState.Liste_joueurs[J].pays}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  SizedBox(height: 20),
                  Text('Nombre de match : ${MyAppState.Liste_joueurs[J].match}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
                  SizedBox(height: 20),
                  Text('Numéro : ${MyAppState.Liste_joueurs[J].numero}',
                  style: TextStyle(
                  fontSize: taille_police,
                )),
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
                onPressed: (){
                  appState.toggleFavorite("${MyAppState.Liste_joueurs[J].prenom}" " ${MyAppState.Liste_joueurs[J].nom}");
                    },
                  ),
                ]
              ),
            ]
          ),
        ),
      )
    );
  }
}




class Categorie extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    int n = MyAppState.Liste_joueurs.length;

    //liste des postes pour la recherche par critères
    List poste = <String>['Gardien', 'Défenseur', 'Milieu', 'Attaquant'];

    //listes pour rechercher des joueurs selon leur nationalité
    List nationalite = <String>[];
    List nationalite2 = <String>[];
    for (int i=0;i<n;i++){
    if (nationalite.contains(MyAppState.Liste_joueurs[i].pays)==false){
        nationalite.add(MyAppState.Liste_joueurs[i].pays);
      }
    }

    // 4 = nombre de postes
    int N = 4+ nationalite.length;

    for (int i=0;i<N;i++){
      appState.criteres.add(false);
    }
    
    //nat sert à constituer la liste des nationalités dans la base de données
    bool nat(List L){
      for (var pays in L){
          if (pays){
            return true;
          }
      }
      return false;
    }

    //sert à savoir quel joueur doit être affiché en fonction des critères cochés
    bool verif_nat(int j){
      for (int i= 0;i<nationalite.length;i++){
        if (appState.criteres[4+i]){
          if (nationalite[i]==MyAppState.Liste_joueurs[j].pays){
            return true;
          }
        }
      }
      return false;
    }

    //sert à ne pas avoir deux fois le même pays dans les critères
    bool test_nat(String pays){
        if (nationalite2.contains(pays)==false){
          nationalite2.add(pays);
          return true;
        }
      return false;
    }

    //sert pour gérer l'affichage des deux barres de critères
    double hauteur_critere(double taille, double chg){
      if (taille>chg){
        return 90;
      }
      if (taille<350){
        return taille/1.5;
      }
      return taille/3;
    }

    //sert pour gérer l'affichage des deux barres de critères
    double taille_critere(double taille){
      if (taille<350){
        return 180;
      }
      return 150;
    }

  //sert pour gérer l'affichage des textButton 
    double taille_button(double taille){
      if (taille<420){
        return 100;
      }
      return 150;
    }


    return ListView(
      children: [
        Padding(padding: const EdgeInsets.all(20),
        child: Text('Poste du joueur :',
          style: TextStyle(
          fontSize: 20
          )
          ),
        ),
        SizedBox(
          height: hauteur_critere(MediaQuery.of(context).size.width,450),
          child : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: taille_critere(MediaQuery.of(context).size.width),
                  childAspectRatio: 200/100 
                  ),


                  children: [
                    for (int i=0;i<poste.length;i++)
                       Column(
                          children: [
                        Text("${poste[i]}"),
                        IconButton(
                              icon: Icon(
                                appState.criteres[i]
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                semanticLabel: 'like',

                                ),
                              onPressed: (){
                                appState.critere(i);
                                  },
                                ),
                              ]
                            ),
                          ]
                        ),
                      )
                    ],
                  ),
                ),

        Padding(padding: const EdgeInsets.all(20),
        child: Text('Nationalité du joueur :',
          style: TextStyle(
          fontSize: 20
            )
          ),
        ),
        SizedBox(
          height: hauteur_critere(MediaQuery.of(context).size.width,600),
          child : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              fit: FlexFit.loose,
              child: GridView(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: taille_critere(MediaQuery.of(context).size.width),
                  childAspectRatio: 200/100 
                  ),
                  children: [
                    for (int i=0;i<nationalite.length;i++)
                      if (test_nat(nationalite[i]))
                       Column(
                          children: [
                        Text("${nationalite[i]}"),
                        IconButton(
                              icon: Icon(
                                appState.criteres[4+i]
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                semanticLabel: 'like',

                                ),
                              onPressed: (){
                                appState.critere(4+i);
                              },
                            ),
                          ]
                        ),
                      ]
                    )
                  ),
                ]
              )
            ),
        Padding(padding: const EdgeInsets.all(20),
        child: Text('Liste des joueurs :',
          style: TextStyle(
          fontSize: 30
              )
            ),
         ),

        for (int j=0;j<n;j++)

          //pour chaque joueur, il faut vérifier s'il rentre bien dans les critères cochés par l'utilisateur
          if ((MyAppState.Liste_joueurs[j].poste=='Gardien')&&(appState.criteres[0])
          || (MyAppState.Liste_joueurs[j].poste=='Défenseur')&&(appState.criteres[1])
          || (MyAppState.Liste_joueurs[j].poste=='Milieu')&&(appState.criteres[2])
          || (MyAppState.Liste_joueurs[j].poste=='Attaquant')&&(appState.criteres[3])
          || (appState.criteres[0]==false && appState.criteres[1]==false && appState.criteres[2]==false && appState.criteres[3]==false))
          if ((verif_nat(j))
          || (nat(appState.criteres.sublist(4,appState.criteres.length))==false)
          )
            //affichage de l'icône favoris, de l'image et du nom du joueur
            ListTile(
              leading: IconButton(
                icon: Icon(
                  appState.favorites.contains("${MyAppState.Liste_joueurs[j].prenom} ${MyAppState.Liste_joueurs[j].nom}")
                      ? Icons.favorite
                      : Icons.favorite_border,
                  semanticLabel: 'like',

                  ),
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
                  padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0), // Padding
                  textStyle: TextStyle(fontSize: 20),
                        ),
                child: Row(
                  children: [ 
                    SizedBox(width: 10),
                    Image.asset(
                      MyAppState.Liste_joueurs[j].image,
                      width: taille_button(MediaQuery.of(context).size.width),
                      height: 80,),
                    SizedBox(width: 10),
                    //si la page est trop petite, on n'affiche que le nom du joueur
                    if (MediaQuery.of(context).size.width<=360)
                    Text(" ${MyAppState.Liste_joueurs[j].nom}",
                    ),
                    if (MediaQuery.of(context).size.width>360)
                    Text("${MyAppState.Liste_joueurs[j].prenom}" " ${MyAppState.Liste_joueurs[j].nom}")
                  ],
                ),
              ),
            ),
        ],
      );
  }
}
