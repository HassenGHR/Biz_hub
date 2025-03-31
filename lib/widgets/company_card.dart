import 'package:flutter/material.dart';
import '../models/company.dart';
import '../utils/constants.dart';
import '../screens/company/company_detail_screen.dart';

class CompanyCard extends StatelessWidget {
  final Company company;

  const CompanyCard({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade200, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailScreen(company: company),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(12.0),
          child: isMobile
              ? _buildMobileLayout(theme)
              : _buildTabletDesktopLayout(theme),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Company Logo
        Container(
          width: 60.0,
          height: 60.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4.0,
                offset: const Offset(0, 2),
              ),
            ],
            image: company.imageUrl != null && company.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(company.imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            color: company.imageUrl == null || company.imageUrl.isEmpty
                ? theme.primaryColor.withOpacity(0.1)
                : null,
          ),
          child: company.imageUrl == null || company.imageUrl.isEmpty
              ? Center(
                  child: Text(
                    company.name.isNotEmpty
                        ? company.name.substring(0, 1).toUpperCase()
                        : "?",
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 12.0),

        // Company Information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                company.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      company.category,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: _buildRatingIndicator(
                        company.thumbsUp, company.thumbsDown),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 14.0,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4.0),
                  Expanded(
                    child: Text(
                      company.address,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Action Buttons
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: IconButton(
                icon: Icon(
                  Icons.phone,
                  size: 16,
                  color: theme.primaryColor,
                ),
                onPressed: () {
                  // TODO: Implement call functionality
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Call',
              ),
            ),
            const SizedBox(height: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: theme.primaryColor.withOpacity(0.1),
              child: IconButton(
                icon: Icon(
                  Icons.email,
                  size: 16,
                  color: theme.primaryColor,
                ),
                onPressed: () {
                  // TODO: Implement email functionality
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'Email',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTabletDesktopLayout(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row - Logo and Name
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4.0,
                    offset: const Offset(0, 2),
                  ),
                ],
                image: company.imageUrl != null && company.imageUrl.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(company.imageUrl),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: company.imageUrl == null || company.imageUrl.isEmpty
                    ? theme.primaryColor.withOpacity(0.1)
                    : null,
              ),
              child: company.imageUrl == null || company.imageUrl.isEmpty
                  ? Center(
                      child: Text(
                        company.name.isNotEmpty
                            ? company.name.substring(0, 1).toUpperCase()
                            : "?",
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                          color: theme.primaryColor,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      company.category,
                      style: TextStyle(
                        fontSize: 12.0,
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),

        // Address Row
        Row(
          children: [
            const Icon(
              Icons.location_on,
              size: 14.0,
              color: Colors.grey,
            ),
            const SizedBox(width: 4.0),
            Expanded(
              child: Text(
                company.address,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8.0),

        // Bottom Row - Ratings and Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildRatingIndicator(company.thumbsUp, company.thumbsDown),
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      Icons.phone,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      // TODO: Implement call functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Call',
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: theme.primaryColor.withOpacity(0.1),
                  child: IconButton(
                    icon: Icon(
                      Icons.email,
                      size: 16,
                      color: theme.primaryColor,
                    ),
                    onPressed: () {
                      // TODO: Implement email functionality
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    tooltip: 'Email',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRatingIndicator(int positiveRatings, int negativeRatings) {
    final int totalRatings = positiveRatings + negativeRatings;
    if (totalRatings == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: const Text(
          'No ratings',
          style: TextStyle(
            fontSize: 11.0,
            color: Colors.grey,
          ),
        ),
      );
    }

    final double positivePercentage = (positiveRatings / totalRatings) * 100;

    Color color;
    IconData icon;

    if (positivePercentage >= 70) {
      color = Colors.green;
      icon = Icons.thumb_up;
    } else if (positivePercentage >= 40) {
      color = Colors.orange;
      icon = Icons.thumbs_up_down;
    } else {
      color = Colors.red;
      icon = Icons.thumb_down;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 11.0,
            color: color,
          ),
          const SizedBox(width: 2.0),
          Text(
            '${positivePercentage.round()}%',
            style: TextStyle(
              fontSize: 11.0,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
