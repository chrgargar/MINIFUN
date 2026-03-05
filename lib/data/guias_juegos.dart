import '../widgets/guia_juego_dialog.dart';
import '../constants/app_strings.dart';

/// Contiene todas las guías de los juegos
class GuiasJuegos {
  // Controles de Snake traducidos
  static List<ControlItem> getSnakeControles(String lang) {
    return [
      ControlItem(
        icon: '⬆️',
        name: AppStrings.get('control_up', lang),
        description: AppStrings.get('control_up_desc', lang),
      ),
      ControlItem(
        icon: '⬇️',
        name: AppStrings.get('control_down', lang),
        description: AppStrings.get('control_down_desc', lang),
      ),
      ControlItem(
        icon: '⬅️',
        name: AppStrings.get('control_left', lang),
        description: AppStrings.get('control_left_desc', lang),
      ),
      ControlItem(
        icon: '➡️',
        name: AppStrings.get('control_right', lang),
        description: AppStrings.get('control_right_desc', lang),
      ),
      ControlItem(
        icon: '🎮',
        name: AppStrings.get('control_joystick', lang),
        description: AppStrings.get('control_joystick_desc', lang),
      ),
    ];
  }

  // Controles de Sudoku traducidos
  static List<ControlItem> getSudokuControles(String lang) {
    return [
      ControlItem(
        icon: '👆',
        name: AppStrings.get('control_select_cell', lang),
        description: AppStrings.get('control_select_cell_desc', lang),
      ),
      ControlItem(
        icon: '✏️',
        name: AppStrings.get('control_pencil', lang),
        description: AppStrings.get('control_pencil_desc', lang),
      ),
      ControlItem(
        icon: '📝',
        name: AppStrings.get('control_notes', lang),
        description: AppStrings.get('control_notes_desc', lang),
      ),
      ControlItem(
        icon: '1️⃣',
        name: AppStrings.get('control_place_number', lang),
        description: AppStrings.get('control_place_number_desc', lang),
      ),
      ControlItem(
        icon: '🔙',
        name: AppStrings.get('control_erase', lang),
        description: AppStrings.get('control_erase_desc', lang),
      ),
      ControlItem(
        icon: '💡',
        name: AppStrings.get('control_hint', lang),
        description: AppStrings.get('control_hint_desc', lang),
      ),
    ];
  }

  // Controles de Water Sort traducidos
  static List<ControlItem> getWaterSortControles(String lang) {
    return [
      ControlItem(
        icon: '👆',
        name: AppStrings.get('control_select', lang),
        description: AppStrings.get('control_select_desc', lang),
      ),
      ControlItem(
        icon: '💧',
        name: AppStrings.get('control_pour', lang),
        description: AppStrings.get('control_pour_desc', lang),
      ),
      ControlItem(
        icon: '↩️',
        name: AppStrings.get('control_undo', lang),
        description: AppStrings.get('control_undo_desc', lang),
      ),
      ControlItem(
        icon: '🔄',
        name: AppStrings.get('control_restart', lang),
        description: AppStrings.get('control_restart_desc', lang),
      ),
    ];
  }

  // Controles de Sopa de Letras traducidos
  static List<ControlItem> getWordSearchControles(String lang) {
    return [
      ControlItem(
        icon: '👆',
        name: AppStrings.get('control_select_start', lang),
        description: AppStrings.get('control_select_start_desc', lang),
      ),
      ControlItem(
        icon: '👆👆',
        name: AppStrings.get('control_drag', lang),
        description: AppStrings.get('control_drag_desc', lang),
      ),
    ];
  }

  // Controles de Ahorcado traducidos
  static List<ControlItem> getHangmanControles(String lang) {
    return [
      ControlItem(
        icon: '🔤',
        name: AppStrings.get('control_guess_letter', lang),
        description: AppStrings.get('control_guess_letter_desc', lang),
      ),
      ControlItem(
        icon: '🔄',
        name: AppStrings.get('control_restart', lang),
        description: AppStrings.get('control_restart_desc', lang),
      ),
    ];
  }

  // Controles de Buscaminas traducidos
  static List<ControlItem> getBuscaminasControles(String lang) {
    return [
      ControlItem(
        icon: '👆',
        name: AppStrings.get('control_reveal', lang),
        description: AppStrings.get('control_reveal_desc', lang),
      ),
      ControlItem(
        icon: '🚩',
        name: AppStrings.get('control_flag', lang),
        description: AppStrings.get('control_flag_desc', lang),
      ),
      ControlItem(
        icon: '💡',
        name: AppStrings.get('control_hint', lang),
        description: AppStrings.get('control_hint_desc', lang),
      ),
      ControlItem(
        icon: '🔄',
        name: AppStrings.get('control_restart', lang),
        description: AppStrings.get('control_restart_desc', lang),
      ),
    ];
  }
}
