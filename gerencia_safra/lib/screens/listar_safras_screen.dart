import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'cadastro_safra_screen.dart'; // Para editar a safra

class ListarSafrasScreen extends StatefulWidget {
  @override
  _ListarSafrasScreenState createState() => _ListarSafrasScreenState();
}

class _ListarSafrasScreenState extends State<ListarSafrasScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _safras = [];

  @override
  void initState() {
    super.initState();
    _carregarSafras();
  }

  Future<void> _carregarSafras() async {
    final safras = await _dbHelper.getSafras();
    setState(() {
      _safras = safras;
    });
  }

  void _deleteSafra(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir esta safra?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('Excluir'),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await _dbHelper.deleteSafra(id);
      _carregarSafras(); // Recarrega a lista após a exclusão
    }
  }

  void _editarSafra(Map<String, dynamic> safra) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroSafraScreen(
          safra: safra, // Passar a safra como parâmetro para edição
        ),
      ),
    ).then((value) => _carregarSafras());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safras Cadastradas'),
        backgroundColor: Colors.teal,
      ),
      body: _safras.isEmpty
          ? Center(child: Text('Nenhuma safra cadastrada'))
          : ListView.builder(
              itemCount: _safras.length,
              itemBuilder: (context, index) {
                final safra = _safras[index];
                return Card(
                  elevation: 4,
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                safra['nome_safra'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  color: Colors.teal[900],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text('Data de Plantio: ${safra['data_plantio']}'),
                              SizedBox(height: 4),
                              Text('Data de Colheita: ${safra['data_colheita']}'),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_red_eye, color: Colors.blueAccent),
                              onPressed: () {
                                _showSafraDetails(safra);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                _editarSafra(safra); // Chama a função de edição
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                _deleteSafra(safra['id']);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showSafraDetails(Map<String, dynamic> safra) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalhes da Safra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${safra['nome_safra']}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Data de Plantio: ${safra['data_plantio']}'),
                SizedBox(height: 8),
                Text('Data de Colheita: ${safra['data_colheita']}'),
                SizedBox(height: 8),
                Text('Área Plantada: ${safra['area_plantada'].toString()} hectares'),
                SizedBox(height: 8),
                Text('Quantidade Esperada: ${safra['quantidade_esperada'].toString()} toneladas'),
                SizedBox(height: 8),
                Text('Insumos Utilizados: ${safra['insumos_utilizados']}'),
                SizedBox(height: 8),
                Text('Custo da Safra: R\$ ${safra['custo_safra'].toString()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
