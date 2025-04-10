// lib/screens/add_task_screen.dart
import 'package:flutter/material.dart';

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
  String status = "To Do";
  bool _isLoading = false;

  // Simuler une requête API pour ajouter une tâche
  Future<Map<String, dynamic>> _addTask(String userId, Map<String, dynamic> task) async {
    // TODO: Remplacer par une vraie requête API (POST /tasks)
    // Exemple d'URL : Uri.parse('https://api.todoapp.com/tasks')
    // Body : { "userId": userId, "title": task['title'], "description": task['description'], "status": task['status'], "dueDate": task['dueDate'] }
    // Attendu : { "success": true, "taskId": "123" } ou { "success": false, "message": "Erreur" }
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau
    return {
      "success": true,
      "taskId": "123",
    };
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      final userId = ModalRoute.of(context)!.settings.arguments as String?;
      if (userId != null) {
        final task = {
          "title": title!,
          "description": description!,
          "status": status,
          "dueDate": dueDate!,
          "createdAt": DateTime.now().toIso8601String(),
        };
        final response = await _addTask(userId, task);
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
        title: const Text("Add Task"),
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
                  labelText: "Title",
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
                items: ["To Do", "In Progress", "Done"]
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
                  hintText: dueDate ?? "Select a date",
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
                      child: const Text("Add Task"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}