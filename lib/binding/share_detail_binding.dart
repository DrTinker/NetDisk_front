import 'package:cheetah_netdesk/controller/share_controller.dart';
import 'package:get/get.dart';


class ShareDetailBinding implements Bindings {
  @override
  void dependencies() {
    // 获取sc
    Get.lazyPut<ShareController>(() => ShareController());
  }
}