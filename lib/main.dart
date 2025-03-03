import 'package:flutter/material.dart';
import 'DatabaseHelper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> users = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final data = await Databasehelper.instance.getUsers();
    setState(() {
      users = data;
    });
  }

  Future<void> addUser(String name, String email) async {
    await Databasehelper.instance.insertUser(name, email);
    fetchUsers();
  }

  Future<void> updateUser(int id, String name, String email) async {
    await Databasehelper.instance.updateUser(id, name, email);
    fetchUsers();
  }

  Future<void> deleteUser(int id) async {
    await Databasehelper.instance.deleteUser(id);
    fetchUsers();
  }

  void showEditDialog(BuildContext context, Map<String, dynamic> user) {
    TextEditingController nameController = TextEditingController(
      text: user['name'],
    );
    TextEditingController emailController = TextEditingController(
      text: user['email'],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit User"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                updateUser(
                  user['id'],
                  nameController.text,
                  emailController.text,
                );
                Navigator.pop(context); // Close dialog after update
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "SQLite CRUD in Flutter",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: "Name"),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: "Email"),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    addUser(nameController.text, emailController.text);
                    nameController.clear();
                    emailController.clear();
                  },
                  child: Text("Add User"),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['name']),
                  subtitle: Text(user['email']),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showEditDialog(context, user);
                          // setState(() {
                          //   nameController.text = user['name'];
                          //   emailController.text = user['email'];
                          // });
                          //
                          // updateUser(
                          //   user['id'],
                          //   nameController.text,
                          //   emailController.text,
                          // );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteUser(user['id']),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
