const baseUrl = "http://192.168.2.6:8081";

const loginUrl = "$baseUrl/user/login";
const fileInfoUrl = "$baseUrl/object/list";
const mkDirUrl = "$baseUrl/object/mkdir";
const copyUrl = "$baseUrl/object/batch/copy";
const moveUrl = "$baseUrl/object/batch/move";
const deleteUrl = "$baseUrl/object/batch/delete";
const renameUrl = "$baseUrl/object/rename";

const uploadUrl = "$baseUrl/trans/upload/total";
const initUploadPartUrl = "$baseUrl/trans/upload/init";
const uploadPartUrl = "$baseUrl/trans/upload/part";
const completeUploadPartUrl = "$baseUrl/trans/upload/complete";
const transInfoUrl = "$baseUrl/trans/info";