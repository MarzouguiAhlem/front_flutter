import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';


class CleanPage extends StatefulWidget {
  const CleanPage({super.key});

  @override
  _CleanPageState createState() => _CleanPageState();
}

class _CleanPageState extends State<CleanPage> {
  final TextEditingController _matriculeController = TextEditingController();
  XFile? _beforeCleaningImage;
  XFile? _afterCleaningImage;

  final List<Map<String, dynamic>> _cleaningData = [];

  Future<void> _pickBeforeCleaningImage() async {
    final ImagePicker picker = ImagePicker();
    _beforeCleaningImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    _beforeCleaningImage ??= await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {});
  }

  Future<void> _pickAfterCleaningImage() async {
    final ImagePicker picker = ImagePicker();
    _afterCleaningImage = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );

    _afterCleaningImage ??= await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    setState(() {});
  }

  Future<void> _submit() async {
    String matricule = _matriculeController.text;

    if (matricule.isNotEmpty && _beforeCleaningImage != null && _afterCleaningImage != null) {
     
      _cleaningData.add({
        'matricule': matricule,
        'beforeImage': _beforeCleaningImage,
        'afterImage': _afterCleaningImage,
        'date': DateTime.now(),
      });

      // Appel API pour soumettre les données
      final response = await _submitCleaningData(matricule, _beforeCleaningImage!, _afterCleaningImage!);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nettoyage enregistré pour le véhicule $matricule.')),
        );

        _matriculeController.clear();
        setState(() {
          _beforeCleaningImage = null;
          _afterCleaningImage = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'enregistrement des données.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs et ajouter les photos.')),
      );
    }
  }

  Future<http.Response> _submitCleaningData(String matricule, XFile beforeImage, XFile afterImage) async {
    // URL de l'API
    final apiUrl = dotenv.env['API_URL']; 

    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/addClean'));
    request.fields['matricule'] = matricule;

    request.files.add(await http.MultipartFile.fromPath('beforeImage', beforeImage.path));
    request.files.add(await http.MultipartFile.fromPath('afterImage', afterImage.path));

    return await request.send().then((response) => http.Response.fromStream(response));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nettoyage de Véhicule'),
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
              
              // Bouton pour la photo avant nettoyage
              Center(
                child: ElevatedButton(
                  onPressed: _pickBeforeCleaningImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Photo avant nettoyage'),
                ),
              ),
              if (_beforeCleaningImage != null) ...[
                const SizedBox(height: 20),
                Image.file(
                  File(_beforeCleaningImage!.path),
                  height: 150,
                ),
              ],
              const SizedBox(height: 20),

              // Bouton pour la photo après nettoyage
              Center(
                child: ElevatedButton(
                  onPressed: _pickAfterCleaningImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Photo après nettoyage'),
                ),
              ),
              if (_afterCleaningImage != null) ...[
                const SizedBox(height: 20),
                Image.file(
                  File(_afterCleaningImage!.path),
                  height: 150,
                ),
              ],
              const SizedBox(height: 20),

              // Bouton Soumettre
              Center(
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 63, 94, 148),
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ).copyWith(
                    foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
                  ),
                  child: const Text('Soumettre'),
                ),
              ),
              const SizedBox(height: 20),

              ExpansionTile(
                title: const Text(
                  'Liste des nettoyages',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                children: _cleaningData.map((data) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Matricule: ${data['matricule']}'),
                          Text('Date: ${data['date']}'),
                          if (data['beforeImage'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Text('Image avant nettoyage:'),
                                Image.file(
                                  File(data['beforeImage']!.path),
                                  height: 100,
                                ),
                              ],
                            ),
                          if (data['afterImage'] != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10),
                                const Text('Image après nettoyage:'),
                                Image.file(
                                  File(data['afterImage']!.path),
                                  height: 100,
                                ),
                              ],
                            ),
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
