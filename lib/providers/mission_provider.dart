import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum MissionType { playGames, completeLevels, reachScore, findWords, discoverMines }

class Mission {
  final String id;
  final String titleKey; // Clave de traducción
  final int goal;
  int progress;
  final String gameType; // 'snake', 'watersort', 'sudoku', 'ahorcado', 'buscaminas', 'sopadeletras', 'any'
  final MissionType type;
  bool isCompleted;

  Mission({
    required this.id,
    required this.titleKey,
    required this.goal,
    this.progress = 0,
    required this.gameType,
    required this.type,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titleKey': titleKey,
      'goal': goal,
      'progress': progress,
      'gameType': gameType,
      'type': type.index,
      'isCompleted': isCompleted,
    };
  }

  factory Mission.fromMap(Map<String, dynamic> map) {
    return Mission(
      id: map['id'],
      titleKey: map['titleKey'],
      goal: map['goal'],
      progress: map['progress'],
      gameType: map['gameType'],
      type: MissionType.values[map['type']],
      isCompleted: map['isCompleted'],
    );
  }
}

class MissionProvider with ChangeNotifier {
  List<Mission> _dailyMissions = [];
  int _streak = 0;
  String? _lastCompletionDate;
  bool _isLoading = true;
  int? _currentUserId;

  List<Mission> get dailyMissions => _dailyMissions;
  int get streak => _streak;
  bool get isLoading => _isLoading;

  int get completedMissionsCount => _dailyMissions.where((m) => m.isCompleted).length;
  int get totalMissionsCount => _dailyMissions.length;
  double get progressPercentage => _dailyMissions.isEmpty ? 0 : completedMissionsCount / _dailyMissions.length;

  // Misiones disponibles por tipo de juego
  static final List<Map<String, dynamic>> _missionTemplates = [
    // Snake
    {'titleKey': 'mission_snake_play', 'goal': 3, 'gameType': 'snake', 'type': MissionType.playGames},
    {'titleKey': 'mission_snake_score', 'goal': 50, 'gameType': 'snake', 'type': MissionType.reachScore},
    {'titleKey': 'mission_snake_score_high', 'goal': 100, 'gameType': 'snake', 'type': MissionType.reachScore},

    // WaterSort
    {'titleKey': 'mission_watersort_levels', 'goal': 2, 'gameType': 'watersort', 'type': MissionType.completeLevels},
    {'titleKey': 'mission_watersort_levels_more', 'goal': 5, 'gameType': 'watersort', 'type': MissionType.completeLevels},

    // Sudoku
    {'titleKey': 'mission_sudoku_complete', 'goal': 1, 'gameType': 'sudoku', 'type': MissionType.completeLevels},
    {'titleKey': 'mission_sudoku_complete_more', 'goal': 3, 'gameType': 'sudoku', 'type': MissionType.completeLevels},

    // Ahorcado
    {'titleKey': 'mission_hangman_win', 'goal': 2, 'gameType': 'ahorcado', 'type': MissionType.completeLevels},
    {'titleKey': 'mission_hangman_win_more', 'goal': 5, 'gameType': 'ahorcado', 'type': MissionType.completeLevels},

    // Buscaminas
    {'titleKey': 'mission_minesweeper_win', 'goal': 1, 'gameType': 'buscaminas', 'type': MissionType.completeLevels},
    {'titleKey': 'mission_minesweeper_discover', 'goal': 20, 'gameType': 'buscaminas', 'type': MissionType.discoverMines},

    // Sopa de Letras
    {'titleKey': 'mission_wordsearch_words', 'goal': 10, 'gameType': 'sopadeletras', 'type': MissionType.findWords},
    {'titleKey': 'mission_wordsearch_complete', 'goal': 2, 'gameType': 'sopadeletras', 'type': MissionType.completeLevels},

    // Cualquier juego
    {'titleKey': 'mission_any_play', 'goal': 5, 'gameType': 'any', 'type': MissionType.playGames},
    {'titleKey': 'mission_any_score', 'goal': 100, 'gameType': 'any', 'type': MissionType.reachScore},
  ];

