import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class DetalhesProdutoScreen extends StatefulWidget {
  final int produtoId;

  DetalhesProdutoScreen({required this.produtoId});

  @override
  _DetalhesProdutoScreenState createState() => _DetalhesProdutoScreenState();
}

class _DetalhesProdutoScreenState extends State<DetalhesProdutoScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<String, dynamic>? _produto;
  List<Map<String, dynamic>> _movimentacoes = [];

  @override
  void initState() {
    super.initState();
    _carregarProduto();
    _carregarMovimentacoes();
  }

  Future<void> _carregarProduto() async {
    final produtos = await _dbHelper.getProdutosEstoque();
    setState(() {
      _produto = produtos.firstWhere((p) => p['id'] == widget.produtoId, orElse: () => {});
    });
  }

  Future<void> _carregarMovimentacoes() async {
    final movimentacoes = await _dbHelper.getMovimentacoesEstoque(widget.produtoId);
    setState(() {
      _movimentacoes = movimentacoes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_produto != null ? _produto!['nome_produto'] : 'Detalhes do Produto'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _produto != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações do Produto:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Nome: ${_produto!['nome_produto']}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Descrição: ${_produto!['descricao']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Unidade de Medida: ${_produto!['unidade_medida']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Local de Armazenamento: ${_produto!['local_armazenamento']}',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Movimentações do Produto:',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _movimentacoes.length,
                      itemBuilder: (context, index) {
                        final mov = _movimentacoes[index];
                        return Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              mov['tipo_movimentacao'] == 'entrada'
                                  ? 'Entrada de Produto'
                                  : 'Saída de Produto',
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Data: ${mov['data_movimentacao']}'),
                                Text('Quantidade: ${mov['quantidade']} ${_produto!['unidade_medida']}'),
                                if (mov['origem'] != null)
                                  Text('Origem/Destino: ${mov['origem']}'),
                                if (mov['motivo'] != null)
                                  Text('Motivo: ${mov['motivo']}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
            : Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
