import "package:flutter/material.dart";
import "../theme/app_theme.dart";

class BudgetCard extends StatelessWidget {
  final String city;
  final String state;
  final String code;
  final String date;
  final int daysRemaining;
  final double value;
  final String status;
  final VoidCallback onTap;

  const BudgetCard({
    Key? key,
    required this.city,
    required this.state,
    required this.code,
    required this.date,
    required this.daysRemaining,
    required this.value,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case "aprovado":
        return Colors.green;
      case "pendente":
        return Colors.orange;
      case "expirado":
        return Colors.red;
      case "não aprovado":
        return Colors.red;
      case "arquivado":
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$city - $state",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        code,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.lightTextColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    "R\$${_formatCurrency(value)}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        "$daysRemaining dias rest.",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toLowerCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatCurrency(double value) {
    return value.toStringAsFixed(2).replaceAll(".", ",");
  }
}
