import 'package:biz_hub/models/resume.dart';
import 'package:biz_hub/widgets/form_section.dart';
import 'package:biz_hub/widgets/resume_template_card.dart';
import 'package:flutter/material.dart';

class ResumeBuilderScreen extends StatefulWidget {
  const ResumeBuilderScreen({Key? key}) : super(key: key);

  @override
  _ResumeBuilderScreenState createState() => _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState extends State<ResumeBuilderScreen> {
  final _formKey = GlobalKey<FormState>();

  // Resume data
  final ResumeData _resumeData = ResumeData(
    personalInfo: PersonalInfo(),
    education: [],
    experience: [],
    skills: [],
  );

  // Template selection
  String _selectedTemplate = 'modern'; // Default template

  // Available templates
  final List<Map<String, String>> _templates = [
    {
      'name': 'Modern',
      'id': 'modern',
      'image': 'assets/images/templates/modern_template.png',
    },
    {
      'name': 'Classic',
      'id': 'classic',
      'image': 'assets/images/templates/classic_template.png',
    },
    {
      'name': 'Minimalist',
      'id': 'minimalist',
      'image': 'assets/images/templates/minimalist_template.png',
    },
  ];

  // Tab controller for different sections
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: AnimatedListState());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _saveResumeData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Show preview or generate PDF
      _showPreviewDialog();
    }
  }

  void _showPreviewDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Resume Preview'),
          content: const Text('Your resume has been created!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Edit'),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Generate and download PDF
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Resume exported as PDF!'),
                  ),
                );
              },
              child: const Text('Download PDF'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume Builder'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              // Show help info
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Resume Builder Help'),
                  content: const Text(
                    'Fill in your details in each section, select a template, and generate your professional resume instantly. Your data will be saved automatically.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Tab bar for sections
            TabBar(
              controller: _tabController,
              labelColor: Theme.of(context).primaryColor,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Theme.of(context).primaryColor,
              tabs: const [
                Tab(text: 'Personal'),
                Tab(text: 'Education'),
                Tab(text: 'Experience'),
                Tab(text: 'Skills'),
              ],
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Personal Information Section
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: FormSection(
                      title: 'Personal Information',
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _resumeData.personalInfo.name = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _resumeData.personalInfo.email = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          keyboardType: TextInputType.phone,
                          onSaved: (value) {
                            _resumeData.personalInfo.phone = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Professional Title',
                            prefixIcon: Icon(Icons.work),
                          ),
                          onSaved: (value) {
                            _resumeData.personalInfo.title = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Address',
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          onSaved: (value) {
                            _resumeData.personalInfo.address = value!;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Professional Summary',
                            prefixIcon: Icon(Icons.description),
                            alignLabelWithHint: true,
                          ),
                          maxLines: 3,
                          onSaved: (value) {
                            _resumeData.personalInfo.summary = value!;
                          },
                        ),
                      ],
                    ),
                  ),

                  // Education Section
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildEducationSection(),
                  ),

                  // Experience Section
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildExperienceSection(),
                  ),

                  // Skills Section
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildSkillsSection(),
                  ),
                ],
              ),
            ),

            // Template selection section
            FormSection(
              title: 'Select Resume Template',
              children: [
                SizedBox(
                  height: 240,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      final isSelected = template['id'] == _selectedTemplate;

                      return ResumeTemplateCard(
                        templateName: template['name']!,
                        imagePath: template['image']!,
                        isSelected: isSelected,
                        onSelect: () {
                          setState(() {
                            _selectedTemplate = template['id']!;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            // Bottom action buttons
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Save as draft
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Resume saved as draft!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Draft'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _saveResumeData,
                    icon: const Icon(Icons.preview),
                    label: const Text('Preview & Export'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return FormSection(
      title: 'Education',
      actionButton: IconButton(
        icon: const Icon(Icons.add_circle),
        onPressed: () {
          setState(() {
            _resumeData.education.add(Education());
          });
        },
      ),
      children: _resumeData.education.isEmpty
          ? [
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.school),
                  label: const Text('Add Education'),
                  onPressed: () {
                    setState(() {
                      _resumeData.education.add(Education());
                    });
                  },
                ),
              ),
            ]
          : List.generate(
              _resumeData.education.length,
              (index) => _buildEducationItem(index),
            ),
    );
  }

  Widget _buildEducationItem(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Education ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _resumeData.education.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Degree / Certificate',
              ),
              onSaved: (value) {
                _resumeData.education[index].degree = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Institution',
              ),
              onSaved: (value) {
                _resumeData.education[index].institution = value!;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                    ),
                    onSaved: (value) {
                      _resumeData.education[index].startDate = value!;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                    ),
                    onSaved: (value) {
                      _resumeData.education[index].endDate = value!;
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
              ),
              maxLines: 2,
              onSaved: (value) {
                _resumeData.education[index].description = value!;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceSection() {
    return FormSection(
      title: 'Work Experience',
      actionButton: IconButton(
        icon: const Icon(Icons.add_circle),
        onPressed: () {
          setState(() {
            _resumeData.experience.add(Experience());
          });
        },
      ),
      children: _resumeData.experience.isEmpty
          ? [
              Center(
                child: TextButton.icon(
                  icon: const Icon(Icons.work),
                  label: const Text('Add Work Experience'),
                  onPressed: () {
                    setState(() {
                      _resumeData.experience.add(Experience());
                    });
                  },
                ),
              ),
            ]
          : List.generate(
              _resumeData.experience.length,
              (index) => _buildExperienceItem(index),
            ),
    );
  }

  Widget _buildExperienceItem(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience ${index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    setState(() {
                      _resumeData.experience.removeAt(index);
                    });
                  },
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Job Title',
              ),
              onSaved: (value) {
                _resumeData.experience[index].title = value!;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Company',
              ),
              onSaved: (value) {
                _resumeData.experience[index].company = value!;
              },
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Start Date',
                    ),
                    onSaved: (value) {
                      _resumeData.experience[index].startDate = value!;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'End Date',
                    ),
                    onSaved: (value) {
                      _resumeData.experience[index].endDate = value!;
                    },
                  ),
                ),
              ],
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Responsibilities',
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              onSaved: (value) {
                _resumeData.experience[index].description = value!;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsSection() {
    return FormSection(
      title: 'Skills',
      children: [
        Wrap(
          spacing: 8.0,
          children: List.generate(
            _resumeData.skills.length,
            (index) => Chip(
              label: Text(_resumeData.skills[index]),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                setState(() {
                  _resumeData.skills.removeAt(index);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Add Skill',
                  hintText: 'E.g., Project Management',
                ),
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    setState(() {
                      _resumeData.skills.add(value);
                    });
                    // Clear the field
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      FocusScope.of(context).previousFocus();
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: () {
                // Get text from field and add to skills
                // final currentText = _formKey.currentState?.fields
                //     .firstWhere((element) =>
                //         element.decoration?.labelText == 'Add Skill')
                //     .value as String?;
                // if (currentText != null && currentText.isNotEmpty) {
                //   setState(() {
                //     _resumeData.skills.add(currentText);
                //   });
                //   // Clear the field
                //   WidgetsBinding.instance.addPostFrameCallback((_) {
                //     FocusScope.of(context).previousFocus();
                //   });
                // }
              },
            ),
          ],
        ),
      ],
    );
  }
}
