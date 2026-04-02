import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../providers/avatar_provider.dart';
import '../../models/avatar.dart';
import '../../services/storage_service.dart';
import '../../utils/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AvatarListScreen extends ConsumerStatefulWidget {
  const AvatarListScreen({super.key});

  @override
  ConsumerState<AvatarListScreen> createState() => _AvatarListScreenState();
}

class _AvatarListScreenState extends ConsumerState<AvatarListScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _createAvatar() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final storageService = StorageService();
      await storageService.init();
      final savedPath = await storageService.saveAvatarImage(File(image.path));

      final thumbnailPath = await storageService.createThumbnail(savedPath);

      await ref.read(avatarListProvider.notifier).addAvatar(
            name: '形象 ${DateTime.now().month}-${DateTime.now().day}',
            photoPath: savedPath,
            thumbnailPath: thumbnailPath,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('形象创建成功'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image == null) return;

    setState(() => _isLoading = true);

    try {
      final storageService = StorageService();
      await storageService.init();
      final savedPath = await storageService.saveAvatarImage(File(image.path));
      final thumbnailPath = await storageService.createThumbnail(savedPath);

      await ref.read(avatarListProvider.notifier).addAvatar(
            name: '形象 ${DateTime.now().month}-${DateTime.now().day}',
            photoPath: savedPath,
            thumbnailPath: thumbnailPath,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('形象创建成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('创建失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteAvatar(Avatar avatar) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: const Text('删除形象'),
        content: Text('确定要删除「${avatar.name}」吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              '取消',
              style: TextStyle(color: AppTheme.textHintLight),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await StorageService().deleteFile(avatar.photoPath);
      if (avatar.thumbnailPath != null) {
        await StorageService().deleteFile(avatar.thumbnailPath!);
      }
      await ref.read(avatarListProvider.notifier).deleteAvatar(avatar.id);
    }
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 拖拽指示器
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '创建形象',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // 拍照
                    ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.camera_alt, color: AppTheme.primaryColor),
                      ),
                      title: const Text('拍照'),
                      subtitle: const Text('拍摄全身照创建形象'),
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                    const SizedBox(height: 8),
                    // 相册
                    ListTile(
                      leading: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.photo_library, color: AppTheme.secondaryColor),
                      ),
                      title: const Text('相册'),
                      subtitle: const Text('从相册选择全身照'),
                      onTap: () {
                        Navigator.pop(context);
                        _createAvatar();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final avatars = ref.watch(avatarListProvider);

    return Scaffold(
      backgroundColor: AppTheme.scaffoldBackgroundLight,
      body: CustomScrollView(
        slivers: [
          // 标题区
          SliverToBoxAdapter(
            child: _buildHeader(context),
          ),

          // 形象列表
          avatars.isEmpty
              ? SliverToBoxAdapter(
                  child: _buildEmptyState(context),
                )
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildAvatarCard(avatars[index]),
                      childCount: avatars.length,
                    ),
                  ),
                ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isLoading ? null : _showCreateOptions,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_a_photo, color: Colors.white),
        label: const Text(
          '创建形象',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '我的形象',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            '形象管理',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '上传全身照作为试穿底图',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_add_outlined,
                size: 48,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '还没有创建形象',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '上传全身照开始虚拟试穿体验',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textHintLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarCard(Avatar avatar) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 查看详情或编辑
          },
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          onLongPress: () => _deleteAvatar(avatar),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 图片
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(AppTheme.radiusMedium),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: avatar.thumbnailPath != null
                            ? Image.file(
                                File(avatar.thumbnailPath!),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    // 更多按钮
                    Positioned(
                      right: 8,
                      top: 8,
                      child: GestureDetector(
                        onTap: () => _showAvatarOptions(avatar),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.more_horiz,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 信息
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      avatar.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${avatar.createdAt.month}月${avatar.createdAt.day}日创建',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textHintLight,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.person, size: 48, color: Colors.grey),
      ),
    );
  }

  void _showAvatarOptions(Avatar avatar) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radiusLarge),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: const Text('编辑名称'),
                      onTap: () {
                        Navigator.pop(context);
                        _editAvatarName(avatar);
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.delete_outline, color: AppTheme.primaryColor),
                      title: Text('删除', style: TextStyle(color: AppTheme.primaryColor)),
                      onTap: () {
                        Navigator.pop(context);
                        _deleteAvatar(avatar);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _editAvatarName(Avatar avatar) async {
    final controller = TextEditingController(text: avatar.name);

    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        title: const Text('编辑名称'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '输入形象名称',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      avatar.name = newName;
      await ref.read(avatarListProvider.notifier).updateAvatar(avatar);
    }
  }
}
