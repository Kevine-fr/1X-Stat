import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stat/pageAuth/controlAuth.dart';
import 'package:stat/pageCrud/ajoutPari.dart';

class Acceuil extends StatefulWidget {
  Acceuil({super.key});

  @override
  State<Acceuil> createState() => _AcceuilState();
}

class _AcceuilState extends State<Acceuil> {
  Color couleurDominante = Color(0xFF17171F);
  Color couleurPredominante = Color(0xFF252530);
  Color couleurIconeSelectionner = Color(0xFFBFF5C7);
  Color couleurIconeNonSelectionner = Color(0xFFD9D9D9);
  late String nomUtil, emailUtil;
  late double gain1 = 0;
  late double gain2 = 0;
  late double bonus1 = 0;
  late double bonus2 = 0;
  late double pBonus1 = 0;
  late double pBonus2 = 0;
  late double cote = 0;
  late double coteTotal = 0;
  late double sommeParier = 0;
  late double sommeParierMax = 0;
  late double sommeParierMin = 0;
  late double coteEquipe1 = 0;
  late double coteEquipe2 = 0;
  late double mise1 = 0 ;
  late double mise2 = 0 ;
  late double pCote1 = 0;
  late double pCote2 = 0;
  late double pCote = 0;
  late double reste = 0;
  late double pMise1 = 0;
  late double pMise2 = 0;
  late double mise = 0;

