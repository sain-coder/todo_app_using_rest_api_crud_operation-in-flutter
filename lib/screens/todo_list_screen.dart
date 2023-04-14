import 'dart:convert';

import 'package:flutter/material.dart';
import 'add_post.dart';
import 'package:http/http.dart' as http;

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {
  bool isLoading = true;
  List item = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //elevation: 0.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: fetchData,
          child: Visibility(
            visible: item.isNotEmpty,
            replacement: const Center(
              child: Text(
                'No Todo Items',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w500),
              ),
            ),
            child: ListView.builder(
                itemCount: item.length,
                padding:
                    const EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                itemBuilder: (context, index) {
                  final items = item[index] as Map;
                  final id = items['_id'] as String;
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xffffd082),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(items['title']),
                      subtitle: Text(items['description']),
                      trailing: PopupMenuButton(
                        onSelected: (value) {
                          if (value == 'edit') {
                            // here is code for edit
                            navigateToEdit(items);
                          } else if (value == 'delete') {
                            // here is code for delete
                            deleteById(id);
                          }
                        },
                        itemBuilder: (context) {
                          return [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ];
                        },
                      ),
                    ),
                  );
                }),
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          navigateToAdd();
        },
        backgroundColor: const Color(0xffffd082),
        label: const Text('Add Todo'),
      ),
    );
  }

// navigate to edit page
  Future<void> navigateToEdit(Map items) async {
    final routes = MaterialPageRoute(
        builder: (context) => AddTodo(
              todo: items,
            ));
    await Navigator.push(context, routes);
    setState(() {
      isLoading = true;
    });
    fetchData();
  }

//navigate
  Future<void> navigateToAdd() async {
    final routes = MaterialPageRoute(builder: (context) => const AddTodo());
    await Navigator.push(context, routes);
    setState(() {
      isLoading = true;
    });
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    final url = 'http://api.nstack.in/v1/todos?page=1&limit=10';
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map;
      final result = json['items'] as List;
      setState(() {
        item = result;
      });
    } else {}
    setState(() {
      isLoading = false;
    });
  }

  // for delete
  Future<void> deleteById(String id) async {
    final url = 'http://api.nstack.in/v1/todos/$id';
    final uri = Uri.parse(url);
    final response = await http.delete(uri);
    if (response.statusCode == 200) {
      // remove item from the list
      final filtered = item.where((element) => element['_id'] != id).toList();
      setState(() {
        item = filtered;
      });
      showSuccessMessage('Deletion Success');
    } else {
      showErrorMessage('Deletion Failed');
    }
  }

  void showSuccessMessage(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void showErrorMessage(String message) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.red,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
