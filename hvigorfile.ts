// /*
//  * Copyright (c) 2026 Huawei Device Co., Ltd.
//  * Licensed under the Apache License, Version 2.0 (the "License");
//  * you may not use this file except in compliance with the License.
//  * You may obtain a copy of the License at
//  *
//  *     http://www.apache.org/licenses/LICENSE-2.0
//  *
//  * Unless required by applicable law or agreed to in writing, software
//  * distributed under the License is distributed on an "AS IS" BASIS,
//  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  * See the License for the specific language governing permissions and
//  * limitations under the License.
//  */
//
// import { appTasks } from '@ohos/hvigor-ohos-plugin';
// import { hvigor, getHvigorNode } from '@ohos/hvigor';
// import { uploadTestCases } from '@ohos/hypium-plugin';
// import { OnlineSignOptions, onlineSignPlugin } from '@ohos/hvigor-ohos-online-sign-plugin';
//
// const signOptions: OnlineSignOptions = {
//   profile: 'hw_sign/simtoolkit_release.p7b',
//   keyAlias: 'HwSimToolkits',
//   hapSignToolFile: `${process.env.HAP_SIGN_TOOL ?? 'hw_sign/hap-sign-tool.jar'}`, // 签名工具hap-sign-tool.jar的路径
//   username: `${process.env.ONLINE_USERNAME}`,
//   password: `${process.env.ONLINE_PASSWD}`,
//   enableOnlineSign: true
// };
//
// export default {
//   system: appTasks,
//   plugins: [
//     onlineSignPlugin(signOptions)
//   ]
// };
//
// const config = {
//   hvigor: hvigor,
//   hvigorNode: getHvigorNode(__filename),
//   templateEngName: 'HwSimToolkits_test', // CDE任务模板中维护的模板英文名称
//   modulesConfig: [
//     {
//       moduleName: 'entry',
//       appName: 'HwSimToolkits'
//     }
//   ]
// };
// uploadTestCases(config);
module.exports = require('@ohos/hvigor-ohos-plugin').appTasks