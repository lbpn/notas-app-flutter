import 'package:flutter/material.dart';

class TelaEditarNota extends StatefulWidget {
  final String? titulo;
  final String? texto;
  final Function(String titulo, String texto) salvar;

  TelaEditarNota({this.titulo, this.texto, required this.salvar});

  @override
  _TelaEditarNotaState createState() => _TelaEditarNotaState();
}

class _TelaEditarNotaState extends State<TelaEditarNota> {
  late TextEditingController _tituloController;
  late TextEditingController _textoController;
  late String _tituloInicial;
  late String _textoInicial;
  final FocusNode _focoTexto = FocusNode();

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController(text: widget.titulo);
    _textoController = TextEditingController(text: widget.texto);
    _tituloInicial = widget.titulo ?? '';
    _textoInicial = widget.texto ?? '';

    // Foca automaticamente no campo de texto ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focoTexto);
    });
  }

  /// Verifica se houve mudanças na nota
  bool get _houveAlteracoes => _tituloInicial != _tituloController.text || _textoInicial != _textoController.text;

  @override
  void dispose() {
    _tituloController.dispose();
    _textoController.dispose();
    _focoTexto.dispose();
    super.dispose();
  }

  /// Salva a nota se houver alterações
  Future<void> _salvarNota() async {
    if (_houveAlteracoes) {
      widget.salvar(_tituloController.text, _textoController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Salva a nota ao pressionar o botão de voltar
      onWillPop: () async {
        await _salvarNota();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            controller: _tituloController,
            decoration: InputDecoration(
              hintText: 'Escreva seu título aqui',
              border: InputBorder.none,
            ),
            onChanged: (text) => setState(() {}),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: TextField(
                  controller: _textoController,
                  decoration: InputDecoration(
                    hintText: 'Escreva seu texto aqui',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textAlignVertical: TextAlignVertical.top,
                  onChanged: (text) => setState(() {}),
                  autofocus: true,
                  focusNode: _focoTexto,
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.small(
          onPressed: () async {
            await _salvarNota();
            Navigator.of(context).pop();
          },
          child: Icon(Icons.check),
        ),
      ),
    );
  }
}
