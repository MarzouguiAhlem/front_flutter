import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert'; // Pour convertir les données JSON
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  _ProfilPageState createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  String chauffeurName = '';
  String chauffeurEmail = '';
  String chauffeurPhone = '';
  String chauffeurImageUrl = '';

  @override
  void initState() {
    super.initState();
    fetchChauffeurData();
  }

  Future<void> fetchChauffeurData() async {
    final apiUrl = dotenv.env['API_URL']; 
    final response = await http.get(Uri.parse('$apiUrl/chauffeurs/id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        chauffeurName = data['name'];
        chauffeurEmail = data['email'];
        chauffeurPhone = data['phone'];
        chauffeurImageUrl = data['imageUrl'];
      });
    } else {
      throw Exception('Failed to load chauffeur data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: const Color.fromARGB(255, 63, 94, 148),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 150,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 62, 96, 160), Color.fromARGB(255, 130, 167, 228)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  top: 80,
                  child: CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 65,
                      backgroundImage: NetworkImage(chauffeurImageUrl.isNotEmpty ? chauffeurImageUrl : 'https://via.placeholder.com/150'),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Text(
              chauffeurName.isNotEmpty ? chauffeurName : 'Chargement...',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                // Logique pour envoyer un email
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email_outlined, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      chauffeurEmail.isNotEmpty ? chauffeurEmail : 'Chargement...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Logique pour passer un appel
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_outlined, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      chauffeurPhone.isNotEmpty ? chauffeurPhone : 'Chargement...',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
