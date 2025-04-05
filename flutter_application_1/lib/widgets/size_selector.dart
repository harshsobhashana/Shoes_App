import 'package:flutter/material.dart';

class SizeSelector extends StatelessWidget {
  final List<double> sizes;
  final double selectedSize;
  final Function(double) onSizeSelected;
  
  const SizeSelector({
    super.key,
    required this.sizes,
    required this.selectedSize,
    required this.onSizeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sizes.map((size) {
        final isSelected = size == selectedSize;
        
        return GestureDetector(
          onTap: () => onSizeSelected(size),
          child: Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? Theme.of(context).primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
            child: Text(
              size.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

