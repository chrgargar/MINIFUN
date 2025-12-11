import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../tema/app_colors.dart';
import '../utils/validators.dart';
import 'pantalla_principal.dart';

// Pantalla de registro de nuevos usuarios
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  // Controladores de texto para los campos de entrada
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Estados de UI para ocultar/mostrar contraseñas
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Mensajes de error de validación
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
    return Validators.validateUsername(value);
  }

  // Validar email (ahora es opcional)
  String? _validarEmail(String? value) {
    return Validators.validateOptionalEmail(value);
  }

  // Validar contraseña
  String? _validarPassword(String? value) {
    return Validators.validatePassword(value);
  }

  // Validar que las contraseñas coincidan
  String? _validarConfirmPassword(String? value) {
    return Validators.validatePasswordMatch(_passwordController.text, value);
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
          backgroundColor: ColoresApp.rojoError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColoresApp.blanco,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cabecera morada con icono de usuario
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: ColoresApp.moradoLogin,
              ),
              child: Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: ColoresApp.blanco,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColoresApp.moradoLoginOscuro, width: 3),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    size: 60,
                    color: ColoresApp.moradoLogin,
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
                  Text(
                    'Añade tus datos para\ncrear una cuenta',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColoresApp.negro,
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
                          hintStyle: TextStyle(color: ColoresApp.gris400),
                          // Borde cuando no está enfocado
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _usernameError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                            ),
                          ),
                          // Borde cuando está enfocado
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _usernameError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
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
                            style: TextStyle(
                              color: ColoresApp.rojoError,
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
                          hintStyle: TextStyle(color: ColoresApp.gris400),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _emailError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _emailError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
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
                            style: TextStyle(
                              color: ColoresApp.rojoError,
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
                          hintStyle: TextStyle(color: ColoresApp.gris400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ColoresApp.gris600,
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
                              color: _passwordError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _passwordError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
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
                            style: TextStyle(
                              color: ColoresApp.rojoError,
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
                          hintStyle: TextStyle(color: ColoresApp.gris400),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: ColoresApp.gris600,
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
                              color: _confirmPasswordError == null ? ColoresApp.gris300 : ColoresApp.rojoError,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _confirmPasswordError == null ? ColoresApp.moradoLogin : ColoresApp.rojoError,
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
                            style: TextStyle(
                              color: ColoresApp.rojoError,
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
                        backgroundColor: ColoresApp.negro,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Crear Cuenta',
                        style: TextStyle(
                          color: ColoresApp.blanco,
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