  Widget _boiteDeCalcule(BuildContext context,double reste ,double pBonus1,double pBonus2,double bonus1,double bonus2, double mise1, double mise2, double pMise1,double pMise2, double cote, double coteTotal, double sommeParierMax, double sommeParierMin, double gain, double coteEquipe1, double coteEquipe2, double pCote1, double pCote2, double pCote, double mise) {

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

         //bonus = double.parse((gain - sommeParier).toStringAsFixed(2));
         //pBonus = double.parse((bonus / sommeParier * 100).toStringAsFixed(2));

         if (coteEquipe1 > coteEquipe2) {

           mise1 = sommeParier / coteEquipe1;
           mise2 = sommeParier / coteEquipe2;

           mise = mise1 + mise2;
           reste = sommeParier - mise;

           pMise2 = mise2 * 0.2;
           pMise1 = reste - pMise2;

           sommeParierMax = double.parse((mise2 + pMise2).toStringAsFixed(2));
           sommeParierMin = double.parse((mise1 + pMise1).toStringAsFixed(2));

           gain2 = double.parse((sommeParierMin * coteEquipe1).toStringAsFixed(2));
           bonus2 = double.parse((gain2 - sommeParier).toStringAsFixed(2));
           pBonus2 = double.parse((bonus2 / sommeParier * 100).toStringAsFixed(2));

           gain1 = double.parse((sommeParierMax * coteEquipe2).toStringAsFixed(2));
           bonus1 = double.parse((gain1 - sommeParier).toStringAsFixed(2));
           pBonus1 = double.parse((bonus1 / sommeParier * 100).toStringAsFixed(2));

         }
         if (coteEquipe1 < coteEquipe2) {

           mise1 = sommeParier / coteEquipe1;
           mise2 = sommeParier / coteEquipe2;

           mise = mise1 + mise2;
           reste = sommeParier - mise;

           pMise1 = mise1 * 0.2;
           pMise2 = reste - pMise1;

           sommeParierMax = double.parse((mise1 + pMise1).toStringAsFixed(2));
           sommeParierMin = double.parse((mise2 + pMise2).toStringAsFixed(2));

           gain1 = double.parse((sommeParierMax * coteEquipe1).toStringAsFixed(2));
           bonus1 = double.parse((gain1 - sommeParier).toStringAsFixed(2));
           pBonus1 = double.parse((bonus1 / sommeParier * 100).toStringAsFixed(2));

           gain2 = double.parse((sommeParierMin * coteEquipe2).toStringAsFixed(2));
           bonus2 = double.parse((gain2 - sommeParier).toStringAsFixed(2));
           pBonus2 = double.parse((bonus2 / sommeParier * 100).toStringAsFixed(2));

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

              if((gain1 > sommeParier || gain2 > sommeParier) && pCote < 100 && coteEquipe1 < coteEquipe2 && pBonus2 > 0) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 150, horizontal: 50),
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
                                      "Mises à éffectuer",
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
                                        "Evenement pré-favorable :",
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
                                        "Evenement favorable :",
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
                                  SizedBox(height: 20),
                                  Center(
                                    child: Text(
                                      "Profit d'évenement favorable",
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'Roboto',
                                        color: Colors.black,
                                        // Changement de couleur pour une meilleure lisibilité
                                        decoration: TextDecoration
                                            .none, // Supprimer le soulignement
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
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
                                        "$gain1",
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
                                        "Bénéfice :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "$bonus1",
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
                                        "% bénéfice :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          // Changement de couleur pour une meilleure lisibilité (vert)
                                          decoration: TextDecoration
                                              .none, // Supprimer le soulignement
                                        ),
                                      ),
                                      SizedBox(width: 5,),
                                      Text("$pBonus1 %", style: TextStyle(
                                          color: Colors.green,
                                          fontSize: 12,
                                          decoration: TextDecoration.none),),],),

                                      SizedBox(height: 20),

                                      Center(
                                      child: Text(
                                      "Profit d'évenement pré-favorable",
                                      style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold, fontFamily: 'Roboto',
                                      color: Colors.black,
                                      // Changement de couleur pour une meilleure lisibilité
                                      decoration: TextDecoration
                                          .none, // Supprimer le soulignement
                                      ),
                                      ),
                                      ),
                                      SizedBox(height: 16),
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
                                      "$gain2",
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
                                        "Bénéfice :",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.black,
                                          decoration: TextDecoration.none,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        "$bonus2",
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
                                      "% bénéfice :",
                                      style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.black,
                                      // Changement de couleur pour une meilleure lisibilité (vert)
                                      decoration: TextDecoration
                                          .none, // Supprimer le soulignement
                                      ),
                                      ),
                                      SizedBox(width: 5,),
                                      Text("$pBonus2 %", style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 12,
                                      decoration: TextDecoration.none),
                                      )
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
              }
              if((gain1 > sommeParier || gain2 > sommeParier) && pCote < 100 && coteEquipe1 > coteEquipe2 && pBonus2 > 0) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 150, horizontal: 50),
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
                                          "Mises à éffectuer",
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
                                            "Evenement pré-favorable :",
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
                                            "Evenement favorable :",
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
                                      SizedBox(height: 20),
                                      Center(
                                        child: Text(
                                          "Profit d'évenement favorable",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Roboto',
                                            color: Colors.black,
                                            // Changement de couleur pour une meilleure lisibilité
                                            decoration: TextDecoration
                                                .none, // Supprimer le soulignement
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
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
                                            "$gain1",
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
                                            "Bénéfice :",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "$bonus1",
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
                                            "% bénéfice :",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              // Changement de couleur pour une meilleure lisibilité (vert)
                                              decoration: TextDecoration
                                                  .none, // Supprimer le soulignement
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Text("$pBonus1 %", style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              decoration: TextDecoration.none),),],),

                                      SizedBox(height: 20),

                                      Center(
                                        child: Text(
                                          "Profit d'évenement pré-favorable",
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold, fontFamily: 'Roboto',
                                            color: Colors.black,
                                            // Changement de couleur pour une meilleure lisibilité
                                            decoration: TextDecoration
                                                .none, // Supprimer le soulignement
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 16),
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
                                            "$gain2",
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
                                            "Bénéfice :",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              decoration: TextDecoration.none,
                                            ),
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            "$bonus2",
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
                                            "% bénéfice :",
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              // Changement de couleur pour une meilleure lisibilité (vert)
                                              decoration: TextDecoration
                                                  .none, // Supprimer le soulignement
                                            ),
                                          ),
                                          SizedBox(width: 5,),
                                          Text("$pBonus2 %", style: TextStyle(
                                              color: Colors.green,
                                              fontSize: 12,
                                              decoration: TextDecoration.none),
                                          )
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
                  }

              if(pCote > 100 || coteEquipe1 == coteEquipe2 || gain1 < sommeParier || gain2 < sommeParier){
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


  Widget _boiteDeDialogue(BuildContext, String nom, String email) {
    return SimpleDialog(
      contentPadding: EdgeInsets.zero,
      children: [
        Padding(
  padding: EdgeInsets.all(8),
  child: Column(
    children: [Text('Déconnexion',style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold,),
    ),
                      const SizedBox(height: 10),
      Text('Êtes-vous sûr(e) de vouloir vous déconnecter', style: TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.normal,
    ),
  ),
      Center(child: Text(' $nom ?'),),
    //Text('$email', style: Theme.of(context).textTheme.subtitle2),
      SizedBox(height: 25),
      Wrap(
  spacing: 10, // Espacement horizontal entre les boutons
  children: [
    ElevatedButton(
      onPressed: () async {
        FirebaseAuth _auth = FirebaseAuth.instance;
        await _auth.signOut();
        Navigator.pop(context);
      },
      child: Text('Oui'),
    ),

    SizedBox(width: 5), // Espace de 10 points entre les boutons

    ElevatedButton(
      onPressed: () {
        // Ajoutez l'action que vous souhaitez effectuer ici
        print('Bouton Annuler a été appuyé.');
        Navigator.pop(context);
      },
        child: Text('Non'),
                 ),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final utilisateur = Provider.of<Utilisateur>(context);

    GetCurrentUserData(idUtil: utilisateur.idUtil)
        .donneesUtil
        .forEach((snapshot) {
      this.nomUtil = snapshot.nomComplet;
      this.emailUtil = snapshot.email;
    });

    Widget _buildListItem(DocumentSnapshot document) {
      var lettreInitial = document['sport'][0];

      Widget affichageImage() {
        return CircleAvatar(
          backgroundColor: Colors.black,
          child: Text(
            lettreInitial,
            style: TextStyle(
              fontFamily: 'aAkarRumput',
              fontSize: 24,
              color: Colors.white,
            ),
          ),
        );
      }

      // Récupérer l'heure et les minutes depuis le document
      int heure = document['heure'];
      int minutes = document['minutes'];

      return Container(
        padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: couleurPredominante,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  affichageImage(),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '${document['nomEquipe1']} ',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            'x',
                            style: TextStyle(color: couleurIconeSelectionner),
                          ),
                          Text(
                            ' ${document['nomEquipe2']}',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      Text(
                        'Heure : ${heure.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    ' ${document['sommeParier']}',
                    style: TextStyle(color: couleurIconeSelectionner),
                  ),
                  Icon(
                    Icons.euro_symbol,
                    color: couleurIconeSelectionner,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: couleurDominante,
      appBar: AppBar(
        backgroundColor: couleurPredominante,
        title: Row(
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

            const SizedBox(width: 260),

            Expanded(
              child: IconButton(
                  onPressed: () => showDialog(
                      context: context,
                      builder: (context) =>
                          _boiteDeDialogue(context, nomUtil, emailUtil)),
                  icon: Icon(Icons.logout, size: 30,color: Colors.black)),
            ),
          ],
        ),
      ),

        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: BottomAppBar(
            color: couleurPredominante, // Couleur de fond personnalisée
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Premier élément (Home)
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
                      icon: Icon(Icons.home, size: 20, color: Colors.black),
                    ),
                  ],
                ),
                // Troisième élément (Add)
                IconButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AjoutPari()));
                  },
                  icon: Icon(Icons.add, size: 30, color: Colors.white),
                ),
                // Deuxième élément (Attach Money)
                IconButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => _boiteDeCalcule(context, coteTotal, sommeParierMax, sommeParierMin, gain1, gain2 , coteEquipe1, coteEquipe2, pCote1, pCote2, pCote, mise1, mise2, sommeParier, pBonus1, pBonus2, reste, pMise1, pMise2, mise ,bonus1)
                  ),
                  icon: Icon(Icons.attach_money, size: 30, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      // ignore: prefer_const_constructors
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('utilisateurs').doc(utilisateur.idUtil).collection('Paris').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(
                'Chargement...',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                "Appuyez sur le bouton + pour ajouter un pari",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) =>
                        _buildListItem(snapshot.data!.docs[index]),
                    ),
                  ),
                ],
              );
            }
          },
        ),
      );
    }
  }
