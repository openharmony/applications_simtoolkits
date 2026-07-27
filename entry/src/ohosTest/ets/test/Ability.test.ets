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

import { afterAll, beforeAll, describe, expect, it } from '@ohos/hypium';
import HiLog from '../../../main/ets/common/utils/HiLog';
import { Driver, ON } from '@ohos.UiTest';
import CommonUtils from '../../../main/ets/common/utils/CommonUtils';
import { ContextStorageHelper } from '../../../main/ets/common/utils/ContextStorageHelper';
import { setMock, sleep, startAbilityMine } from './TestUtils';
import OhosTestUtils from './OhosTestUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from './constants/TestConstants';
import { DELAY_TIME } from './constants/TestConstants';
import { SLOT_ID } from './constants/TestConstants';
import { PageUrl } from '../../../main/ets/common/constant/Constants';

const TAG = 'AbilityTest';
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function AbilityTest() {
  describe('AbilityTest', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      OhosTestUtils.getInstance().setMockReturnSimStateLoaded(false);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
      OhosTestUtils.getInstance().setMockReturnSimStateLoaded(true);
    })
    it('AbilityTest_SET_UP_MENU', 0, async (done: Function) => {
      HiLog.info(TAG, 'AbilityTest_SET_UP_MENU start');
      let driver = Driver.create();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);

      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
      // expect show main menu
      let uiContext = ContextStorageHelper.getInstance().getEntryUiContext();
      let hasUiContext = CommonUtils.isEmptyObj(uiContext);
      HiLog.info(TAG, `AbilityTest_SET_UP_MENU hasUiContext:${hasUiContext}`);
      expect(hasUiContext).assertTrue();
      await sleep(DELAY_TIME_1000)
      done();
    })
  })
}