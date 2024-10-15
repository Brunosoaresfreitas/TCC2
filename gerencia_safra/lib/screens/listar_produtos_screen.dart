import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'detalhes_produto_screen.dart'; // Tela de detalhes do produto
import 'cadastro_produto_screen.dart'; // Tela de edição do produto

class ListarProdutosScreen extends StatefulWidget {
  @override
  _ListarProdutosScreenState createState() => _ListarProdutosScreenState();
}

class _ListarProdutosScreenState extends State<ListarProdutosScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _produtos = [];
  bool _isLoading = true; // Para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    final produtos = await _dbHelper.getProdutosEstoque();
    List<Map<String, dynamic>> produtosComSaldo = [];

    if (produtos.isNotEmpty) {
      for (var produto in produtos) {
        double saldo = await _dbHelper.getSaldoProduto(produto['id']);  // Obter saldo atual

        // Cria uma cópia mutável do produto e adiciona o saldo
        var produtoComSaldo = Map<String, dynamic>.from(produto);
        produtoComSaldo['saldo'] = saldo;
        produtosComSaldo.add(produtoComSaldo);
      }
    }
    
    setState(() {
      _produtos = produtosComSaldo;
      _isLoading = false; // Carregamento concluído
    });
  }

  void _deleteProduto(int id) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir este produto?'),
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
      await _dbHelper.deleteProduto(id);
      _carregarProdutos(); // Recarrega a lista após a exclusão
    }
  }

  void _editarProduto(Map<String, dynamic> produto) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CadastroProdutoScreen(produto: produto),
      ),
    ).then((value) => _carregarProdutos());
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Produtos no Estoque'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator()) // Exibe carregando enquanto busca os produtos
            : _produtos.isEmpty
                ? Center(
                    child: Text(
                      'Nenhum produto cadastrado.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _produtos.length,
                    itemBuilder: (context, index) {
                      final produto = _produtos[index];
                      return Card(
                        elevation: 4,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      produto['nome_produto'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color: Colors.teal[900],
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                        'Saldo: ${produto['saldo'].toStringAsFixed(2)} unidades'),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.remove_red_eye,
                                        color: Colors.blueAccent),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              DetalhesProdutoScreen(
                                                  produtoId: produto['id']),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.green),
                                    onPressed: () {
                                      _editarProduto(produto);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () {
                                      _deleteProduto(produto['id']);
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
      ),
    );
  }
}
