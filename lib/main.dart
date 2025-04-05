import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'tela_principal.dart';

void main() => runApp(MeuApp());

class MeuApp extends StatefulWidget {
  @override
  _MeuAppState createState() => _MeuAppState();
}

class _MeuAppState extends State<MeuApp> {
  bool _modoEscuro = false;
  final _armazenamentoSeguro = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _carregarTema();
  }

  /// Carrega o tema salvo (claro ou escuro) ao iniciar o app
  Future<void> _carregarTema() async {
    String? temaSalvo = await _armazenamentoSeguro.read(key: 'modoEscuro');
    setState(() {
      _modoEscuro = temaSalvo == 'true';
    });
  }

  /// Alterna entre modo claro e escuro e salva a configuração
  Future<void> _alternarTema() async {
    setState(() {
      _modoEscuro = !_modoEscuro;
    });
    await _armazenamentoSeguro.write(key: 'modoEscuro', value: _modoEscuro.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _modoEscuro ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
      home: TelaPrincipal(alternarTema: _alternarTema, modoEscuro: _modoEscuro),
    );
  }
}
