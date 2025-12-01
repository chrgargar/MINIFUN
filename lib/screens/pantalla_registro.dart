import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'pantalla_principal.dart';

// Pantalla de registro de nuevos usuarios
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // Para guardar lo que escribe el usuario
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Variables para guardar mensajes de error
  String? _usernameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void dispose() {
    // Para liberar recursos de los objetos
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Validar el nombre de usuario
  String? _validarUsuario(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa un usuario';
    }
    if (value.length < 3) {
      return 'El usuario debe tener al menos 3 caracteres';
    }
    return null; // Si es null es que no hay errores
  }

  // Validar email (ahora es opcional)
  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email es opcional
    }
    if (!value.contains('@')) {
      return 'Ingresa un correo válido';
    }
    // Validar formato
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido (ejemplo@dominio.com)';
    }
    return null; // null = sin errores
  }

  // Validar contraseña (simplificado a 6 caracteres)
  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa una contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Validar que las contraseñas coincidan
  String? _validarConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null; // null = sin errores
  }

  // Función que se ejecuta al presionar Crear Cuenta
  Future<void> _crearCuenta() async {
    setState(() {
      // Validar campos
      _usernameError = _validarUsuario(_usernameController.text);
      _emailError = _validarEmail(_emailController.text);
      _passwordError = _validarPassword(_passwordController.text);
      _confirmPasswordError = _validarConfirmPassword(_confirmPasswordController.text);
    });

    // Si hay errores, no continuar
    if (_usernameError != null ||
        _emailError != null ||
        _passwordError != null ||
        _confirmPasswordError != null) {
      return;
    }

    // Registrar usuario en la base de datos
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (success && mounted) {
      // Registro exitoso, navegar a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PantallaPrincipal()),
      );
    } else if (mounted) {
      // Mostrar error del provider
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Error al registrarse'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera morada con icono de usuario
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF7B68B8), // Morado
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF5B4A8B), width: 3),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    size: 60,
                    color: Color(0xFF7B68B8),
                  ),
                ),
              ),
            ),

            // Formulario de registro
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Título del formulario
                  const Text(
                    'Añade tus datos para\ncrear una cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Campo de nombre de usuario
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Usuario',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          // Borde cuando no está enfocado
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _usernameError == null ? Colors.grey[300]! : Colors.red,
                            ),
                          ),
                          // Borde cuando está enfocado
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _usernameError == null ? const Color(0xFF7B68B8) : Colors.red,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        // Revalidar mientras el usuario escribe
                        onChanged: (value) {
                          if (_usernameError != null) {
                            setState(() {
                              _usernameError = _validarUsuario(value);
                            });
                          }
                        },
                      ),
                      // Mostrar mensaje de error si existe
                      if (_usernameError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            _usernameError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Campo de email
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'correoelectrónico@dominio.com',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _emailError == null ? Colors.grey[300]! : Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _emailError == null ? const Color(0xFF7B68B8) : Colors.red,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        // Revalidar mientras el usuario escribe
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() {
                              _emailError = _validarEmail(value);
                            });
                          }
                        },
                      ),
                      // Mostrar mensaje de error si existe
                      if (_emailError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            _emailError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo de contraseña
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: _obscurePassword, // Ocultar contraseña con puntos
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null ? Colors.grey[300]! : Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null ? const Color(0xFF7B68B8) : Colors.red,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onChanged: (value) {
                          // Revalidar la contraseña mientras escribe
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = _validarPassword(value);
                            });
                          }
                          // También revalidar confirmación si ya fue llenada
                          if (_confirmPasswordController.text.isNotEmpty && _confirmPasswordError != null) {
                            setState(() {
                              _confirmPasswordError = _validarConfirmPassword(_confirmPasswordController.text);
                            });
                          }
                        },
                      ),
                      // Mostrar mensaje de error si existe
                      if (_passwordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            _passwordError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Campo de confirmar contraseña
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword, // Ocultar contraseña con puntos
                        decoration: InputDecoration(
                          hintText: 'Confirmar contraseña',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _confirmPasswordError == null ? Colors.grey[300]! : Colors.red,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _confirmPasswordError == null ? const Color(0xFF7B68B8) : Colors.red,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        // Revalidar mientras el usuario escribe
                        onChanged: (value) {
                          if (_confirmPasswordError != null) {
                            setState(() {
                              _confirmPasswordError = _validarConfirmPassword(value);
                            });
                          }
                        },
                      ),
                      // Mostrar mensaje de error si existe
                      if (_confirmPasswordError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 12),
                          child: Text(
                            _confirmPasswordError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Botón "Crear Cuenta"
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _crearCuenta,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
