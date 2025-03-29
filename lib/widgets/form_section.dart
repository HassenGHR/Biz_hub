import 'package:flutter/material.dart';

class FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Widget? actionButton;

  const FormSection({
    Key? key,
    required this.title,
    required this.children,
    this.actionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              if (actionButton != null) actionButton!,
            ],
          ),
        ),

        // Divider
        Divider(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          thickness: 1.0,
        ),

        // Section Content
        const SizedBox(height: 16.0),
        ...children,
      ],
    );
  }
}
