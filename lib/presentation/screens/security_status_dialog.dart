import 'package:flutter/material.dart';
import '../../core/security/security_engine.dart';
import '../../core/telemetry/native_crash_bridge.dart';
import '../../core/theme/app_colors.dart';

class SecurityStatusDialog extends StatelessWidget {
  final SecurityAuditResult? audit;
  final VoidCallback onRefresh;

  const SecurityStatusDialog({
    super.key,
    required this.audit,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderSubtle),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.uberBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.security, color: AppColors.uberBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Engine (SE) Audit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        Text(
                          'Reverse-engineered from libse.so & libeef0.so',
                          style: TextStyle(fontSize: 11, color: AppColors.gray400),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.gray400, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: AppColors.borderSubtle, height: 24),

              // Verdict Summary Banner
              _buildVerdictBanner(audit?.verdict ?? SecurityVerdict.clean),
              const SizedBox(height: 16),

              // Checks list
              const Text(
                'NATIVE INTEGRITY AUDIT CHECKS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 10),
              _buildCheckItem(
                title: 'Root Binary Scan (/sbin/su, /system/xbin/su)',
                passed: !(audit?.isRooted ?? false),
              ),
              _buildCheckItem(
                title: 'Kernel Mount Inspection (/proc/mounts Magisk/Overlay)',
                passed: !(audit?.hasSuspiciousMounts ?? false),
              ),
              _buildCheckItem(
                title: 'Instrumentation & Hooking Scanner (Frida Port 27042)',
                passed: !(audit?.isDebuggerAttached ?? false),
              ),
              _buildCheckItem(
                title: 'Emulator Signatures (QEMU / Ranchu Hardware)',
                passed: !(audit?.isEmulator ?? false),
              ),
              const SizedBox(height: 14),

              // Attestation Token Preview
              const Text(
                'SIGNED INTEGRITY ATTESTATION TOKEN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDarkElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  audit?.integrityToken ?? 'Generating token...',
                  style: const TextStyle(
                    fontSize: 10,
                    fontFamily: 'Courier',
                    color: AppColors.uberBlue,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 20),

              // Telemetry & Crash Test Controls (libndk-crash & libndk-anr)
              const Text(
                'DIAGNOSTIC TEST PROBES (NDK BRIDGES)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: AppColors.gray400,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.uberRed,
                        side: const BorderSide(color: AppColors.uberRed),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        NativeCrashBridge().forceTestCrash();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulated SIGSEGV native signal dispatched to NdkCrashBridge'),
                            backgroundColor: AppColors.uberRed,
                          ),
                        );
                      },
                      child: const Text('Test SIGSEGV', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.uberGold,
                        side: const BorderSide(color: AppColors.uberGold),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        NativeCrashBridge().simulateAnrEvent();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulated SIGQUIT watchdog event captured by NdkAnrBridge'),
                            backgroundColor: AppColors.uberGold,
                          ),
                        );
                      },
                      child: const Text('Test SIGQUIT (ANR)', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerdictBanner(SecurityVerdict verdict) {
    Color bg;
    Color border;
    IconData icon;
    String text;

    switch (verdict) {
      case SecurityVerdict.clean:
        bg = AppColors.uberGreen.withOpacity(0.12);
        border = AppColors.uberGreen;
        icon = Icons.check_circle_outline;
        text = 'Environment Verified — Device Integrity Clean';
        break;
      case SecurityVerdict.warning:
        bg = AppColors.uberGold.withOpacity(0.12);
        border = AppColors.uberGold;
        icon = Icons.warning_amber_rounded;
        text = 'Warning — Potential Virtualization / Debug Environment';
        break;
      case SecurityVerdict.compromised:
        bg = AppColors.uberRed.withOpacity(0.12);
        border = AppColors.uberRed;
        icon = Icons.error_outline;
        text = 'Device Compromised — Root or Hook Framework Detected';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: border, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: border,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem({required String title, required bool passed}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check : Icons.close,
            color: passed ? AppColors.uberGreen : AppColors.uberRed,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 12, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}
