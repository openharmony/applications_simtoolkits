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
import i18n from '@ohos.i18n';
import { EncodeDecodeUtils } from '../../../../../../main/ets/common/utils/EncodeDecodeUtils';
import {
  LanguageResponseData
} from '../../../../../../main/ets/model/responseData/terminalResponseData/LanguageResponseData';
import { LanguageNotificationParam } from '../../../../../../main/ets/model/upDecode/LanguageNotificationParam';
import HiLog from '../../../../../../main/ets/common/utils/HiLog';

const languageNotificationParamJson = '{"slotId":0,"commandHex":"D009810301260482028182","commandNumber":1,"commandType":38,"commandQual":4,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"infoMode":4}';
const languageNotificationParam: LanguageNotificationParam = JSON.parse(languageNotificationParamJson) as LanguageNotificationParam;

export default function LanguageResponseDataTest() {
  describe('LanguageResponseDataTest', () => {
    it('LanguageResponseDataTest_parseDataToHex', 0, () => {
      let data = new LanguageResponseData(languageNotificationParam);
      data.resultCode = 0;
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect(hexStr.startsWith('810301260402028281830100')).assertTrue();
    })
    it('LanguageResponseDataTest_parseDataToHex_not_code', 0, () => {
      let data = new LanguageResponseData(languageNotificationParam);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageResponseDataTest_parseDataToHex_undefined', 0, () => {
      let data = new LanguageResponseData(undefined);
      data.resultCode = 0;
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
  })
}