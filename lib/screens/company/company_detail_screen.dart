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
  final ScrollController _scrollController = ScrollController();

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
    _scrollController.dispose();
    super.dispose();
  }

  String limitTitleLength(String? title, {int maxLength = 28}) {
    if (title == null || title.isEmpty) return '';

    return title.length > maxLength
        ? '${title.substring(0, maxLength)}...'
        : title;
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
      _showErrorSnackBar('Error loading comments: ${e.toString()}');
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
          companyId: '',
          userProfileUrl: '',
          isPositive: true,
          createdAt: DateTime.now(),
        ),
      );
      _commentController.clear();
      _loadComments();
    } catch (e) {
      _showErrorSnackBar('Error adding comment: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showErrorSnackBar('Could not call $phoneNumber');
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
      _showErrorSnackBar('Could not email $email');
    }
  }

  void _editCompany() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompanyFormScreen(company: widget.company),
      ),
    ).then((_) {
      // Refresh company data when returning from edit screen
      setState(() {});
    });
  }

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.business, size: 24),
                const SizedBox(width: 12),
                Text(
                  'Contact ${widget.company.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              icon: Icons.phone,
              title: 'Call',
              subtitle: widget.company.phone,
              onTap: () {
                Navigator.pop(context);
                _makePhoneCall(widget.company.phone);
              },
            ),
            if (widget.company.email != null &&
                widget.company.email!.isNotEmpty)
              _buildContactOption(
                icon: Icons.email,
                title: 'Email',
                subtitle: widget.company.email!,
                onTap: () {
                  Navigator.pop(context);
                  _sendEmail(widget.company.email!);
                },
              ),
            if (widget.company.website != null &&
                widget.company.website!.isNotEmpty)
              _buildContactOption(
                icon: Icons.language,
                title: 'Visit Website',
                subtitle: widget.company.website!,
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(widget.company.website!);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 240.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: Theme.of(context).primaryColor,
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
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.only(bottom: 60),
                centerTitle: true,
                expandedTitleScale: 1.5,
                title: Text(
                  limitTitleLength(widget.company.name),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        blurRadius: 4.0,
                        color: Colors.black54,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    widget.company.imageUrl.isNotEmpty
                        ? Image.network(
                            widget.company.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.blue.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.business,
                                    size: 80,
                                    color: Colors.white70,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.blue.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.business,
                                size: 80,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              bottom: TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                tabs: const [
                  Tab(
                    icon: Icon(Icons.info_outline),
                    text: 'Details',
                  ),
                  Tab(
                    icon: Icon(Icons.comment_outlined),
                    text: 'Reviews',
                  ),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Details Tab
            _buildDetailsTab(),

            // Comments Tab
            _buildCommentsTab(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showContactOptions,
        icon: const Icon(Icons.contact_phone),
        label: const Text('Contact'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildDetailsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RatingWidget(
                        initialRating: widget.company.ratings.toInt(),
                        companyId: widget.company.id,
                        onRatingUpdate: (rating) {},
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '(${widget.company.thumbsUp + widget.company.thumbsDown} reviews)',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.company.category,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactInfoTile(
                    icon: Icons.location_on,
                    title: 'Address',
                    content: widget.company.address,
                    onTap: () {
                      // Open map with this location
                    },
                  ),
                  _buildContactInfoTile(
                    icon: Icons.phone,
                    title: 'Phone',
                    content: widget.company.phone,
                    onTap: () => _makePhoneCall(widget.company.phone),
                  ),
                  if (widget.company.email != null &&
                      widget.company.email!.isNotEmpty)
                    _buildContactInfoTile(
                      icon: Icons.email,
                      title: 'Email',
                      content: widget.company.email!,
                      onTap: () => _sendEmail(widget.company.email!),
                    ),
                  if (widget.company.website != null &&
                      widget.company.website!.isNotEmpty)
                    _buildContactInfoTile(
                      icon: Icons.language,
                      title: 'Website',
                      content: widget.company.website!,
                      onTap: () => _launchUrl(widget.company.website!),
                      isLast: true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoTile({
    required IconData icon,
    required String title,
    required String content,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Theme.of(context).primaryColor),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              content,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ),
          onTap: onTap,
        ),
        if (!isLast)
          Divider(
            color: Colors.grey.shade200,
            height: 1,
            indent: 56,
          ),
      ],
    );
  }

  Widget _buildCommentsTab() {
    return Column(
      children: [
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No reviews yet',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to leave a review!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _comments.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        return Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: CommentItem(
                              comment: _comments[index],
                            ),
                          ),
                        );
                      },
                    ),
        ),
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: const Offset(0, -1),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.1),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Write a review...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        Icons.message_outlined,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _addComment,
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
