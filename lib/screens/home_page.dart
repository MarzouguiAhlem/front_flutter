import 'package:flutter/material.dart';
import 'login_page.dart'; 
import 'profil.dart'; 
import 'fuel.dart'; 
import 'clean.dart'; 
import 'suivi.dart'; 
import 'vehicules.dart'; 
import 'chauffeurs.dart'; 
import 'package:http/http.dart' as http; // Pour les requêtes HTTP
import 'package:flutter_dotenv/flutter_dotenv.dart';


class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // Méthodes de navigation vers d'autres pages
  void _goToProfile(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilPage()));
  }

  void _goToCarburant(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const FuelPage()));
  }

  void _goToNettoyage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const CleanPage()));
  }

  void _goToSuivi(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const SuiviPage()));
  }

  void _goToLogin(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
  }

  void _goToVehicules(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const VehiculesPage()));
  }

  void _goToChauffeurs(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ChauffeursPage()));
  }

  // Méthode pour déconnecter l'utilisateur
  Future<void> _logout(BuildContext context) async {
    final apiUrl = dotenv.env['API_URL']; 
    final response = await http.post(
      Uri.parse('$apiUrl/logout'), // Remplacez par l'URL de votre API de déconnexion
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer votre_token', // Ajoutez votre méthode d'authentification ici
      },
    );

    if (response.statusCode == 200) {
      // Déconnexion réussie
      _goToLogin(context);
    } else {
      // Gérer l'erreur de déconnexion
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la déconnexion. Veuillez réessayer.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 0), 
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 63, 94, 148), 
            borderRadius: BorderRadius.circular(0), 
          ),
          child: AppBar(
            title: const Text('Accueil'),
            backgroundColor: Colors.transparent, 
            elevation: 0, 
            actions: [
              IconButton(
                icon: const Icon(Icons.person, color: Colors.grey), 
                onPressed: () => _goToProfile(context),
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 80), 
            const Text(
              'Bienvenue !',
              style: TextStyle(
                fontSize: 28,
                color: Color.fromARGB(255, 181, 182, 233),
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(), 
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _goToCarburant(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: const Color.fromARGB(255, 205, 233, 219),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Carburant',
                    style: TextStyle(fontSize: 18), 
                  ),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => _goToNettoyage(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    backgroundColor: const Color.fromARGB(255, 207, 178, 209),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text(
                    'Nettoyage',
                    style: TextStyle(fontSize: 18), 
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _goToSuivi(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 20),
                backgroundColor: const Color.fromARGB(255, 248, 224, 193),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                'Suivi quotidien',
                style: TextStyle(fontSize: 18),
              ),
            ),
            const Spacer(), 
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
          currentIndex: 0, 
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(color: Colors.grey),
          onTap: (index) {
            switch (index) {
              case 0:
                break; 
              case 1:
                _goToVehicules(context);
                break;
              case 2:
                _goToChauffeurs(context);
                break;
              case 3:
                _logout(context); 
                break;
            }
          },
        ),
      ),
    );
  }
}
