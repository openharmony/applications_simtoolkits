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
import { MenuSelectionEnvelopeData } from '../../../../../../main/ets/model/responseData/envelopeData/MenuSelectionEnvelopeData';

export default function MenuSelectionEnvelopeDataTest() {
  describe('MenuSelectionEnvelopeDataTest', () => {
    it('MenuSelectionEnvelopeDataTest_param_false_help', 0, () => {
      let data = new MenuSelectionEnvelopeData(0, 1, false);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('D30782020181900101').assertEqual(hexStr);
    })
    it('MenuSelectionEnvelopeDataTest_param_true_help', 0, () => {
      let data = new MenuSelectionEnvelopeData(0, 1, true);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('D309820201819001011500').assertEqual(hexStr);
    })
    it('MenuSelectionEnvelopeDataTest_undefined_help', 0, () => {
      let data = new MenuSelectionEnvelopeData(0, 1, undefined);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('MenuSelectionEnvelopeDataTest_undefined_menuId', 0, () => {
      let data = new MenuSelectionEnvelopeData(0, undefined, true);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
    it('MenuSelectionEnvelopeDataTest_undefined_slotId', 0, () => {
      let data = new MenuSelectionEnvelopeData(undefined, 1, true);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
  })
}