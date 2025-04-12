// lib/screens/home_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Ajoute cette importation
import 'package:todo_list_app/views/add_task_screen.dart';
import 'package:todo_list_app/views/edit_task_screen.dart';
import 'package:todo_list_app/views/login/login_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String route = '/home';

  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> tasks = [];
  String? userId; // Variable pour stocker userId

  @override
  void initState() {
    super.initState();
    _loadUserId(); // Charger userId au démarrage
  }

  // Charger userId depuis SharedPreferences
  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId');
    });
    if (userId != null) {
      _fetchTasks(userId!);
    } else {
      // Si userId n'est pas trouvé, rediriger vers LoginScreen
      Navigator.pushReplacementNamed(context, LoginScreen.route);
    }
  }

  // Requête API pour récupérer les tâches de l'utilisateur
  Future<void> _fetchTasks(String userId) async {
    const String baseUrl = 'http://localhost:5000/api/users';
    final String apiUrl = '$baseUrl/$userId/todos'; // GET /api/users/:id/todos

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          tasks = data.map((task) {
            return {
              "id": task['id'].toString(), // Convertir en String pour cohérence
              "userId": task['user_id'].toString(),
              "title": task['title'],
              "description": task['tasks'], // Le champ "tasks" correspond à "description" dans ton front
              "status": task['status'],
              "dueDate": task['updated_at'].toString().split('T')[0], // Extraire la date sans l'heure
              "createdAt": task['created_at'].toString().split('T')[0],
            };
          }).toList();
        });
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur lors de la récupération des tâches')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : $e')),
      );
    }
  }

  // Requête API pour supprimer une tâche
  Future<void> _deleteTask(String taskId) async {
    const String baseUrl = 'http://localhost:5000/api/todos';
    final String apiUrl = '$baseUrl/$taskId'; // DELETE /api/todos/:id

    try {
      final response = await http.delete(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        setState(() {
          tasks.removeWhere((task) => task['id'] == taskId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tâche supprimée avec succès')),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur lors de la suppression de la tâche')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur réseau : $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My To-Do List"),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Supprimer userId de SharedPreferences lors de la déconnexion
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('userId');
              Navigator.pushReplacementNamed(context, LoginScreen.route);
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: CircularProgressIndicator()) // Afficher un indicateur de chargement pendant le chargement de userId
          : tasks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(
                          task['title'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task['description']),
                            const SizedBox(height: 4),
                            Text(
                              "Status: ${task['status']}",
                              style: TextStyle(
                                color: task['status'] == "Done"
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            Text("Due: ${task['dueDate']}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  EditTaskScreen.route,
                                  arguments: task,
                                ).then((value) {
                                  if (userId != null) {
                                    _fetchTasks(userId!);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Confirmer"),
                                    content: const Text(
                                        "Voulez-vous supprimer cette tâche ?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Annuler"),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Supprimer"),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteTask(task['id']);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          if (userId != null) {
            Navigator.pushNamed(
              context,
              AddTaskScreen.route,
              arguments: userId, // Passer userId à AddTaskScreen
            ).then((value) {
              if (userId != null) {
                _fetchTasks(userId!);
              }
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Erreur : ID utilisateur non trouvé')),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}