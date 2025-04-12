// lib/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:todo_list_app/views/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  static const String route = 'OnboardingScreen';

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> contents = [
    {
      'title': "TO-DO LIST",
      'subtitle': "Bienvenue dans votre To-Do List !\nOrganisez vos tâches facilement.",
      'image': "images/slide1.webp",
      'color': const Color.fromARGB(255, 83, 177, 221), // Bleu clair
    },
    {
      'title': "TO-DO LIST",
      'subtitle': "Ajoutez, modifiez et supprimez\nvos tâches en un clin d'œil.",
      'image': "images/slide4.webp",
      'color': const Color(0xFFE1BEE7), // Violet clair
    },
    {
      'title': "TO-DO LIST",
      'subtitle': "Restez productif où que vous soyez,\nmême hors ligne !",
      'image': "images/slide3.jpg",
      'color': const Color.fromARGB(255, 119, 75, 145), // Cyan clair
    },
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: contents.length,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      contents[index]['color'] as Color,
                      (contents[index]['color'] as Color).withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Animate(
                        delay: Duration(milliseconds: index == 0 ? 0 : 500),
                        effects: index == 0
                            ? const [
                                FadeEffect(
                                    delay: Duration(milliseconds: 300),
                                    duration: Duration(milliseconds: 800)),
                                ScaleEffect(
                                    delay: Duration(milliseconds: 300),
                                    duration: Duration(milliseconds: 800)),
                                SlideEffect(
                                    begin: Offset(0, 0.2),
                                    end: Offset.zero,
                                    delay: Duration(milliseconds: 300),
                                    duration: Duration(milliseconds: 800)),
                                RotateEffect(
                                    begin: 0.1,
                                    end: 0,
                                    delay: Duration(milliseconds: 300),
                                    duration: Duration(milliseconds: 800)),
                              ]
                            : const [
                                FadeEffect(duration: Duration(milliseconds: 600)),
                                ScaleEffect(duration: Duration(milliseconds: 600)),
                              ],
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            contents[index]['image'],
                            height: size.height * 0.35,
                            width: size.height * 0.35,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(color: Colors.grey),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Animate(
                        delay: Duration(milliseconds: index == 0 ? 800 : 600),
                        effects: index == 0
                            ? const [
                                FadeEffect(
                                    delay: Duration(milliseconds: 200),
                                    duration: Duration(milliseconds: 800)),
                                SlideEffect(
                                    begin: Offset(0, 0.2),
                                    end: Offset.zero,
                                    delay: Duration(milliseconds: 200),
                                    duration: Duration(milliseconds: 800)),
                              ]
                            : const [
                                FadeEffect(duration: Duration(milliseconds: 600)),
                              ],
                        child: Text(
                          contents[index]['title'],
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 20),
                      Animate(
                        delay: Duration(milliseconds: index == 0 ? 1200 : 800),
                        effects: index == 0
                            ? const [
                                FadeEffect(
                                    delay: Duration(milliseconds: 200),
                                    duration: Duration(milliseconds: 800)),
                                SlideEffect(
                                    begin: Offset(0, 0.2),
                                    end: Offset.zero,
                                    delay: Duration(milliseconds: 200),
                                    duration: Duration(milliseconds: 800)),
                              ]
                            : const [
                                FadeEffect(duration: Duration(milliseconds: 600)),
                              ],
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              contents[index]['subtitle'],
                              textStyle: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                          isRepeatingAnimation: false,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: size.height * 0.15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                contents.length,
                (index) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: _currentPage == index ? 30 : 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ).animate().scale(duration: const Duration(milliseconds: 300)),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 30,
            child: _NextButton(
              controller: _controller,
              currentPage: _currentPage,
              totalPages: contents.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final PageController controller;
  final int currentPage;
  final int totalPages;

  const _NextButton({
    required this.controller,
    required this.currentPage,
    required this.totalPages,
  });

  @override
  Widget build(BuildContext context) {
    final isLastPage = currentPage == totalPages - 1;

    return GestureDetector(
      onTap: () async {
        if (isLastPage) {
          try {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isSeen', true);
          } catch (e) {
            print("Erreur lors de l'enregistrement de l'onboarding : $e");
          }
          Navigator.pushReplacementNamed(context, LoginScreen.route);
        } else {
          controller.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Animate(
        effects: const [
          FadeEffect(duration: Duration(milliseconds: 300)),
          ScaleEffect(duration: Duration(milliseconds: 300)),
        ],
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade700, Colors.green.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLastPage ? "COMMENCER" : "SUIVANT",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (!isLastPage) SizedBox(width: 4),
              if (!isLastPage)
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ),
    );
  }
}