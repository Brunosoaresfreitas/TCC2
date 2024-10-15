import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app_database_v5.db');  // Incrementando a versão para 5
    return await openDatabase(
      path,
      version: 5,  // Atualizando a versão do banco de dados
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela de Terras (mantida)
    await db.execute('''CREATE TABLE terras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome TEXT,
        area REAL,
        tipo_solo TEXT,
        localizacao TEXT,
        data_cadastro TEXT,
        observacoes TEXT
      )''');

    // Tabela de Safras
    await db.execute('''CREATE TABLE safras (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idTerra INTEGER,
        nome_safra TEXT,
        data_plantio TEXT,
        data_colheita TEXT,
        area_plantada REAL,
        quantidade_esperada REAL,
        insumos_utilizados TEXT,
        observacoes TEXT,
        condicoes_climaticas TEXT,
        custo_safra REAL,
        FOREIGN KEY (idTerra) REFERENCES terras (id)
      )''');

    // Tabela de Controle Financeiro (mantida)
    await db.execute('''CREATE TABLE controle_financeiro (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        idSafra INTEGER,
        gasto REAL,
        receita REAL,
        FOREIGN KEY (idSafra) REFERENCES safras (id)
      )''');

    // Tabela de Produtos do Estoque
    await db.execute('''CREATE TABLE produtos_estoque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nome_produto TEXT,
        descricao TEXT,
        unidade_medida TEXT,
        local_armazenamento TEXT,
        data_cadastro TEXT
      )''');

    // Tabela de Movimentações do Estoque (Entradas e Saídas)
    await db.execute('''CREATE TABLE movimentacoes_estoque (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        id_produto INTEGER,
        tipo_movimentacao TEXT,
        data_movimentacao TEXT,
        quantidade REAL,
        safra_relacionada TEXT,
        origem TEXT,
        destino TEXT,
        motivo TEXT,
        FOREIGN KEY (id_produto) REFERENCES produtos_estoque (id)
      )''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      // Criação de tabela temporária e migração de dados com a nova coluna 'destino'
      await db.execute('''CREATE TABLE IF NOT EXISTS movimentacoes_estoque_temp (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          id_produto INTEGER,
          tipo_movimentacao TEXT,
          data_movimentacao TEXT,
          quantidade REAL,
          safra_relacionada TEXT,
          origem TEXT,
          destino TEXT,
          motivo TEXT,
          FOREIGN KEY (id_produto) REFERENCES produtos_estoque (id)
      )''');

      await db.execute('''INSERT INTO movimentacoes_estoque_temp (
          id, id_produto, tipo_movimentacao, data_movimentacao, quantidade, safra_relacionada, origem, motivo)
          SELECT id, id_produto, tipo_movimentacao, data_movimentacao, quantidade, safra_relacionada, origem, motivo
          FROM movimentacoes_estoque
      ''');

      await db.execute('DROP TABLE movimentacoes_estoque');
      await db.execute('ALTER TABLE movimentacoes_estoque_temp RENAME TO movimentacoes_estoque');
    }
  }

  // Funções para o Estoque
  Future<int> addProdutoEstoque(Map<String, dynamic> produto) async {
    final db = await database;
    return await db.insert('produtos_estoque', produto);
  }

  Future<List<Map<String, dynamic>>> getProdutosEstoque() async {
    final db = await database;
    return await db.query('produtos_estoque');
  }

  // Função para atualizar um produto no estoque
  Future<int> updateProduto(Map<String, dynamic> produto, int id) async {
    final db = await database;
    return await db.update(
      'produtos_estoque',
      produto,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addMovimentacaoEstoque(Map<String, dynamic> movimentacao) async {
    final db = await database;
    return await db.insert('movimentacoes_estoque', movimentacao);
  }

  Future<List<Map<String, dynamic>>> getMovimentacoesEstoque(int idProduto) async {
    final db = await database;
    return await db.query('movimentacoes_estoque', where: 'id_produto = ?', whereArgs: [idProduto]);
  }

  Future<double> getSaldoProduto(int idProduto) async {
    final db = await database;

    // Consulta para obter a soma das entradas
    final entradas = await db.rawQuery('SELECT SUM(quantidade) as total FROM movimentacoes_estoque WHERE id_produto = ? AND tipo_movimentacao = "entrada"', [idProduto]);
    // Consulta para obter a soma das saídas
    final saidas = await db.rawQuery('SELECT SUM(quantidade) as total FROM movimentacoes_estoque WHERE id_produto = ? AND tipo_movimentacao = "saida"', [idProduto]);

    // Verifica se o valor é nulo e faz a conversão para double com '?? 0.0' para evitar valores nulos
    double totalEntradas = (entradas.first['total'] as double?) ?? 0.0;
    double totalSaidas = (saidas.first['total'] as double?) ?? 0.0;

    // Retorna o saldo (entradas - saídas)
    return totalEntradas - totalSaidas;
  }

  Future<int> deleteProduto(int id) async {
    final db = await database;
    return await db.delete('produtos_estoque', where: 'id = ?', whereArgs: [id]);
  }

  // Funções para Terras e Safras (mantidas)
  Future<int> addTerra(String nome, double area, String tipoSolo, String localizacao, String dataCadastro, String observacoes) async {
    final db = await database;
    return await db.insert('terras', {
      'nome': nome,
      'area': area,
      'tipo_solo': tipoSolo,
      'localizacao': localizacao,
      'data_cadastro': dataCadastro,
      'observacoes': observacoes,
    });
  }

  Future<List<Map<String, dynamic>>> getTerras() async {
    final db = await database;
    return await db.query('terras');
  }

  Future<int> deleteTerra(int id) async {
    final db = await database;
    return await db.delete('terras', where: 'id = ?', whereArgs: [id]);
  }

  // Funções para Safras (mantidas e adicionadas)
  Future<int> addSafra(Map<String, dynamic> safra) async {
    final db = await database;
    return await db.insert('safras', safra);
  }

  Future<List<Map<String, dynamic>>> getSafras() async {
    final db = await database;
    return await db.query('safras');
  }

  Future<int> updateSafra(Map<String, dynamic> safra, int id) async {
    final db = await database;
    return await db.update(
      'safras',
      safra,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteSafra(int id) async {
    final db = await database;
    return await db.delete('safras', where: 'id = ?', whereArgs: [id]);
  }

  // Funções para Controle Financeiro (mantidas)
  Future<int> addControleFinanceiro(int idSafra, double gasto, double receita) async {
    final db = await database;
    return await db.insert('controle_financeiro', {
      'idSafra': idSafra,
      'gasto': gasto,
      'receita': receita,
    });
  }

  Future<List<Map<String, dynamic>>> getControlesFinanceiros() async {
    final db = await database;
    return await db.query('controle_financeiro');
  }

  // Função para atualizar uma terra
Future<int> updateTerra(Map<String, dynamic> terra, int id) async {
  final db = await database;
  return await db.update(
    'terras',
    terra,
    where: 'id = ?',
    whereArgs: [id],
  );
}

}
