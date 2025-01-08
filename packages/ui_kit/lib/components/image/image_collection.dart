import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:imela_ui_kit/components/image/app_image.dart';

class ImageCollection extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final BorderRadius borderRadius;
  final double spacing;
  final Function(int)? onImagePressed;

  const ImageCollection({
    super.key,
    required this.imageUrls,
    this.height = 200,
    this.borderRadius = const BorderRadius.all(Radius.circular(2)),
    this.spacing = 2,
    this.onImagePressed,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) return const SizedBox();

    return _buildImageGrid();
  }

  Widget _buildImageGrid() {
    // Different patterns based on number of images
    switch (imageUrls.take(3).length) {
      case 1:
        return _buildSingleImageLayout();
      case 2:
        return _buildTwoImageLayout();

      default:
        return _buildManyImageLayout();
    }
  }

  Widget _buildSingleImageLayout() {
    return SizedBox(
      height: height,
      child: StaggeredGrid.count(
        crossAxisCount: 1,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                onImagePressed?.call(0);
              },
              child: AppImage(
                imageUrl: imageUrls[0],
                borderRadius: borderRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoImageLayout() {
    return SizedBox(
      height: height,
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        children: [
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                onImagePressed?.call(0);
              },
              child: AppImage(
                imageUrl: imageUrls[0],
                borderRadius: borderRadius,
              ),
            ),
          ),
          StaggeredGridTile.count(
            crossAxisCellCount: 1,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                onImagePressed?.call(1);
              },
              child: AppImage(
                imageUrl: imageUrls[1],
                borderRadius: borderRadius,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManyImageLayout() {
    return SizedBox(
      height: height,
      child: StaggeredGrid.count(
        crossAxisCount: 4,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        children: [
          // First image (largest)
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 2,
            child: InkWell(
              onTap: () {
                onImagePressed?.call(0);
              },
              child: AppImage(
                imageUrl: imageUrls[0],
                borderRadius: borderRadius,
                height: 100,
              ),
            ),
          ),
          // Second image
          StaggeredGridTile.count(
            crossAxisCellCount: 2,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                onImagePressed?.call(1);
              },
              child: AppImage(
                imageUrl: imageUrls[1],
                borderRadius: borderRadius,
              ),
            ),
          ),
          // Third image
          StaggeredGridTile.count(
            crossAxisCellCount: imageUrls.length > 3 ? 1 : 2,
            mainAxisCellCount: 1,
            child: InkWell(
              onTap: () {
                onImagePressed?.call(2);
              },
              child: AppImage(
                imageUrl: imageUrls[2],
                borderRadius: borderRadius,
              ),
            ),
          ),
          if (imageUrls.length > 3)

            // Fourth image with potential overlay
            StaggeredGridTile.count(
              crossAxisCellCount: 1,
              mainAxisCellCount: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  AppImage(
                    imageUrl: imageUrls[3],
                    borderRadius: borderRadius,
                  ),
                  if (imageUrls.length > 3)
                    InkWell(
                      onTap: () {
                        onImagePressed?.call(3);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: borderRadius,
                        ),
                        child: Center(
                          child: Text(
                            '+${imageUrls.length - 4}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
