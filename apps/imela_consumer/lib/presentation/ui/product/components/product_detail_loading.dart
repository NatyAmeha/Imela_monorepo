// FILE: shimmer_loading.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

class ProductDetailLoadingComponent extends StatelessWidget {
  const ProductDetailLoadingComponent({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: double.infinity, height: 200.0, color: Colors.white),
            const SizedBox(height: 8.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: double.infinity, height: 30.0, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 150.0, height: 20.0, color: Colors.white),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 100.0, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: 150.0, height: 20.0, color: Colors.white),
                const SizedBox(height: 16),
                Container(width: double.infinity, height: 80.0, color: Colors.white),
                const SizedBox(height: 8),
                Container(width: double.infinity, height: 80.0, color: Colors.white),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Container(height: 30.0, color: Colors.white)),
                    const SizedBox(width: 16),
                    Expanded(child: Container(height: 30.0, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0))),
                    const SizedBox(width: 16),
                    Expanded(child: Container(height: 30.0, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0))),
                    const SizedBox(width: 16),
                    Expanded(child: Container(height: 30.0, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0))),
                    const SizedBox(width: 16),
                    Expanded(child: Container(height: 30.0, color: Colors.white)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(width: 30, height: 30, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.0))),
                    const SizedBox(width: 16),
                    Expanded(child: Container(height: 30.0, color: Colors.white)),
                  ],
                )
              ],
            ).paddingSymmetric(horizontal: 16)
          ],
        ));
  }
}
