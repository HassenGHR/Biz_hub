import 'package:flutter/material.dart';

class SocialLoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String icon;
  final String text;
  final bool isLoading;

  const SocialLoginButton({
    Key? key,
    required this.onPressed,
    required this.icon,
    required this.text,
    this.isLoading = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: isLoading
          ? const CircularProgressIndicator()
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  icon,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
    );
  }
}
