import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class TidesScreen extends StatelessWidget {
  const TidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Marées & Courants', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.iconBgCyan,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.waves, color: AppColors.primaryTeal, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Text('Brest', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                        SizedBox(width: 6),
                        Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('HAUTEUR ACTUELLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: const [
                            Text('0.61', style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: AppColors.textDark)),
                            SizedBox(width: 4),
                            Text('m', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.iconBgCyan,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, color: AppColors.primaryTeal, size: 16),
                          SizedBox(width: 4),
                          Text('Montante (flot)', style: TextStyle(color: AppColors.primaryTeal, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Prochaines pleines / basses mers (étales)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textDark)),
                        Text('Coef. 82', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryTeal)),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.cardBorder),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.arrow_upward_rounded, color: AppColors.primaryTeal, size: 18),
                            SizedBox(width: 6),
                            Text('Pleine Mer (PM)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          ],
                        ),
                        Text('21:52', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        Text('6.44 m', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.arrow_downward_rounded, color: AppColors.alertRed, size: 18),
                            SizedBox(width: 6),
                            Text('Basse Mer (BM)', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                          ],
                        ),
                        Text('04:04', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
                        Text('0.40 m', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.alertRed)),
                      ],
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
}
