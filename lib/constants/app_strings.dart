/// Clase que contiene todas las traducciones de la app
class AppStrings {
  static String get(String key, String language) {
    return _translations[language]?[key] ?? _translations['es']?[key] ?? key;
  }

  static const Map<String, Map<String, String>> _translations = {
    // ESPAÑOL
    'es': {
      // General
      'settings': 'Ajustes',
      'close': 'Cerrar',
      'play': 'Jugar',
      'guide': 'Guía',
      'back': 'Volver',
      'retry': 'Reintentar',
      'play_again': 'Jugar de nuevo',
      'exit_menu': 'Salir al menú',

      // Ajustes
      'dark_theme': 'Tema oscuro',
      'activated': 'Activado',
      'deactivated': 'Desactivado',
      'music_volume': 'Volumen de música',
      'effects_volume': 'Volumen de efectos',
      'mute_all': 'Silenciar todo',
      'muted': 'Silenciado',
      'with_sound': 'Con sonido',
      'streak': 'Racha',
      'consecutive_days': 'Días jugando consecutivos',
      'days': 'días',
      'play_as_guest': 'Jugar como invitado',
      'continue_without_account': 'Continuar sin cuenta',
      'switch_account': 'Cambiar de cuenta',
      'login_other_account': 'Iniciar sesión con otra cuenta',
      'language': 'Idioma',
      'select_language': 'Seleccionar idioma',

      // Mensajes
      'now_playing_as_guest': 'Ahora estás jugando como invitado',
      'error_guest_mode': 'Error al cambiar a modo invitado',

      // Selección de modo
      'select_mode': 'Selecciona\nModalidad',
      'time_attack': 'Contrarreloj',
      'perfect': 'Perfecto',
      'speed': 'Velocidad',
      'survival_pro': 'Supervivencia\nPRO',
      'perfect_pro': 'Perfecto\nPRO',
      'hard_pro': 'Difícil\nPRO',

      // Game Over
      'congratulations': '¡Felicidades!',
      'game_over': 'Game Over',
      'completed_in': 'Has completado el Sudoku en',
      'made_error': 'Cometiste un error. ¡Inténtalo de nuevo!',
      'time_up': '¡Se acabó el tiempo!',
      'try_again': 'Inténtalo de nuevo',
      'what_to_do': '¿Qué deseas hacer?',

      // Sudoku
      'pencil': 'Lápiz',
      'notes': 'Notas',
      'erase': 'Borrar',
      'hint': 'Pista',

      // Login
      'welcome': 'Bienvenido',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'login': 'Iniciar sesión',
      'register': 'Registrarse',
      'no_account': '¿No tienes cuenta?',
      'have_account': '¿Ya tienes cuenta?',
    },

    // ENGLISH
    'en': {
      // General
      'settings': 'Settings',
      'close': 'Close',
      'play': 'Play',
      'guide': 'Guide',
      'back': 'Back',
      'retry': 'Retry',
      'play_again': 'Play again',
      'exit_menu': 'Exit to menu',

      // Settings
      'dark_theme': 'Dark theme',
      'activated': 'Enabled',
      'deactivated': 'Disabled',
      'music_volume': 'Music volume',
      'effects_volume': 'Effects volume',
      'mute_all': 'Mute all',
      'muted': 'Muted',
      'with_sound': 'Sound on',
      'streak': 'Streak',
      'consecutive_days': 'Consecutive days playing',
      'days': 'days',
      'play_as_guest': 'Play as guest',
      'continue_without_account': 'Continue without account',
      'switch_account': 'Switch account',
      'login_other_account': 'Login with another account',
      'language': 'Language',
      'select_language': 'Select language',

      // Messages
      'now_playing_as_guest': 'Now playing as guest',
      'error_guest_mode': 'Error switching to guest mode',

      // Mode selection
      'select_mode': 'Select\nMode',
      'time_attack': 'Time Attack',
      'perfect': 'Perfect',
      'speed': 'Speed',
      'survival_pro': 'Survival\nPRO',
      'perfect_pro': 'Perfect\nPRO',
      'hard_pro': 'Hard\nPRO',

      // Game Over
      'congratulations': 'Congratulations!',
      'game_over': 'Game Over',
      'completed_in': 'You completed the Sudoku in',
      'made_error': 'You made an error. Try again!',
      'time_up': 'Time is up!',
      'try_again': 'Try again',
      'what_to_do': 'What would you like to do?',

      // Sudoku
      'pencil': 'Pencil',
      'notes': 'Notes',
      'erase': 'Erase',
      'hint': 'Hint',

      // Login
      'welcome': 'Welcome',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'register': 'Register',
      'no_account': "Don't have an account?",
      'have_account': 'Already have an account?',
    },

    // FRANÇAIS
    'fr': {
      // General
      'settings': 'Paramètres',
      'close': 'Fermer',
      'play': 'Jouer',
      'guide': 'Guide',
      'back': 'Retour',
      'retry': 'Réessayer',
      'play_again': 'Rejouer',
      'exit_menu': 'Quitter au menu',

      // Settings
      'dark_theme': 'Thème sombre',
      'activated': 'Activé',
      'deactivated': 'Désactivé',
      'music_volume': 'Volume de la musique',
      'effects_volume': 'Volume des effets',
      'mute_all': 'Tout couper',
      'muted': 'Coupé',
      'with_sound': 'Avec son',
      'streak': 'Série',
      'consecutive_days': 'Jours consécutifs joués',
      'days': 'jours',
      'play_as_guest': 'Jouer en invité',
      'continue_without_account': 'Continuer sans compte',
      'switch_account': 'Changer de compte',
      'login_other_account': 'Se connecter avec un autre compte',
      'language': 'Langue',
      'select_language': 'Sélectionner la langue',

      // Messages
      'now_playing_as_guest': 'Vous jouez maintenant en invité',
      'error_guest_mode': 'Erreur lors du passage en mode invité',

      // Mode selection
      'select_mode': 'Sélectionner\nle mode',
      'time_attack': 'Contre la montre',
      'perfect': 'Parfait',
      'speed': 'Vitesse',
      'survival_pro': 'Survie\nPRO',
      'perfect_pro': 'Parfait\nPRO',
      'hard_pro': 'Difficile\nPRO',

      // Game Over
      'congratulations': 'Félicitations!',
      'game_over': 'Fin de partie',
      'completed_in': 'Vous avez terminé le Sudoku en',
      'made_error': 'Vous avez fait une erreur. Réessayez!',
      'time_up': 'Le temps est écoulé!',
      'try_again': 'Réessayez',
      'what_to_do': 'Que voulez-vous faire?',

      // Sudoku
      'pencil': 'Crayon',
      'notes': 'Notes',
      'erase': 'Effacer',
      'hint': 'Indice',

      // Login
      'welcome': 'Bienvenue',
      'email': 'Email',
      'password': 'Mot de passe',
      'login': 'Connexion',
      'register': "S'inscrire",
      'no_account': "Pas de compte?",
      'have_account': 'Déjà un compte?',
    },

    // PORTUGUÊS
    'pt': {
      // General
      'settings': 'Configurações',
      'close': 'Fechar',
      'play': 'Jogar',
      'guide': 'Guia',
      'back': 'Voltar',
      'retry': 'Tentar novamente',
      'play_again': 'Jogar novamente',
      'exit_menu': 'Sair para o menu',

      // Settings
      'dark_theme': 'Tema escuro',
      'activated': 'Ativado',
      'deactivated': 'Desativado',
      'music_volume': 'Volume da música',
      'effects_volume': 'Volume dos efeitos',
      'mute_all': 'Silenciar tudo',
      'muted': 'Silenciado',
      'with_sound': 'Com som',
      'streak': 'Sequência',
      'consecutive_days': 'Dias consecutivos jogando',
      'days': 'dias',
      'play_as_guest': 'Jogar como convidado',
      'continue_without_account': 'Continuar sem conta',
      'switch_account': 'Trocar de conta',
      'login_other_account': 'Entrar com outra conta',
      'language': 'Idioma',
      'select_language': 'Selecionar idioma',

      // Messages
      'now_playing_as_guest': 'Agora você está jogando como convidado',
      'error_guest_mode': 'Erro ao mudar para modo convidado',

      // Mode selection
      'select_mode': 'Selecionar\nModo',
      'time_attack': 'Contra o tempo',
      'perfect': 'Perfeito',
      'speed': 'Velocidade',
      'survival_pro': 'Sobrevivência\nPRO',
      'perfect_pro': 'Perfeito\nPRO',
      'hard_pro': 'Difícil\nPRO',

      // Game Over
      'congratulations': 'Parabéns!',
      'game_over': 'Fim de jogo',
      'completed_in': 'Você completou o Sudoku em',
      'made_error': 'Você cometeu um erro. Tente novamente!',
      'time_up': 'O tempo acabou!',
      'try_again': 'Tente novamente',
      'what_to_do': 'O que você quer fazer?',

      // Sudoku
      'pencil': 'Lápis',
      'notes': 'Notas',
      'erase': 'Apagar',
      'hint': 'Dica',

      // Login
      'welcome': 'Bem-vindo',
      'email': 'Email',
      'password': 'Senha',
      'login': 'Entrar',
      'register': 'Registrar',
      'no_account': 'Não tem uma conta?',
      'have_account': 'Já tem uma conta?',
    },
  };
}
