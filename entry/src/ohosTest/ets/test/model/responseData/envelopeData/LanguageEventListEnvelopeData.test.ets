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
import { LanguageEventListEnvelopeData } from '../../../../../../main/ets/model/responseData/envelopeData/LanguageEventListEnvelopeData';
import { EventIdType, DeviceId } from '../../../../../../main/ets/common/constant/SimToolKitConstant';
import { EncodeDecodeUtils } from '../../../../../../main/ets/common/utils/EncodeDecodeUtils';

export default function LanguageEventListEnvelopeDataTest() {
  describe('LanguageEventListEnvelopeDataTest', () => {
    it('LanguageEventListEnvelopeDataTest_param', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesSource = DeviceId.DEV_ID_TERMINAL;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      data.language = 'zh';
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('D60B99010782028281AD027A68').assertEqual(hexStr);
    })
    it('LanguageEventListEnvelopeDataTest_not_slotId', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      data.language = 'zh';
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageEventListEnvelopeDataTest_not_eventId', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      data.language = 'zh';
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageEventListEnvelopeDataTest_not_source', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      data.language = 'zh';
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageEventListEnvelopeDataTest_not_dest', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
      data.language = 'zh';
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageEventListEnvelopeDataTest_not_lan', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageEventListEnvelopeDataTest_lan_undefined', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      data.language = '';
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('LanguageEventListEnvelopeDataTest_lan_error', 0, () => {
      let data = new LanguageEventListEnvelopeData();
      data.slotId = 0;
      data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
      data.devicesDest = DeviceId.DEV_ID_UICC;
      data.language = '中国';
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
  })
}