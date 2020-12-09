import 'package:flutter/animation.dart';

class HomeAnimator {
  final AnimationController controller;

  final Animation<double> nameYTranslation;
  final Animation<double> nameOpacity;

  final Animation<double> searchYTranslation;
  final Animation<double> searchOpacity;
  final Animation<double> searchCoursesXTranslation;
  final Animation<double> searchCoursesListOpacity;
  final Animation<double> studyingCoursesOpacity;
  final Animation<double> studyingCoursesYTranslation;
  final Animation<double> progressYTranslation;
  final Animation<double> progressOpacity;
  final Animation<double> progressSize;
  HomeAnimator(this.controller)
      : this.nameYTranslation = Tween(begin: 100.0, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.400,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        this.nameOpacity = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.300,
              curve: Curves.ease,
            ),
          ),
        ),
        this.searchYTranslation =
            Tween(begin: 220.0, end: 50.0).animate(CurvedAnimation(
                parent: controller,
                curve: Interval(
                  0.000,
                  0.400,
                  curve: Curves.fastOutSlowIn,
                ))),
        this.searchOpacity = Tween(begin: 0.5, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.400,
              curve: Curves.ease,
            ),
          ),
        ),
        this.studyingCoursesYTranslation =
            Tween(begin: 300.0, end: 600.0).animate(CurvedAnimation(
                parent: controller,
                curve: Interval(
                  0.000,
                  0.300,
                  curve: Curves.fastOutSlowIn,
                ))),
        this.studyingCoursesOpacity = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.300,
              curve: Curves.ease,
            ),
          ),
        ),
        this.progressYTranslation = Tween(begin: 470.0, end: 387.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.400,
              curve: Curves.ease,
            ),
          ),
        ),
        this.progressOpacity = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.300,
              curve: Curves.ease,
            ),
          ),
        ),
        this.progressSize = Tween(begin: 60.0, end: 10.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.400,
              curve: Curves.ease,
            ),
          ),
        ),
        this.searchCoursesListOpacity = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.200,
              0.500,
              curve: Curves.ease,
            ),
          ),
        ),
        this.searchCoursesXTranslation =
            Tween(begin: 700.0, end: 100.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.200,
              0.500,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        );
}

class HomeListAnimator {
  final AnimationController controller;
  final Animation<double> coursesListXTranslation;
  final Animation<double> coursesListOpacity;
  HomeListAnimator(this.controller)
      : this.coursesListXTranslation = Tween(begin: 100.0, end: 8.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.500,
              curve: Curves.fastOutSlowIn,
            ),
          ),
        ),
        this.coursesListOpacity = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(
              0.000,
              0.500,
              curve: Curves.ease,
            ),
          ),
        );
}
