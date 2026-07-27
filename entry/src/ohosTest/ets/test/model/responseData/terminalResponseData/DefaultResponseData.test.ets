/*
 * Copyright (c) 2026 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { EncodeDecodeUtils } from '../../../../../../main/ets/common/utils/EncodeDecodeUtils';
import {
  DefaultResponseData
} from '../../../../../../main/ets/model/responseData/terminalResponseData/DefaultResponseData';
import { BaseUpParams } from '../../../../../../main/ets/model/upDecode/BaseUpParams';
import * as simToolKitConstant from '../../../../../../main/ets/common/constant/SimToolKitConstant';

export default function DefaultResponseDataTest() {
  let param: BaseUpParams;
  describe('DefaultResponseDataTest', () => {
    beforeAll(() => {
      let paramJson: string = '{"slotId":0,"commandHex":"D0288103012304820281828D19088BF78F93516565E776845FEB6377786E8BA453E34EE4FF1A91020608","commandNumber":1,"commandType":35,"commandQual":4,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"text":"请输入旧的快捷确认口令：","duration":0,"isDigitOnly":true,"isUcs2":false,"isYesNo":false,"isHelpAvailable":false,"isEcho":false,"isPacked":false,"responseMinLength":6,"responseMaxLength":8,"defaultText":"","inputEncodeType":4}';
      param = JSON.parse(paramJson) as BaseUpParams;
    })
    it('DefaultResponseDataTest_param_undefined', 0, () => {
      let data = new DefaultResponseData(undefined, 0);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('DefaultResponseDataTest_param', 0, () => {
      let data = new DefaultResponseData(param, simToolKitConstant.ResponseCode.BACKWARD_MOVE_BY_USER);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('810301230402028281830111').assertEqual(hexStr);
    })
    it('DefaultResponseDataTest_param_addInfo', 0, () => {
      let data = new DefaultResponseData(param, simToolKitConstant.ResponseCode.BACKWARD_MOVE_BY_USER);
      data.setAdditionalInfo(0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('81030123040202828183021100').assertEqual(hexStr);
    })
    it('DefaultResponseDataTest_param_not_code', 0, () => {
      let data = new DefaultResponseData(param);
      data.setAdditionalInfo(0);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('DefaultResponseDataTest_param_flag', 0, () => {
      param.hasCompRequiredFlag = false;
      let data = new DefaultResponseData(param, simToolKitConstant.ResponseCode.BACKWARD_MOVE_BY_USER);
      data.setAdditionalInfo(0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('01030123040202828103021100').assertEqual(hexStr);
    })
  })
}