import 'package:flutter/material.dart';

void main() {
  runApp(const MeuApp());
}

class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lista de Compras',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TelaLista(),
    );
  }
}

// modelo do item
class Item {
  String nome;
  int quantidade;
  bool comprado;

  Item({
    required this.nome,
    required this.quantidade,
    this.comprado = false,
  });
}

class TelaLista extends StatefulWidget {
  const TelaLista({super.key});

  @override
  State<TelaLista> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  // lista que guarda os itens
  final List<Item> _itens = [
    Item(nome: 'Arroz', quantidade: 2),
    Item(nome: 'Feijão', quantidade: 1),
    Item(nome: 'Macarrão', quantidade: 3),
    Item(nome: 'Leite', quantidade: 6, comprado: true),
  ];

  // abre a tela de adicionar e espera um item de volta
  Future<void> abrirTelaAdicionar() async {
    final novoItem = await Navigator.push<Item>(
      context,
      MaterialPageRoute(builder: (context) => const TelaAdicionarItem()),
    );

    if (novoItem != null) {
      setState(() {
        _itens.add(novoItem);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${novoItem.nome} adicionado à lista'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // remove o item pelo indice
  void removerItem(int indice) {
    final itemRemovido = _itens[indice];
    setState(() {
      _itens.removeAt(indice);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${itemRemovido.nome} removido da lista'),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalComprados = _itens.where((i) => i.comprado).length;
    final int totalItens = _itens.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        // contador de comprados
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '$totalComprados de $totalItens comprados',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ),
      ),
      body: _itens.isEmpty
          ? const Center(
              child: Text(
                'Nenhum item na lista',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: _itens.length,
              itemBuilder: (context, indice) {
                final item = _itens[indice];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Checkbox(
                      value: item.comprado,
                      activeColor: Colors.deepPurple,
                      onChanged: (valor) {
                        setState(() {
                          item.comprado = valor!;
                        });
                      },
                    ),
                    title: Text(
                      item.nome,
                      style: TextStyle(
                        fontSize: 16,
                        decoration: item.comprado
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: item.comprado ? Colors.grey : Colors.black,
                      ),
                    ),
                    subtitle: Text('Quantidade: ${item.quantidade}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => removerItem(indice),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: abrirTelaAdicionar,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class TelaAdicionarItem extends StatefulWidget {
  const TelaAdicionarItem({super.key});

  @override
  State<TelaAdicionarItem> createState() => _TelaAdicionarItemState();
}

class _TelaAdicionarItemState extends State<TelaAdicionarItem> {
  // controllers dos campos
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _quantidadeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    super.dispose();
  }

  // salva o item e devolve pra tela anterior
  void salvar() {
    final nome = _nomeController.text.trim();
    final quantidadeTexto = _quantidadeController.text.trim();

    if (nome.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome do item'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final int quantidade = int.tryParse(quantidadeTexto) ?? 1;

    final novoItem = Item(nome: nome, quantidade: quantidade);
    Navigator.pop(context, novoItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Item'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nomeController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome do item',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.shopping_cart),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantidadeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: salvar,
              icon: const Icon(Icons.save),
              label: const Text('Salvar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}