import 'package:flutter/material.dart';

class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({
    required this.icon,
    required this.label,
  });
}

class CurvedNavigationBar extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<NavigationItem> items;

  CurvedNavigationBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  _CurvedNavigationBarState createState() => _CurvedNavigationBarState();
}

class CurvePainter extends CustomPainter {
  final double position;
  final double itemWidth;

  CurvePainter({
    required this.position,
    required this.itemWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade50
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(position - itemWidth / 2, 0)
      ..quadraticBezierTo(position, 0, position, 20)
      ..quadraticBezierTo(position, 40, position + itemWidth / 2, 40)
      ..lineTo(size.width, 40)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CurvePainter oldDelegate) {
    return position != oldDelegate.position;
  }
}

class _CurvedNavigationBarState extends State<CurvedNavigationBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _curveAnimation;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _curveAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _previousIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(CurvedNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Curva animada
          AnimatedBuilder(
            animation: _curveAnimation,
            builder: (context, child) {
              double startPos = _previousIndex * (MediaQuery.of(context).size.width / widget.items.length);
              double endPos = widget.currentIndex * (MediaQuery.of(context).size.width / widget.items.length);
              double currentPos = startPos + (endPos - startPos) * _curveAnimation.value;
              
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width, 70),
                painter: CurvePainter(
                  position: currentPos,
                  itemWidth: MediaQuery.of(context).size.width / widget.items.length,
                ),
              );
            },
          ),
          // Botones de navegación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(widget.items.length, (index) {
              bool isSelected = index == widget.currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => widget.onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          transform: Matrix4.translationValues(
                            0,
                            isSelected ? -8 : 0,
                            0,
                          ),
                          child: Icon(
                            widget.items[index].icon,
                            color: isSelected ? Colors.blue[700] : Colors.grey[600],
                            size: isSelected ? 28 : 24,
                          ),
                        ),
                        SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: Duration(milliseconds: 300),
                          style: TextStyle(
                            fontSize: isSelected ? 12 : 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected ? Colors.blue[700] : Colors.grey[600],
                          ),
                          child: Text(widget.items[index].label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}