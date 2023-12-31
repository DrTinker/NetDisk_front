import 'package:flutter/widgets.dart';

var tabImages = [
  [
    Image.asset('assets/icons/disk.png', height: 25, width: 25,),
    Image.asset('assets/icons/disk_selected.png', height: 25, width: 25,),
  ],
  [
    Image.asset('assets/icons/trans.png', height: 25, width: 25,),
    Image.asset('assets/icons/trans_selected.png', height: 25, width: 25,),
  ],
  [

  ],
  [
    Image.asset('assets/icons/share.png', height: 25, width: 25,),
    Image.asset('assets/icons/share_selected.png', height: 25, width: 25,),
  ],
  [
    Image.asset('assets/icons/user.png', height: 25, width: 25,),
    Image.asset('assets/icons/user_selected.png', height: 25, width: 25,),
  ],
];

// 中间多一个上传按钮
const tabLabels = ["文件", "传输", "", "分享", "用户"];
const tabRouters = ['/file', '/trans', '', '/share', '/user_info'];

const filePageIndex = 0;
const transPageIndex = 1;
const sharePageIndex = 3;
const userPageIndex = 4;