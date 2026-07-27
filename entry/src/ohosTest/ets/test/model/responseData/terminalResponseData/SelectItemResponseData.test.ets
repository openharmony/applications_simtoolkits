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
import { SelectItemResponseData } from '../../../../../../main/ets/model/responseData/terminalResponseData/SelectItemResponseData';
import { SelectItemParam } from '../../../../../../main/ets/model/upDecode/SelectItemParam';

const paramJson = '{"slotId":0,"commandHex":"D04B8103012400820281828F1C01804EC55728670D52A189816C4265F64F7F752853E34EE44FDD62A48F0A028053E34EE44FEE65398F0A03804E1A52A14ECB7ECD8F0A0480724867434FE1606F","commandNumber":1,"commandType":36,"commandQual":0,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"menuTitle":"","presentationType":0,"isSoftKeyPreferred":false,"isHelpAvailable":false,"isShowEndSession":true,"defaultItemId":0,"itemArray":[{"itemId":1,"itemText":"仅在服务要求时使用口令保护"},{"itemId":2,"itemText":"口令修改"},{"itemId":3,"itemText":"业务介绍"},{"itemId":4,"itemText":"版权信息"}]}';
const selectItemParam: SelectItemParam = JSON.parse(paramJson) as SelectItemParam;

export default function SelectItemResponseDataTest() {
  describe('SelectItemResponseDataTest', () => {
    it('SelectItemResponseDataTest_parseDataToHex', 0, () => {
      let data = new SelectItemResponseData(selectItemParam, 1, 0);
      let hexStr = EncodeDecodeUtils.getInstance().numberArrToHexString(data.parseDataToHex());
      expect('810301240002028281830100900101').assertEqual(hexStr);
    })
    it('SelectItemResponseDataTest_parseDataToHex_undefined', 0, () => {
      let data = new SelectItemResponseData(selectItemParam, undefined, 0);
      let numberArr = data.parseDataToHex();
      expect(numberArr.length).assertEqual(0);
    })
  })
}