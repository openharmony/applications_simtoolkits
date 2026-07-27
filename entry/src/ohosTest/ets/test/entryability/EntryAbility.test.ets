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
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { setMock, sleep, startAbilityMine } from '../TestUtils';
import HiLog from '../../../../main/ets/common/utils/HiLog';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import OhosTestUtils from '../OhosTestUtils';
import { PageUrl } from '../../../../main/ets/common/constant/Constants';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { SLOT_ID } from '../constants/TestConstants';
import { ContextStorageHelper } from '../../../../main/ets/common/utils/ContextStorageHelper';

const TAG = 'EntryAbilityTest';
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function EntryAbilityTest(): void {
  describe('EntryAbilityTest', () => {
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
    it('EntryAbilityTest_SET_UP_MENU', 0, async (done: Function) => {
      HiLog.info(TAG, 'EntryAbilityTest_SET_UP_MENU start');
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
      let uiContext = ContextStorageHelper.getInstance().getEntryUiContext();
      expect(CommonUtils.isEmptyObj(uiContext)).assertTrue();
      done();
    })
  })
}