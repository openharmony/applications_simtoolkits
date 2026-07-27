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
import OhosTestUtils from '../OhosTestUtils';
import { sendCommandHex, sendEndSession, setMock, sleep } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { ViewId } from '../../../../main/ets/common/constant/Constants';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { DELAY_TIME_3000 } from '../constants/TestConstants';
import { GetInputConstants } from '../constants/CommandTypetConstants';

const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function GetInputTest(): void {
  describe('GetInputTest', () => {
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

    // GetInput GET_INPUT_1_1_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.1 (GET INPUT, digits only, SMS default alphabet, Terminal to echo text, Terminal
    // supporting 8 bit data Message)
    it('GetInput_GET_INPUT_1_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_1_1, 0);
      let inputText = await driver.waitForComponent(ON.text('Enter 12345'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('1234567');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301008D06043132333435').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_2_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.2 (GET INPUT, digits only, SMS default alphabet, Terminal to echo text, packing SMS
    // Point-to-point required by Terminal)
    it('GetInput_GET_INPUT_1_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_2_1, 0);
      let inputText = await driver.waitForComponent(ON.text('Enter 67*#+'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('67*#+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012308020282818301008D0600B69B6AB402').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_3_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.3 (GET INPUT, character set, SMS Default Alphabet, Terminal to echo text, Terminal
    // supporting 8 bit data Message)
    it('GetInput_GET_INPUT_1_3_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_3_1, 0);
      let inputText = await driver.waitForComponent(ON.text('Enter AbCdE'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('AbCdE');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012301020282818301008D06044162436445').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_4_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.4 (GET INPUT, digits only, SMS default alphabet, Terminal to hide text, Terminal
    // supporting 8 bit data Message)
    it('GetInput_GET_INPUT_1_4_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_4_1, 0);
      let inputText = await driver.waitForComponent(ON.text('Password 1<SEND>2345678'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('2345678');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012304020282818301008D080432333435363738').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_5_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.5 (GET INPUT, digits only, SMS default alphabet, Terminal to echo text, Terminal
    // supporting 8 bit data Message)
    it('GetInput_GET_INPUT_1_5_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_5_1, 0);
      let inputText = await driver.waitForComponent(ON.text('Enter 1..9,0..9,0(1)'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('12345678901234567890');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301008D15043132333435363738393031323334353637383930').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_6_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.6 (GET INPUT, backwards move)
    it('GetInput_GET_INPUT_1_6_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_6_1, 0);
      let inputText = await driver.waitForComponent(ON.text('<GO-BACKWARDS>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      expect('810301230002028281830111').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_7_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.7 (GET INPUT, abort)
    it('GetInput_GET_INPUT_1_7_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_7_1, 0);
      let inputText = await driver.waitForComponent(ON.text('<ABORT>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      // end session
      let menuButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let endSessionButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`), 2000);
      expect(!CommonUtils.isEmptyObj(endSessionButton)).assertTrue();
      await endSessionButton.click();
      await driver.delayMs(DELAY_TIME);

      expect('810301230002028281830110').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_8_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.8 (GET INPUT, digits only, SMS default alphabet, Terminal to echo text, Terminal
    // supporting 8 bit data Message)
    it('GetInput_GET_INPUT_1_8_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_8_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = '***1111111111###***2222222222###***3333333333###***4444444444###***5555555555###***6666666666###' +
        '***7777777777###***8888888888###***9999999999###***0000000000###';
      let inputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText(textStr);

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);

      let responseHex = '8103012300020282818301008D81A1042A2A2A313131313131313131312323232A2A2A3232323232323232323223' +
        '23232A2A2A333333333333333333332323232A2A2A343434343434343434342323232A2A2A353535353535353535352323232A2A2A36' +
        '3636363636363636362323232A2A2A373737373737373737372323232A2A2A383838383838383838382323232A2A2A39393939393939' +
        '3939392323232A2A2A30303030303030303030232323';
      expect(responseHex).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_1_9_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.9 (GET INPUT, digits only, SMS default alphabet, Terminal to echo text, Terminal
    // supporting 8 bit data Message)
    it('GetInput_GET_INPUT_1_9_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_9_1, 0);
      await driver.delayMs(DELAY_TIME);

      let inputButton = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301008D0104').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })


    // GetInput GET_INPUT_1_10_1
    // 27.22.4.3.1 GET INPUT (normal)
    // Expected Sequence 1.10 (GET INPUT, null length for the text string, successful)
    it('GetInput_GET_INPUT_1_10_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_1_10_1, 0);
      await driver.delayMs(DELAY_TIME);

      let inputButton = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT), 2000);
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('12345');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301008D06043132333435').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_2_1_1
    // 27.22.4.3.2 GET INPUT (No response from User)
    // Expected Sequence 2.1 (GET INPUT, no response from the user)
    it('GetInput_GET_INPUT_2_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInputConstants.GET_INPUT_2_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('<TIME-OUT>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();
      await driver.delayMs(61000);
      expect('810301230002028281830112').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_3_1_1
    // 27.22.4.3.3 GET INPUT (UCS2 display in Cyrillic)
    // Expected Sequence 3.1 (GET INPUT, text string coding in UCS2 in Cyrillic, successful)
    it('GetInput_GET_INPUT_3_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_3_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('ЗДРАВСТВУЙТЕ'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('HELLO');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);

      expect('8103012301020282818301008D060448454C4C4F').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_3_2_1
    // 27.22.4.3.3 GET INPUT (UCS2 display in Cyrillic)
    // Expected Sequence 3.2 (GET INPUT, max length for the text string coding in UCS2 in Cyrillic, successful)
    it('GetInput_GET_INPUT_3_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_3_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = 'ЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙ';
      let inputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('HELLO');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);

      expect('8103012301020282818301008D060448454C4C4F').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_4_1_1
    // 27.22.4.3.4 GET INPUT (UCS2 entry in Cyrillic)
    // Expected Sequence 4.1 (GET INPUT, character set from UCS2 alphabet in Cyrillic, successful)
    it('GetInput_GET_INPUT_4_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_4_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = 'Enter Hello';
      let inputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('ЗДРАВСТВУЙТЕ');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);

      expect('8103012303020282818301008D1908041704140420041004120421042204120423041904220415').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_4_2_1
    // 27.22.4.3.4 GET INPUT (UCS2 entry in Cyrillic)
    // Expected Sequence 4.2 (GET INPUT, character set from UCS2 alphabet in Cyrillic, Max length for the input,
    // successful)
    it('GetInput_GET_INPUT_4_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_4_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = 'Enter Hello';
      let inputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      let inputStr = 'ЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙ';
      await inputButton.inputText(inputStr);

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);

      let responseHex = '8103012303020282818301008D818D0804170414042004100412042104220412042304190422041504170414042' +
        '00410041204210422041204230419042204150417041404200410041204210422041204230419042204150417041404200410041204' +
        '21042204120423041904220415041704140420041004120421042204120423041904220415041704140420041004120421042204120' +
        '4230419';
      expect(responseHex).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_5_1_1
    // 27.22.4.3.5 GET INPUT (default text)
    // Expected Sequence 5.1 (GET INPUT, default text for the input, successful)
    it('GetInput_GET_INPUT_5_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_5_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter 12345'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      expect('12345').assertEqual(await inputButton.getText());

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301008D06043132333435').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_5_2_1
    // 27.22.4.3.5 GET INPUT (default text)
    // Expected Sequence 5.2 (GET INPUT, default text for the input with max length, successful)
    it('GetInput_GET_INPUT_5_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_5_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter:'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      let inputStr = '***1111111111###***2222222222###***3333333333###***4444444444###***5555555555###***6666666666' +
        '###***7777777777###***8888888888###***9999999999###***0000000000###';
      expect(inputStr).assertEqual(await inputButton.getText());

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      let responseHex = '8103012300020282818301008D81A1042A2A2A313131313131313131312323232A2A2A323232323232323' +
        '232322323232A2A2A333333333333333333332323232A2A2A343434343434343434342323232A2A2A35353535353535353535' +
        '2323232A2A2A363636363636363636362323232A2A2A373737373737373737372323232A2A2A3838383838383838383823232' +
        '32A2A2A393939393939393939392323232A2A2A30303030303030303030232323';
      expect(responseHex).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_6_1_1
    // 27.22.4.3.6 GET INPUT (display of Icon)
    // Expected Sequence 6.1A (GET INPUT, Basic icon, self-explanatory, successful)
    // Expected Sequence 6.1B (GET INPUT, Basic icon, self-explanatory, requested icon could not be displayed)
    it('GetInput_GET_INPUT_6_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_6_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('<NO-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_6_2_1
    // 27.22.4.3.6 GET INPUT (display of Icon)
    // Expected Sequence 6.2A (GET INPUT, Basic icon, non self-explanatory, successful)
    // Expected Sequence 6.2B (GET INPUT, Basic icon, non self-explanatory, requested icon could not be displayed)
    it('GetInput_GET_INPUT_6_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_6_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('<BASIC-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_6_3_1
    // 27.22.4.3.6 GET INPUT (display of Icon)
    // Expected Sequence 6.3A (GET INPUT, Colour icon, self-explanatory, successful)
    // Expected Sequence 6.3B (GET INPUT, Colour icon, self-explanatory, requested icon could not be displayed)
    it('GetInput_GET_INPUT_6_3_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_6_3_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('<NO-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_6_4_1
    // 27.22.4.3.6 GET INPUT (display of Icon)
    // Expected Sequence 6.4A (GET INPUT, Colour icon, non self-explanatory, successful)
    // Expected Sequence 6.4B (GET INPUT, Colour icon, non self-explanatory, requested icon could not be displayed)
    it('GetInput_GET_INPUT_6_4_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_6_4_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('<COLOUR-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012300020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_7_1_1
    // 27.22.4.3.7 GET INPUT (Help Information)
    // Expected Sequence 7.1 (GET INPUT, digits only, Terminal to echo text, Terminal supporting 8 bit data Message,
    // help information available)
    it('GetInput_GET_INPUT_7_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_7_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter 12345'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let menuButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let helpButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}1`), 2000);
      await helpButton.click();

      await driver.delayMs(DELAY_TIME);
      expect('810301238002028281830113').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_9_1_1
    // 27.22.4.3.9 GET INPUT (UCS2 display in Chinese)
    // Expected Sequence 9.1 (GET INPUT, text string coding in UCS2 in Chinese, successful)
    it('GetInput_GET_INPUT_9_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_9_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('你好'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('HELLO');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012301020282818301008D060448454C4C4F').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_9_2_1
    // 27.22.4.3.9 GET INPUT (UCS2 display in Chinese)
    // Expected Sequence 9.2 (GET INPUT, max length for the text string coding in UCS2 in Chinese, successful)
    it('GetInput_GET_INPUT_9_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_9_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr =
        '你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好' +
          '你好你好你好你好你好你好你好你好';
      let inputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('HELLO');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012301020282818301008D060448454C4C4F').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_10_1_1
    // 27.22.4.3.10 GET INPUT (UCS2 entry in Chinese)
    // Expected Sequence 10.1 (GET INPUT, character set from UCS2 alphabet in Chinese, successful)
    it('GetInput_GET_INPUT_10_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_10_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter Hello'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('你好');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012303020282818301008D05084F60597D').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_10_2_1
    // 27.22.4.3.10 GET INPUT (UCS2 entry in Chinese)
    // Expected Sequence 10.2 (GET INPUT, character set from UCS2 alphabet in Chinese, Max length for the input,
    // successful)
    it('GetInput_GET_INPUT_10_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_10_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter Hello'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      let inputStr =
        '你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你' +
          '好你好你好你好你好你好你好你好你好你好你好';
      await inputButton.inputText(inputStr);

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      let responseHex = '8103012303020282818301008D818D084F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4' +
        'F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F' +
        '60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F60597D4F6' +
        '0597D4F60597D';
      expect(responseHex).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_11_1_1
    // 27.22.4.3.11 GET INPUT (UCS2 display in Katakana)
    // Expected Sequence 11.1 (GET INPUT, text string coding in UCS2 in Katakana, successful)
    it('GetInput_GET_INPUT_11_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_11_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('ル'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('HELLO');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012301020282818301008D060448454C4C4F').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_11_2_1
    // 27.22.4.3.11 GET INPUT (UCS2 display in Katakana)
    // Expected Sequence 11.2 (GET INPUT, max length for the text string coding in UCS2 in Katakana, successful)
    it('GetInput_GET_INPUT_11_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_11_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr =
        'ルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルル' +
          'ルルルルルルルルルルルル';
      let inputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('HELLO');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012301020282818301008D060448454C4C4F').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_12_1_1
    // 27.22.4.3.12 GET INPUT (UCS2 entry in Katakana)
    // Expected Sequence 12.1 (GET INPUT, character set from UCS2 alphabet in Katakana, successful)
    it('GetInput_GET_INPUT_12_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_12_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter Hello'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('ルル');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012303020282818301008D050830EB30EB').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInput GET_INPUT_12_2_1
    // 27.22.4.3.12 GET INPUT (UCS2 entry in Katakana)
    // Expected Sequence 12.2 (GET INPUT, character set from UCS2 alphabet in Katakana, Max length for the input,
    // successful)
    it('GetInput_GET_INPUT_12_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInputConstants.GET_INPUT_12_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let inputText = await driver.waitForComponent(ON.text('Enter Hello'), 2000);
      expect(!CommonUtils.isEmptyObj(inputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      let inputStr =
        'ルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルル' +
          'ルルルルルルルルルルルルルルルル';
      await inputButton.inputText(inputStr);

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      let responseStr = '8103012303020282818301008D818D0830EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30E' +
        'B30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30' +
        'EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB30EB3' +
        '0EB30EB';
      expect(responseStr).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}