import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'chauffeurs.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les données JSON
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Vehicule {
  final String marque;
  final String modele;
  final String matricule;

  Vehicule({required this.marque, required this.modele, required this.matricule});

  factory Vehicule.fromJson(Map<String, dynamic> json) {
    return Vehicule(
      marque: json['marque'],
      modele: json['modele'],
      matricule: json['matricule'],
    );
  }
}

class VehiculesPage extends StatefulWidget {
  const VehiculesPage({super.key});

  @override
  _VehiculesPageState createState() => _VehiculesPageState();
}

class _VehiculesPageState extends State<VehiculesPage> {
  List<Vehicule> _vehicules = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchVehicules();
  }

  Future<void> _fetchVehicules() async {
    try {
      final apiUrl = dotenv.env['API_URL']; 
      final response = await http.get(Uri.parse('$apiUrl/vehicules')); 
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _vehicules = data.map((json) => Vehicule.fromJson(json)).toList();
        });
      } else {
        throw Exception('Échec de la récupération des véhicules');
      }
    } catch (e) {
      print(e); 
    }
  }

  void _ajouterVehicule(String marque, String modele, String matricule) {
    setState(() {
      _vehicules.add(Vehicule(marque: marque, modele: modele, matricule: matricule));
    });
    Navigator.pop(context); 
  }

  void _showAddVehiculeDialog() {
    String marque = '';
    String modele = '';
    String matricule = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter un Véhicule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  marque = value;
                },
                decoration: const InputDecoration(labelText: 'Marque'),
              ),
              TextField(
                onChanged: (value) {
                  modele = value;
                },
                decoration: const InputDecoration(labelText: 'Modèle'),
              ),
              TextField(
                onChanged: (value) {
                  matricule = value;
                },
                decoration: const InputDecoration(labelText: 'Matricule'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialogue
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (marque.isNotEmpty && modele.isNotEmpty && matricule.isNotEmpty) {
                  _ajouterVehicule(marque, modele, matricule);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _goToHome(BuildContext context) {
    Navigator.pop(context); // Retour à la page d'accueil
  }

  void _goToChauffeurs(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChauffeursPage()));
  }

  @override
  Widget build(BuildContext context) {
    final filteredVehicules = _vehicules.where((vehicule) {
      return vehicule.matricule.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Véhicules'),
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
                labelText: 'Rechercher par matricule',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 20),
            // Liste des véhicules
            Expanded(
              child: ListView.builder(
                itemCount: filteredVehicules.length,
                itemBuilder: (context, index) {
                  final vehicule = filteredVehicules[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text('${vehicule.marque} ${vehicule.modele}'),
                      subtitle: Text('Matricule: ${vehicule.matricule}'),
                    ),
                  );
                },
              ),
            ),
            // Bouton d'ajout de véhicule
            ElevatedButton.icon(
              onPressed: _showAddVehiculeDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 134, 218, 177),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              icon: const Icon(Icons.add, size: 24),
              label: const Text('Ajouter un Véhicule'),
            ),
          ],
        ),
      ),
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
          currentIndex: 1, // Indice pour la page actuelle
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
                // Rester sur la page des véhicules
                break;
              case 2:
                _goToChauffeurs(context);
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
