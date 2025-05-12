import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class Pet {
  final String nome;
  final String raca;
  final String sexo;

  Pet({required this.nome, required this.raca, required this.sexo});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetAgenda',
      theme: ThemeData.dark(),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/pets': (context) => PetListScreen(),
        '/form': (context) => PetFormScreen(),
        '/confirmation': (context) => ConfirmationScreen(),
      },
    );
  }
}

// ------------------ TELA 1: LOGIN ------------------

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nomeUsuario = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome do usuário'),
                validator: (value) => value!.isEmpty ? 'Digite seu nome' : null,
                onSaved: (value) => _nomeUsuario = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Entrar'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Navigator.pushReplacementNamed(
                      context,
                      '/pets',
                      arguments: {'nomeUsuario': _nomeUsuario, 'pets': <Pet>[]},
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------ TELA 2: LISTA DE PETS ------------------

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  List<Pet> _pets = [];
  late String _nomeUsuario;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map;
    _nomeUsuario = args['nomeUsuario'];
    _pets = args['pets'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pets de $_nomeUsuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _pets.isEmpty
            ? Center(child: Text('Nenhum pet cadastrado.'))
            : SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Nome')),
                    DataColumn(label: Text('Raça')),
                    DataColumn(label: Text('Sexo')),
                  ],
                  rows: _pets.map((pet) {
                    return DataRow(cells: [
                      DataCell(Text(pet.nome)),
                      DataCell(Text(pet.raca)),
                      DataCell(Text(pet.sexo)),
                    ]);
                  }).toList(),
                ),
              ),
      ),
      floatingActionButton: ElevatedButton(
        child: Text('Cadastrar Novo Pet'),
        onPressed: () async {
          final Pet? novoPet = await Navigator.pushNamed(
            context,
            '/form',
          ) as Pet?;

          if (novoPet != null) {
            setState(() {
              _pets.add(novoPet);
            });
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

// ------------------ TELA 3: FORMULÁRIO DE PET ------------------

class PetFormScreen extends StatefulWidget {
  @override
  _PetFormScreenState createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _formKey = GlobalKey<FormState>();
  String _nome = '';
  String _raca = '';
  String _sexo = 'Macho';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastrar Pet')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Digite o nome' : null,
                onSaved: (value) => _nome = value!,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Raça'),
                validator: (value) => value!.isEmpty ? 'Digite a raça' : null,
                onSaved: (value) => _raca = value!,
              ),
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: InputDecoration(labelText: 'Sexo'),
                items: ['Macho', 'Fêmea']
                    .map((sexo) => DropdownMenuItem(
                          value: sexo,
                          child: Text(sexo),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _sexo = value!),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                child: Text('Cadastrar'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    Pet novoPet = Pet(nome: _nome, raca: _raca, sexo: _sexo);
                    Navigator.pushNamed(
                      context,
                      '/confirmation',
                      arguments: novoPet,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------ TELA 4: CONFIRMAÇÃO ------------------

class ConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Pet pet = ModalRoute.of(context)!.settings.arguments as Pet;

    return Scaffold(
      appBar: AppBar(title: Text('Cadastro Confirmado')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Pet "${pet.nome}" cadastrado com sucesso!'),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Voltar à Lista'),
              onPressed: () {
                Navigator.pop(context); // Fecha tela de confirmação
                Navigator.pop(context, pet); // Retorna com pet à tela de lista
              },
            ),
          ],
        ),
      ),
    );
  }
}
