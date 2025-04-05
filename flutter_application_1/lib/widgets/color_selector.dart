import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final List<String> colors;
  final String selectedColor;
  final Function(String) onColorSelected;
  
  const ColorSelector({
    super.key,
    required this.colors,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: colors.map((color) {
        final isSelected = color == selectedColor;
        
        // This is a simplified approach - in a real app,
        // you would convert color names to actual color values
        Color actualColor;
        switch (color.toLowerCase()) {
          case 'red':
            actualColor = Colors.red;
            break;
          case 'blue':
            actualColor = Colors.blue;
            break;
          case 'green':
            actualColor = Colors.green;
            break;
          case 'yellow':
            actualColor = Colors.yellow;
            break;
          case 'white':
            actualColor = Colors.white;
            break;
          case 'black':
            actualColor = Colors.black;
            break;
          case 'grey':
            actualColor = Colors.grey;
            break;
          case 'navy':
            actualColor = const Color(0xFF000080);
            break;
          default:
            // For compound colors like 'red/black', just use the first color
            if (color.contains('/')) {
              final firstColor = color.split('/')[0].toLowerCase();
              switch (firstColor) {
                case 'red':
                  actualColor = Colors.red;
                  break;
                case 'blue':
                  actualColor = Colors.blue;
                  break;
                case 'black':
                  actualColor = Colors.black;
                  break;
                default:
                  actualColor = Colors.grey;
              }
            } else {
              actualColor = Colors.grey;
            }
        }
        
        return GestureDetector(
          onTap: () => onColorSelected(color),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: actualColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? Theme.of(context).primaryColor : Colors.grey,
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: actualColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }
}

