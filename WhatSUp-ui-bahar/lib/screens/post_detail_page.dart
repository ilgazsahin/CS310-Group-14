import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/data_models.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';

class PostDetailPage extends StatefulWidget {
  final PostModel post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _commentAuthorNameController =
      TextEditingController();
  bool _isSubmittingComment = false;
  late PostModel _currentPost;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
  }

  @override
  void dispose() {
    _commentController.dispose();
    _commentAuthorNameController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (widget.post.id == null || _isSubmittingComment) return;

    final content = _commentController.text.trim();
    final authorName = _commentAuthorNameController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (authorName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmittingComment = true);

    try {
      final comment = CommentModel(
        postId: widget.post.id!,
        userId: '', // Will be set by FirestoreService
        authorName: authorName,
        content: content,
        createdAt: DateTime.now(),
      );

      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).createComment(comment);

      // Clear form
      _commentController.clear();
      _commentAuthorNameController.clear();

      // Refresh post to get updated comment count
      if (mounted) {
        final updatedPost = await _firestoreService.getPost(widget.post.id!);
        if (updatedPost != null && mounted) {
          setState(() {
            _currentPost = updatedPost;
          });
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add comment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmittingComment = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    if (widget.post.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await Provider.of<PostProvider>(
          context,
          listen: false,
        ).deleteComment(commentId, widget.post.id!);

        // Refresh post to get updated comment count
        if (mounted) {
          final updatedPost = await _firestoreService.getPost(widget.post.id!);
          if (updatedPost != null && mounted) {
            setState(() {
              _currentPost = updatedPost;
            });
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comment deleted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete comment: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kCreatePurple,
        foregroundColor: Colors.white,
        title: const Text('Post Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: kCreatePurple,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentPost.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.white70, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        _currentPost.authorName ?? 'Unknown Author',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.calendar_today,
                        color: Colors.white70,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(_currentPost.createdAt),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Content
                  Text(
                    _currentPost.content,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Images Section
                  if (_currentPost.imageUrls.isNotEmpty) ...[
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Images',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._currentPost.imageUrls.map((imageUrl) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 40,
                                      ),
                                      SizedBox(height: 8),
                                      Text('Failed to load image'),
                                    ],
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                        ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  ],

                  // Like Button Section (isolated widget to prevent comments refresh)
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  _LikeButtonSection(
                    postId: _currentPost.id,
                    initialLikeCount: _currentPost.likes,
                  ),

                  // Comments Section
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Text(
                    'Comments (${_currentPost.comments})',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Comments List (appears first)
                  if (_currentPost.id != null)
                    StreamBuilder<List<CommentModel>>(
                      stream: Provider.of<PostProvider>(
                        context,
                        listen: false,
                      ).getCommentsStream(_currentPost.id!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'Error loading comments: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        final comments = snapshot.data ?? [];

                        if (comments.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              'No comments yet. Be the first to comment!',
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }

                        return Column(
                          children: comments.map((comment) {
                            final canDelete = Provider.of<PostProvider>(
                              context,
                              listen: false,
                            ).canUserDeleteComment(comment);

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(
                                    Icons.account_circle,
                                    size: 32,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              comment.authorName ?? 'Unknown',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodyLarge?.color,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              _formatDate(comment.createdAt),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall?.color,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          comment.content,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyMedium?.color,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (canDelete)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete_outline,
                                        size: 20,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        if (comment.id != null) {
                                          _deleteComment(comment.id!);
                                        }
                                      },
                                      tooltip: 'Delete comment',
                                    ),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),

                  // Add Comment Form (appears at bottom, after comments)
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: _commentAuthorNameController,
                          decoration: const InputDecoration(
                            labelText: 'Your Name*',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Write a comment...*',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmittingComment
                                ? null
                                : _submitComment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: kCreatePurple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: _isSubmittingComment
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Post Comment'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24), // Extra padding at bottom
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Isolated Like Button Widget to prevent parent widget rebuilds
class _LikeButtonSection extends StatefulWidget {
  final String? postId;
  final int initialLikeCount;

  const _LikeButtonSection({
    required this.postId,
    required this.initialLikeCount,
  });

  @override
  State<_LikeButtonSection> createState() => _LikeButtonSectionState();
}

class _LikeButtonSectionState extends State<_LikeButtonSection> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _isLiked = false;
  bool _isProcessingLike = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _likeCount = widget.initialLikeCount;
    _checkLikeStatus();
  }

  Future<void> _checkLikeStatus() async {
    if (widget.postId != null) {
      final liked = await Provider.of<PostProvider>(
        context,
        listen: false,
      ).hasUserLikedPost(widget.postId!);
      if (mounted) {
        setState(() {
          _isLiked = liked;
        });
      }
    }
  }

  Future<void> _toggleLike() async {
    if (widget.postId == null || _isProcessingLike) return;

    // Optimistically update UI immediately for smooth experience
    final wasLiked = _isLiked;
    final currentLikeCount = _likeCount;
    final newLikedState = !_isLiked;
    final newLikeCount = newLikedState
        ? currentLikeCount + 1
        : currentLikeCount - 1;

    // Update UI immediately - no waiting (only this widget rebuilds)
    setState(() {
      _isProcessingLike = true; // Prevent double-clicks
      _isLiked = newLikedState;
      _likeCount = newLikeCount;
    });

    // Perform the actual like/unlike operation in the background
    try {
      await Provider.of<PostProvider>(
        context,
        listen: false,
      ).toggleLikePost(widget.postId!);

      // Operation succeeded - no need to refresh, optimistic update was correct
      // Silently verify in background without updating UI
      Future.microtask(() async {
        if (mounted && widget.postId != null) {
          try {
            final actualCount = await _firestoreService.getPostLikeCount(
              widget.postId!,
            );
            final actualLiked = await _firestoreService.hasUserLikedPost(
              widget.postId!,
            );
            // Only update if there's a discrepancy (shouldn't happen, but safety check)
            if (mounted &&
                (actualCount != newLikeCount || actualLiked != newLikedState)) {
              setState(() {
                _likeCount = actualCount;
                _isLiked = actualLiked;
              });
            }
          } catch (_) {
            // Silently ignore background verification errors
          }
        }
      });
    } catch (e) {
      // Revert optimistic update on error
      if (mounted) {
        setState(() {
          _isLiked = wasLiked;
          _likeCount = currentLikeCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to like post: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // Re-enable button after operation completes
      if (mounted) {
        setState(() => _isProcessingLike = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: ElevatedButton.icon(
            key: ValueKey(_isLiked),
            onPressed: _isProcessingLike ? null : _toggleLike,
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.grey,
            ),
            label: Text(
              _isLiked ? 'Liked' : 'Like',
              style: TextStyle(color: _isLiked ? Colors.red : Colors.grey),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isLiked
                  ? Colors.red.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        const SizedBox(width: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Text(
            '$_likeCount likes',
            key: ValueKey(_likeCount),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }
}
