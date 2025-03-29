import 'package:biz_hub/models/comment.dart';
import 'package:biz_hub/screens/company/edit_comapny_details_screen.dart';
import 'package:biz_hub/services/comapny_service.dart';
import 'package:biz_hub/widgets/comment_item.dart';
import 'package:biz_hub/widgets/rating_widget.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/company.dart';

class CompanyDetailScreen extends StatefulWidget {
  final Company company;

  const CompanyDetailScreen({Key? key, required this.company})
      : super(key: key);

  @override
  _CompanyDetailScreenState createState() => _CompanyDetailScreenState();
}

class _CompanyDetailScreenState extends State<CompanyDetailScreen>
    with SingleTickerProviderStateMixin {
  final CompanyService _companyService = CompanyService();
  final TextEditingController _commentController = TextEditingController();
  late TabController _tabController;
  List<Comment> _comments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final comments =
          await _companyService.getCompanyComments(widget.company.id);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading comments: ${e.toString()}')),
      );
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    try {
      await _companyService.addComment(
        widget.company.id,
        Comment(
          id: '',
          userId: 'current_user_id', // Replace with actual user ID
          userName: 'Current User', // Replace with actual user name
          content: _commentController.text,
          companyId: '', userProfileUrl: '', isPositive: true,
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
      _loadComments();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding comment: ${e.toString()}')),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $url')),
      );
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not call $phoneNumber')),
      );
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Inquiry from BizHub',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not email $email')),
      );
    }
  }

  void _editCompany() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditCompanyScreen(company: widget.company),
      ),
    ).then((_) {
      // Refresh company data when returning from edit screen
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.company.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editCompany,
            tooltip: 'Edit company',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Implement share functionality
            },
            tooltip: 'Share',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Comments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Details Tab
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.company.imageUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.company.imageUrl,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.business, size: 50),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              widget.company.name,
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Chip(
                              label: Text(widget.company.category),
                              backgroundColor: Colors.blue[100],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingWidget(
                              initialRating: widget.company.ratings.toInt(),
                              companyId: widget.company.id,
                              onRatingUpdate: (int) {},
                            ),
                            const SizedBox(width: 8),
                            Text(
                                '(${widget.company.thumbsUp + widget.company.thumbsDown} reviews)'),
                          ],
                        ),
                        const Divider(height: 24),
                        if (widget.company.category.isNotEmpty) ...[
                          Text(
                            'Description',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(widget.company.category),
                          const Divider(height: 24),
                        ],
                        ListTile(
                          leading: const Icon(Icons.location_on),
                          title: Text(widget.company.address),
                          subtitle: const Text('Address'),
                          onTap: () {
                            // Open map with this location
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.phone),
                          title: Text(widget.company.phone),
                          subtitle: const Text('Phone'),
                          onTap: () => _makePhoneCall(widget.company.phone),
                        ),
                        if (widget.company.email != null &&
                            widget.company.email!.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.email),
                            title: Text(widget.company.email!),
                            subtitle: const Text('Email'),
                            onTap: () => _sendEmail(widget.company.email!),
                          ),
                        if (widget.company.website != null &&
                            widget.company.website!.isNotEmpty)
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: Text(widget.company.website!),
                            subtitle: const Text('Website'),
                            onTap: () => _launchUrl(widget.company.website!),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Comments Tab
          Column(
            children: [
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text('No comments yet'))
                        : ListView.builder(
                            padding: const EdgeInsets.all(8.0),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              return CommentItem(
                                comment: _comments[index],
                              );
                            },
                          ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        decoration: const InputDecoration(
                          hintText: 'Add a comment...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _addComment,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Quick contact options
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Call'),
                  onTap: () {
                    Navigator.pop(context);
                    _makePhoneCall(widget.company.phone);
                  },
                ),
                if (widget.company.email != null &&
                    widget.company.email!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text('Email'),
                    onTap: () {
                      Navigator.pop(context);
                      _sendEmail(widget.company.email!);
                    },
                  ),
                if (widget.company.website != null &&
                    widget.company.website!.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Visit Website'),
                    onTap: () {
                      Navigator.pop(context);
                      _launchUrl(widget.company.website!);
                    },
                  ),
              ],
            ),
          );
        },
        child: const Icon(Icons.contact_phone),
        tooltip: 'Quick Contact',
      ),
    );
  }
}
