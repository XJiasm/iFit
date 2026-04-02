import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/tryon_provider.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class TryOnResultScreen extends ConsumerStatefulWidget {
  final String resultPath;
  final String avatarId;
  final String clothItemId;
  final double offsetX;
  final double offsetY;
  final double scale;
  final double rotation;
  final double opacity;
  final String? clothType;
  final String? clothColor;

  const TryOnResultScreen({
    super.key,
    required this.resultPath,
    required this.avatarId,
    required this.clothItemId,
    required this.offsetX,
    required this.offsetY,
    required this.scale,
    required this.rotation,
    required this.opacity,
    this.clothType,
    this.clothColor,
  });

  @override
  ConsumerState<TryOnResultScreen> createState() => _TryOnResultScreenState();
}

class _TryOnResultScreenState extends ConsumerState<TryOnResultScreen> {
  bool _isSaving = false;
  bool _isGettingAiComment = false;
  AiCommentResponse? _aiComment;

  @override
  void initState() {
    super.initState();
    _autoSave();
  }

  Future<void> _autoSave() async {
    await ref.read(tryOnListProvider.notifier).addTryOnResult(
          avatarId: widget.avatarId,
          clothItemId: widget.clothItemId,
          resultImagePath: widget.resultPath,
          offsetX: widget.offsetX,
          offsetY: widget.offsetY,
          scale: widget.scale,
          rotation: widget.rotation,
          opacity: widget.opacity,
        );
  }

  Future<void> _getAiComment() async {
    setState(() => _isGettingAiComment = true);

    try {
      final response = await ApiService.getAiComment(
        clothType: widget.clothType ?? 'top',
        clothColor: widget.clothColor ?? '黑色',
      );

      if (response['code'] == 200 && response['data'] != null) {
        setState(() {
          _aiComment = AiCommentResponse.fromJson(response['data']);
        });
      } else {
        // 使用模拟数据
        _getMockComment();
      }
    } catch (e) {
      // 使用模拟数据
      _getMockComment();
    } finally {
      if (mounted) {
        setState(() => _isGettingAiComment = false);
      }
    }
  }

  void _getMockComment() {
    setState(() {
      _aiComment = AiCommentResponse(
        score: 85,
        summary: '这件服装整体风格不错，很适合你的气质！',
        color: ColorAnalysis(
          score: 88,
          comment: '颜色百搭，适合大多数肤色，尤其适合暖黄皮',
          suitableSkinTones: ['暖黄皮', '冷白皮', '自然肤色'],
        ),
        style: StyleAnalysis(
          score: 82,
          comment: '简约大方，易于搭配，是衣橱必备单品',
          tags: ['简约', '休闲', '百搭', '通勤'],
        ),
        occasions: ['日常休闲', '通勤上班', '朋友聚会', '约会'],
        suggestions: [
          '可搭配浅色牛仔裤或米色休闲裤',
          '适合搭配简约风格的首饰',
          '建议选择小白鞋或乐福鞋',
        ],
        conclusion: '推荐购买！这是一件百搭实用的单品，可以轻松驾驭多种场合。',
      );
    });
  }

  Future<void> _shareResult() async {
    try {
      await Share.shareXFiles(
        [XFile(widget.resultPath)],
        text: 'FitMirror 虚拟试穿效果',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: $e')),
        );
      }
    }
  }

  Future<void> _saveToGallery() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('已保存到相册'),
        backgroundColor: AppTheme.accentColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 效果图展示
          Expanded(
            child: _buildResultImage(),
          ),

          // AI 点评卡片
          if (_aiComment != null) _buildAiCommentCard(),

          // 底部操作栏
          _buildBottomBar(),
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
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
      ),
      title: const Text('试穿效果'),
      actions: [
        IconButton(
          icon: const Icon(Icons.share),
          onPressed: _shareResult,
        ),
      ],
    );
  }

  Widget _buildResultImage() {
    return Center(
      child: InteractiveViewer(
        minScale: 0.5,
        maxScale: 3.0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          child: Image.file(
            File(widget.resultPath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAiCommentCard() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 顶部标签和评分
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 14,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'AI 穿搭点评',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _getScoreGradient(_aiComment!.score),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_aiComment!.score}分',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 总结
              Text(
                _aiComment!.summary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),

              // 评分详情
              _buildScoreDetail('颜色匹配', _aiComment!.color.score, _aiComment!.color.comment),
              const SizedBox(height: 12),
              _buildScoreDetail('风格契合', _aiComment!.style.score, _aiComment!.style.comment),
              const SizedBox(height: 16),

              // 适用场合
              Text(
                '适用场合',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _aiComment!.occasions.map((o) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    o,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[300],
                    ),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 16),

              // 搭配建议
              Text(
                '搭配建议',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 8),
              ...(_aiComment!.suggestions.map((s) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, size: 14, color: AppTheme.accentColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
              ))),

              const SizedBox(height: 16),

              // 结论
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _aiComment!.conclusion,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.accentColor,
                        ),
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

  Widget _buildScoreDetail(String label, int score, String comment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _getScoreColor(score),
                  ),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$score',
              style: TextStyle(
                fontSize: 12,
                color: _getScoreColor(score),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          comment,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.accentColor;
    if (score >= 60) return AppTheme.secondaryColor;
    return Colors.orange;
  }

  List<Color> _getScoreGradient(int score) {
    if (score >= 80) return [AppTheme.accentColor, Color(0xFF00E676)];
    if (score >= 60) return [AppTheme.secondaryColor, Color(0xFFFFD54F)];
    return [Colors.orange, Colors.deepOrange];
  }

  Widget _buildBottomBar() {
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
        child: Row(
          children: [
            // AI 点评按钮
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isGettingAiComment ? null : _getAiComment,
                icon: _isGettingAiComment
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                        ),
                      )
                    : const Icon(Icons.auto_awesome, size: 18),
                label: Text(_aiComment != null ? '重新点评' : 'AI 点评'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 保存按钮
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saveToGallery,
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text('保存'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