  Future<void> init(int? userId) async {
    if (userId == null) {
      _dailyMissions = [];
      _streak = 0;
      _isLoading = false;
      _currentUserId = null;
      notifyListeners();
      return;
    }

    _currentUserId = userId;
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();

    // Cargar racha
    _streak = prefs.getInt('user_${userId}_streak') ?? 0;
    _lastCompletionDate = prefs.getString('user_${userId}_last_completion');

    // Verificar si la racha se rompió (más de 1 día sin completar)
    if (_lastCompletionDate != null) {
      final lastDate = DateTime.parse(_lastCompletionDate!);
      final difference = DateTime.now().difference(lastDate).inDays;
      if (difference > 1) {
        _streak = 0;
        await prefs.setInt('user_${userId}_streak', 0);
      }
    }

    // Cargar o generar misiones para hoy
    final missionsJson = prefs.getString('user_${userId}_missions_$today');
    if (missionsJson != null) {
      final List<dynamic> decoded = jsonDecode(missionsJson);
      _dailyMissions = decoded.map((m) => Mission.fromMap(m)).toList();
    } else {
      _generateDailyMissions(userId, today);
      await _saveMissions(userId, today);
    }

    _isLoading = false;
    notifyListeners();
  }

  String _getTodayString() {
    final now = DateTime.now();
    return "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  void _generateDailyMissions(int userId, String date) {
    // Usar fecha + userId como semilla para generar misiones consistentes durante el día
    final seed = date.hashCode + userId;
    final random = Random(seed);

    // Barajar las plantillas y seleccionar 4 misiones únicas
    final shuffled = List<Map<String, dynamic>>.from(_missionTemplates);
    shuffled.shuffle(random);

    // Asegurar variedad: máximo 1 misión por tipo de juego (excepto 'any')
    final selectedGameTypes = <String>{};
    final selected = <Map<String, dynamic>>[];

    for (var template in shuffled) {
      final gameType = template['gameType'] as String;
      if (gameType == 'any' || !selectedGameTypes.contains(gameType)) {
        selected.add(template);
        if (gameType != 'any') {
          selectedGameTypes.add(gameType);
        }
        if (selected.length >= 4) break;
      }
    }

    _dailyMissions = selected.asMap().entries.map((entry) {
      final i = entry.key;
      final template = entry.value;
      return Mission(
        id: 'm${i + 1}_$date',
        titleKey: template['titleKey'],
        goal: template['goal'],
        gameType: template['gameType'],
        type: template['type'],
      );
    }).toList();
  }

  Future<void> _saveMissions(int userId, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = jsonEncode(_dailyMissions.map((m) => m.toMap()).toList());
    await prefs.setString('user_${userId}_missions_$date', missionsJson);
  }

  /// Notifica una actividad al sistema de misiones
  /// [gameType]: 'snake', 'watersort', 'sudoku', 'ahorcado', 'buscaminas', 'sopadeletras'
  /// [activityType]: tipo de actividad realizada
  /// [value]: valor a sumar (por defecto 1)
  Future<void> notifyActivity({
    required String gameType,
    required MissionType activityType,
    int value = 1
  }) async {
    if (_currentUserId == null) return;

    bool changed = false;
    final today = _getTodayString();

    for (var mission in _dailyMissions) {
      if (!mission.isCompleted &&
          (mission.gameType == gameType || mission.gameType == 'any') &&
          mission.type == activityType) {

        mission.progress += value;
        if (mission.progress >= mission.goal) {
          mission.progress = mission.goal;
          mission.isCompleted = true;
        }
        changed = true;
      }
    }

    if (changed) {
      await _saveMissions(_currentUserId!, today);

      // Verificar si se completaron todas las misiones para aumentar racha
      if (_dailyMissions.every((m) => m.isCompleted)) {
        await _updateStreak(_currentUserId!, today);
      }

      notifyListeners();
    }
  }

  Future<void> _updateStreak(int userId, String today) async {
    if (_lastCompletionDate == today) return;

    final prefs = await SharedPreferences.getInstance();

    if (_lastCompletionDate != null) {
      final lastDate = DateTime.parse(_lastCompletionDate!);
      final difference = DateTime.now().difference(lastDate).inDays;

      if (difference == 1) {
        _streak++;
      } else if (difference > 1) {
        _streak = 1;
      }
    } else {
      _streak = 1;
    }

    _lastCompletionDate = today;
    await prefs.setInt('user_${userId}_streak', _streak);
    await prefs.setString('user_${userId}_last_completion', today);
    notifyListeners();
  }

  /// Reinicia las misiones (para testing o debug)
  Future<void> resetMissions() async {
    if (_currentUserId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();

    await prefs.remove('user_${_currentUserId}_missions_$today');
    await init(_currentUserId);
  }
}
