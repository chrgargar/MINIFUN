import 'package:flutter/material.dart';
import '../screens/seleccion_modo.dart';

// Widget reutilizable para mostrar tarjeta de juego
class TarjetasJuegos extends StatelessWidget {
  final String title; // Título del juego
  final String? imagePath; // Ruta de la imagen opcional

  const TarjetasJuegos({
    super.key,
    required this.title, // El título es obligatorio
    this.imagePath, // La imagen es opcional
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
                    gameImagePath: imagePath ?? '',
                  ),
                ),
              );
            },
            splashColor: Colors.transparent, // Sin efecto de onda
            highlightColor: Colors.transparent, // Sin efecto al mantener presionado
            // Si hay imagen, mostrarla. Si no, muestra el título
            child: imagePath != null
                ? Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20), // Bordes redondeados
                      color: Colors.white, // Fondo blanco para la imagen
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20), // Bordes redondeados para la imagen
                      child: Image.asset(
                        imagePath!, // Muestra la imagen desde assets
                        fit: BoxFit.contain, // Ajustar la imagen completa sin recortar
                        width: double.infinity,
                        height: double.infinity,
                      ),
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
