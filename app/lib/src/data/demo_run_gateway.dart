import 'demo_run_gateway_contract.dart';
import 'demo_run_gateway_stub.dart'
    if (dart.library.html) 'demo_run_gateway_web.dart';

export 'demo_run_gateway_contract.dart';
export 'demo_run_gateway_fixture.dart';

DemoRunGateway createDemoRunGateway() => createPlatformDemoRunGateway();
