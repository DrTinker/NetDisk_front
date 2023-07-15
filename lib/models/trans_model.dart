// ignore_for_file: prefer_initializing_formals

import 'package:flutter_learn/components/toast.dart';
import 'package:flutter_learn/conf/const.dart';
import 'package:flutter_learn/helper/storage.dart';

import '../conf/url.dart';
import '../helper/convert.dart';
import '../helper/net.dart';

class TransObj {
  String transID=""; // 传输uuid
  String fileUuid=""; // 文件file_uuid
  String icon=""; 
  String fullName="";
  String ext="";
  String hash = "";
  String localPath = ""; // 本地文件地址
  String fileKey = ""; // 云端地址
  String parentId = ""; // 父节点file_uuid
  int totalSize=0; // 文件总大小
  int curSize=0; // 已上传大小
  int startTime=0;
  // 分块上传
  int chunkSize=0;
  int chunkCount=0;
  List<int> chunkList=[]; // 已上传的分块列表
  Stream<List<int>>? fileReadStream;

  static TransObj fromMap(Map trans) {
    String fullName = trans['Name'] + "." + trans['Ext'];
    String ext = trans['Ext'];
    String local = trans['Local_Path'];
    int totalSize = trans['Size'];
    String parentId = trans['Parent_Uuid'];
    TransObj obj = TransObj(fullName, ext, local, totalSize, parentId);
    obj.transID = trans['Uuid'];
    obj.fileUuid = trans['File_Uuid'];
    obj.hash = trans['Hash'];
    obj.curSize = trans['CurSize'];
    // 处理最后一个分片不满的情况
    if (obj.curSize > obj.totalSize) {
      obj.curSize = obj.totalSize;
    }
    obj.chunkSize = trans['ChunkSize'];
    for (var chunk in trans['ChunkList']) {
      obj.chunkList.add(chunk);
    }
    return obj;
  }
  
  TransObj(String fullName, String? ext, String? local, int totalSize, String? parentId) {
    icon = 'assets/images/nodata.png';
    this.fullName = fullName;
    ext = ext;
    if (iconMap.containsKey(ext)) {
      icon = iconMap[ext]!;
    }
    localPath = local!;
    // 默认在根路径下
    if (parentId!=null) {
      this.parentId = parentId;
    } else {
      var store = SyncStorage();
      if (store.hasKey(userStartDir)) {
        parentId = store.getStorage(userStartDir);
      }
    }
    
    // 初始化时先置为0，到发请求时再计算
    this.totalSize = totalSize;
    startTime = DateTime.now().second;
  }
}

class TransList {
  List<TransObj> transList = [];
  int page = 1;
  String token="";
  int mod=0; // 上传还是下载
  int status=0; // 状态 进行 成功 失败

  TransList(int mod, int status) {
    this.mod = mod;
    this.status = status;
  }

  // 读取传输列表
  getTransList(bool append) async {
    Map<String, String> headers = {
      'Authorization': token,
    };
    Map<String, String> params = {
      'page': page.toString(),
      'isdown': mod.toString(),
      'status': status.toString(),
    };
    // 删除
    await NetWorkHelper.requestGet(
      transInfoUrl,
      (data) {
        var trans_list = data['trans_list'];
        // 刷新清空
        if (!append) {
          transList.clear();
          // 刷新则重置页码
          page = 1;
        }
        // file是map
        for (var trans in trans_list) {
          TransObj transObj = TransObj.fromMap(trans);
          transList.add(transObj);
        }
      },
      params: params,
      headers: headers,
      transform: JSONConvert.create(),
    );
  }

  // 加载更多
  getMoreData() async {
    if (page <= 0) {
      return;
    }
    page++;
    print('getMoreData, page: $page');
    int preLen = transList.length;
    await getTransList(true);
    int curLen = transList.length;
    // 没有更多数据
    if (curLen == preLen && page > 1) {
      page--;
      MsgToast().customeToast('没有更多数据了');
      print('page: $page');
    }
    return;
  }
}