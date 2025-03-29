import 'package:biz_hub/config/theme.dart';
import 'package:biz_hub/widgets/tool_card.dart';
import 'package:flutter/material.dart';

class ToolsDashboardScreen extends StatelessWidget {
  const ToolsDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productivity Tools'),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Boost Your Productivity',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Choose a tool to help you manage business connections and information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ToolCard(
                    title: 'Resume Builder',
                    description: 'Create professional resumes with templates',
                    icon: Icons.description,
                    color: AppColors.textPrimaryLight,
                    onTap: () {
                      Navigator.pushNamed(context, '/tools/resume-builder');
                    },
                  ),
                  ToolCard(
                    title: 'Text Extraction',
                    description: 'Extract text from images and documents',
                    icon: Icons.text_fields,
                    color: AppColors.textSecondaryLight,
                    onTap: () {
                      Navigator.pushNamed(context, '/tools/text-extraction');
                    },
                  ),
                  ToolCard(
                    title: 'Business Card Scanner',
                    description: 'Scan business cards to save contacts',
                    icon: Icons.contact_mail,
                    color: AppColors.textPrimaryLight,
                    onTap: () {
                      Navigator.pushNamed(context, '/tools/card-scanner');
                    },
                  ),
                  ToolCard(
                    title: 'Saved Files',
                    description: 'Access your saved documents and scans',
                    icon: Icons.folder,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.pushNamed(context, '/tools/saved-files');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
