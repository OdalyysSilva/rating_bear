import 'package:flutter/material.dart';
import 'package:flutter_rating_bear/flutter_rating_bear.dart'
import 'package:rive/rive.dart';

class RatingBear extends StatefulWidget {
  const RatingBear({super.key});

  @override
  State<RatingBear> createState() => _RatingBearState();
}

class _RatingBearState extends State<RatingBear> {
  int selectedStars = 0;
  StateMachineController? controller;
  SMITrigger? trigFail;//sad
  SMITrigger? trigSuccess;//happy
  SMIBool? isCheking;//neutral

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // 🧠 Carga el archivo Rive y obtiene los controles
  void _onRiveInit(Artboard artboard) {
    controller = StateMachineController.fromArtboard(artboard, 'State Machine 1')!;
    artboard.addController(controller);

    trigFail = controller.findInput<bool>('isSad') as SMITrigger?;
    trigSuccess = controller.findInput<bool>('isHappy') as SMIBool?;
    isCheking = controller.findInput<bool>('isNeutral') as SMIBool?;
  }

  // 💫 Cambia el estado del oso según la calificación
  void _updateBearEmotion() {
    if (selectedStars <= 2) {
      trigFail?.value = true;
      trigSuccess?.value = false;
      isCheking?.value = false;
    } else if (selectedStars == 3) {
      isCheking?.value = true;
      trigFail?.value = false;
      trigSuccess?.value = false;
    } else {
      trigSuccess?.value = true;
      trigFail?.value = false;
      isCheking?.value = false;
    }
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
              // 🧸 Oso animado con Rive
              SizedBox(
                height: 220,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  fit: BoxFit.contain,
                  onInit: _onRiveInit,
                ),
              ),
              const SizedBox(height: 16),

              // 📝 Texto principal
              const Text(
                'Enjoying Sounter?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // 📄 Texto secundario
              const Text(
                'With how many stars do you rate your experience?\nTap a star to rate!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // ⭐ Estrellas interactivas
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
                    onPressed: () {
                      setState(() {
                        selectedStars = starIndex;
                        _updateBearEmotion();
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // 🟦 Botón "Rate now"
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
    );
  }
}
