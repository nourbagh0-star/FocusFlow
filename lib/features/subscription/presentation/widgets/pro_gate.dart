import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:focus_flow/features/subscription/presentation/cubit/subscription_cubit.dart';

class ProGate extends StatelessWidget {
  const ProGate({
    super.key,
    required this.child,
    required this.locked,
  });

  final Widget child;
  final Widget locked;

  @override
  Widget build(BuildContext context) {
    final isPro = context.select<SubscriptionCubit, bool>(
      (cubit) => cubit.state.status.isPro,
    );
    return isPro ? child : locked;
  }
}
