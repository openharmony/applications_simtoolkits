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
import { Driver, ON } from '@ohos.UiTest';
import { sendCommandHex, sendEndSession, setMock, sleep, startLaunchBrowser } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import OhosTestUtils from '../OhosTestUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { CONFIRM_DIALOG_CONFIRM_TEXT } from '../constants/TestConstants';
import { CONFIRM_DIALOG_CANCEL_TEXT } from '../constants/TestConstants';
import { DisplayTextConstants } from '../constants/CommandTypetConstants';

const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function DisplayText(): void {
  describe('DisplayText', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_1_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.1 (DISPLAY TEXT normal priority, Unpacked 8 bit data for Text String, successful)
    it('DisplayText_DISPLAY_TEXT_1_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_1_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 1'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_2_1 same sa DISPLAY_TEXT_1_1_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.2 (DISPLAY TEXT normal priority, Unpacked 8 bit data for Text String, screen busy)
    it('DisplayText_DISPLAY_TEXT_1_2_1', 0, async (done: Function) => {
      await startLaunchBrowser();
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_1_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 1'), 5000);
      expect(CommonUtils.isEmptyObj(dialogText)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      expect('81030121800202828183022001').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_3_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.3 (DISPLAY TEXT, high priority, Unpacked 8 bit data for Text String, successful)
    it('DisplayText_DISPLAY_TEXT_1_3_1', 0, async (done: Function) => {
      await startLaunchBrowser();
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_3_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 2'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218102028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_4_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.4 (DISPLAY TEXT, Packed, SMS default alphabet, successful)
    it('DisplayText_DISPLAY_TEXT_1_4_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_4_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 3'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_5_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.5 (DISPLAY TEXT, Clear message after delay, successful)
    it('DisplayText_DISPLAY_TEXT_1_5_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_5_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 4'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      await driver.delayMs(11000);
      expect('810301210002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_6_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.6 (DISPLAY TEXT, Text string with 160 bytes, successful)
    it('DisplayText_DISPLAY_TEXT_1_6_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_6_1, 0);
      let textStr =
        'This command instructs the ME to display a text message. It allows the SIM to define the priority' +
          ' of that message, and the text string format. Two types of prio';
      let dialogText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_7_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.7 (DISPLAY TEXT, Backward move in Proactive UICC session, successful)
    it('DisplayText_DISPLAY_TEXT_1_7_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_7_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('<GO-BACKWARDS>'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830111').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_8_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.8 (DISPLAY TEXT, session terminated by user)
    it('DisplayText_DISPLAY_TEXT_1_8_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_8_1, 0);
      let dialogText = await driver.waitForComponent(ON.text('<ABORT>'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830110').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_1_9_1
    // 27.22.4.1.1 DISPLAY TEXT (Normal)
    // Expected Sequence 1.9 (DISPLAY TEXT, icon and text to be displayed, no text string given, not understood by
    // Terminal)
    it('DisplayText_DISPLAY_TEXT_1_9_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_1_9_1, 0);
      await driver.delayMs(2000);
      expect('810301218002028281830132').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })


    // DISPLAY TEXT DISPLAY_TEXT_2_1_1
    // 27.22.4.1.2 DISPLAY TEXT (Support of "No response from user")
    // Expected Sequence 2.1 (DISPLAY TEXT, no response from user)
    it('DisplayText_DISPLAY_TEXT_2_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_2_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('<TIME-OUT>'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();
      await driver.delayMs(6000);
      expect('810301218002028281830112').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressBack();
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_3_1_1
    // 27.22.4.1.3 DISPLAY TEXT (Display of extension text)
    // Expected Sequence 3.1 (DISPLAY TEXT, display of the extension text)
    it('DisplayText_DISPLAY_TEXT_3_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_3_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = 'This command instructs the ME to display a text message, and/or an icon (see 6.5.4). ' +
        'It allows the SIM to define the priority of that message, and the text string format. Two types of ' +
        'priority are defined:- display normal priority text and/';
      let dialogText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_4_1_1
    // 27.22.4.1.4 DISPLAY TEXT (Sustained text)
    // Expected Sequence 4.1 (DISPLAY TEXT, sustained text, unpacked data 8 bits, successful)
    it('DisplayText_DISPLAY_TEXT_4_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_4_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 1'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      dialogText = await driver.findComponent(ON.text('Toolkit Test 1'));
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();
      expect('Toolkit Test 1').assertEqual(await dialogText.getText());

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_4_2_1
    // 27.22.4.1.4 DISPLAY TEXT (Sustained text)
    // Expected Sequence 4.2 (DISPLAY TEXT, sustained text, clear message after delay, successful)
    it('DisplayText_DISPLAY_TEXT_4_2_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_4_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 2'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      expect('810301210002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      dialogText = await driver.findComponent(ON.text('Toolkit Test 2'));
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      await driver.delayMs(6000);
      dialogText = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(CommonUtils.isEmptyObj(dialogText)).assertTrue();
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_4_3_1
    // 27.22.4.1.4 DISPLAY TEXT (Sustained text)
    // Expected Sequence 4.3 (DISPLAY TEXT, sustained text, wait for user MMI to clear, successful)
    it('DisplayText_DISPLAY_TEXT_4_3_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_4_3_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('Toolkit Test 3'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      dialogText = await driver.findComponent(ON.text('Toolkit Test 3'));
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_5_1_1
    // 27.22.4.1.5 DISPLAY TEXT (Display of icons)
    // 5.1A (DISPLAY TEXT, display of basic icon, self-explanatory, successful)
    // 5.1B (DISPLAY TEXT, display of basic icon, self-explanatory, requested icon could not be displayed)
    it('DisplayText_DISPLAY_TEXT_5_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_5_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('Basic Icon'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830104').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_5_2_1
    // 27.22.4.1.5 DISPLAY TEXT (Display of icons)
    // 5.2A (DISPLAY TEXT, display of colour icon, successful)
    // 5.2B (DISPLAY TEXT, display of colour icon, requested icon could not be displayed)
    it('DisplayText_DISPLAY_TEXT_5_2_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_5_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('Colour Icon'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830104').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_5_3_1
    // 27.22.4.1.5 DISPLAY TEXT (Display of icons)
    // 5.3A (DISPLAY TEXT, display of basic icon, not self explanatory, successful)
    // 5.3B (DISPLAY TEXT, display of basic icon, not self explanatory, requested icon could not be displayed)
    it('DisplayText_DISPLAY_TEXT_5_3_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_5_3_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('Basic Icon'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830104').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_6_1_1
    // 27.22.4.1.6 DISPLAY TEXT (UCS2 display supported in Cyrillic)
    // Expected Sequence 6.1 (DISPLAY TEXT, UCS2 coded in Cyrillic)
    it('DisplayText_DISPLAY_TEXT_6_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_6_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('ЗДРАВСТВУЙТЕ'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_7_1_1
    // 27.22.4.1.7 DISPLAY TEXT (Variable Time out)
    // Expected Sequence 7.1 (DISPLAY TEXT, variable timeout of 10 seconds)
    it('DisplayText_DISPLAY_TEXT_7_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_7_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('10 Second'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      // 10s after
      await driver.delayMs(11000);

      dialogText = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(CommonUtils.isEmptyObj(dialogText)).assertTrue();
      expect('810301218002028281830112').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_9_1_1
    // 27.22.4.1.9 DISPLAY TEXT (UCS2 display in Chinese)
    // Expected Sequence 9.1 (DISPLAY TEXT, UCS2 coded in Chinese)
    it('DisplayText_DISPLAY_TEXT_9_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_9_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('你好'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // DISPLAY TEXT DISPLAY_TEXT_10_1_1
    // 27.22.4.1.10 DISPLAY TEXT (UCS2 display in Katakana)
    // Expected Sequence 10.1 (DISPLAY TEXT, UCS2 coded in Katakana)
    it('DisplayText_DISPLAY_TEXT_10_1_1', 0, async (done: Function) => {
      await sendCommandHex(DisplayTextConstants.DISPLAY_TEXT_10_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let dialogText = await driver.waitForComponent(ON.text('80ル'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();
      expect('80ル').assertEqual(await dialogText.getText());

      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218002028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}
