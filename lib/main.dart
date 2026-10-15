import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
        fontFamily: 'System UI',
      ),
      home: const GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  List<String> board = List.filled(9, '');
  String player = 'X';
  String? winner;
  int winsX = 0;
  int winsO = 0;
  int draws = 0;
  List<int> moveHistory = [];
  List<int> winningCells = [];

  late AnimationController _turnController;
  late AnimationController _winController;
  late Animation<double> _turnScale;

  static const List<List<int>> winningLines = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6],
  ];

  Color playerColor(String p) => p == 'X' ? Colors.blue : Colors.red;

  @override
  void initState() {
    super.initState();
    _turnController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat(reverse: true);
    _turnScale = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _turnController, curve: Curves.easeInOut),
    );
    _winController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _turnController.dispose();
    _winController.dispose();
    super.dispose();
  }

  void tap(int i) {
    if (board[i].isNotEmpty || winner != null) return;
    setState(() {
      board[i] = player;
      moveHistory.add(i);
      winner = checkWinner();
      if (winner != null && winner != 'Draw') {
        if (winner == 'X') {
          winsX++;
        } else if (winner == 'O') {
          winsO++;
        }
        _winController.forward(from: 0);
      } else if (!board.contains('')) {
        winner = 'Draw';
        draws++;
      } else {
        player = player == 'X' ? 'O' : 'X';
      }
    });
  }

  String? checkWinner() {
    for (final line in winningLines) {
      if (board[line[0]].isNotEmpty &&
          board[line[0]] == board[line[1]] &&
          board[line[1]] == board[line[2]]) {
        winningCells = line;
        return board[line[0]];
      }
    }
    winningCells = [];
    return null;
  }

  void resetRound() {
    setState(() {
      board = List.filled(9, '');
      player = 'X';
      winner = null;
      moveHistory = [];
      winningCells = [];
      _winController.reset();
    });
  }

  void resetAll() {
    setState(() {
      board = List.filled(9, '');
      player = 'X';
      winner = null;
      winsX = 0;
      winsO = 0;
      draws = 0;
      moveHistory = [];
      winningCells = [];
      _winController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final shortest = MediaQuery.of(context).size.shortestSide;
    final boardSize = (shortest * 0.85).clamp(260.0, 420.0);

    final String status;
    final Color statusColor;
    if (winner == 'Draw') {
      status = 'Berabere!';
      statusColor = Colors.orange;
    } else if (winner != null) {
      status = '$winner Kazandı!';
      statusColor = playerColor(winner!);
    } else {
      status = 'Sıra: $player';
      statusColor = playerColor(player);
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf8f9ff),
              Color(0xFFe8f4ff),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text(
                'Tic Tac Toe',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _scoreCard('X', winsX, Colors.blue),
                  const SizedBox(width: 8),
                  _scoreCard('Berabere', draws, Colors.orange),
                  const SizedBox(width: 8),
                  _scoreCard('O', winsO, Colors.red),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _turnController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: winner == null ? _turnScale.value : 1.0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 28, vertical: 12),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: statusColor,
                          width: winner == null ? 3 : 2,
                        ),
                        boxShadow: winner == null
                            ? [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: boardSize,
                height: boardSize,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: 9,
                  itemBuilder: (context, i) {
                    final value = board[i];
                    final isWinning = winningCells.contains(i);
                    return GestureDetector(
                      onTap: () => tap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOutBack,
                        decoration: BoxDecoration(
                          color: isWinning
                              ? playerColor(value).withValues(alpha: 0.25)
                              : value.isEmpty
                                  ? Colors.white
                                  : playerColor(value).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isWinning
                                ? playerColor(value)
                                : value.isEmpty
                                    ? Colors.blue.shade200
                                    : playerColor(value),
                            width: isWinning ? 3.5 : 2,
                          ),
                          boxShadow: isWinning
                              ? [
                                  BoxShadow(
                                    color: playerColor(value)
                                        .withValues(alpha: 0.4),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Center(
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.elasticOut,
                            scale: value.isEmpty ? 0.8 : 1.0,
                            child: Text(
                              value,
                              style: TextStyle(
                                fontSize: boardSize / 5.2,
                                fontWeight: FontWeight.bold,
                                color: playerColor(value),
                                shadows: isWinning
                                    ? [
                                        Shadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.2),
                                          blurRadius: 4,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              if (moveHistory.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Hamle Geçmişi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        alignment: WrapAlignment.center,
                        children: moveHistory.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final pos = entry.value;
                          final movePlayer = idx % 2 == 0 ? 'X' : 'O';
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color:
                                  playerColor(movePlayer).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${idx + 1}. $movePlayer (${pos + 1})',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: playerColor(movePlayer),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: resetRound,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Yeni Tur'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: resetAll,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        icon: const Icon(Icons.restart_alt),
                        label: const Text('Tümünü Sıfırla'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreCard(String label, int score, Color color) {
    return Container(
      width: 95,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
