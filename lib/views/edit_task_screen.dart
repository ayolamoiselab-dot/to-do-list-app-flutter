// lib/screens/edit_task_screen.dart
import 'package:flutter/material.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final task = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    title = task['title'];
    description = task['description'];
    dueDate = task['dueDate'];
    status = task['status'];
  }

  // Simuler une requête API pour modifier une tâche
  Future<Map<String, dynamic>> _updateTask(String taskId, Map<String, dynamic> task) async {
    // TODO: Remplacer par une vraie requête API (PUT /tasks/$taskId)
    // Exemple d'URL : Uri.parse('https://api.todoapp.com/tasks/$taskId')
    // Body : { "title": task['title'], "description": task['description'], "status": task['status'], "dueDate": task['dueDate'] }
    // Attendu : { "success": true } ou { "success": false, "message": "Erreur" }
    await Future.delayed(const Duration(seconds: 1)); // Simuler un délai réseau
    return {
      "success": true,
    };
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
      final response = await _updateTask(task['id'], updatedTask);
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