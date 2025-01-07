import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:github_repo_finder/l10n/l10n.dart';

class GrfErrorWidget extends StatelessWidget {
  const GrfErrorWidget({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Gap(64),
          Text(
            context.l10n.genericOupsSomethingWentWrong,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
          ),
          const Gap(24),
          if (onPressed != null) ElevatedButton(onPressed: onPressed, child: Text(context.l10n.genericTryAgain)),
        ],
      ),
    );
  }
}
