import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'cadastro_terra_screen.dart';

class ListarTerrasScreen extends StatefulWidget {
  @override
  _ListarTerrasScreenState createState() => _ListarTerrasScreenState();
}

class _ListarTerrasScreenState extends State<ListarTerrasScreen> {
  List<Map<String, dynamic>> _terras = [];

  @override
  void initState() {
    super.initState();
    _loadTerras();
  }

  void _loadTerras() async {
    final terras = await DatabaseHelper().getTerras();
    setState(() {
      _terras = terras;
    });
  }

  void _deleteTerra(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir esta terra?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Não exclui
            },
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Exclui
            },
            child: Text('Excluir'),
            style: TextButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      await DatabaseHelper().deleteTerra(id);
      _loadTerras(); // Recarrega a lista após a exclusão
    }
  }

  void _editarTerra(Map<String, dynamic> terra) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroTerraScreen(terra: terra), // Passa a terra para edição
      ),
    ).then((value) => _loadTerras());
  }

  void _showTerraDetails(Map<String, dynamic> terra) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detalhes da Terra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nome: ${terra['nome']}', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Área: ${terra['area'].toString()} hectares'),
                SizedBox(height: 8),
                Text('Tipo de Solo: ${terra['tipo_solo']}'),
                SizedBox(height: 8),
                Text('Localização: ${terra['localizacao']}'),
                SizedBox(height: 8),
                Text('Data de Cadastro: ${terra['data_cadastro']}'),
                SizedBox(height: 8),
                Text('Observações: ${terra['observacoes']}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha a mini tela
              },
              child: Text('Fechar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terras Cadastradas'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: _terras.length,
        itemBuilder: (context, index) {
          final terra = _terras[index];
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
                  // Exibição das informações da terra
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          terra['nome'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.teal[900],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text('Área: ${terra['area'].toString()} hectares'),
                        SizedBox(height: 4),
                        Text('Tipo de Solo: ${terra['tipo_solo']}'),
                      ],
                    ),
                  ),
                  // Ícones de visualização, edição e exclusão
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_red_eye, color: Colors.blueAccent),
                        onPressed: () => _showTerraDetails(terra), // Exibe os detalhes da terra
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _editarTerra(terra), // Permite editar a terra
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => _deleteTerra(terra['id']), // Exclui a terra
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
}
