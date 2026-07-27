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
import { Driver, MatchPattern, ON } from '@ohos.UiTest';
import notificationManager from '@ohos.notificationManager';
import OhosTestUtils from '../OhosTestUtils';
import { sendCommandHex, setMock, sleep } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { SetUpIdleConstants } from '../constants/CommandTypetConstants';


const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SetUpIdleModeText(): void {
  describe('SetUpIdleModeText', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_1_1_1
    // 27.22.4.22.1 SET UP IDLE MODE TEXT (normal)
    // Expected Sequence 1.1 (SET UP IDLE MODE TEXT, display idle mode text)
    it('SetUpIdleModeText_1_1_1', 0, async (done: Function) => {
      await notificationManager.cancelAll();
      await driver.delayMs(DELAY_TIME);
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_1_1_1, 0);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(SetUpIdleConstants.CLEAR_NOTIFICATION, 0);
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_1_2_1
    // 27.22.4.22.1 SET UP IDLE MODE TEXT (normal)
    // Expected Sequence 1.2 (SET UP IDLE MODE TEXT, replace idle mode text)
    it('SetUpIdleModeText_1_2_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_1_1_1, 0);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      // refresh notification text
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_1_2_1, 0);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      // clear notification
      await sendCommandHex(SetUpIdleConstants.CLEAR_NOTIFICATION, 0);
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_1_3_1
    // 27.22.4.22.1 SET UP IDLE MODE TEXT (normal)
    // Expected Sequence 1.3 (SET UP IDLE MODE TEXT, remove idle mode text)
    it('SetUpIdleModeText_1_3_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_1_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      // clear notification
      await sendCommandHex(SetUpIdleConstants.CLEAR_NOTIFICATION, 0);
      await driver.delayMs(DELAY_TIME);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_1_4_1
    // 27.22.4.22.1 SET UP IDLE MODE TEXT (normal)
    // Expected Sequence 1.4 (SET UP IDLE MODE TEXT, competing information on Terminal display)
    it('SetUpIdleModeText_1_4_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_1_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_1_7_1
    // 27.22.4.22.1 SET UP IDLE MODE TEXT (normal)
    // Expected Sequence 1.7 (SET UP IDLE MODE TEXT, large text string)
    it('SetUpIdleModeText_1_7_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_1_7_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_2_1_1
    // 27.22.4.22.2 SET UP IDLE MODE TEXT (Icon support)
    // Expected Sequence 2.1A (SET UP IDLE MODE TEXT, Icon is self-explanatory, successful)
    // Expected Sequence 2.1B (SET UP IDLE MODE TEXT, Icon is self-explanatory, requested icon could not be
    // displayed)
    it('SetUpIdleModeText_2_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_2_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_NOT_ICON_OK)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_2_2_1
    // 27.22.4.22.2 SET UP IDLE MODE TEXT (Icon support)
    // Expected Sequence 2.2A (SET UP IDLE MODE TEXT, Icon is not self-explanatory, successful)
    // Expected Sequence 2.2B (SET UP IDLE MODE TEXT, Icon is not self-explanatory, requested icon could not be
    // displayed)
    it('SetUpIdleModeText_2_2_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_2_2_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_NOT_ICON_OK)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_2_3_1
    // 27.22.4.22.2 SET UP IDLE MODE TEXT (Icon support)
    // Expected Sequence 2.3A (SET UP IDLE MODE TEXT, Icon is self-explanatory, colour icon, successful)
    // Expected Sequence 2.3B (SET UP IDLE MODE TEXT, Icon is self-explanatory, colour icon, requested icon
    // could not be displayed)
    it('SetUpIdleModeText_2_3_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_2_3_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_NOT_ICON_OK)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_2_4_1
    // 27.22.4.22.2 SET UP IDLE MODE TEXT (Icon support)
    // Expected Sequence 2.4 (SET UP IDLE MODE TEXT, Icon is not self-explanatory, empty text string)
    it('SetUpIdleModeText_2_4_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_2_4_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect('810301280002028281830132').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_3_1_1
    // 27.22.4.22.3 SET UP IDLE MODE TEXT (UCS2 display in Cyrillic)
    // Expected Sequence 3.1 (SET UP IDLE MODE TEXT, UCS2 alphabet text in Cyrillic)
    it('SetUpIdleModeText_3_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_3_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_5_1_1
    // 27.22.4.22.5 SET UP IDLE MODE TEXT (UCS2 display in Chinese)
    // Expected Sequence 5.1 (SET UP IDLE MODE TEXT, UCS2 alphabet text in Chinese)
    it('SetUpIdleModeText_5_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_5_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })

    // SetUpIdleModeText SET_UP_IDLE_MODE_TEXT_6_1_1
    // 27.22.4.22.6 SET UP IDLE MODE TEXT (UCS2 display in Katakana)
    // Expected Sequence 6.1 (SET UP IDLE MODE TEXT, UCS2 alphabet text in Katakana)
    it('SetUpIdleModeText_6_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpIdleConstants.SET_UP_IDLE_MODE_TEXT_6_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpIdleConstants.RESPONSE_OK).assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await notificationManager.cancelAll();
      done();
    })
  })
}

