class Joueurs{
  final String nom;
  final String prenom;
  final String poste;
  final String image;
  final String numero;
  final String pays;
  final String match;
  final String but;
  final String description;
  final String saison;

  Joueurs({
    required this.nom,
    required this.prenom,
    required this.numero,
    required this.image,
    required this.poste,
    required this.pays,
    required this.but,
    required this.match,
    required this.description,
    required this.saison
  });

  factory Joueurs.fromJson(Map<String, dynamic> json){
    return Joueurs(
      nom: json['name'],
      prenom: json['prénom'],
      numero: json["numéro"],
      image: json['image'],
      poste: json['poste'],
      pays: json['pays'],
      description: json['description'],
      but: json['but'],
      match: json['match'],
      saison: json['saison']
    );
  }
}
