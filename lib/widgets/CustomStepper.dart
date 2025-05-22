import 'package:flutter/material.dart';

class CustomStepper extends StatelessWidget {
  final int currentStep;
  final Function(int) onStepTapped;
  final List<Widget> stepContents;

  const CustomStepper({
    required this.currentStep,
    required this.onStepTapped,
    required this.stepContents,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Custom step indicators (No lines)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(stepContents.length, (index) {
            return GestureDetector(
              onTap: () => onStepTapped(index),
              child: CircleAvatar(
                backgroundColor: currentStep >= index ? Colors.red : Colors.grey,
                child: Text((index + 1).toString(), style: TextStyle(color: Colors.white)),
              ),
            );
          }),
        ),
        SizedBox(height: 20),
        // Display the content based on the current step
        stepContents[currentStep],
      ],
    );
  }
}
