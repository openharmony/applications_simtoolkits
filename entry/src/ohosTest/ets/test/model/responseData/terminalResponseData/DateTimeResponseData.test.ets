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

import { describe, it, expect } from '@ohos/hypium';
import { EncodeDecodeUtils } from '../../../../../../main/ets/common/utils/EncodeDecodeUtils';
import { DateTimeResponseData } from '../../../../../../main/ets/model/responseData/terminalResponseData/DateTimeResponseData'
import { BaseUpParams } from '../../../../../../main/ets/model/upDecode/BaseUpParams';

export default function DateTimeResponseDataTest() {
  describe('DateTimeResponseDataTest', () => {
    it('DateTimeResponseDataTest_parseDataToHex', 0, () => {
      let paramJson: string = '{"slotId":0,"commandHex":"D009810301260382028182","commandNumber":1,"commandType":38,"commandQual":3,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"infoMode":3}';
      let param = JSON.parse(paramJson) as BaseUpParams;
      let data = new DateTimeResponseData(param);
      data.resultCode = 0;
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      let result = hexStr.startsWith('810301260302028281830100A607');
      expect(result).assertTrue();
    })

    it('DateTimeResponseDataTest_parseDataToHex_undefined', 0, () => {
      let data = new DateTimeResponseData(undefined);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
  })
}