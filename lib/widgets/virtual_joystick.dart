import 'package:flutter/material.dart';

/// Widget reutilizable de joystick virtual para controles de dirección
/// Útil para juegos que requieren movimiento en 4 direcciones (arriba, abajo, izquierda, derecha)
class VirtualJoystick extends StatelessWidget {
  final VoidCallback? onUpPressed;
  final VoidCallback? onDownPressed;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final Color backgroundColor;
  final Color buttonColor;
  final Color iconColor;
  final double size;

  const VirtualJoystick({
    super.key,
    this.onUpPressed,
    this.onDownPressed,
    this.onLeftPressed,
    this.onRightPressed,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.buttonColor = const Color(0xFF7B3FF2),
    this.iconColor = Colors.white,
    this.size = 280, // Aumentado de 200 a 280
  });

  @override
  Widget build(BuildContext context) {
    // Botones (32% del tamaño total)
    final buttonSize = size * 0.32;
    final centerSpace = size * 0.15;
    // Mayor espaciado entre botones (botones más separados del borde)
    final buttonOffset = size * 0.02;

    return Center(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor.withOpacity(0.5),
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: buttonColor.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Botón ARRIBA
            Positioned(
              top: buttonOffset,
              left: (size - buttonSize) / 2,
              child: _buildDirectionButton(
                icon: Icons.arrow_drop_up,
                onPressed: onUpPressed,
                size: buttonSize,
              ),
            ),
            // Botón ABAJO
            Positioned(
              bottom: buttonOffset,
              left: (size - buttonSize) / 2,
              child: _buildDirectionButton(
                icon: Icons.arrow_drop_down,
                onPressed: onDownPressed,
                size: buttonSize,
              ),
            ),
            // Botón IZQUIERDA
            Positioned(
              left: buttonOffset,
              top: (size - buttonSize) / 2,
              child: _buildDirectionButton(
                icon: Icons.arrow_left,
                onPressed: onLeftPressed,
                size: buttonSize,
              ),
            ),
            // Botón DERECHA
            Positioned(
              right: buttonOffset,
              top: (size - buttonSize) / 2,
              child: _buildDirectionButton(
                icon: Icons.arrow_right,
                onPressed: onRightPressed,
                size: buttonSize,
              ),
            ),
            // Centro decorativo
            Container(
              width: centerSpace,
              height: centerSpace,
              decoration: BoxDecoration(
                color: buttonColor.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: buttonColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required double size,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: buttonColor.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.65, // Iconos un poco más grandes
        ),
      ),
    );
  }
}

/// Variante alternativa: D-Pad (cruz direccional estilo consola)
class VirtualDPad extends StatelessWidget {
  final VoidCallback? onUpPressed;
  final VoidCallback? onDownPressed;
  final VoidCallback? onLeftPressed;
  final VoidCallback? onRightPressed;
  final Color backgroundColor;
  final Color buttonColor;
  final Color iconColor;
  final double size;

  const VirtualDPad({
    super.key,
    this.onUpPressed,
    this.onDownPressed,
    this.onLeftPressed,
    this.onRightPressed,
    this.backgroundColor = const Color(0xFF1E1E1E),
    this.buttonColor = const Color(0xFF7B3FF2),
    this.iconColor = Colors.white,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = size * 0.35;
    final buttonHeight = size * 0.25;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Fila superior: ARRIBA
          _buildDPadButton(
            icon: Icons.keyboard_arrow_up,
            onPressed: onUpPressed,
            width: buttonWidth,
            height: buttonHeight,
          ),
          // Fila central: IZQUIERDA, espacio, DERECHA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildDPadButton(
                icon: Icons.keyboard_arrow_left,
                onPressed: onLeftPressed,
                width: buttonWidth,
                height: buttonHeight,
              ),
              SizedBox(width: buttonWidth * 0.3),
              _buildDPadButton(
                icon: Icons.keyboard_arrow_right,
                onPressed: onRightPressed,
                width: buttonWidth,
                height: buttonHeight,
              ),
            ],
          ),
          // Fila inferior: ABAJO
          _buildDPadButton(
            icon: Icons.keyboard_arrow_down,
            onPressed: onDownPressed,
            width: buttonWidth,
            height: buttonHeight,
          ),
        ],
      ),
    );
  }

  Widget _buildDPadButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required double width,
    required double height,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: buttonColor.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: height * 0.8,
        ),
      ),
    );
  }
}
