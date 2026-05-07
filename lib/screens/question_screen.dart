import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/providers/selectedanswers_provider.dart';
import 'package:quiz_app/data/questions_list.dart';
import 'package:google_fonts/google_fonts.dart';

class QuestionScreen extends ConsumerStatefulWidget {
  const QuestionScreen(this.showResult, {super.key});
  final void Function() showResult;

  @override
  ConsumerState<QuestionScreen> createState() => _QuestionState();
}

class _QuestionState extends ConsumerState<QuestionScreen> {
  var currentquestionindex = 0;

  // ✅ TIMER
  int timeLeft = 15;
  Timer? timer;

  // ✅ FIX: store shuffled answers once
  late List<String> shuffledAnswers;

  @override
  void initState() {
    super.initState();
    shuffledAnswers =
        questionslist[currentquestionindex].shuffleAnswers(); // only once
    startTimer();
  }

  void startTimer() {
    timeLeft = 15;

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        changeIndex(""); // auto move
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void changeIndex(String answers) {
    timer?.cancel();

    if (answers.isNotEmpty) {
      ref.read(selectedAnswersProvider.notifier).choosedAnswers(answers);
    } else {
      ref
          .read(selectedAnswersProvider.notifier)
          .choosedAnswers("Not Answered");
    }

    if (currentquestionindex < questionslist.length - 1) {
      setState(() {
        currentquestionindex++;

        // ✅ shuffle only once for next question
        shuffledAnswers =
            questionslist[currentquestionindex].shuffleAnswers();
      });

      startTimer();
    } else {
      widget.showResult();
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentquestion = questionslist[currentquestionindex];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade800, Colors.purple.shade800],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: (currentquestionindex + 1) / questionslist.length,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              ),

              const SizedBox(height: 20),

              // ✅ TIMER UI
              Text(
                'Time Left: $timeLeft s',
                style: GoogleFonts.poppins(
                  color: timeLeft <= 5 ? Colors.red : Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                'Question ${currentquestionindex + 1}/${questionslist.length}',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    currentquestion.text,
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: shuffledAnswers
                      .map(
                        (answer) => AnswerButton(
                          answer,
                          () => changeIndex(answer),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AnswerButton extends StatelessWidget {
  const AnswerButton(this.answertext, this.onTap, {super.key});

  final String answertext;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          backgroundColor: Colors.white,
          foregroundColor: Colors.blue.shade800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        onPressed: onTap,
        child: Text(
          answertext,
          style: GoogleFonts.poppins(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}