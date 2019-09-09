# Flutter Tetris

A basic tetris clone done in Flutter as a personal learning project

## Flutter version and dependencies

- Flutter 1.7.8+hotfix.4
- frideos: ^0.7.0+1 - Helpers for managing streams (based on and compatible with rxDart)
- collection: ^1.14.11 - used to compare Lists and Maps
- vector_math: ^2.0.8 - used to manage block rotation

## Get Started

Compile and run file

## Gameplay Features
[x] use random generator compliant with Tetris guidelines to generate block order
[x] on contact, allow delay before locking piece
[x] rotate piece
[x] wall & block detection
[x] wall & block detection on rotation
[x] hard drop
[] fast drop
[x] t-spin
[] ghost piece
[] pause game


## UX features
[] background music
[] sound effect
[] scores
[] save high score
[] themes
[] start screen
[] settings screen

## Other improvements
[] Refactor variable names for clarity
[x] DRY up code (sort of)
[x] Refactor Bloc
[] use provider library, or Didier Boelens's BlocProvider
[] write unit tests


## Known bugs
[x] rotation wall detection flaky
[x] rotation of I block not correctly centered

