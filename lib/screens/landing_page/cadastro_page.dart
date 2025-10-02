import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import 'package:odonto/widgets/custom_input.dart';
import 'package:odonto/widgets/custom_button.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefoneController = TextEditingController();
  final _senhaController = TextEditingController();
  final _confirmarSenhaController = TextEditingController();

  bool _isLoading = false;
  bool _obscureSenha = true;
  bool _obscureConfirmarSenha = true;

  final _telefoneFormatter = _TelefoneInputFormatter();

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _senhaController.dispose();
    _confirmarSenhaController.dispose();
    super.dispose();
  }

  Future<void> _cadastrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await _authService.signUp(
        // Use instance method
        nome: _nomeController.text.trim(),
        email: _emailController.text.trim(),
        telefone: _telefoneController.text.trim(),
        senha: _senhaController.text,
      );

      if (response != null && mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600]),
            const SizedBox(width: 8),
            const Text('Cadastro realizado!'),
          ],
        ),
        content: const Text('Verifique seu e-mail para confirmar o cadastro.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('FAZER LOGIN'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[600]),
            const SizedBox(width: 8),
            const Text('Erro no cadastro'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Informe o e-mail';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v.trim())) return 'E-mail inválido';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar Conta'), centerTitle: true),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CustomInput(
                    controller: _nomeController,
                    label: 'Nome completo',
                    hintText: 'Nome completo',
                    prefixIcon: const SizedBox.shrink(), // Corrigido
                    suffixIcon: const SizedBox.shrink(), // Corrigido
                    keyboardType: TextInputType.name,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _emailController,
                    label: 'E-mail',
                    hintText: 'exemplo@email.com',
                    prefixIcon: const Icon(Icons.email_outlined), // Corrigido
                    suffixIcon: null, // Agora aceita null
                    keyboardType: TextInputType.emailAddress,
                    validator: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _telefoneController,
                    label: 'Telefone',
                    hintText: '(11) 99999-9999',
                    prefixIcon: const Icon(Icons.phone_outlined), // Corrigido
                    suffixIcon: null, // Agora aceita null
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(15),
                      _telefoneFormatter,
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe o telefone';
                      final digits = v.replaceAll(RegExp(r'[^\d]'), '');
                      if (digits.length < 10) return 'Telefone incompleto';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _senhaController,
                    label: 'Senha',
                    hintText: 'Digite sua senha',
                    prefixIcon: const Icon(Icons.lock_outlined), // Corrigido
                    obscureText: _obscureSenha,
                    suffixIcon: Icon(
                      // Corrigido
                      _obscureSenha
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onSuffixTap: () {
                      setState(() => _obscureSenha = !_obscureSenha);
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Informe a senha';
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomInput(
                    controller: _confirmarSenhaController,
                    label: 'Confirmar senha',
                    hintText: 'Repita sua senha',
                    prefixIcon: const Icon(Icons.lock_outlined), // Corrigido
                    obscureText: _obscureConfirmarSenha,
                    suffixIcon: Icon(
                      // Corrigido
                      _obscureConfirmarSenha
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                    onSuffixTap: () {
                      setState(
                        () => _obscureConfirmarSenha = !_obscureConfirmarSenha,
                      );
                    },
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Confirme a senha';
                      if (v != _senhaController.text)
                        return 'Senhas não coincidem';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: _isLoading ? 'Cadastrando...' : 'Cadastrar',
                    onPressed: _isLoading ? null : _cadastrar,
                    isLoading: _isLoading, // Adicionado
                    // foregroundColor removido pois não é mais necessário
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: const Text('Já tem conta? Fazer login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Formatter simples para telefone brasileiro: (00) 00000-0000 ou (00) 0000-0000
class _TelefoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length < oldValue.text.length) {
      return newValue;
    }

    final digits = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.isEmpty) return const TextEditingValue();

    String formatted = '';
    if (digits.length <= 2) {
      formatted = '(${digits}';
    } else if (digits.length <= 6) {
      formatted = '(${digits.substring(0, 2)}) ${digits.substring(2)}';
    } else if (digits.length <= 10) {
      formatted =
          '(${digits.substring(0, 2)}) ${digits.substring(2, 6)}-${digits.substring(6)}';
    } else {
      formatted =
          '(${digits.substring(0, 2)}) ${digits.substring(2, 7)}-${digits.substring(7)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
