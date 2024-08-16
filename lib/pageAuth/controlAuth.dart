import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stat/pageAuth/liaisonAuth.dart';
import 'package:stat/pageCrud/acceuil.dart';

class Utilisateur {
  String idUtil;

  Utilisateur({required this.idUtil});
}


class DonneesUtil {
  String email;
  String nomComplet;

  DonneesUtil({required this.email, required this.nomComplet});
}

class StreamProviderAuth {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //Création d'objet utilisateur provenant de la classe User
  Utilisateur? _utilisateurDeFirebaseUser(User? user) {
    return user != null ? Utilisateur(idUtil: user.uid) : null;
  }

  //La diffusion de l'auth de l'utilisateur

  Stream<Utilisateur?> get utilisateur {
    return _auth.authStateChanges().map(_utilisateurDeFirebaseUser);
  }
}

class Passerelle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final utilisateur = Provider.of<Utilisateur?>(context);

    //Si l'utilisateur existe on le dirige directement sur la page d'accueil sinon sur celle de l'authentification
    if (utilisateur == null) {
      return LiaisonPageAuth();
    } else {
      return Acceuil();
    }
  }
}

class GetCurrentUserData {
  String idUtil;
  GetCurrentUserData({required this.idUtil});

  //La référence de la collection utilisateur
  final CollectionReference collectionUtil =
      FirebaseFirestore.instance.collection('utilisateurs');
  DonneesUtil _donneesUtilDeSnapshot(DocumentSnapshot snapshot) {
    return DonneesUtil(
      nomComplet: snapshot['nomComplet'],
      email: snapshot['emailUtil'],
    );
  }

  //Obtenir les données d'utilisateur en stream

  Stream<DonneesUtil> get donneesUtil {
    return collectionUtil.doc(idUtil).snapshots().map(_donneesUtilDeSnapshot);
  }
}
