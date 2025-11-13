import 'package:flutter/material.dart';
import 'register_page.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo electrónico';
    }
    if (!value.contains('@')) {
      return 'Ingresa un correo válido';
    }
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un correo válido';
    }
    return null;
  }

  String? _validarPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    return null;
  }

  void _iniciarSesion() {
    setState(() {
      _emailError = _validarEmail(_emailController.text);
      _passwordError = _validarPassword(_passwordController.text);
    });

    if (_emailError == null && _passwordError == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }

  void _jugarComoInvitado() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: const BoxDecoration(
                color: Color(0xFF7B68B8),
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
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
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
                        onChanged: (value) {
                          if (_emailError != null) {
                            setState(() {
                              _emailError = _validarEmail(value);
                            });
                          }
                        },
                      ),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: 'Contraseña',
                          hintStyle: TextStyle(color: Colors.grey[400]),
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
                          if (_passwordError != null) {
                            setState(() {
                              _passwordError = _validarPassword(value);
                            });
                          }
                        },
                      ),
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
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Has olvidado la contraseña?',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Iniciar Sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey[300])),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'o',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey[300])),
                    ],
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const HomePage()),
                        );
                      },
                      icon: Image.network(
                        'https://www.svgrepo.com/show/303108/google-icon-logo.svg',
                        width: 24,
                        height: 24,
                      ),
                      label: const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: _jugarComoInvitado,
                    child: const Text(
                      'Jugar como invitado',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      children: [
                        const TextSpan(text: 'Al hacer clic en continuar, aceptas nuestros '),
                        TextSpan(
                          text: 'Términos de servicio',
                          style: TextStyle(color: Colors.blue),
                        ),
                        const TextSpan(text: ' y '),
                        TextSpan(
                          text: 'Política de privacidad',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
