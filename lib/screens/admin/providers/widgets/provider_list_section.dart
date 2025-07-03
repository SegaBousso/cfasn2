import 'package:flutter/material.dart';
import '../../../../utils/responsive_helper.dart';

class ProviderListSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;
  final TextEditingController controller;
  final String hintText;
  final Function(String) onAdd;
  final Function(String) onRemove;

  const ProviderListSection({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.controller,
    required this.hintText,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = ResponsiveHelper.getSpacing(context);
    final dimensions = ResponsiveHelper.getDimensions(context);

    return Card(
      child: Padding(
        padding: ResponsiveHelper.getScreenPadding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveHelper.getFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
              ),
            ),
            SizedBox(height: spacing),
            _buildInputRow(context, spacing),
            if (items.isNotEmpty) ...[
              SizedBox(height: spacing),
              _buildItemsList(context, spacing, dimensions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputRow(BuildContext context, double spacing) {
    final dimensions = ResponsiveHelper.getDimensions(context);

    if (dimensions.deviceType == DeviceType.mobile) {
      return Column(
        children: [
          _buildTextField(context),
          SizedBox(height: spacing / 2),
          SizedBox(width: double.infinity, child: _buildAddButton(context)),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildTextField(context)),
        SizedBox(width: spacing / 2),
        _buildAddButton(context),
      ],
    );
  }

  Widget _buildTextField(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hintText,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
        labelStyle: TextStyle(
          fontSize: ResponsiveHelper.getFontSize(
            context,
            mobile: 14,
            tablet: 15,
            desktop: 16,
          ),
        ),
      ),
      onFieldSubmitted: (value) => _handleSubmit(),
      style: TextStyle(
        fontSize: ResponsiveHelper.getFontSize(
          context,
          mobile: 14,
          tablet: 15,
          desktop: 16,
        ),
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    final dimensions = ResponsiveHelper.getDimensions(context);
    final isFullWidth = dimensions.deviceType == DeviceType.mobile;

    return isFullWidth
        ? ElevatedButton.icon(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.add),
            label: const Text('Ajouter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.getSpacing(context),
              ),
            ),
          )
        : IconButton(
            onPressed: _handleSubmit,
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
              padding: EdgeInsets.all(ResponsiveHelper.getSpacing(context)),
            ),
          );
  }

  Widget _buildItemsList(
    BuildContext context,
    double spacing,
    ResponsiveDimensions dimensions,
  ) {
    if (dimensions.deviceType == DeviceType.mobile) {
      return _buildMobileList(context, spacing);
    }

    return _buildDesktopWrap(context, spacing);
  }

  Widget _buildMobileList(BuildContext context, double spacing) {
    return Column(
      children: items
          .map(
            (item) => Card(
              margin: EdgeInsets.only(bottom: spacing / 2),
              child: ListTile(
                dense: true,
                title: Text(
                  item,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.getFontSize(context),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, size: 18),
                  onPressed: () => onRemove(item),
                  color: Colors.red.shade600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDesktopWrap(BuildContext context, double spacing) {
    return Wrap(
      spacing: spacing / 2,
      runSpacing: spacing / 2,
      children: items.map((item) {
        return Chip(
          label: Text(
            item,
            style: TextStyle(
              fontSize: ResponsiveHelper.getFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
            ),
          ),
          deleteIcon: Icon(
            Icons.close,
            size: ResponsiveHelper.getValue<double>(
              context,
              mobile: 16,
              tablet: 18,
              desktop: 20,
            ),
          ),
          onDeleted: () => onRemove(item),
          backgroundColor: Colors.purple.shade50,
          deleteIconColor: Colors.purple.shade600,
        );
      }).toList(),
    );
  }

  void _handleSubmit() {
    final value = controller.text.trim();
    if (value.isNotEmpty && !items.contains(value)) {
      onAdd(value);
      controller.clear();
    }
  }
}
