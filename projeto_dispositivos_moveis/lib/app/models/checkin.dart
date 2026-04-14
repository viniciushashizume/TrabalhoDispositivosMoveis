class CheckIn {
  final String? id;
  final DateTime data;
  final int humor; // 1–10
  final double horasSono; // 0–24
  final int nivelEstresse; // 1–5
  final bool atividadeFisica;
  final String interacaoSocial; // "Isolado", "Interações breves", "Muito social"

  CheckIn({
    this.id,
    required this.data,
    required this.humor,
    required this.horasSono,
    required this.nivelEstresse,
    required this.atividadeFisica,
    required this.interacaoSocial,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'data': data.toIso8601String(),
      'humor': humor,
      'horasSono': horasSono,
      'nivelEstresse': nivelEstresse,
      'atividadeFisica': atividadeFisica,
      'interacaoSocial': interacaoSocial,
    };
  }

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] as String?,
      data: DateTime.parse(json['data'] as String),
      humor: json['humor'] as int,
      horasSono: (json['horasSono'] as num).toDouble(),
      nivelEstresse: json['nivelEstresse'] as int,
      atividadeFisica: json['atividadeFisica'] as bool,
      interacaoSocial: json['interacaoSocial'] as String,
    );
  }
}