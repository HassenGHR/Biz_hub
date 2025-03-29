import 'package:biz_hub/models/company.dart';
import 'package:biz_hub/models/user.dart';
import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/services/user_service.dart';
import 'package:biz_hub/widgets/company_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final UserService _userService = UserService();
  final CompanyService _companyService = CompanyService();
  User? _user;
  List<Map<String, dynamic>> _contributions = [];
  List<Company> _savedCompanies = [];
  bool _isLoading = true;
  bool _isCurrentUser = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if this is the current user's profile
      _isCurrentUser = _userService.currentUser?.uid == widget.userId;

      // Get user profile
      _user = await _userService.getUserById(widget.userId);

      // Get user contributions
      _contributions = await _userService.getUserContributions(widget.userId);

      // Get saved companies if this is the current user
      if (_isCurrentUser && _user != null) {
        List<String> savedCompanyIds =
            await _userService.getSavedCompanies(widget.userId);
        List<Company> companies = [];

        for (String id in savedCompanyIds) {
          Company? company = await _companyService.getCompanyById(id);
          if (company != null) {
            companies.add(company);
          }
        }

        _savedCompanies = companies;
      }
    } catch (e) {
      print('Error loading user data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load user data')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildProfileHeader() {
    if (_user == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage:
                _user!.photoUrl != null ? NetworkImage(_user!.photoUrl!) : null,
            child:
                _user!.photoUrl == null ? Icon(Icons.person, size: 50) : null,
          ),
          SizedBox(height: 16),
          Text(
            _user!.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            _user!.email,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('${_user!.reputation}', 'Reputation'),
              SizedBox(width: 24),
              _buildStatItem('${_user!.contributions}', 'Contributions'),
            ],
          ),
          SizedBox(height: 16),
          // if (_user!.isVerified)
          Chip(
            avatar: Icon(Icons.verified, color: Colors.white, size: 16),
            label: Text('Verified Contributor'),
            backgroundColor: Colors.green,
            labelStyle: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 8),
          if (_isCurrentUser)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profile/edit');
              },
              icon: Icon(Icons.edit),
              label: Text('Edit Profile'),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildContributionsTab() {
    if (_contributions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No contributions yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _contributions.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final contribution = _contributions[index];
        final DateTime timestamp =
            contribution['timestamp']?.toDate() ?? DateTime.now();

        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: _getActionIcon(contribution['actionType']),
            title: Text(
              _getActionTitle(contribution['actionType']),
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Company ID: ${contribution['companyId']}'),
                Text('Date: ${_formatDate(timestamp)}'),
              ],
            ),
            trailing: _getStatusChip(contribution['status']),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/company/detail',
                arguments: contribution['companyId'],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSavedCompaniesTab() {
    if (!_isCurrentUser) {
      return Center(
        child: Text('Only visible to account owner'),
      );
    }

    if (_savedCompanies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No saved companies yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _savedCompanies.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final company = _savedCompanies[index];
        return CompanyCard(company: company);
      },
    );
  }

  Widget _buildResumesTab() {
    if (!_isCurrentUser || _user == null) {
      return Center(
        child: Text('Only visible to account owner'),
      );
    }

    final resumes = _user!.savedResumes;

    if (resumes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No resumes yet',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/tools/resume-builder');
              },
              icon: Icon(Icons.add),
              label: Text('Create Resume'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: resumes.length,
      padding: EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final resume = resumes[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(Icons.description),
            title: Text(resume.personalInfo.name),
            subtitle: Text('Created: ${_formatDate(resume.createdAt)}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit, color: Colors.blue),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      '/tools/resume-builder',
                      arguments: resume.id,
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteResumeDialog(resume.id);
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/tools/resume-view',
                arguments: resume.id,
              );
            },
          ),
        );
      },
    );
  }

  void _showDeleteResumeDialog(String resumeId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Resume'),
          content: Text('Are you sure you want to delete this resume?'),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _userService.removeUserResume(widget.userId, resumeId);
                  _loadUserData(); // Refresh data
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Resume deleted')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete resume')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Icon _getActionIcon(String actionType) {
    switch (actionType) {
      case 'edit':
        return Icon(Icons.edit, color: Colors.blue);
      case 'comment':
        return Icon(Icons.comment, color: Colors.green);
      case 'report':
        return Icon(Icons.flag, color: Colors.orange);
      default:
        return Icon(Icons.info, color: Colors.grey);
    }
  }

  String _getActionTitle(String actionType) {
    switch (actionType) {
      case 'edit':
        return 'Edited Company Info';
      case 'comment':
        return 'Added Comment';
      case 'report':
        return 'Reported Issue';
      default:
        return 'Contribution';
    }
  }

  Widget _getStatusChip(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'approved':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.pending;
        break;
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.white),
      label: Text(
        status.toUpperCase(),
        style: TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
      padding: EdgeInsets.symmetric(horizontal: 4),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isCurrentUser ? 'My Profile' : 'User Profile'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Contributions'),
            Tab(text: 'Saved'),
            Tab(text: 'Resumes'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user == null
              ? Center(child: Text('User not found'))
              : Column(
                  children: [
                    _buildProfileHeader(),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildContributionsTab(),
                          _buildSavedCompaniesTab(),
                          _buildResumesTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
