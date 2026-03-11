import 'package:flutter/material.dart';
import '../screens/seleccion_modo.dart';

// Widget reutilizable para mostrar tarjeta de juego
class TarjetasJuegos extends StatelessWidget {
  final String title; // Título del juego (localizado, solo para mostrar)
  final String gameKey; // Clave interna no localizada para enrutamiento
  final String? imagePath; // Ruta de la imagen opcional

  const TarjetasJuegos({
    super.key,
    required this.title,
    required this.gameKey,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click, // Cursor de mano con el ratón
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100), 
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Navegar a la pantalla de selección de modalidad
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SeleccionModo(
                    gameTitle: title,
                    gameKey: gameKey,
                    gameImagePath: imagePath ?? '',
                  ),
                ),
              );
            },
            splashColor: Colors.transparent, // Sin efecto de onda
            highlightColor: Colors.transparent, // Sin efecto al mantener presionado
            // Si hay imagen, mostrarla. Si no, muestra el título
            child: imagePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: Image.asset(
                            imagePath!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        // Filtro oscuro para modo oscuro
                        if (Theme.of(context).brightness == Brightness.dark)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                      ],
                    ),
                  )
                : Container(
                    // Si no hay imagen, mostrsar un fondo gris con el título
                    color: Colors.grey[300],
                    child: Center(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
