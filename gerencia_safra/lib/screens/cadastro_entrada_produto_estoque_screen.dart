import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'listar_produtos_screen.dart';

class CadastroEntradaProdutoScreen extends StatefulWidget {
  @override
  _CadastroEntradaProdutoScreenState createState() => _CadastroEntradaProdutoScreenState();
}

class _CadastroEntradaProdutoScreenState extends State<CadastroEntradaProdutoScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _produtos = [];
  int? _produtoSelecionado;
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _origemController = TextEditingController();
  String? _dataEntrada;

  @override
  void initState() {
    super.initState();
    _carregarProdutos();
  }

  Future<void> _carregarProdutos() async {
    final produtos = await _dbHelper.getProdutosEstoque();
    setState(() {
      _produtos = produtos;
    });
  }

  Future<void> _salvarEntrada() async {
    if (_produtoSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione um produto.')),
      );
      return;
    }

    double quantidade = double.tryParse(_quantidadeController.text) ?? 0.0;
    String origem = _origemController.text;
    String dataEntrada = _dataEntrada ?? '';

    if (quantidade > 0 && dataEntrada.isNotEmpty && origem.isNotEmpty) {
      try {
        Map<String, dynamic> entrada = {
          'id_produto': _produtoSelecionado,
          'tipo_movimentacao': 'entrada',
          'data_movimentacao': dataEntrada,
          'quantidade': quantidade,
          'origem': origem,
        };

        await _dbHelper.addMovimentacaoEstoque(entrada);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Entrada registrada com sucesso!')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListarProdutosScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao registrar a entrada. Tente novamente.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Preencha todos os campos obrigatórios.')),
      );
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataEntrada = "${dataSelecionada.day}/${dataSelecionada.month}/${dataSelecionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastrar Entrada de Produto'),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrar Entrada de Produto no Estoque',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              _buildDropdownProdutos(),
              SizedBox(height: 16),
              _buildDateField(context, 'Data de Entrada'),
              SizedBox(height: 16),
              _buildTextField(_quantidadeController, 'Quantidade', Icons.inventory, keyboardType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_origemController, 'Origem da Entrada', Icons.store),
              SizedBox(height: 20),
              _buildElevatedButton('Registrar Entrada', _salvarEntrada),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDropdownProdutos() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<int>(
        value: _produtoSelecionado,
        hint: Text('Selecione o Produto'),
        items: _produtos.map((produto) {
          return DropdownMenuItem<int>(
            value: produto['id'],
            child: Text(produto['nome_produto']),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _produtoSelecionado = newValue;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context, String label) {
    return GestureDetector(
      onTap: () => _selecionarData(context),
      child: AbsorbPointer(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: TextEditingController(text: _dataEntrada ?? 'Clique para selecionar'),
            decoration: InputDecoration(
              labelText: label,
              prefixIcon: Icon(Icons.calendar_today, color: Colors.teal),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElevatedButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
