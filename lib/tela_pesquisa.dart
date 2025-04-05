import 'package:flutter/material.dart';

class TelaPesquisa extends SearchDelegate {
  final List<Map<String, dynamic>> notas;

  TelaPesquisa(this.notas);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final resultados = notas
        .where((nota) =>
    nota['titulo'].toLowerCase().contains(query.toLowerCase()) ||
        nota['texto'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _construirListaResultados(resultados);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final resultados = notas
        .where((nota) =>
    nota['titulo'].toLowerCase().contains(query.toLowerCase()) ||
        nota['texto'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    return _construirListaResultados(resultados);
  }

  /// Exibe os resultados da pesquisa em formato de grid, como a tela principal
  Widget _construirListaResultados(List<Map<String, dynamic>> resultados) {
    if (resultados.isEmpty) {
      return Center(child: Text('Nenhuma nota encontrada.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: resultados.length,
      itemBuilder: (context, index) {
        final nota = resultados[index];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: Text(nota['texto'] ?? '', style: TextStyle(fontSize: 14))),
                SizedBox(height: 4),
                Text(nota['titulo']?.isEmpty ?? true ? 'Sem Título' : nota['titulo'],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Text(nota['data'].split('.')[0], style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        );
      },
    );
  }
}
