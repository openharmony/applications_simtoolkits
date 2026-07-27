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
import { SettingsDataHelper } from '../../../../../main/ets/common/helper/SettingsDataHelper';
import { SetUpMenuParam } from '../../../../../main/ets/model/upDecode/SetUpMenuParam';
import TestAbility from '../../../testability/TestAbility';

const setupMenuParam: SetUpMenuParam =
  JSON.parse('{"slotId":3,"commandHex":"D0388103012500820281828509804E2D56FD79FB52A88F10018000530049004D5FEB6377786E8BA48F100280005500530049004D53614FE1606F","commandNumber":1,"commandType":37,"commandQual":0,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"menuTitle":"中国移动","presentationType":0,"isSoftKeyPreferred":false,"isHelpAvailable":false,"isShowEndSession":false,"itemArray":[{"itemId":1,"itemText":"SIM快捷确认"},{"itemId":2,"itemText":"USIM卡信息"}]}');

export default function SettingsDataHelperTest() {
  describe('SettingsDataHelperTest', () => {
    it('SettingsDataHelperTest_clear', 0, async () => {
      await SettingsDataHelper.getInstance().deleteSetUpParam(TestAbility.uiContext, 3);
      let paramResult = await SettingsDataHelper.getInstance().querySetUpParam(TestAbility.uiContext, 3);
      expect(paramResult === undefined).assertTrue();
    })
    it('SettingsDataHelperTest_insertSetUpParam', 0, async () => {
      let value = await SettingsDataHelper.getInstance().insertSetUpParam(TestAbility.uiContext, setupMenuParam);
      expect(value).assertTrue();
      let paramResult = await SettingsDataHelper.getInstance().querySetUpParam(TestAbility.uiContext, 3);
      expect(JSON.stringify(setupMenuParam)).assertEqual(JSON.stringify(paramResult));
    })
    it('SettingsDataHelperTest_deleteSetUpParam', 0, async () => {
      await SettingsDataHelper.getInstance().deleteSetUpParam(TestAbility.uiContext, 3);
      let paramResult = await SettingsDataHelper.getInstance().querySetUpParam(TestAbility.uiContext, 3);
      expect(paramResult === undefined).assertTrue();
    })
  })
}