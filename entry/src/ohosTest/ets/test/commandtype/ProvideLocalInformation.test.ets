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

import { describe, it, expect, beforeEach, afterAll, beforeAll } from '@ohos/hypium';
import { Driver } from '@ohos.UiTest';
import i18n from '@ohos.i18n';
import OhosTestUtils from '../OhosTestUtils';
import { sendCommandHex, setMock, sleep } from '../TestUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000, DELAY_TIME_3000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';

const PROVIDE_LOCAL_INFORMATION_1_4_1 = 'D009810301260382028182';
const PROVIDE_LOCAL_INFORMATION_1_5_1 = 'D009810301260482028182';

const RESPONSE_1_4_1_PRE = '810301260302028281830100A6';
const RESPONSE_1_5_1 = '810301260402028281830100AD027A68';
const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

function setSystemLanguageZh(): void {
  if (!i18n.System.getSystemLanguage().startsWith('zh-Hans')) {
    try {
      i18n.System.setSystemLanguage('zh-Hans');
    } catch (error) {
    }
  }
}

export default function ProvideLocalInformation(): void {
  describe('ProvideLocalInformation', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      setSystemLanguageZh();
      await driver.delayMs(DELAY_TIME_3000);
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    afterAll(async (done: Function) => {
      setSystemLanguageZh();
      await driver.delayMs(DELAY_TIME_3000);
      abilityDelegator.setMockList({});
      done();
    })

    // ProvideLocalInformation PROVIDE_LOCAL_INFORMATION_1_4_1
    // 27.22.4.15 PROVIDE LOCAL INFORMATION
    // Expected Sequence 1.4 (PROVIDE LOCAL INFORMATION, Date, Time, Time Zone)
    it('ProvideLocalInformation_1_4_1', 0, async (done: Function) => {
      await sendCommandHex(PROVIDE_LOCAL_INFORMATION_1_4_1, 0);
      await driver.delayMs(DELAY_TIME);
      let isSuccess = OhosTestUtils.getInstance().getLastTerminalResponseData().startsWith(RESPONSE_1_4_1_PRE);
      expect(isSuccess).assertTrue();
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      done();
    })

    // ProvideLocalInformation PROVIDE_LOCAL_INFORMATION_1_5_1
    // 27.22.4.15 PROVIDE LOCAL INFORMATION
    // Expected Sequence 1.5 (PROVIDE LOCAL INFORMATION, Language setting)
    it('ProvideLocalInformation_1_5_1', 0, async (done: Function) => {
      await sendCommandHex(PROVIDE_LOCAL_INFORMATION_1_5_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(RESPONSE_1_5_1).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      done();
    })
  })
}

