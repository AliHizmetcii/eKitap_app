import 'package:flutter/material.dart';
import 'package:sa4_migration_kit/multi_tween/multi_tween.dart';
import 'package:sa4_migration_kit/sa4_migration_kit.dart';
enum AniProps { opacity, translateX }

class FadeAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  final bool isLeft;

  FadeAnimation( this.child , {this.delay=0.3,this.isLeft=true});

  @override
  Widget build(BuildContext context) {
    /*final tween = MultiTween([
      Track('opacity').add(Duration(milliseconds: 500),
        Tween(begin: 0.0, end: 1.0)
      ),
      Track('translateX').add(Duration(milliseconds: 500),
        Tween(begin: 120.0, end: 0.0),
        curve: Curves.easeOut
      )
    ]);*/
    final _tween= MultiTween<AniProps>()
      ..add(AniProps.opacity,Tween(begin: 0.0, end: 1.0),Duration(milliseconds: 600))
      ..add(AniProps.translateX,Tween(begin: (isLeft?-120.0:120.0), end: 0.0),Duration(milliseconds: 300),Curves.easeInOut);
    return PlayAnimation<MultiTweenValues<AniProps>>(
      delay: Duration(milliseconds: (500 * delay).round()),
      duration: _tween.duration,
      tween: _tween,
      child: child,
      builder: (context, child, animation) => Opacity(
        opacity: animation.get(AniProps.opacity),
        child: Transform.translate(
          offset: Offset(animation.get(AniProps.translateX), 0),
          child: child,
        ),
      ),
    );
  }
}
