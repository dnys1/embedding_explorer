import 'package:jaspr/jaspr.dart';
import 'package:jaspr_router/jaspr_router.dart';

class Header extends StatelessComponent {
  const Header({super.key});

  @override
  Component build(BuildContext context) {
    var activePath = RouteState.of(context).location;

    return header([
      nav([
        for (var route in [
          (label: 'Home', path: '/'),
          (label: 'Data Source', path: '/data-source'),
          (label: 'About', path: '/about'),
        ])
          div(classes: activePath == route.path ? 'active' : null, [
            Link(to: route.path, child: text(route.label)),
          ]),
      ]),
    ]);
  }
}
