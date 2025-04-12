// lib/screens/edit_task_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditTaskScreen extends StatefulWidget {
  static const String route = '/edit_task';

  const EditTaskScreen({super.key});

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  String? dueDate;
  String? status;
  bool _isLoading = false;

  // Correspondance entre les anciennes valeurs et les nouvelles
  final Map<String, String> statusMapping = {
    'À faire': 'a faire',
    'En cours': 'en cours',
    'Terminé': 'termine',
    'a faire': 'a faire',
    'en cours': 'en cours',
    'termine': 'termine',
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // S'assurer que didChangeDependencies n'écrase pas les valeurs si elles ont déjà été initialisées
    if (title == null && description == null && dueDate == null && status == null) {
      final task = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      title = task['title'];
      description = task['description'];
      dueDate = task['dueDate'];
      status = statusMapping[task['status']] ?? 'a faire';
      print('Valeur initiale du statut dans didChangeDependencies : ${task['status']}');
      print('Valeur mappée du statut : $status');
    }
  }

  // Requête API pour modifier une tâche
  Future<Map<String, dynamic>> _updateTask(String taskId, Map<String, dynamic> task) async {
    final String apiUrl = 'http://localhost:5000/api/todos/$taskId'; // PUT /api/todos/:id

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task['title'],
          'tasks': task['description'],
          'status': task['status'],
        }),
      );

      print('Réponse de l\'API (statut HTTP) : ${response.statusCode}');
      print('Corps de la réponse : ${response.body}');

      if (response.statusCode == 200) {
        return {
          'success': true,
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de la modification de la tâche',
        };
      }
    } catch (e) {
      print('Erreur réseau dans _updateTask : $e');
      return {
        'success': false,
        'message': 'Erreur réseau : $e',
      };
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final task = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final updatedTask = {
        "title": title!,
        "description": description!,
        "status": status!,
        "dueDate": dueDate!,
      };
      print('Données envoyées à l\'API : $updatedTask');
      final response = await _updateTask(task['id'], updatedTask);
      setState(() {
        _isLoading = false;
      });
      if (response['success'] == true) {
        print('Mise à jour réussie, retour à l\'écran précédent.');
        Navigator.pop(context);
      } else {
        print('Échec de la mise à jour : ${response['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(dueDate!),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dueDate = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Task"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: title,
                onSaved: (value) => title = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un titre";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: description,
                onSaved: (value) => description = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer une description";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: status,
                onChanged: (value) {
                  setState(() {
                    status = value!;
                    print('Statut sélectionné dans le dropdown : $status');
                  });
                },
                onSaved: (value) {
                  status = value; // Sauvegarder la valeur lors de _formKey.currentState!.save()
                  print('Statut sauvegardé via onSaved : $status');
                },
                items: ["a faire", "en cours", "termine"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Status",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: "Due Date",
                  border: const OutlineInputBorder(),
                  hintText: dueDate,
                ),
                validator: (value) {
                  if (dueDate == null) {
                    return "Veuillez sélectionner une date d'échéance";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                      ),
                      child: const Text("Update Task"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}