import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'tela_editar_nota.dart';
import 'tela_pesquisa.dart';

class TelaPrincipal extends StatefulWidget {
  final Future<void> Function() alternarTema;
  final bool modoEscuro;

  TelaPrincipal({required this.alternarTema, required this.modoEscuro});

  @override
  _TelaPrincipalState createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  final _armazenamentoSeguro = FlutterSecureStorage();
  List<Map<String, dynamic>> _notas = [];
  List<int> _notasSelecionadas = [];

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  /// Carrega as notas salvas do armazenamento seguro
  Future<void> _carregarNotas() async {
    String? dadosNotas = await _armazenamentoSeguro.read(key: 'notas');
    if (dadosNotas != null) {
      setState(() {
        _notas = List<Map<String, dynamic>>.from(json.decode(dadosNotas));
      });
    }
  }

  /// Salva as notas no armazenamento seguro
  Future<void> _salvarNotas() async {
    String dadosNotas = json.encode(_notas);
    await _armazenamentoSeguro.write(key: 'notas', value: dadosNotas);
  }

  /// Adiciona uma nova nota
  void _adicionarNota() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            TelaEditarNota(
              salvar: (titulo, texto) {
                if (titulo.isNotEmpty || texto.isNotEmpty) {
                  setState(() {
                    _notas.add({
                      'titulo': titulo,
                      'texto': texto,
                      'data': DateTime.now().toString(),
                      'fixado': false
                    });
                  });
                  _salvarNotas();
                }
              },
            ),
      ),
    );
  }

  /// Exclui notas selecionadas com confirmação
  void _excluirNotasSelecionadas() async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
            title: Text('Confirmar Exclusão'),
            content: Text(_notasSelecionadas.length == 1
                ? 'Deseja excluir esta nota?'
                : 'Você deseja excluir ${_notasSelecionadas.length} notas?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('Cancelar')),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text('Excluir')),
            ],
          ),
    );

    if (confirmar) {
      setState(() {
        _notasSelecionadas.sort();
        for (int i = _notasSelecionadas.length - 1; i >= 0; i--) {
          _notas.removeAt(_notasSelecionadas[i]);
        }
        _notasSelecionadas.clear();
      });
      _salvarNotas();
    }
  }

  /// Alterna a fixação da nota para mover para o topo
  void _alternarFixacao(int index) {
    setState(() {
      _notas[index]['fixado'] = !_notas[index]['fixado'];
      // Reordena: notas fixadas sempre para o início
      _notas.sort((a, b) {
        if (a['fixado'] == b['fixado']) return 0;
        return a['fixado'] ? -1 : 1;
      });
      // Limpa a seleção, pois a ação de fixar já foi executada
      _notasSelecionadas.clear();
    });
    _salvarNotas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notas App'),
        actions: _notasSelecionadas.isEmpty
            ? [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () =>
                showSearch(
                  context: context,
                  delegate: TelaPesquisa(_notas),
                ),
          ),
          IconButton(
            icon: Icon(widget.modoEscuro ? Icons.light_mode : Icons.dark_mode),
            onPressed: () async => await widget.alternarTema(),
          ),
        ]
            : [
          // Se apenas uma nota estiver selecionada, exibe o botão de fixar
          if (_notasSelecionadas.length == 1)
            IconButton(
              icon: Icon(Icons.push_pin),
              onPressed: () => _alternarFixacao(_notasSelecionadas.first),
            ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _excluirNotasSelecionadas,
          ),
        ],
      ),
      body: _notas.isEmpty
          ? Center(child: Text('Nenhuma nota salva.'))
          : GridView.builder(
        padding: const EdgeInsets.all(8.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3),
        itemCount: _notas.length,
        itemBuilder: (context, index) {
          final nota = _notas[index];
          final estaSelecionada = _notasSelecionadas.contains(index);
          return GestureDetector(
            onTap: () {
              if (_notasSelecionadas.isNotEmpty) {
                setState(() {
                  if (estaSelecionada) {
                    _notasSelecionadas.remove(index);
                  } else {
                    _notasSelecionadas.add(index);
                  }
                });
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        TelaEditarNota(
                          titulo: nota['titulo'],
                          texto: nota['texto'],
                          salvar: (titulo, texto) {
                            setState(() {
                              _notas[index] = {
                                'titulo': titulo,
                                'texto': texto,
                                'data': DateTime.now().toString(),
                                'fixado': nota['fixado'],
                              };
                            });
                            _salvarNotas();
                          },
                        ),
                  ),
                );
              }
            },
            onLongPress: () {
              setState(() {
                if (estaSelecionada) {
                  _notasSelecionadas.remove(index);
                } else {
                  _notasSelecionadas.add(index);
                }
              });
            },
            child: Card(
              color: estaSelecionada ? Colors.blue.shade900 : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        nota['texto'] ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      nota['titulo']?.isEmpty ?? true
                          ? 'Sem Título'
                          : nota['titulo'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      nota['data'].split('.')[0],
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.small(
        onPressed: _adicionarNota,
        child: Icon(Icons.add),
      ),
    );
  }
}
