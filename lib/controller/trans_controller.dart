// ignore_for_file: unrelated_type_equality_checks

import 'package:flutter_learn/helper/md5.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/conf/url.dart';
import 'package:flutter_learn/helper/net.dart';
import 'package:flutter_learn/models/trans_model.dart';
import 'package:get/get.dart';

import '../components/toast.dart';
import '../conf/code.dart';
import '../helper/convert.dart';
import '../helper/storage.dart';

class TransController extends GetxController {
  List<TransObj> uploadList = [];
  List<TransObj> downloadList = [];

  List<TransObj> uploadFailList = [];
  List<TransObj> downloadFailList = [];

  // 用户登录
  String token = "";

  @override
  void onInit() {
    // 尝试读取token和根目录，读不到直接返回，说明没登录
    var store = SyncStorage();
    if (!store.hasKey(userToken) && !store.hasKey(userStartDir)) {
      return;
    }
    if (token == "") {
      token = store.getStorage(userToken);
    }
    TransObj t1 = TransObj('测试1', 'png', '/root/test/测试.png', 2000, '');
    t1.setCurSize(200);

    TransObj t2 = TransObj('测试2', 'png', '/root/test/测试.png', 2000, '');
    t2.setCurSize(1000);

    uploadList.add(t1);
    uploadList.add(t2);
    downloadList.add(t1);
  }

  doUpload(String parentId, List<PlatformFile> files) async{
    for (var file in files) {
      // 封装transobj
      TransObj obj = TransObj(file.name, file.extension, file.path, file.size, parentId);
      // 获取文件流
      final fileReadStream = file.readStream;
      if (fileReadStream == null) {
        throw Exception('Cannot read file from null stream');
      }
      obj.setReadStream(fileReadStream);
      // 加入队列
      uploadList.add(obj);
      // 判断文件大小决定传输策略
      if (file.size >= largeMark) {
        // TODO 分块上传
      } else {
        // 普通上传
        await uploadFile(obj);
      }
    }
  }

  // 初始化分块上传
  initUploadPart(TransObj file) async {
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> body = {
      'hash': file.hash,
      'name': file.fullName,
      'parent_uuid': file.parentId,
      'size': (file.totalSize).toString(),
    };
    await NetWorkHelper.requestPost(
      initUploadPartUrl,
      (data) {
        String code = data['code'];
        // 秒传
        if (code == quickUploadCode) {
          // 设置进度为100
          file.curSize = file.totalSize;
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
        // 非秒传，获取数据
        file.partInfo = TransPart(
          data['chunk_size'],
          data['chunk_count'],
          data['chunk_list'],
          data['upload_id'],
        );
      },
      body: body,
      headers: headers,
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        MsgToast().customeToast(error.toString());
      },
    );
  }

  // 普通上传接口
  uploadFile(TransObj file) async {
    // TODO 查看原因 直接读取byte数组导致文件损坏
    // 计算hash值，为了减少文件磁盘IO，hash值推迟到此时计算
    // var fileBytes = await file.fileReadStream!.first;
    // file.hash = getFileHashByStream(fileBytes);
    await getFileHashSimple(file.localPath).then((value) => file.hash = value);
    Map<String, dynamic> body = {
      'hash': file.hash,
      'name': file.fullName,
      'parent_uuid': file.parentId,
    };
    await NetWorkHelper.fileUplod(
      uploadUrl,
      token,
      (data) {
        String code = data['code'];
        // 秒传
        if (code == quickUploadCode || code == httpSuccessCode) {
          // 设置进度为100
          file.curSize = file.totalSize;
          MsgToast().customeToast('有文件上传成功了，快去看看吧');
          return;
        }
      },
      file,
      body: body,
      // fileBytes: fileBytes,
      progress: (curSize, totalSize) {
        // 进入发生变化时更新界面
        file.curSize = curSize;
        print('当前: ${file.curSize}, 总计: $totalSize');
        update();
      },
      transform: JSONConvert.create(),
      error: (statusCode, error) {
        MsgToast().serverErrToast();
        return;
      },
    );
  }
}