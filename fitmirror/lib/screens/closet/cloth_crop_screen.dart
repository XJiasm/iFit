import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

import '../../models/cloth_item.dart';
import '../../utils/app_theme.dart';

class ClothCropScreen extends StatefulWidget {
  final String imagePath;
  final ClothType? initialType;

  const ClothCropScreen({
    super.key,
    required this.imagePath,
    this.initialType,
  });

  @override
  State<ClothCropScreen> createState() => _ClothCropScreenState();
}

class _ClothCropScreenState extends State<ClothCropScreen> {
  File? _originalImage;
  File? _croppedImage;
  bool _isProcessing = false;
  ClothType _selectedType = ClothType.top;
  String _color = '';
  final List<String> _selectedStyles = [];

  final List<String> _styleOptions = [
    '休闲', '正式', '运动', '甜美', '街头', '简约',
    '优雅', '复古', '潮流', '文艺', '性感', '少女',
  ];

  @override
  void initState() {
    super.initState();
    _originalImage = File(widget.imagePath);
    _selectedType = widget.initialType ?? ClothType.top;
    _cropImage();
  }

  Future<void> _cropImage() async {
    setState(() => _isProcessing = true);

    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: '裁剪服装',
            toolbarColor: AppTheme.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: '裁剪服装',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _croppedImage = File(croppedFile.path);
        });
      } else {
        // 用户取消裁剪，返回上一页
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('裁剪失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _saveCloth() {
    if (_croppedImage == null) return;

    final clothItem = ClothItem(
      id: '', // 将在 provider 中生成
      type: _selectedType,
      originalPath: widget.imagePath,
      croppedPath: _croppedImage!.path,
      color: _color,
      styleTags: _selectedStyles,
    );

    Navigator.pop(context, clothItem);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('添加服装'),
        actions: [
          TextButton(
            onPressed: _croppedImage != null ? _saveCloth : null,
            child: Text(
              '保存',
              style: TextStyle(
                color: _croppedImage != null ? AppTheme.primaryColor : AppTheme.textHintLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isProcessing
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 图片预览
                  _buildImagePreview(),

                  // 服装类型
                  _buildTypeSelector(),

                  // 颜色
                  _buildColorInput(),

                  // 风格标签
                  _buildStyleSelector(),

                  const SizedBox(height: 100),
                ],
              ),
            ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 280,
      color: Colors.grey[100],
      child: _croppedImage != null
          ? Stack(
              children: [
                InteractiveViewer(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      child: Image.file(
                        _croppedImage!,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                // 重新裁剪按钮
                Positioned(
                  right: 16,
                  bottom: 16,
                  child: FloatingActionButton.small(
                    onPressed: _cropImage,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.crop, color: AppTheme.primaryColor),
                  ),
                ),
              ],
            )
          : _originalImage != null
              ? InteractiveViewer(
                  child: Center(
                    child: Image.file(_originalImage!),
                  ),
                )
              : const Center(child: Text('未选择图片')),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '服装类型',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimaryLight,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '*',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ClothType.values.map((type) {
              final isSelected = _selectedType == type;
              return GestureDetector(
                onTap: () => setState(() => _selectedType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    _getTypeName(type),
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                      fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '主色调',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          // 快速选择
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '黑色', '白色', '灰色', '红色', '粉色', '橙色',
              '黄色', '绿色', '蓝色', '紫色', '棕色', '米色',
            ].map((color) {
              final isSelected = _color == color;
              return GestureDetector(
                onTap: () => setState(() => _color = color),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    color,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryLight,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          // 自定义输入
          TextField(
            decoration: InputDecoration(
              hintText: '或输入其他颜色...',
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() => _color = value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '风格标签',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '选择符合的风格（可多选）',
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textHintLight,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _styleOptions.map((style) {
              final isSelected = _selectedStyles.contains(style);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedStyles.remove(style);
                    } else {
                      _selectedStyles.add(style);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey[100],
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                      Text(
                        style,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getTypeName(ClothType type) {
    switch (type) {
      case ClothType.top:
        return '上衣';
      case ClothType.pants:
        return '裤子';
      case ClothType.skirt:
        return '裙子';
      case ClothType.dress:
        return '连衣裙';
      case ClothType.jacket:
        return '外套';
      case ClothType.shoes:
        return '鞋子';
      case ClothType.bag:
        return '包包';
      case ClothType.accessory:
        return '配饰';
    }
  }
}
