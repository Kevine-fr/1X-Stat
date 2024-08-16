import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stat/pageAuth/controlAuth.dart';
import 'package:stat/pageCrud/acceuil.dart';
import 'package:stat/pageCrud/ajoutPari.dart';

class AjoutPari extends StatefulWidget {
  AjoutPari({super.key});

  @override
  State<AjoutPari> createState() => _AjoutPariState();
}

class _AjoutPariState extends State<AjoutPari> {


  Color couleurDominante = Color(0xFF17171F);
  Color couleurPredominante = Color(0xFF252530);
  Color couleurIconeSelectionner = Color(0xFFBFF5C7);
  Color couleurIconeNonSelectionner = Color(0xFFD9D9D9);
  late String nomUtil, emailUtil;
  late double gain = 0;
  late double bonus = 0;
  late double pBonus = 0;
  late double cote = 0;
  late double coteTotal = 0;
  late double sommeParierMax = 0;
  late double sommeParierMin = 0;
  late double mise = 0 ;
  late double pCote1 = 0;
  late double pCote2 = 0;
  late double pCote = 0;

  Widget _boiteDeCalcule(BuildContext context, double cote, double coteTotal, double sommeParierMax, double sommeParierMin, double gain, double coteEquipe1, double coteEquipe2, double pCote1, double pCote2, double pCote, double mise) {

    final _formKey = GlobalKey<FormState>();

    final sommeParierController = TextEditingController();
    final coteEquipe1Controller = TextEditingController();
    final coteEquipe2Controller = TextEditingController();

    _calculateResult() {
      double sommeParier = double.tryParse(sommeParierController.text) ?? 0;
      double coteEquipe1 = double.tryParse(coteEquipe1Controller.text) ?? 0;
      double coteEquipe2 = double.tryParse(coteEquipe2Controller.text) ?? 0;

      pCote1 = 100 / coteEquipe1;
      pCote2 = 100 / coteEquipe2;
      pCote = pCote1 + pCote2;

      cote = double.parse((coteEquipe1 - coteEquipe2).toStringAsFixed(2));
      bonus = double.parse((gain - sommeParier).toStringAsFixed(2));
      pBonus = double.parse((bonus / sommeParier * 100).toStringAsFixed(2));

      if (coteEquipe1 > coteEquipe2) {
        mise = sommeParier / coteEquipe2;
        gain = double.parse(((sommeParier - mise) * coteEquipe1).toStringAsFixed(2));
        sommeParierMax = double.parse((sommeParier / coteEquipe2).toStringAsFixed(2));
        sommeParierMin = double.parse((sommeParier - sommeParierMax).toStringAsFixed(2));
      }
      if (coteEquipe1 < coteEquipe2) {
        mise = sommeParier / coteEquipe1;
        gain = double.parse(((sommeParier - mise) * coteEquipe2).toStringAsFixed(2));
        sommeParierMax = double.parse((sommeParier / coteEquipe1).toStringAsFixed(2));
        sommeParierMin = double.parse((sommeParier - sommeParierMax).toStringAsFixed(2));
      }
    }

    return SimpleDialog(
      title: Center(
        child: Text(
          'Evaluation de gain',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
      contentPadding: EdgeInsets.all(20.0),
      children: [
        Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: sommeParierController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Montant à parier'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer un montant';
                  }
                  double? montant = double.tryParse(value);
                  if (montant == null || montant <= 0 || montant > 5000000) {
                    return 'Veuillez entrer un montant valide';
                  }
                  // You can add additional checks if needed
                  return null;
                },
                onChanged: (value) {
                  _calculateResult(); // Recalculate whenever the input changes
                },
              ),
              TextFormField(
                controller: coteEquipe1Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Côte de l'équipe 1"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une côte';
                  }
                  double? coteEquipe1 = double.tryParse(value);
                  if (coteEquipe1 == null || coteEquipe1 <= 1 || coteEquipe1 > 100) {
                    return 'Veuillez entrer une côte valide';
                  }
                  // You can add additional checks if needed
                  return null;
                },
                onChanged: (value) {
                  _calculateResult(); // Recalculate whenever the input changes
                },
              ),
              TextFormField(
                controller: coteEquipe2Controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Côte de l'équipe 2"),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Veuillez entrer une côte';
                  }
                  double? coteEquipe2 = double.tryParse(value);
                  if (coteEquipe2 == null || coteEquipe2 <= 0 || coteEquipe2 > 100) {
                    return 'Veuillez entrer une côte valide';
                  }
                  // You can add additional checks if needed
                  return null;
                },
                onChanged: (value) {
                  _calculateResult(); // Recalculate whenever the input changes
                },
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              _calculateResult();
              double sommeParier = double.tryParse(sommeParierController.text) ?? 0;
              double coteEquipe1 = double.tryParse(coteEquipe1Controller.text) ?? 0;
              double coteEquipe2 = double.tryParse(coteEquipe2Controller.text) ?? 0;

              if(gain > sommeParier && pCote < 100) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 300, horizontal: 50),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                // Pour réduire l'espace vertical
                                children: [
                                  Center(
                                    child: Text(
                                      "Résultat",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        // Changement de couleur pour une meilleure lisibilité
                                        decoration: TextDecoration
                                            .none, // Supprimer le soulignement
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Mise équipe favorite :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "$sommeParierMax",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.euro_symbol,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
// Espacement entre les messages
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Mise équipe non-fav :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "$sommeParierMin",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.euro_symbol,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Bénéfice réalisé :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "$bonus",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.euro_symbol,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Somme à gagner :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "$gain",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.green,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Icon(
                                        Icons.euro_symbol,
                                        color: Colors.green,
                                        size: 12,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  // Espacement entre les messages
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "% Bénéfice réalisé:",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          // Changement de couleur pour une meilleure lisibilité (vert)
                                          decoration: TextDecoration
                                              .none, // Supprimer le soulignement
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Text("$pBonus %", style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          decoration: TextDecoration.none),),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              }if(pCote > 100 || coteEquipe1 == coteEquipe2 || gain < sommeParier){
                showDialog(
                  context: context,
                  builder: (context) {
                    return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: 300, horizontal: 50),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Center(
                                  child: Text("Le pari n'est pas bénéfique!",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ]
                    );
                  },
                );
              }
            }
          },
          child: Text('Placer le pari'),
        ),
        SizedBox(height: 16),

      ],
    );
  }



  final _formKey = GlobalKey<FormState>();

  final CollectionReference collectionUtil =
      FirebaseFirestore.instance.collection('utilisateurs');

  late User currentUser;

  String nomEquipe1 = '';
  String nomEquipe2 = '';
  double sommeParier = 0;
  double coteEquipe1 = 0;
  double coteEquipe2 = 0;
  int idPari = 0;
  String? equipeParier;
  String? equipeGagnante;
  String? sport;

  @override
  Widget build(BuildContext context) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user!;
      });
    });

    String idUtil(){
      if(currentUser != null){
        return currentUser!.uid;
      }else{
        return "Pas d'id";
      }
    }

    final utilisateur = Provider.of<Utilisateur?>(context);
    if (utilisateur != null) { // Vérification que utilisateur n'est pas nul
      GetCurrentUserData(idUtil: utilisateur.idUtil)
          .donneesUtil
          .forEach((snapshot) {
        this.nomUtil = snapshot.nomComplet;
        this.emailUtil = snapshot.email;
      });
    }

    // Reste de votre code ici...


  return Scaffold(
    bottomNavigationBar: ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(15.0),
        topRight: Radius.circular(15.0),
      ),
      child: BottomAppBar(
        color: couleurPredominante,
        height: 60,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
                icon: Icon(
                  Icons.home,
                  size: 30,
                  color: Colors.white,
                ),
              ),
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: couleurIconeSelectionner,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.add, size: 20, color: Colors.black),
                ),
              ],
            ),
            Expanded(
              child: IconButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (context) => _boiteDeCalcule(context, cote, coteTotal, sommeParierMax, sommeParierMin, gain, coteEquipe1, pCote1, pCote2, pCote, mise, sommeParier),
                ),
                icon: Icon(Icons.attach_money, size: 30, color: Colors.white),
              ),
            ),
          ],
        ),
      ),),
      backgroundColor: couleurDominante,
      appBar: AppBar(
        backgroundColor: couleurPredominante,
        title: const Row(
          children: [
            Text(
              '1XStat',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'DiamorScript',
                fontWeight: FontWeight.bold,
                fontSize: 45,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5), //padding left
                  child: TextFormField(
                    decoration: const InputDecoration(
                      // Champ de saisie
                      labelText: "Entrer le nom de l'équipe 1",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled:
                      true, // Définit le fond du champ de saisie en blanc
                      fillColor: Color(0xFF252530), // Couleur de remplissage e
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (val) => val!.isEmpty ? 'Entrez un nom' : null,
                    onChanged: (val) => setState(() => nomEquipe1 = val),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5), //padding left
                  child: TextFormField(
                    decoration: const InputDecoration(
                      // Champ de saisie
                      labelText: "Entrer le nom de l'équipe 2",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled:
                      true, // Définit le fond du champ de saisie en blanc
                      fillColor: Color(0xFF252530), // Couleur de remplissage e
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    style: TextStyle(color: Colors.white),
                    validator: (val) =>
                        val!.isEmpty ? "Saisissez le nom de l'équipe" : null,
                    onChanged: (val) => setState(() => nomEquipe2 = val),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: TextFormField(
                    keyboardType: TextInputType.number, // Clavier numérique
                    decoration: InputDecoration(
                      labelText: "Entrer votre mise",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled:
                      true, // Définit le fond du champ de saisie en blanc
                      fillColor: Color(0xFF252530), // Couleur de remplissage e
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {});
                        },
                        child: Icon(Icons.euro_outlined, color: couleurIconeSelectionner),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                     validator: (val) =>
                        val!.isEmpty ? "Saisissez la somme à parier" : null,
                    onChanged: (val) => setState(() => sommeParier = double.parse(val)),
                  ),
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5), //padding left
                  child: TextFormField(
                    keyboardType: TextInputType.number, // Clavier numérique
                    decoration: const InputDecoration(
                      // Champ de saisie
                      labelText: "Entrer la côte de l'équipe 1",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled: true, // Définit le fond du champ de saisie en blanc
                      fillColor: Color(0xFF252530), // Couleur de remplissage
                      contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                    style: TextStyle(color: Colors.white), // Modifier la couleur du texte saisi en blanc
                    validator: (val) =>
                    val!.isEmpty ? "Saisissez la côte de l'équipe 1" : null,
                    onChanged: (val) => setState(() => coteEquipe1 = double.parse(val)),
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 5), //padding left
                  child: TextFormField(
                    keyboardType: TextInputType.number, // Clavier numérique
                    decoration: const InputDecoration(
                      // Champ de saisie
                      labelText: "Entrer la côte de l'équipe 2",
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled:
                          true, // Définit le fond du champ de saisie en blanc
                      fillColor: Color(0xFF252530), // Couleur de remplissage e
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                    ),
                      style: TextStyle(color: Colors.white),
                     validator: (val) =>
                        val!.isEmpty ? "Saisissez la côte de l'équipe 2" : null,
                    onChanged: (val) => setState(() => coteEquipe2 = double.parse(val))
                    // onChanged: (val) => setState(() => coteEquipe2 = val),
                  ),
                ),
                
                const SizedBox(height: 10),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Champ de sélection d'équipe
                      DropdownButtonFormField<String>(
                        value: equipeParier,
                        decoration: InputDecoration(
                          labelText: "Vous avez parier sur : ",
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: Colors.black,
                        items: <String>['Equipe 1', 'Equipe 2']
                            .map((equipe) => DropdownMenuItem<String>(
                                  value: equipe,
                                  child: Row( // Utiliser un Row pour ajouter l'icône à droite du texte
                                    children: [
                                      Icon(Icons.create, color: couleurIconeSelectionner), // Icône personnalisée (vous pouvez en utiliser une autre)
                                      SizedBox(width: 10), // Espacement entre l'icône et le texte
                                      Text(
                                        equipe,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (nouvelleEquipe) {
                          setState(() {
                            equipeParier = nouvelleEquipe!;

                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Champ de sélection d'équipe
                      DropdownButtonFormField<String>(
                        value: equipeGagnante,
                        decoration: InputDecoration(
                          labelText: "L'équipe gagnant est : ",
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                        ),
                        dropdownColor: Colors.black,
                        items: <String>['Equipe 1', 'Equipe 2']
                            .map((equipe) => DropdownMenuItem<String>(
                                  value: equipe,
                                  child: Row( // Utiliser un Row pour ajouter l'icône à droite du texte
                                    children: [
                                      Icon(Icons.create, color: couleurIconeSelectionner), // Icône personnalisée (vous pouvez en utiliser une autre)
                                      SizedBox(width: 10), // Espacement entre l'icône et le texte
                                      Text(
                                        equipe,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (nouvelleEquipe) {
                          setState(() {
                            equipeGagnante = nouvelleEquipe!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 0),
                Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Champ de sélection d'équipe
                      DropdownButtonFormField<String>(
                        value: sport,
                        decoration: InputDecoration(
                          labelText: "Sport",
                          labelStyle: TextStyle(color: Colors.white),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10), // Réduire de 20 pixels à gauche et à droite
                        ),
                        dropdownColor: Colors.black,
                        items: <String>['BasketBall', 'FootBall', 'Ténnis', 'E-Sport', 'Autres']
                            .map((equipe) => DropdownMenuItem<String>(
                          value: equipe,
                          child: Row( // Utiliser un Row pour ajouter l'icône à droite du texte
                            children: [
                              Icon(Icons.create, color: couleurIconeSelectionner), // Icône personnalisée (vous pouvez en utiliser une autre)
                              SizedBox(width: 10), // Espacement entre l'icône et le texte
                              Text(
                                equipe,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ))
                            .toList(),
                        onChanged: (nouvelleEquipe) {
                          setState(() {
                            sport = nouvelleEquipe!;
                          });
                        },
                      ),
                    ],
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
                          couleurIconeSelectionner), // Fond blanc
                      foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.black), // Texte noir
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              15), // Réduire les bordures de 15 pixels
                          side: const BorderSide(
                              color:
                                  Colors.white), // Couleur des bordures en noir
                        ),
                      ),
                    ),onPressed: () async {
                if (_formKey.currentState!.validate()) {
                idPari++;

                // Obtenir l'heure actuelle
                DateTime maintenant = DateTime.now();
                int heure = maintenant.hour;
                int minutes = maintenant.minute;

                await collectionUtil.doc(utilisateur!.idUtil).collection('Paris').add({
                'nomEquipe1': nomEquipe1,
                'nomEquipe2': nomEquipe2,
                'sommeParier': sommeParier,
                'coteEquipe1': coteEquipe1,
                'coteEquipe2': coteEquipe2,
                'equipeParier': equipeParier,
                'equipeGagnante': equipeGagnante,
                'sport': sport,
                'heure': heure,
                'minutes': minutes,
                });

                this.setState(() {
                Navigator.pop(context);
                });
                }
                },

                  child: const Text('ENREGISTRER'), // Texte du bouton
                  ),
                ),
                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Information du pari',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Times New Roman'),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
