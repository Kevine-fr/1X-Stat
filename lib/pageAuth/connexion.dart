import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stat/constants/chargement.dart';

class Connexion extends StatefulWidget {
  final Function basculation;
  Connexion({required this.basculation});

  @override
  _ConnexionState createState() => _ConnexionState();
}

class _ConnexionState extends State<Connexion> {
  FirebaseAuth _auth = FirebaseAuth.instance;

  String email = '';
  String motDePasse = '';

  bool chargement = false;

  final _keyform = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    bool _isPasswordVisible = false;
    return chargement
        ? Chargement()
        : Scaffold(
            body: SingleChildScrollView(
              // Permet de gerer des beugs d'affichage avec le clavier tactile du telephone
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 50, horizontal: 30),
                child: Form(
                  key: _keyform,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const SizedBox(height: 80),

                      // logo
                      const Icon(
                        Icons.lock_open,
                        size: 100,
                      ),

                      const SizedBox(height: 50),

                      // Message de bienvenue!
                      Padding(
                        padding: const EdgeInsets.only(
                            left:
                                95), // Ajoute un padding de 20 pixels à gauche
                        child: Text(
                          'Bienvenue sur 1XStat !',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 16,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

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
                          ),
                          validator: (val) {
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
                                  _isPasswordVisible =
                                      !_isPasswordVisible; // Inverser l'état de visibilité du mot de passe
                                });
                              },
                              child: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          obscureText:
                              !_isPasswordVisible, // Affiche ou masque le texte du mot de passe en fonction de l'état de visibilité
                          validator: (val) => val!.length < 7
                              ? 'Mot de passe incorrecte'
                              : null,
                          onChanged: (val) => setState(() => motDePasse = val),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all<Color>(Colors.black),
                            foregroundColor:
                                MaterialStateProperty.all<Color>(Colors.white),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                          onPressed: () async {
                            // Action à exécuter lorsque le bouton est pressé
                            if (_keyform.currentState!.validate()) {
                              if (!email.contains('@')) {
                                // Afficher un message d'erreur si l'adresse e-mail ne contient pas le symbole "@"
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Text('Erreur'),
                                      content: Text(
                                          'L\'adresse e-mail doit contenir un "@"'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                setState(() {
                                  chargement = true;
                                });
                                var result =
                                    await _auth.signInWithEmailAndPassword(
                                  email: email,
                                  password: motDePasse,
                                );
                                if (result == null) {
                                  // Gérer l'erreur d'authentification ici
                                }
                              }
                            }
                          },
                          child: const Text('Connexion'),
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
                          child: const Text('Inscription'), // Texte du bouton
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
