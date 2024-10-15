import 'package:flutter/material.dart';
import 'cadastro_terra_screen.dart';
import '../screens/cadastro_safra_screen.dart';
import 'listar_terras_screen.dart';
import 'listar_safras_screen.dart'; 
import 'estoque_screen.dart';  // Importar a tela de Estoque

class MenuPrincipalScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu Principal'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Olá, bem-vindo!',
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
                crossAxisCount: 2, // Define o layout em duas colunas
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildMenuBox(
                    context,
                    color: Colors.greenAccent,
                    icon: Icons.landscape_outlined,
                    label: 'Listar Terras',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListarTerrasScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.blueAccent,
                    icon: Icons.add_location_alt_outlined,
                    label: 'Cadastrar Terra',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastroTerraScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.orangeAccent,
                    icon: Icons.spa_outlined,
                    label: 'Cadastrar Safra',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CadastroSafraScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.redAccent,
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Controle Financeiro',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'Funcionalidade de Controle Financeiro em desenvolvimento.'),
                      ));
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.purpleAccent,
                    icon: Icons.list_alt_outlined,
                    label: 'Listar Safras',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ListarSafrasScreen()),
                      );
                    },
                  ),
                  _buildMenuBox(
                    context,
                    color: Colors.amberAccent,
                    icon: Icons.inventory_2_outlined,
                    label: 'Estoque',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EstoqueScreen()),
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
