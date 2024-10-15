import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'listar_safras_screen.dart';

class CadastroSafraScreen extends StatefulWidget {
  final Map<String, dynamic>? safra; // Parâmetro opcional para editar uma safra

  CadastroSafraScreen({this.safra});

  @override
  _CadastroSafraScreenState createState() => _CadastroSafraScreenState();
}

class _CadastroSafraScreenState extends State<CadastroSafraScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _dataPlantioController = TextEditingController();
  final TextEditingController _dataColheitaController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();
  final TextEditingController _insumosController = TextEditingController();
  final TextEditingController _observacoesController = TextEditingController();
  final TextEditingController _condicoesController = TextEditingController();
  final TextEditingController _custoController = TextEditingController();

  int? _terraSelecionada;

  @override
  void initState() {
    super.initState();
    _carregarTerras();

    if (widget.safra != null) {
      // Pré-preencher os campos caso seja uma edição
      _nomeController.text = widget.safra!['nome_safra'];
      _dataPlantioController.text = widget.safra!['data_plantio'];
      _dataColheitaController.text = widget.safra!['data_colheita'];
      _areaController.text = widget.safra!['area_plantada'].toString();
      _quantidadeController.text = widget.safra!['quantidade_esperada'].toString();
      _insumosController.text = widget.safra!['insumos_utilizados'];
      _observacoesController.text = widget.safra!['observacoes'];
      _condicoesController.text = widget.safra!['condicoes_climaticas'];
      _custoController.text = widget.safra!['custo_safra'].toString();
      _terraSelecionada = widget.safra!['idTerra'];
    }
  }

  List<Map<String, dynamic>> _terras = [];

  Future<void> _carregarTerras() async {
    final terras = await _dbHelper.getTerras();
    setState(() {
      _terras = terras;
    });
  }

  Future<void> _salvarSafra() async {
    if (_terraSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecione uma terra para associar à safra.')),
      );
      return;
    }

    String nome = _nomeController.text;
    String dataPlantio = _dataPlantioController.text;
    String dataColheita = _dataColheitaController.text;
    double areaPlantada = double.tryParse(_areaController.text) ?? 0.0;
    double quantidadeEsperada = double.tryParse(_quantidadeController.text) ?? 0.0;
    String insumosUtilizados = _insumosController.text;
    String observacoes = _observacoesController.text;
    String condicoesClimaticas = _condicoesController.text;
    double custoSafra = double.tryParse(_custoController.text) ?? 0.0;

    if (nome.isNotEmpty && dataPlantio.isNotEmpty && dataColheita.isNotEmpty && areaPlantada > 0 && quantidadeEsperada > 0) {
      try {
        Map<String, dynamic> safra = {
          'idTerra': _terraSelecionada!,
          'nome_safra': nome,
          'data_plantio': dataPlantio,
          'data_colheita': dataColheita,
          'area_plantada': areaPlantada,
          'quantidade_esperada': quantidadeEsperada,
          'insumos_utilizados': insumosUtilizados,
          'observacoes': observacoes,
          'condicoes_climaticas': condicoesClimaticas,
          'custo_safra': custoSafra,
        };

        if (widget.safra == null) {
          // Criando uma nova safra
          await _dbHelper.addSafra(safra);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Safra cadastrada com sucesso!')),
          );
        } else {
          // Editando uma safra existente
          await _dbHelper.updateSafra(safra, widget.safra!['id']);  // Implementar essa função no database_helper.dart
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Safra atualizada com sucesso!')),
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ListarSafrasScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar a safra. Tente novamente.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, preencha todos os campos obrigatórios.')),
      );
    }
  }

  Future<void> _selecionarData(BuildContext context, TextEditingController controller) async {
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (dataSelecionada != null) {
      setState(() {
        controller.text = "${dataSelecionada.day}/${dataSelecionada.month}/${dataSelecionada.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.safra == null ? 'Cadastro de Safra' : 'Editar Safra'),
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
                widget.safra == null ? 'Preencha as informações da Safra' : 'Edite as informações da Safra',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              SizedBox(height: 20),
              _buildDropdownTerras(),
              SizedBox(height: 16),
              _buildTextField(_nomeController, 'Nome da Safra', Icons.landscape),
              SizedBox(height: 16),
              _buildDateField(context, _dataPlantioController, 'Data de Plantio'),
              SizedBox(height: 16),
              _buildDateField(context, _dataColheitaController, 'Data de Colheita'),
              SizedBox(height: 16),
              _buildTextField(_areaController, 'Área Plantada (ha)', Icons.map, keyboardType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_quantidadeController, 'Quantidade Esperada (ton)', Icons.inventory, keyboardType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_insumosController, 'Insumos Utilizados', Icons.agriculture),
              SizedBox(height: 16),
              _buildTextField(_condicoesController, 'Condições Climáticas (opcional)', Icons.cloud),
              SizedBox(height: 16),
              _buildTextField(_custoController, 'Custo da Safra (R\$)', Icons.attach_money, keyboardType: TextInputType.number),
              SizedBox(height: 16),
              _buildTextField(_observacoesController, 'Observações', Icons.notes, maxLines: 3),
              SizedBox(height: 20),
              _buildElevatedButton(widget.safra == null ? 'Cadastrar Safra' : 'Atualizar Safra', _salvarSafra),
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

  Widget _buildDateField(BuildContext context, TextEditingController controller, String label) {
    return GestureDetector(
      onTap: () => _selecionarData(context, controller),
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
            controller: controller,
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

  Widget _buildDropdownTerras() {
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
        value: _terraSelecionada,
        hint: Text('Selecione a Terra'),
        items: _terras.map((terra) {
          return DropdownMenuItem<int>(
            value: terra['id'],
            child: Text(terra['nome']),
          );
        }).toList(),
        onChanged: (int? newValue) {
          setState(() {
            _terraSelecionada = newValue;
          });
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(16),
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

