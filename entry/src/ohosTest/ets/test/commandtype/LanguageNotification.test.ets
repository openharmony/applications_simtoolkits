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
import HiLog from '../../../../main/ets/common/utils/HiLog';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { DELAY_TIME_3000 } from '../constants/TestConstants';
import { LanguageNotificationConstants } from '../constants/CommandTypetConstants';


const TAG = 'ohosTest_LanguageNotification';
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

export default function LanguageNotification(): void {
  describe('LanguageNotification', () => {
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

    // LanguageNotification LANGUAGE_NOTIFICATION_1_1_1
    // 27.22.4.25 LANGUAGE NOTIFICATION
    // Expected Sequence 1.1 (LANGUAGE NOTIFICATION)
    it('LanguageNotification_1_1_1', 0, async (done: Function) => {
      HiLog.info(TAG, 'LanguageNotification_1_1_1 start');
      await sendCommandHex(LanguageNotificationConstants.LANGUAGE_NOTIFICATION_1_1_1, 0);
      expect(LanguageNotificationConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      expect(i18n.System.getSystemLanguage().startsWith('en')).assertTrue();
      await driver.delayMs(DELAY_TIME);
      HiLog.info(TAG, 'LanguageNotification_1_1_1 end');
      done();
    })

    // LanguageNotification LANGUAGE_NOTIFICATION_1_2_1
    // 27.22.4.25 LANGUAGE NOTIFICATION
    // Expected Sequence 1.2 (LANGUAGE NOTIFICATION)
    it('LanguageNotification_1_2_1', 0, async (done: Function) => {
      HiLog.info(TAG, 'LanguageNotification_1_2_1 start');
      await sendCommandHex(LanguageNotificationConstants.LANGUAGE_NOTIFICATION_1_1_1, 0);
      expect(LanguageNotificationConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      expect(i18n.System.getSystemLanguage().startsWith('en')).assertTrue();

      // initial language
      await sendCommandHex(LanguageNotificationConstants.LANGUAGE_NOTIFICATION_1_2_1, 0);
      let isInit = '810301350002028281830100' === OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info(TAG, `LanguageNotification_1_2_1 isInit:${isInit}`);
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      HiLog.info(TAG, `LanguageNotification_1_2_1 init:${i18n.System.getSystemLanguage().startsWith('zh')}`);
      done();
    })
  })
}