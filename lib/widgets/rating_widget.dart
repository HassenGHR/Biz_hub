import 'package:biz_hub/services/comapny_service.dart';
import 'package:flutter/material.dart';

class RatingWidget extends StatefulWidget {
  final String companyId;
  final int initialRating;
  final Function(int) onRatingUpdate;

  const RatingWidget({
    Key? key,
    required this.companyId,
    required this.initialRating,
    required this.onRatingUpdate,
  }) : super(key: key);

  @override
  _RatingWidgetState createState() => _RatingWidgetState();
}

class _RatingWidgetState extends State<RatingWidget> {
  late int _currentRating;
  final CompanyService _companyService = CompanyService();

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.thumb_up,
            color: _currentRating == 1 ? Colors.green : Colors.grey,
            size: 30,
          ),
          onPressed: () => _updateRating(1),
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Icon(
            Icons.thumb_down,
            color: _currentRating == -1 ? Colors.red : Colors.grey,
            size: 30,
          ),
          onPressed: () => _updateRating(-1),
        ),
      ],
    );
  }

  void _updateRating(int newRating) {
    // If clicking the same button, toggle off
    if (_currentRating == newRating) {
      newRating = 0;
    }

    setState(() {
      _currentRating = newRating;
    });

    // Update in the database
    _companyService.rateCompany(widget.companyId,
        _currentRating == 1 ? true : false, newRating.toDouble());

    // Call the callback
    widget.onRatingUpdate(newRating);
  }
}
