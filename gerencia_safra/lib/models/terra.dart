// lib/models/terra.dart
class Terra {
  final int? id;
  final String nome;
  final double area;
  final String tipoSolo; // Novo campo
  final String localizacao; // Novo campo
  final String dataCadastro; // Novo campo
  final String observacoes; // Novo campo

  Terra({
    this.id,
    required this.nome,
    required this.area,
    required this.tipoSolo,
    required this.localizacao,
    required this.dataCadastro,
    required this.observacoes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'area': area,
      'tipo_solo': tipoSolo, // Adicionado ao mapa
      'localizacao': localizacao, // Adicionado ao mapa
      'data_cadastro': dataCadastro, // Adicionado ao mapa
      'observacoes': observacoes, // Adicionado ao mapa
    };
  }
}
