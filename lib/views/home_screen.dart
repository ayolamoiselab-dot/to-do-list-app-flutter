// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Récupérer l'ID utilisateur passé depuis LoginScreen
    final userId = ModalRoute.of(context)!.settings.arguments as String?;
    if (userId != null) {
      _fetchTasks(userId);
    }
  }

  // Simuler une requête API pour récupérer les tâches de l'utilisateur
  Future<void> _fetchTasks(String userId) async {
    // TODO: Remplacer par une vraie requête API (GET /tasks?userId=$userId)
    // Exemple d'URL : Uri.parse('https://api.todoapp.com/tasks?userId=$userId')
    // Attendu : Liste de tâches [{ "id": "1", "title": "Tâche 1", "description": "...", "status": "To Do", ... }]
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau
    setState(() {
      tasks = [
        {
          "id": "1",
          "userId": userId,
          "title": "Acheter des provisions",
          "description": "Lait, pain, œufs",
          "status": "To Do",
          "dueDate": "2025-04-15",
          "createdAt": "2025-04-09",
        },
        {
          "id": "2",
          "userId": userId,
          "title": "Réunion d'équipe",
          "description": "Préparer la présentation",
          "status": "Done",
          "dueDate": "2025-04-10",
          "createdAt": "2025-04-08",
        },
      ];
    });
  }

  // Simuler la suppression d'une tâche
  Future<void> _deleteTask(String taskId) async {
    // TODO: Remplacer par une vraie requête API (DELETE /tasks/$taskId)
    // Exemple d'URL : Uri.parse('https://api.todoapp.com/tasks/$taskId')
    // Attendu : { "success": true } ou { "success": false, "message": "Erreur" }
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau
    setState(() {
      tasks.removeWhere((task) => task['id'] == taskId);
    });
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
            onPressed: () {
              // TODO: Implémenter la déconnexion (supprimer le token, etc.)
              Navigator.pushReplacementNamed(context, LoginScreen.route);
            },
          ),
        ],
      ),
      body: tasks.isEmpty
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
                              // Rafraîchir la liste après modification
                              final userId = ModalRoute.of(context)!
                                  .settings
                                  .arguments as String?;
                              if (userId != null) {
                                _fetchTasks(userId);
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
                                content: const Text("Voulez-vous supprimer cette tâche ?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text("Annuler"),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
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
          Navigator.pushNamed(context, AddTaskScreen.route).then((value) {
            // Rafraîchir la liste après ajout
            final userId = ModalRoute.of(context)!.settings.arguments as String?;
            if (userId != null) {
              _fetchTasks(userId);
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}