import 'package:flutter/material.dart';

class ModernBottomSheet {
  static void show({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData? titleIcon,
    required List<BottomSheetAction> actions,
    bool showCancelButton = true,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              
              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    if (titleIcon != null) ...[
                      Icon(titleIcon, color: Colors.teal, size: 24),
                      SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          if (subtitle != null) ...[
                            SizedBox(height: 4),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              
              // Actions
              ...actions.map((action) => _buildActionTile(
                context: context,
                action: action,
              )),
              
              SizedBox(height: 12),
              
              // Cancel button
              if (showCancelButton)
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildActionTile({
    required BuildContext context,
    required BottomSheetAction action,
  }) {
    final isDestructive = action.isDestructive ?? false;
    final color = isDestructive ? Colors.red : Colors.teal;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          action.icon,
          color: color,
          size: 24,
        ),
      ),
      title: Text(
        action.label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: isDestructive ? Colors.red : Colors.black87,
        ),
      ),
      subtitle: action.description != null
          ? Text(
              action.description!,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            )
          : null,
      onTap: () {
        Navigator.pop(context);
        action.onTap();
      },
    );
  }
}

class BottomSheetAction {
  final String label;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;
  final bool? isDestructive;

  BottomSheetAction({
    required this.label,
    this.description,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });
}

// Example usage:
class ExampleUsage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bottom Sheet Example'),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            ModernBottomSheet.show(
              context: context,
              title: 'Paris Trip',
              subtitle: 'Dec 15 - Dec 22, 2024',
              titleIcon: Icons.location_on,
              actions: [
                BottomSheetAction(
                  label: 'Edit Trip',
                  description: 'Modify trip details',
                  icon: Icons.edit,
                  onTap: () {
                    print('Edit tapped');
                  },
                ),
                BottomSheetAction(
                  label: 'Share Trip',
                  description: 'Share with friends',
                  icon: Icons.share,
                  onTap: () {
                    print('Share tapped');
                  },
                ),
                BottomSheetAction(
                  label: 'Delete Trip',
                  description: 'Remove this trip permanently',
                  icon: Icons.delete,
                  isDestructive: true,
                  onTap: () {
                    print('Delete tapped');
                  },
                ),
              ],
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Show Bottom Sheet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}