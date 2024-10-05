import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les données JSON
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'login_page.dart';
import 'vehicules.dart';

class Chauffeur {
  final String nom;
  final String email;
  final String numeroTelephone;

  Chauffeur({required this.nom, required this.email, required this.numeroTelephone});

  // Méthode pour créer un chauffeur à partir d'un JSON
  factory Chauffeur.fromJson(Map<String, dynamic> json) {
    return Chauffeur(
      nom: json['nom'],
      email: json['email'],
      numeroTelephone: json['numeroTelephone'],
    );
  }
}

class ChauffeursPage extends StatefulWidget {
  const ChauffeursPage({super.key});

  @override
  _ChauffeursPageState createState() => _ChauffeursPageState();
}

class _ChauffeursPageState extends State<ChauffeursPage> {
  List<Chauffeur> _chauffeurs = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchChauffeurs();
  }

  // Méthode pour récupérer les chauffeurs depuis l'API
  Future<void> _fetchChauffeurs() async {
    final apiUrl = dotenv.env['API_URL']; 
    final response = await http.get(Uri.parse('$apiUrl/chauffeurs')); 

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _chauffeurs = data.map((chauffeurJson) => Chauffeur.fromJson(chauffeurJson)).toList();
      });
    } else {
      throw Exception('Échec de la récupération des chauffeurs');
    }
  }

  // Méthode pour lancer l'appel
  void _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Impossible d\'appeler ce numéro $phoneNumber';
    }
  }

  // Méthode pour envoyer un email
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      throw 'Impossible d\'envoyer un email à $email';
    }
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _goToHome(BuildContext context) {
    Navigator.pop(context); // Retour à la page d'accueil
  }

  void _goToVehicules(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const VehiculesPage()));
  }

  @override
  Widget build(BuildContext context) {
    final filteredChauffeurs = _chauffeurs.where((chauffeur) {
      return chauffeur.nom.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             chauffeur.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             chauffeur.numeroTelephone.contains(_searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chauffeurs'),
        backgroundColor: const Color.fromARGB(255, 63, 94, 148),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Rechercher par nom, email ou numéro de téléphone',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            // Liste des chauffeurs
            Expanded(
              child: filteredChauffeurs.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredChauffeurs.length,
                      itemBuilder: (context, index) {
                        final chauffeur = filteredChauffeurs[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(chauffeur.nom),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.email, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(chauffeur.email)),
                                    IconButton(
                                      icon: const Icon(Icons.send, color: Colors.blue),
                                      onPressed: () => _launchEmail(chauffeur.email),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(chauffeur.numeroTelephone)),
                                    IconButton(
                                      icon: const Icon(Icons.call, color: Colors.green),
                                      onPressed: () => _launchPhone(chauffeur.numeroTelephone),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      // Barre de navigation en bas de page avec le même design
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 63, 94, 148),
          borderRadius: BorderRadius.circular(20),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Accueil',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car),
              label: 'Véhicules',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Chauffeurs',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout),
              label: 'Déconnexion',
            ),
          ],
          currentIndex: 2, 
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          onTap: (index) {
            switch (index) {
              case 0:
                _goToHome(context);
                break;
              case 1:
                _goToVehicules(context);
                break;
              case 2:
            
                break;
              case 3:
                _goToLogin(context);
                break;
            }
          },
        ),
      ),
    );
  }
}
