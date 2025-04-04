import 'package:biz_hub/config/routes.dart';
import 'package:biz_hub/models/user.dart';
import 'package:biz_hub/services/auth_service.dart';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late User _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialize with default values
    _user = User(
      id: 'default-id',
      name: 'Alex Johnson',
      email: 'alex.johnson@example.com',
      photoUrl: 'https://example.com/default-photo.png',
      reputation: 1,
      contributions: [],
      savedCompanies: [],
      savedResumes: [],
      createdAt: DateTime.now(),
    );
    // Load user data
    loadUser();
  }

  void loadUser() async {
    final cachedUser = await AuthService().getCachedUser();
    setState(() {
      if (cachedUser != null) {
        _user = cachedUser;
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BizHub Menu'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () {
              AuthService().signOut();
              AppRoutes.navigateAndRemoveUntil(context, AppRoutes.splash);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navigate to settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserSection(() {
                AppRoutes.navigateTo(context, AppRoutes.userProfile,
                    arguments: "");
              }),
              const SizedBox(height: 24),
              _buildMenuSection(
                'Directory',
                [
                  MenuOption(
                    title: 'Browse Companies',
                    icon: Icons.business_outlined,
                    route: '/companies',
                  ),
                  MenuOption(
                    title: 'Search',
                    icon: Icons.search,
                    route: '/search',
                  ),
                  MenuOption(
                    title: 'Nearby',
                    icon: Icons.location_on_outlined,
                    route: '/nearby',
                  ),
                  MenuOption(
                    title: 'Recent',
                    icon: Icons.history_outlined,
                    route: '/recent',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildMenuSection(
                'Productivity Tools',
                [
                  MenuOption(
                    title: 'Resume Builder',
                    icon: Icons.description_outlined,
                    route: '/resume-builder',
                  ),
                  MenuOption(
                    title: 'Business Card Scanner',
                    icon: Icons.camera_alt_outlined,
                    route: '/card-scanner',
                  ),
                  MenuOption(
                    title: 'Text Extraction',
                    icon: Icons.document_scanner_outlined,
                    route: '/text-extraction',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserSection(void Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: _user == null
            ? CircularProgressIndicator()
            : Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.blue.shade100,
                    child:
                        const Icon(Icons.person, size: 36, color: Colors.blue),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _user.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.star,
                                size: 16, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Reputation: ${_user.reputation}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.edit_note,
                                size: 16, color: Colors.blue.shade700),
                            const SizedBox(width: 4),
                            Text(
                              '${_user.contributions.length} Contributions',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon:
                        Icon(Icons.chevron_right, color: Colors.grey.shade700),
                    onPressed: () {
                      // Navigate to profile
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildMenuSection(String title, List<MenuOption> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                leading: Icon(option.icon, color: Colors.blue.shade700),
                title: Text(option.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // Navigate to the specified route
                  Navigator.of(context).pushNamed(option.route);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class MenuOption {
  final String title;
  final IconData icon;
  final String route;

  MenuOption({
    required this.title,
    required this.icon,
    required this.route,
  });
}
