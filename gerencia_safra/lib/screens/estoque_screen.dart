import 'package:flutter/material.dart';
import 'cadastro_produto_screen.dart';  // Tela de cadastro de produto
import 'listar_produtos_screen.dart';  // Tela de listagem de produtos
import '../screens/cadastro_entrada_produto_estoque_screen.dart';  // Tela de cadastro de entrada de produto
import '../screens/cadastro_saida_produto_estoque_screen.dart';  // Tela de cadastro de saída de produto

class EstoqueScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerenciamento de Estoque'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo ao Estoque',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Escolha uma das opções abaixo para continuar:',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Layout em duas colunas
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildMenuBox(
                    context,
                    color: Colors.greenAccent,
                    icon: Icons.add_box_outlined,
                    label: 'Cadastrar Produto',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastroProdutoScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.blueAccent,
                    icon: Icons.list_alt_outlined,
                    label: 'Visualizar Produtos',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListarProdutosScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.orangeAccent,
                    icon: Icons.input_outlined,
                    label: 'Entrada de Produto',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                CadastroEntradaProdutoScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.redAccent,
                    icon: Icons.output_outlined,
                    label: 'Saída de Produto',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastroSaidaProdutoScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuBox(BuildContext context,
      {required Color color,
      required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 40,
              color: Colors.white,
            ),
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
