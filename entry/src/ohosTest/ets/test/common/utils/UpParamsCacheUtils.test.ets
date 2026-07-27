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

import { describe, it, expect, beforeAll, afterAll } from '@ohos/hypium';
import { SettingsDataHelper } from '../../../../../main/ets/common/helper/SettingsDataHelper';
import { UpParamsCacheUtils } from '../../../../../main/ets/common/utils/UpParamsCacheUtils';
import { SetUpMenuParam } from '../../../../../main/ets/model/upDecode/SetUpMenuParam';
import TestAbility from '../../../testability/TestAbility';
import { DELAY_TIME_1000 } from '../../constants/TestConstants';
import { sleep } from '../../TestUtils';

const MENU_TITLE = '中国移动';
const setupMenuParam: SetUpMenuParam = JSON.parse('{"slotId":3,"commandHex":"D0388103012500820281828509804E2D56FD79FB52A88F10018000530049004D5FEB6377786E8BA48F100280005500530049004D53614FE1606F","commandNumber":1,"commandType":37,"commandQual":0,"hasCompRequiredFlag":true,"devicesSource":129,"devicesDest":130,"isParseSuccess":true,"isParseCmdDetailSuccess":true,"isSupport":true,"menuTitle":"中国移动","presentationType":0,"isSoftKeyPreferred":false,"isHelpAvailable":false,"isShowEndSession":false,"itemArray":[{"itemId":1,"itemText":"SIM快捷确认"},{"itemId":2,"itemText":"USIM卡信息"}]}');
const TEST_SLOT_ID = 3;

export default function UpParamsCacheUtilsTest() {
  describe('UpParamsCacheUtilsTest', () => {
    beforeAll(async (done: Function) => {
      UpParamsCacheUtils.getInstance().deleteMainMenuParams(TestAbility.uiContext, TEST_SLOT_ID);
      UpParamsCacheUtils.getInstance().deleteCurrentUpParams(TestAbility.uiContext, TEST_SLOT_ID);
      await sleep(DELAY_TIME_1000);
      done();
    })
    afterAll(() => {
      UpParamsCacheUtils.getInstance().deleteMainMenuParams(TestAbility.uiContext, TEST_SLOT_ID);
      UpParamsCacheUtils.getInstance().deleteCurrentUpParams(TestAbility.uiContext, TEST_SLOT_ID);
    })
    it('UpParamsCacheUtils_MainMenu_undefined', 0, async (done: Function) => {
      let mainMenu = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(TEST_SLOT_ID);
      expect(mainMenu).assertUndefined();
      mainMenu = await UpParamsCacheUtils.getInstance()
        .getMainMenuParams(TestAbility.uiContext, TEST_SLOT_ID);
      expect(mainMenu).assertUndefined();
      done();
    })
    it('UpParamsCacheUtils_MainMenu_param', 0, async (done: Function) => {
      let result = await SettingsDataHelper.getInstance().insertSetUpParam(TestAbility.uiContext, setupMenuParam);
      expect(true).assertEqual(result);
      let mainMenu = await UpParamsCacheUtils.getInstance()
        .getMainMenuParams(TestAbility.uiContext, TEST_SLOT_ID);
      expect(JSON.stringify(mainMenu)).assertEqual(JSON.stringify(setupMenuParam));
      mainMenu = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(TEST_SLOT_ID);
      expect(JSON.stringify(mainMenu)).assertEqual(JSON.stringify(setupMenuParam));
      done();
    })
    it('UpParamsCacheUtils_MainMenu_menuTitle', 0, async (done: Function) => {
      let result = await SettingsDataHelper.getInstance().insertSetUpParam(TestAbility.uiContext, setupMenuParam);
      expect(true).assertEqual(result);
      let menuTitle = UpParamsCacheUtils.getInstance().getSimTitle(TEST_SLOT_ID);
      expect(menuTitle).assertEqual(MENU_TITLE);
      done();
    })
    it('UpParamsCacheUtils_MainMenu_delete', 0, async (done: Function) => {
      UpParamsCacheUtils.getInstance().deleteMainMenuParams(TestAbility.uiContext, TEST_SLOT_ID);
      UpParamsCacheUtils.getInstance().deleteCurrentUpParams(TestAbility.uiContext, TEST_SLOT_ID);
      expect(TestAbility.uiContext != undefined).assertTrue();
      setTimeout(() => {
        done();
      }, 1000);
    })
  })
}