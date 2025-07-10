import 'package:flutter/material.dart';
import 'dart:convert'; // Para decodificar JSON

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cotação da Bolsa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const StockQuotePage(),
    );
  }
}

class StockQuotePage extends StatefulWidget {
  const StockQuotePage({super.key});

  @override
  State<StockQuotePage> createState() => _StockQuotePageState();
}

class _StockQuotePageState extends State<StockQuotePage> {
  String _stockInfo = 'Preparando dados...'; // Texto para exibir a cotação
  bool _isLoading = true; // Para controlar o estado de carregamento

  // O JSON que você forneceu, armazenado como uma string.
  // Simula a resposta da API da HG Brasil.
  final String staticJsonResponse = '''
{"by":"default","valid_key":false,"results":{"currencies":{"source":"BRL","USD":{"name":"Dollar","buy":5.5323,"sell":5.535,"variation":-0.743},"EUR":{"name":"Euro","buy":6.4711,"sell":6.4767,"variation":-0.964},"GBP":{"name":"Pound Sterling","buy":7.5135,"sell":null,"variation":-0.814},"ARS":{"name":"Argentine Peso","buy":0.0042,"sell":null,"variation":0.0},"CAD":{"name":"Canadian Dollar","buy":4.0507,"sell":null,"variation":-0.557},"AUD":{"name":"Australian Dollar","buy":3.6437,"sell":null,"variation":0.091},"JPY":{"name":"Japanese Yen","buy":0.0377,"sell":null,"variation":-0.789},"CNY":{"name":"Renminbi","buy":0.7745,"sell":null,"variation":-0.437},"BTC":{"name":"Bitcoin","buy":666277.012,"sell":666277.012,"variation":2.135}},"stocks":{"IBOVESPA":{"name":"BM\u0026F BOVESPA","location":"Sao Paulo, Brazil","points":136743.27,"variation":-0.54},"IFIX":{"name":"Índice de Fundos de Investimentos Imobiliários B3","location":"Sao Paulo, Brazil","points":3474.99,"variation":-0.22},"NASDAQ":{"name":"NASDAQ Stock Market","location":"New York City, United States","points":20630.66,"variation":0.09},"DOWJONES":{"name":"Dow Jones Industrial Average","location":"New York City, United States","points":44650.64,"variation":0.43},"CAC":{"name":"CAC 40","location":"Paris, French","points":7902.25,"variation":0.3},"NIKKEI":{"name":"Nikkei 225","location":"Tokyo, Japan","points":39646.36,"variation":-0.44}},"available_sources":["BRL"],"taxes":[]},"execution_time":0.0,"from_cache":true}
'''; // Fim do JSON string

  @override
  void initState() {
    super.initState();
    _processStaticData(); // Chama a função para processar os dados estáticos
  }

  Future<void> _processStaticData() async {
    setState(() {
      _isLoading = true; // Define como carregando (simula um atraso)
      _stockInfo = 'Processando dados da cotação...';
    });

    // Simula um pequeno atraso para que a tela de carregamento apareça
    await Future.delayed(const Duration(seconds: 1));

    try {
      // Decodifica a string JSON
      final Map<String, dynamic> data = json.decode(staticJsonResponse);

      // Acessa os dados da bolsa de valores (Bovespa)
      final bovespa = data['results']['stocks']['IBOVESPA'];

      if (bovespa != null) {
        final String name = bovespa['name'];
        final double points = bovespa['points'].toDouble();
        final double variation = bovespa['variation'].toDouble();

        setState(() {
          // Formatamos a string aqui para facilitar a extração na UI
          _stockInfo =
              '$name: ${points.toStringAsFixed(2)} | ${variation.toStringAsFixed(2)}%';
        });
      } else {
        setState(() {
          _stockInfo = 'Dados da Bovespa não encontrados no JSON.';
        });
      }
    } catch (e) {
      // Captura erros de processamento JSON
      setState(() {
        _stockInfo = 'Ocorreu um erro ao processar os dados: $e';
      });
    } finally {
      setState(() {
        _isLoading = false; // Define como não carregando
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cotação da Bolsa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed:
                _isLoading
                    ? null
                    : _processStaticData, // Desabilita o botão enquanto carrega
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child:
              _isLoading
                  ? const CircularProgressIndicator() // Mostra indicador de carregamento
                  : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 8, // Sombra para o card
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            15,
                          ), // Bordas arredondadas
                        ),
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 20,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            25.0,
                          ), // Preenchimento interno do card
                          child: Column(
                            mainAxisSize:
                                MainAxisSize
                                    .min, // Ocupa o mínimo de espaço vertical
                            children: [
                              Text(
                                // Nome da Bolsa
                                _stockInfo.split(
                                  ':',
                                )[0], // Pega apenas o "BM&F BOVESPA"
                                textAlign: TextAlign.center,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium?.copyWith(
                                  color:
                                      Theme.of(
                                        context,
                                      ).primaryColorDark, // Cor mais escura
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Extrai pontos da string formatada
                                  Builder(
                                    builder: (context) {
                                      final String pointsStr =
                                          _stockInfo
                                              .split(':')[1]
                                              .split('|')[0]
                                              .trim();
                                      final double points =
                                          double.tryParse(pointsStr) ?? 0.0;
                                      return Icon(
                                        Icons.trending_up,
                                        color: Colors.green[700],
                                        size: 30,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    // Pontos
                                    'Pontos: ${_stockInfo.split(':')[1].split('|')[0].trim()}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      color: Colors.green[700], // Cor verde
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Extrai variação da string formatada
                                  Builder(
                                    builder: (context) {
                                      final String variationStr =
                                          _stockInfo
                                              .split('|')[1]
                                              .replaceAll('%', '')
                                              .trim();
                                      final double variation =
                                          double.tryParse(variationStr) ?? 0.0;
                                      return Icon(
                                        variation >= 0
                                            ? Icons.arrow_circle_up
                                            : Icons.arrow_circle_down,
                                        color:
                                            variation >= 0
                                                ? Colors.green[700]
                                                : Colors.red[700],
                                        size: 30,
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    // Variação
                                    'Variação: ${_stockInfo.split('|')[1].trim()}',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall?.copyWith(
                                      color:
                                          double.parse(
                                                    _stockInfo
                                                        .split('|')[1]
                                                        .replaceAll('%', '')
                                                        .trim(),
                                                  ) >=
                                                  0
                                              ? Colors.green[700]
                                              : Colors.red[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30), // Espaçamento antes do botão
                      ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _processStaticData, // Desabilita o botão enquanto carrega
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 15,
                          ),
                          textStyle: const TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Atualizar Cotação'),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
