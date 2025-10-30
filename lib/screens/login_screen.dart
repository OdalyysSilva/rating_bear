import 'package:flutter/material.dart'; //importa los widgets y estilos de flutter
//Para las animaciones de rive
import 'package:rive/rive.dart';

class RatingBear extends StatefulWidget {
  const RatingBear({super.key});

  @override
  State<RatingBear> createState() => _RatingBearState();
} //Si se quita la pantalla no existe

class _RatingBearState extends State<RatingBear> {
  int selectedStars = 0; //Almacena estrellas
  StateMachineController? controller; //controla la animación
  SMITrigger? trigFail; // para tristeza
  SMITrigger? trigSuccess; // para felicidad
  SMIBool? isCheking; // para neutral
  SMINumber? numLook; // controla la dirección de los ojos

  bool _isAnimating = false; // para reaccion rápida

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  } //Liberar recursos

  // Carga el archivo Rive y obtiene los controles
  void _onRiveInit(Artboard artboard) {
    controller = StateMachineController.fromArtboard(
      artboard,
      'Login Machine',
    ); //Busca la máquina de estados
    if (controller == null) return;
    artboard.addController(controller!);

    trigFail = controller!.findSMI<SMITrigger>('trigFail');
    trigSuccess = controller!.findSMI<SMITrigger>('trigSuccess');
    isCheking = controller!.findSMI<SMIBool>('isCheking');
    numLook = controller!.findSMI<SMINumber>('numLook');
    //Si se quita, el oso no mostrará sus animaciones
  }

  // Cambia el estado del oso según la calificación
  void _updateBearEmotion() async {
    if (_isAnimating) return; // evita disparos dobles
    _isAnimating = true;

    // Aplica la emoción según la calificación
    if (selectedStars <= 2) {
      trigFail?.fire(); //Dispara cuando ve que son 1 o 2 estrellas
      isCheking?.value = false;
    } else if (selectedStars == 3) {
      isCheking?.value = true; //Cuando son tres se queda normal
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
    //Si el biuld se quita, no muestra nada
    return Scaffold(
      //Base visual
      backgroundColor: Colors.white, //Color del fondo
      body: Center(
        //Para que el contenido no se superponga
        child: Padding(
          //Margenes
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Oso animado con Rive
              SizedBox(
                height: 220,
                child: RiveAnimation.asset(
                  'assets/animated_login_character.riv',
                  stateMachines: ["Login Machine"],
                  fit: BoxFit.contain,
                  onInit: _onRiveInit, //Conecta los triggers
                ),
              ),
              const SizedBox(height: 16),

              // Texto principal
              const Text(
                //crea un widget de texto, const significa que no cambiará
                'Enjoying Sounter?',
                style: TextStyle(
                  fontSize: 22, //Tamaño
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8), //Espacio vertical, separación
              // Texto secundario
              const Text(
                'With how many stars do you rate your experience?\nTap a star to rate!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),
              const SizedBox(height: 20),

              // Estrellas interactivas
              Row(
                mainAxisAlignment: MainAxisAlignment.center, //Alinea al centro
                children: List.generate(5, (index) {
                  //Genera las estrellitas
                  final starIndex = index + 1; //Para que no comience en 0
                  return IconButton(
                    iconSize: 40, //Tamaño de la estrella
                    icon: Icon(
                      Icons.star,
                      color: selectedStars >= starIndex
                          ? Colors.amber
                          : Colors.grey.shade300,
                    ),
                    onPressed: () async {
                      //Define la acción cuando se toca una estrella
                      if (_isAnimating) return; // bloquea taps rápidos
                      setState(() {
                        selectedStars = starIndex;
                      }); //Refleja al presionar una estrella
                      _updateBearEmotion(); //El oso reacciona al presionar
                    },
                  );
                }),
              ),
              const SizedBox(height: 20),

              // Botón "Rate now"
              SizedBox(
                //Controla el botón
                width: double.infinity, //Para ocupar todo el espacio disponible
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    //Dar apariencia del botón
                    backgroundColor: const Color(0xFF5C6BC0),
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                    ), //Margenes
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    //Define que pasa al presionar el boton
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        //Al seleccionar el botón muestra un mnesaje con la cantidad de estrellas que elegimos
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
                      fontSize: 16, //Tamaño
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
          //Botón sin relleno
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF5C6BC0), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ), //Margen del interior
          ),
          onPressed: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Maybe next time 😅')));
          }, //Cuando se selecciona muestra el mensaje
          child: const Text(
            'NO THANKS',
            style: TextStyle(
              color: Color(0xFF5C6BC0),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1, //Separa un poco las letras
            ),
          ),
        ),
      ),
    );
  }
}
