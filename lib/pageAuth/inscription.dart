import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stat/constants/chargement.dart';

class Inscription extends StatefulWidget {
  final Function basculation;
  Inscription({required this.basculation});

  @override
  State<Inscription> createState() => _InscriptionState();
}

class _InscriptionState extends State<Inscription> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  User? currentUser;

//Collection utilisateur depuis firestore
  final CollectionReference collectionUtil =
      FirebaseFirestore.instance.collection('utilisateurs');

  //initialisation des variables
  String nomComplet = '';
  String email = '';
  String motDePasse = '';
  String confimMdP = '';

  bool chargement = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? util) {
      setState(() {
        currentUser = util;
      });
    });

    String _idUtil() {
      final currentUser = this.currentUser;
      if (currentUser != null) {
        return currentUser.uid;
      } else {
        return "Pas d'utilisateur courant";
      }
    }

    bool isPasswordVisible = false;
    return chargement
        ? Chargement()
        : Scaffold(
            backgroundColor: Colors.grey[300],
            body: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 90),

                      // logo
                      const Icon(
                        Icons.lock,
                        size: 100,
                      ),

                      const SizedBox(height: 15),

                      // Message de bienvenue!
                      Padding(
                        padding: const EdgeInsets.only(
                            left:
                                105), // Ajoute un padding de 20 pixels à gauche
                        child: Text(
                          'Bienvenue sur 1XStat !',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      // Nom d'utilisateur textfield
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5), //padding left
                        child: TextFormField(
                          decoration: const InputDecoration(
                            // Champ de saisie
                            labelText: "Entrer votre nom",
                            border: OutlineInputBorder(),
                            filled:
                                true, // Définit le fond du champ de saisie en blanc
                            fillColor: Colors.white, // Couleur de remplissage e
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15, horizontal: 15),
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Entrez un nom' : null,
                          onChanged: (val) => setState(() => nomComplet = val),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5), // Padding à gauche
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: "Entrer votre E-mail",
                            border: OutlineInputBorder(),
                            filled:
                                true, // Définit le fond du champ de saisie en blanc
                            fillColor:
                                Colors.white, // Couleur de remplissage en blanc
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 15), // Padding à gauche et en haut
                          ),validator: (val) {
                              if (val!.isEmpty) {
                                return 'Entrez une adresse mail';
                              } else if (!val.contains('@')) {
                                return 'L\'adresse mail doit contenir un @';
                              }
                              return null; // Retourne null si la validation est réussie
                            },
                            onChanged: (val) => setState(() => email = val),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Mot de passe textfield

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5), // Padding à gauche
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Saisissez votre mot de passe',
                            border: const OutlineInputBorder(),
                            filled:
                                true, // Définit le fond du champ de saisie en blanc
                            fillColor:
                                Colors.white, // Couleur de remplissage en blanc
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 15), // Padding à gauche et en haut
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPasswordVisible =
                                      !isPasswordVisible; // Inverser l'état de visibilité du mot de passe
                                });
                              },
                              child: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          obscureText:
                              !isPasswordVisible, // Affiche ou masque le texte du mot de passe en fonction de l'état de visibilité
                          validator: (val) => val!.length < 8
                              ? 'Votre mot de passe doit comporter au moins 8 caractères'
                              : null,
                          onChanged: (val) => setState(() => motDePasse = val),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5), // Padding à gauche
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmer votre mot de passe',
                            border: const OutlineInputBorder(),
                            filled:
                                true, // Définit le fond du champ de saisie en blanc
                            fillColor:
                                Colors.white, // Couleur de remplissage en blanc
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 15), // Padding à gauche et en haut
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isPasswordVisible =
                                      !isPasswordVisible; // Inverser l'état de visibilité du mot de passe
                                });
                              },
                              child: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          obscureText:
                              !isPasswordVisible, // Affiche ou masque le texte du mot de passe en fonction de l'état de visibilité

                          onChanged: (val) => setState(() => confimMdP = val),
                          validator: (val) => confimMdP != motDePasse
                              ? 'Ce mot de passe ne correspond pas au mot de passe écrit'
                              : null,
                        ),
                      ),

                      // Mot de passe oublié?
                      const SizedBox(height: 5),

                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Mot de passe oublié?',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 0, 138, 252)),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

                      // Boutton de connexion
                      ButtonTheme(
                        height: 35,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15), // Padding à gauche et à droite
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.black), // Fond noir
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.white), // Texte blanc
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Réduire les bordures de 15 pixels
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // Action à exécuter lorsque le bouton est pressé
                            if (_formKey.currentState!.validate()) {
                              if (mounted) {
                                setState(() {
                                  chargement =
                                      true; // Assurez-vous de déclarer et d'initialiser "chargement" ailleurs dans le code.
                                });
                              }

                              // Le formulaire est valide
                              // Effectuez les actions nécessaires ici

                              try {
                                var result =
                                    await _auth.createUserWithEmailAndPassword(
                                  email: email,
                                  password: motDePasse,
                                );

                                await FirebaseFirestore.instance
                                    .collection('utilisateurs')
                                    .doc(_idUtil())
                                    .set({
                                  'idUtil': _idUtil(),
                                  'nomComplet': nomComplet,
                                  'emailUtil': email,
                                });

                                if (result == null) {
                                  // Gérer l'erreur en cas d'échec de création d'utilisateur
                                }
                              } catch (e) {
                                // Gérer les autres erreurs possibles (par exemple, email déjà utilisé)
                              }

                              setState(() {
                                chargement = false;
                              });
                            }
                          },
                          child: const Text('Inscription'), // Texte du bouton
                        ),
                      ),

                      const SizedBox(height: 5),
                      ButtonTheme(
                        height: 35,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15), // Padding à gauche et à droite
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.white), // Fond blanc
                            foregroundColor: MaterialStateProperty.all<Color>(
                                Colors.black), // Texte noir
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    15), // Réduire les bordures de 15 pixels
                                side: const BorderSide(
                                    color: Colors
                                        .black), // Couleur des bordures en noir
                              ),
                            ),
                          ),
                          onPressed: () {
                            // Action à exécuter lorsque le bouton est pressé
                            widget.basculation();
                          },
                          child: const Text('Connexion'), // Texte du bouton
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Autre alternative (Google)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10.0),
                              child: Text(
                                'Connexion avec Google',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                thickness: 0.5,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // google
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          // google button
                          Container(
                            width: 100,
                            height: 90,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white,
                                  width:
                                      1), // Modifier les bordures (couleur et largeur)
                              color: Colors
                                  .white, // Changer la couleur de fond en blanc
                              borderRadius: BorderRadius.circular(
                                  10), // Modifier la forme des bordures de l'image (arrondies)
                            ),
                            child: Image.asset(
                              'assets/google.png', // Remplacez 'assets/google_button.png' par le chemin de votre image
                              fit: BoxFit
                                  .contain, // Ajuster l'image au conteneur
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // not a member? register now
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Pas de compte?',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Enregistrez vous maintenant!',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
