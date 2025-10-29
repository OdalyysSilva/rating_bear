import 'package:flutter/material.dart';

import 'package:rive/rive.dart';

class RatingBear extends StatefulWidget {
  const RatingBear({super.key});

  @override
  State<RatingBear> createState() => _RatingBearState();
}

class _RatingBearState extends State<RatingBear> {
  int selectedStars = 0;
  StateMachineController? controller;
  SMITrigger? trigFail; // para tristeza
  SMITrigger? trigSuccess; // para felicidad
  SMIBool? isCheking; // para neutral

  bool _isAnimating = false; // para reaccion rápida

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Carga el archivo Rive y obtiene los controles
  void _onRiveInit(Artboard artboard) {
    controller = StateMachineController.fromArtboard(artboard, 'Login Machine');
    if (controller == null) return;
    artboard.addController(controller!);

    trigFail = controller!.findSMI<SMITrigger>('trigFail');
    trigSuccess = controller!.findSMI<SMITrigger>('trigSuccess');
    isCheking = controller!.findSMI<SMIBool>('isCheking');
  }

  // Cambia el estado del oso según la calificación
  void _updateBearEmotion() async {
    if (_isAnimating) return; // evita disparos dobles
    _isAnimating = true;

    // Aplica la emoción según la calificación
    if (selectedStars <= 2) {
      trigFail?.fire();
      isCheking?.value = false;
    } else if (selectedStars == 3) {
      isCheking?.value = true;
    } else {
      trigSuccess?.fire();
      isCheking?.value = false;
    }

    // Espera un instante corto antes de permitir otra animación
    await Future.delayed(const Duration(milliseconds: 200));
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Oso animado con Rive
              SizedBox(
                height: 220,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                ),
              ),
              const SizedBox(height: 16),

              // Texto principal
              const Text(
                'Enjoying Sounter?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Texto secundario
              const Text(
                'With how many stars do you rate your experience?\nTap a star to rate!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Estrellas interactivas
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return IconButton(
                    iconSize: 40,
                    icon: Icon(
                      Icons.star,
                      color: selectedStars >= starIndex
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                    onPressed: () async {
                      if (_isAnimating) return; // bloquea taps rápidos
                      setState(() {
                        selectedStars = starIndex;
                      });
                      _updateBearEmotion();
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Botón "Rate now"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5C6BC0),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          selectedStars > 0
                              ? 'You rated $selectedStars star(s)!'
                              : 'Please select a rating first.',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Rate now',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      // Botón del final
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: OutlinedButton(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Maybe next time 😅')));
          },
          child: const Text(
            'NO THANKS',
            style: TextStyle(
              color: Color(0xFF5C6BC0),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
