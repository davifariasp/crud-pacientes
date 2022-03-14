import 'package:flutter/material.dart';
import '../database/db.dart';

enum SingingCharacter { m, f }

class ListaPacientes extends StatefulWidget {
  const ListaPacientes({Key? key}) : super(key: key);

  @override
  State<ListaPacientes> createState() => _ListaPacientesState();
}

class _ListaPacientesState extends State<ListaPacientes> {
  List<Map<String, dynamic>> _pacientes = [];

  bool _isLoading = true;
  // Pega os dados do banco de dados
  void _refreshPacientes() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _pacientes = data;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshPacientes(); // Carrega os pacientes
  }

  SingingCharacter? _character = SingingCharacter.f;

  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _idadeController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();

  void _showForm(int? id) async {
    if (id != null) {
      // id == null -> cria novo paciente
      // id != null -> altera paciente já existente
      final existingPaciente =
          _pacientes.firstWhere((element) => element['id'] == id);
      _nomeController.text = existingPaciente['nome'];
      _idadeController.text = '${existingPaciente['idade']}';
      _sexoController.text = existingPaciente['sexo'];
    }

    showModalBottomSheet(
        context: context,
        elevation: 5,
        isScrollControlled: true,
        builder: (_) => Container(
              padding: EdgeInsets.only(
                top: 15,
                left: 15,
                right: 15,
                // this will prevent the soft keyboard from covering the text fields
                bottom: MediaQuery.of(context).viewInsets.bottom + 120,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _nomeController,
                    decoration: const InputDecoration(hintText: 'Nome'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _idadeController,
                    decoration: const InputDecoration(hintText: 'Idade'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextField(
                    controller: _sexoController,
                    decoration: const InputDecoration(hintText: 'Sexo'),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: <Widget>[
                      ListTile(
                        title: const Text('Masculino'),
                        leading: Radio<SingingCharacter>(
                          value: SingingCharacter.m,
                          groupValue: _character,
                          onChanged: (SingingCharacter? value) {
                            setState(() {
                              _character = SingingCharacter.f;
                              print('mudou');
                            });
                          },
                        ),
                      ),
                      ListTile(
                        title: const Text('Feminino'),
                        leading: Radio<SingingCharacter>(
                          value: SingingCharacter.f,
                          groupValue: _character,
                          onChanged: (SingingCharacter? value) {
                            setState(() {
                              _character = SingingCharacter.m;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Save new journal
                      if (id == null) {
                        await _addItem();
                      }

                      if (id != null) {
                        await _updateItem(id);
                      }

                      // Clear the text fields
                      _nomeController.text = '';
                      _idadeController.text = '';
                      _sexoController.text = '';

                      // Close the bottom sheet
                      Navigator.of(context).pop();
                    },
                    child: Text(id == null ? 'Criar' : 'Atualizar'),
                  )
                ],
              ),
            ));
  }

  // Adicionando novo paciente
  Future<void> _addItem() async {
    await SQLHelper.createItem(_nomeController.text,
        int.parse(_idadeController.text), _sexoController.text);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Paciente adicionado com sucesso!'),
    ));
    _refreshPacientes();
  }

  // Alterando paciente
  Future<void> _updateItem(int id) async {
    await SQLHelper.updateItem(id, _nomeController.text,
        int.parse(_idadeController.text), _sexoController.text);
    _refreshPacientes();
  }

  // Deletando paciente
  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Paciente removido com sucesso!'),
    ));
    _refreshPacientes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista Pacientes'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView.builder(
              itemCount: _pacientes.length,
              itemBuilder: (context, index) => Card(
                color: Colors.green[200],
                margin: const EdgeInsets.all(10),
                child: ListTile(
                    title: Text(_pacientes[index]['nome']),
                    subtitle: Text(
                        'Sexo ${_pacientes[index]['sexo']}, ${_pacientes[index]['idade']} anos'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(_pacientes[index]['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteItem(_pacientes[index]['id']),
                          ),
                        ],
                      ),
                    )),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showForm(null),
      ),
    );
  }
}
