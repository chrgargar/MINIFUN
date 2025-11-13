import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String? imagePath;

  const GameCard({
    super.key,
    required this.title,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: imagePath != null
              ? Image.asset(
                  imagePath!,
                  fit: BoxFit.cover,
                )
              : Container(
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
    );
  }
}
