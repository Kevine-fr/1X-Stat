import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stat/pageAuth/connexion.dart';
import 'package:stat/pageAuth/controlAuth.dart';
import 'package:stat/pageAuth/inscription.dart';
import 'package:stat/pageAuth/liaisonAuth.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MonApp());
}

class MonApp extends StatelessWidget {
  const MonApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamProvider<Utilisateur?>.value(
      value: StreamProviderAuth().utilisateur,
      initialData: null, // Valeur initiale de l'utilisateur (null dans ce cas)
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(),
        home: Passerelle(),
      ),
    );
  }
}
