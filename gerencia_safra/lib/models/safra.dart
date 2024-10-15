class Safra {
  final int? id;
  final int idTerra;
  final String nomeSafra;
  final String dataPlantio;
  final String dataColheita;
  final double areaPlantada;
  final double quantidadeEsperada;
  final String insumosUtilizados;
  final String observacoes;
  final String condicoesClimaticas;
  final double custoSafra;

  Safra({
    this.id,
    required this.idTerra,
    required this.nomeSafra,
    required this.dataPlantio,
    required this.dataColheita,
    required this.areaPlantada,
    required this.quantidadeEsperada,
    required this.insumosUtilizados,
    required this.observacoes,
    this.condicoesClimaticas = '',
    required this.custoSafra,
  });

  Map<String, dynamic> toMap() {
    return {
      'idTerra': idTerra,
      'nome_safra': nomeSafra,
      'data_plantio': dataPlantio,
      'data_colheita': dataColheita,
      'area_plantada': areaPlantada,
      'quantidade_esperada': quantidadeEsperada,
      'insumos_utilizados': insumosUtilizados,
      'observacoes': observacoes,
      'condicoes_climaticas': condicoesClimaticas,
      'custo_safra': custoSafra,
    };
  }
}
