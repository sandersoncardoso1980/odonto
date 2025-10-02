class Servico {
  final String id;
  final String nome;
  final int duracaoMinutos;

  Servico({required this.id, required this.nome, required this.duracaoMinutos});

  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      id: json["id"],
      nome: json["nome"],
      duracaoMinutos: json["duracao_minutos"],
    );
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "nome": nome, "duracao_minutos": duracaoMinutos};
  }

  @override
  String toString() {
    return 'Servico{id: $id, nome: $nome, duracaoMinutos: $duracaoMinutos}';
  }
}
