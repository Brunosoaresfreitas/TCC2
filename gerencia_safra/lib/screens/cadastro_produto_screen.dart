import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'listar_produtos_screen.dart';

class CadastroProdutoScreen extends StatefulWidget {
  final Map<String, dynamic>? produto; // O produto será opcional, usado para edição

  CadastroProdutoScreen({this.produto});

  @override
  _CadastroProdutoScreenState createState() => _CadastroProdutoScreenState();
}

class _CadastroProdutoScreenState extends State<CadastroProdutoScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  final TextEditingController _unidadeMedidaController = TextEditingController();
  final TextEditingController _localArmazenamentoController = TextEditingController();
  String? _dataCadastro;

  @override
  void initState() {
    super.initState();
    // Se um produto foi passado para edição, preencher os campos com as informações do produto
    if (widget.produto != null) {
      _nomeController.text = widget.produto!['nome_produto'] ?? '';
      _descricaoController.text = widget.produto!['descricao'] ?? '';
      _unidadeMedidaController.text = widget.produto!['unidade_medida'] ?? '';
      _localArmazenamentoController.text = widget.produto!['local_armazenamento'] ?? '';
      _dataCadastro = widget.produto!['data_cadastro'] ?? '';
    }
  }

  Future<void> _salvarProduto() async {
    String nome = _nomeController.text;
    String descricao = _descricaoController.text;
    String unidadeMedida = _unidadeMedidaController.text;
    String localArmazenamento = _localArmazenamentoController.text;
    String dataCadastro = _dataCadastro ?? '';

    if (nome.isNotEmpty && unidadeMedida.isNotEmpty && localArmazenamento.isNotEmpty && dataCadastro.isNotEmpty) {
      try {
        Map<String, dynamic> produto = {
          'nome_produto': nome,
          'descricao': descricao,
          'unidade_medida': unidadeMedida,
          'local_armazenamento': localArmazenamento,
          'data_cadastro': dataCadastro,
        };

        if (widget.produto == null) {
          // Caso esteja criando um novo produto
          await _dbHelper.addProdutoEstoque(produto);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto cadastrado com sucesso!')),
          );
        } else {
          // Caso esteja editando um produto existente
          await _dbHelper.updateProduto(produto, widget.produto!['id']);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Produto atualizado com sucesso!')),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListarProdutosScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar o produto. Tente novamente.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos.')),
      );
    }
  }

  Future<void> _selecionarDataCadastro(BuildContext context) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (dataSelecionada != null) {
      setState(() {
        _dataCadastro = "${dataSelecionada.day}/${dataSelecionada.month}/${dataSelecionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produto == null ? 'Cadastro de Produto' : 'Editar Produto'),
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
                widget.produto == null
                    ? 'Preencha as informações do Produto'
                    : 'Edite as informações do Produto',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              _buildTextField(_nomeController, 'Nome do Produto', Icons.production_quantity_limits),
              SizedBox(height: 16),
              _buildTextField(_descricaoController, 'Descrição', Icons.description),
              SizedBox(height: 16),
              _buildTextField(_unidadeMedidaController, 'Unidade de Medida', Icons.balance),
              SizedBox(height: 16),
              _buildTextField(_localArmazenamentoController, 'Local de Armazenamento', Icons.warehouse),
              SizedBox(height: 16),
              _buildDateField(context),
              SizedBox(height: 20),
              _buildElevatedButton(widget.produto == null ? 'Cadastrar Produto' : 'Salvar Alterações', _salvarProduto),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
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
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
        ),
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return GestureDetector(
      onTap: () => _selecionarDataCadastro(context),
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
            controller: TextEditingController(text: _dataCadastro ?? 'Clique para selecionar a data'),
            decoration: InputDecoration(
              labelText: 'Data de Cadastro',
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
