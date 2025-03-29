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
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompanyDetailScreen(company: company),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Company Logo or Image
              Container(
                width: 80.0,
                height: 80.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: company.imageUrl != null && company.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(company.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[200],
                ),
                child: company.imageUrl == null || company.imageUrl.isEmpty
                    ? Center(
                        child: Text(
                          company.name.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16.0),
              // Company Information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: const TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      company.category,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey[600],
                      ),
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
                            style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Rating information
                    Row(
                      children: [
                        _buildRatingIndicator(
                            company.thumbsUp, company.thumbsDown),
                        const SizedBox(width: 8.0),
                        Text(
                          '${company.thumbsUp + company.thumbsDown} reviews',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Quick actions
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.phone),
                    onPressed: () {
                      // TODO: Implement call functionality
                    },
                    tooltip: 'Call',
                  ),
                  IconButton(
                    icon: const Icon(Icons.email),
                    onPressed: () {
                      // TODO: Implement email functionality
                    },
                    tooltip: 'Email',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRatingIndicator(int positiveRatings, int negativeRatings) {
    final int totalRatings = positiveRatings + negativeRatings;
    if (totalRatings == 0) {
      return const Text(
        'No ratings yet',
        style: TextStyle(
          fontSize: 12.0,
          color: Colors.grey,
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

    return Row(
      children: [
        Icon(
          icon,
          size: 14.0,
          color: color,
        ),
        const SizedBox(width: 4.0),
        Text(
          '${positivePercentage.round()}%',
          style: TextStyle(
            fontSize: 12.0,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
