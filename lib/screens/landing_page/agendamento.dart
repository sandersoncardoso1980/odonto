class Agendamento {
  final String? id;
  final String nome;
  final String email;
  final String telefone;
  final DateTime dataHora;
  final String servico;
  final String? observacoes;
  final String? userId;
  final String status;

  Agendamento({
    this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.dataHora,
    required this.servico,
    this.observacoes,
    this.userId,
    this.status = 'pendente',
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'],
      nome: json['nome'],
      email: json['email'],
      telefone: json['telefone'],
      dataHora: DateTime.parse(json['data']),
      servico: json['servico'],
      observacoes: json['observacoes'],
      userId: json['user_id'],
      status: json['status'] ?? 'pendente',
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'data': dataHora.toIso8601String(),
      'servico': servico,
      'observacoes': observacoes,
      'user_id': userId,
      'status': status,
    };

    // Só inclui o ID se não for null (para evitar problemas no INSERT)
    if (id != null) {
      data['id'] = id;
    }

    return data;
  }

  @override
  String toString() {
    return 'Agendamento{id: $id, nome: $nome, email: $email, telefone: $telefone, dataHora: $dataHora, servico: $servico, observacoes: $observacoes, userId: $userId, status: $status}';
  }
}
