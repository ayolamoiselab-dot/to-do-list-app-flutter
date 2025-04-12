// lib/screens/add_task_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Ajoute cette importation

class AddTaskScreen extends StatefulWidget {
  static const String route = '/add_task';

  const AddTaskScreen({super.key});

  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String? title;
  String? description;
  String? dueDate;
  String status = "a faire";
  bool _isLoading = false;
  String? userId; // Variable pour stocker userId

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Charger userId au démarrage
  }

  // Charger userId depuis SharedPreferences
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUserId = prefs.getString('userId');
    final passedUserId = ModalRoute.of(context)!.settings.arguments as String?;
    setState(() {
      userId = storedUserId ?? passedUserId; // Utiliser SharedPreferences en priorité, sinon les arguments
    });
    if (userId == null) {
      // Si userId n'est pas trouvé, rediriger vers LoginScreen
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Requête API pour ajouter une tâche
  Future<Map<String, dynamic>> _addTask(String userId, Map<String, dynamic> task) async {
    const String apiUrl = 'http://localhost:5000/api/todos'; // POST /api/todos

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': task['title'],
          'tasks': task['description'], // "description" dans le front correspond à "tasks" dans le backend
          'status': task['status'],
          'user_id': int.parse(userId), // Convertir userId en entier
          'group_name': 'default', // Valeur par défaut
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'taskId': data['insertId'].toString(),
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['error'] ?? 'Erreur lors de l\'ajout de la tâche',
        };
      }
    } catch (e) {
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
      if (userId != null) {
        final task = {
          "title": title!,
          "description": description!,
          "status": status,
          "dueDate": dueDate!,
          "createdAt": DateTime.now().toIso8601String(),
        };
        final response = await _addTask(userId!, task);
        setState(() {
          _isLoading = false;
        });
        if (response['success'] == true) {
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'])),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur : ID utilisateur non trouvé')),
        );
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
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
        title: const Text("Ajouter une tache"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                onSaved: (value) => title = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Veuillez entrer un titre";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Titre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
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
                  });
                },
                items: ["a faire", "en cours", "termine"]
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                decoration: const InputDecoration(
                  labelText: "Statut",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: "Date échéance",
                  border: const OutlineInputBorder(),
                  hintText: dueDate ?? "Selectionner une date",
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
                      child: const Text("Ajouter"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}