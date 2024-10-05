import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SuiviPage extends StatefulWidget {
  const SuiviPage({super.key});

  @override
  _SuiviPageState createState() => _SuiviPageState();
}

class _SuiviPageState extends State<SuiviPage> {
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _kilometrageController = TextEditingController();
  final TextEditingController _carburantController = TextEditingController();
  XFile? _proofImage;  // Pour stocker l'image de preuve
  List<dynamic> _submittedData = []; // Liste des suivis récupérés

  @override
  void initState() {
    super.initState();
    _getListSuivi(); // Récupérer la liste des suivis au démarrage
  }

  Future<void> _pickProofImage() async {
    final ImagePicker picker = ImagePicker();
    _proofImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    _proofImage ??= await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {}); // Met à jour l'état pour refléter l'image sélectionnée
  }

  Future<void> _addSuivi() async {
    String matricule = _matriculeController.text;
    String kilometrage = _kilometrageController.text;
    String carburant = _carburantController.text;

    if (matricule.isNotEmpty && kilometrage.isNotEmpty && carburant.isNotEmpty && _proofImage != null) {
       final apiUrl = dotenv.env['API_URL']; 
      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/addSuivi'));
      request.fields['matricule'] = matricule;
      request.fields['kilometrage'] = kilometrage;
      request.fields['carburant'] = carburant;

      // Ajoutez l'image de preuve
      if (_proofImage != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'proofImage', 
          _proofImage!.path,
        ));
      }

      var response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suivi enregistré pour $matricule avec $kilometrage km et $carburant litres.')),
        );
        _matriculeController.clear();
        _kilometrageController.clear();
        _carburantController.clear();
        setState(() {
          _proofImage = null;
        });
        _getListSuivi(); // Récupérer la liste après l'ajout
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement du suivi.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et ajouter la preuve.')),
      );
    }
  }

  Future<void> _getListSuivi() async {
     final apiUrl = dotenv.env['API_URL']; 
    final response = await http.get(Uri.parse('$apiUrl/getListSuivi'));

    if (response.statusCode == 200) {
      setState(() {
        _submittedData = json.decode(response.body); // Remplacez par la structure appropriée
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération des suivis.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suivi de Véhicule'),
        backgroundColor: const Color.fromARGB(255, 63, 94, 148),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _matriculeController,
                decoration: const InputDecoration(
                  labelText: 'Matricule du véhicule',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _kilometrageController,
                decoration: const InputDecoration(
                  labelText: 'Kilométrage (en km)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _carburantController,
                decoration: const InputDecoration(
                  labelText: 'Niveau de carburant (en litres)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickProofImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: const Text('Ajouter Preuve'),
              ),
              if (_proofImage != null) ...[
                const SizedBox(height: 20),
                Image.file(
                  File(_proofImage!.path),
                  height: 150, // Hauteur de l'image
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addSuivi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 63, 94, 148),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ).copyWith(
                  foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                child: const Text('Soumettre'),
              ),
              const SizedBox(height: 20),

              // ExpansionTile pour afficher la liste des suivis
              ExpansionTile(
                title: const Text(
                  'Liste des suivis',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: _submittedData.map((data) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Matricule: ${data['matricule']}'),
                          Text('Kilométrage: ${data['kilometrage']} km'),
                          Text('Niveau de carburant: ${data['carburant']} litres'),
                          Text('Email: ${data['email']}'),
                          Text('Date et Heure: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(data['date']))}'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
