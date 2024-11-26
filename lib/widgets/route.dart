import 'package:flutter/material.dart';
import 'package:nihogo_geemu/game_state.dart';
import 'package:nihogo_geemu/question_page.dart';

Route createRoute(GameState gameState) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
        QuestionPage(
          gameState: gameState,
        ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }


