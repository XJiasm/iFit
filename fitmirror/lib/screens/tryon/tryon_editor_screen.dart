import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/avatar.dart';
import '../../models/cloth_item.dart';
import '../../services/image_service.dart';
import '../../utils/app_theme.dart';
import 'tryon_result_screen.dart';

class TryOnEditorScreen extends ConsumerStatefulWidget {
  final Avatar avatar;
  final ClothItem clothItem;
  final double initialScale;
  final double initialRotation;
  final double initialOpacity;

  const TryOnEditorScreen({
    super.key,
    required this.avatar,
    required this.clothItem,
    this.initialScale = 1.0,
    this.initialRotation = 0.0,
    this.initialOpacity = 1.0,
  });

  @override
  ConsumerState<TryOnEditorScreen> createState() => _TryOnEditorScreenState();
}

class _TryOnEditorScreenState extends ConsumerState<TryOnEditorScreen> {
  // 拖拽状态
  Offset _position = const Offset(100, 150);
  late double _scale;
  late double _rotation;
  late double _opacity;

  // 临时缩放
  double _tempScale = 1.0;

  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialScale;
    _rotation = widget.initialRotation;
    _opacity = widget.initialOpacity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 编辑区域
          Expanded(
            child: _buildEditor(),
          ),

          // 控制面板
          _buildControlPanel(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          const Text(
            '调整位置',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            '${widget.avatar.name} × ${widget.clothItem.typeName}',
            style: TextStyle(fontSize: 11, color: Colors.grey[400]),
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : _resetControls,
          child: Text(
            '重置',
            style: TextStyle(color: Colors.grey[400]),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildEditor() {
    return Container(
      color: Colors.grey[900],
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 底层：用户形象
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Image.file(
                File(widget.avatar.photoPath),
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.person, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
          ),

          // 上层：服装图层（可拖拽）
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onScaleUpdate: _onScaleUpdate,
              onPanUpdate: _onPanUpdate,
              child: Transform.scale(
                scale: _scale * _tempScale,
                child: Transform.rotate(
                  angle: _rotation,
                  child: Opacity(
                    opacity: _opacity,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.file(
                        File(widget.clothItem.croppedPath),
                        width: 150,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: 150,
                          height: 200,
                          color: Colors.grey[700],
                          child:
                              const Icon(Icons.checkroom, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // 提示文字
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '拖动服装调整位置，双指缩放旋转',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 拖拽指示器
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[700],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // 控制滑块
            _buildSlider(
              icon: Icons.zoom_in,
              label: '大小',
              value: _scale,
              min: 0.3,
              max: 3.0,
              onChanged: (v) => setState(() => _scale = v),
            ),
            const SizedBox(height: 12),
            _buildSlider(
              icon: Icons.rotate_right,
              label: '旋转',
              value: _rotation,
              min: -3.14,
              max: 3.14,
              onChanged: (v) => setState(() => _rotation = v),
            ),
            const SizedBox(height: 12),
            _buildSlider(
              icon: Icons.opacity,
              label: '透明',
              value: _opacity,
              min: 0.1,
              max: 1.0,
              onChanged: (v) => setState(() => _opacity = v),
            ),

            const SizedBox(height: 20),

            // 生成按钮
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _generateResult,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  ),
                ),
                child: _isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, size: 20),
                          SizedBox(width: 8),
                          Text(
                            '生成效果图',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[400]),
        const SizedBox(width: 8),
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.primaryColor,
              inactiveTrackColor: Colors.grey[700],
              thumbColor: AppTheme.primaryColor,
              overlayColor: AppTheme.primaryColor.withOpacity(0.2),
              trackHeight: 3,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 50,
          child: Text(
            value.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
        ),
      ],
    );
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _tempScale = details.scale;
      if (details.rotation != 0) {
        _rotation += details.rotation * 0.5;
      }
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
    });
  }

  void _resetControls() {
    setState(() {
      _position = const Offset(100, 150);
      _scale = 1.0;
      _rotation = 0;
      _opacity = 1.0;
      _tempScale = 1.0;
    });
  }

  Future<void> _generateResult() async {
    setState(() => _isProcessing = true);

    try {
      final resultPath = await ImageService().composeTryOnImage(
        avatarPath: widget.avatar.photoPath,
        clothPath: widget.clothItem.croppedPath,
        offsetX: _position.dx,
        offsetY: _position.dy,
        scale: _scale * _tempScale,
        rotation: _rotation,
        opacity: _opacity,
      );

      if (resultPath != null && mounted) {
        // 跳转到结果页面
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TryOnResultScreen(
              resultPath: resultPath,
              avatarId: widget.avatar.id,
              clothItemId: widget.clothItem.id,
              offsetX: _position.dx,
              offsetY: _position.dy,
              scale: _scale * _tempScale,
              rotation: _rotation,
              opacity: _opacity,
              clothType: widget.clothItem.type.name,
              clothColor: widget.clothItem.color,
            ),
          ),
        );
      } else if (mounted) {
        _showError('生成失败，请重试');
      }
    } catch (e) {
      if (mounted) {
        _showError('生成失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
