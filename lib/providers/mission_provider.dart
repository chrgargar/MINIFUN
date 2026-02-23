import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

enum MissionType { playGames, completeLevels, reachScore }

class Mission {
  final String id;
  final String title;
  final int goal;
  int progress;
  final String gameType; // 'snake', 'watersort', 'sudoku', etc.
  final MissionType type;
  bool isCompleted;

  Mission({
    required this.id,
    required this.title,
    required this.goal,
    this.progress = 0,
    required this.gameType,
    required this.type,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
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
      title: map['title'],
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
  String? _lastCompletionDate; // YYYY-MM-DD
  bool _isLoading = true;

  List<Mission> get dailyMissions => _dailyMissions;
  int get streak => _streak;
  bool get isLoading => _isLoading;

  int get completedMissionsCount => _dailyMissions.where((m) => m.isCompleted).length;
  double get progressPercentage => _dailyMissions.isEmpty ? 0 : completedMissionsCount / _dailyMissions.length;

  Future<void> init(int? userId) async {
    if (userId == null) {
      _dailyMissions = [];
      _streak = 0;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final today = _getTodayString();
    
    // Cargar racha
    _streak = prefs.getInt('user_${userId}_streak') ?? 0;
    _lastCompletionDate = prefs.getString('user_${userId}_last_completion');

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
    // Generar misiones basadas en la fecha para que sean iguales durante todo el día
    // Pero diferentes cada día. Usamos la fecha como semilla para el random
    final seed = date.hashCode + userId;
    final random = (seed % 100); // Simplificado

    _dailyMissions = [
      Mission(
        id: 'm1',
        title: 'Juega 3 partidas de Snake',
        goal: 3,
        gameType: 'snake',
        type: MissionType.playGames,
      ),
      Mission(
        id: 'm2',
        title: 'Completa 2 niveles de Water Sort',
        goal: 2,
        gameType: 'watersort',
        type: MissionType.completeLevels,
      ),
      Mission(
        id: 'm3',
        title: 'Alcanza 100 puntos en cualquier juego',
        goal: 100,
        gameType: 'any',
        type: MissionType.reachScore,
      ),
    ];
  }

  Future<void> _saveMissions(int userId, String date) async {
    final prefs = await SharedPreferences.getInstance();
    final missionsJson = jsonEncode(_dailyMissions.map((m) => m.toMap()).toList());
    await prefs.setString('user_${userId}_missions_$date', missionsJson);
  }

  Future<void> notifyActivity(int userId, {required String gameType, required MissionType activityType, int value = 1}) async {
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
          changed = true;
        } else {
          changed = true;
        }
      }
    }

    if (changed) {
      await _saveMissions(userId, today);
      
      // Verificar si se completaron todas las misiones para aumentar racha
      if (_dailyMissions.every((m) => m.isCompleted)) {
        await _updateStreak(userId, today);
      }
      
      notifyListeners();
    }
  }

  Future<void> _updateStreak(int userId, String today) async {
    if (_lastCompletionDate == today) return; // Ya completado hoy, no aumentar racha de nuevo

    final prefs = await SharedPreferences.getInstance();
    
    // Verificar si fue ayer para continuar racha o reiniciar
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
  }
}
