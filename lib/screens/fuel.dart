import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; // Importation de la bibliothèque http
import 'dart:convert'; // Pour utiliser jsonEncode
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FuelPage extends StatefulWidget {
  const FuelPage({super.key});

  @override
  _FuelPageState createState() => _FuelPageState();
}

class _FuelPageState extends State<FuelPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _litersController = TextEditingController();
  final TextEditingController _matriculeController = TextEditingController();
  XFile? _image;

  List<Map<String, dynamic>> _submittedData = []; // Liste vide pour stocker les données
  final apiUrl = dotenv.env['API_URL']; 


  @override
  void initState() {
    super.initState();
    _fetchFuelData(); 
  }

  Future<void> _fetchFuelData() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl/getListeFuel')); // Remplacez par votre endpoint de récupération
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _submittedData = data.map((item) {
            return {
              'amount': item['amount'],
              'liters': item['liters'],
              'matricule': item['matricule'],
              'date': DateTime.parse(item['date']), // Assurez-vous que votre API renvoie une date au format ISO
              'email': item['email'],
            };
          }).toList();
        });
      } else {
        throw Exception('Échec de la récupération des données');
      }
    } catch (e) {
      print('Erreur: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la récupération des données.')),
      );
    }
  }

  Future<void> _addFuelData() async {
    String amount = _amountController.text;
    String liters = _litersController.text;
    String matricule = _matriculeController.text;

    if (amount.isNotEmpty && liters.isNotEmpty && matricule.isNotEmpty && _image != null) {
      final request = http.MultipartRequest('POST', Uri.parse('$apiUrl/addFuel')); 
      request.fields['amount'] = amount;
      request.fields['liters'] = liters;
      request.fields['matricule'] = matricule;
      

      // Ajout de l'image si disponible
      request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

      try {
        final response = await request.send();
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Facture ajoutée pour $amount TND et $liters litres')),
          );
          _amountController.clear();
          _litersController.clear();
          _matriculeController.clear();
          _image = null;

          _fetchFuelData(); 
        } else {
          throw Exception('Échec de l\'ajout de la facture');
        }
      } catch (e) {
        print('Erreur: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'ajout de la facture.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et ajouter une image.')),
      );
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    image ??= await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achat de Carburant'),
        backgroundColor: const Color.fromARGB(255, 63, 94, 148),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Montant (en TND)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _litersController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de litres',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Ajouter Facture'),
                ),
              ),

              const SizedBox(height: 20),

              if (_image != null) ...[
                SizedBox(
                  height: 150,
                  child: Image.file(
                    File(_image!.path),
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              Center(
                child: ElevatedButton(
                  onPressed: _addFuelData, 
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 63, 94, 148),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ).copyWith(
                    foregroundColor: const WidgetStatePropertyAll<Color>(Colors.white),
                  ),
                  child: const Text('Soumettre'),
                ),
              ),
              const SizedBox(height: 20),

              ExpansionTile(
                title: const Text(
                  'Liste des achats',
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
                          Text('Montant: ${data['amount']} TND'),
                          Text('Litres: ${data['liters']} litres'),
                          Text('Email: ${data['email']}'),
                          Text('Date et Heure: ${DateFormat('dd/MM/yyyy HH:mm').format(data['date'])}'),
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
