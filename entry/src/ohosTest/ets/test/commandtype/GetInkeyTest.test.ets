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
import { ViewId } from '../../../../main/ets/common/constant/Constants';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { CONFIRM_DIALOG_CONFIRM_TEXT } from '../constants/TestConstants';
import { GetInkeyConstants } from '../constants/CommandTypetConstants';

const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function GetInkeyTest(): void {
  describe('GetInkeyTest', () => {
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

    // GetInkey GET_INKEY_1_1_1
    // 27.22.4.2.1 GET INKEY(normal)
    // Expected Sequence 1.1 (GET INKEY, digits only for character, Unpacked 8 bit data for Text String, successful)
    it('GetInkey_GET_INKEY_1_1_1', 0, async (done: Function) => {
      await sendCommandHex(GetInkeyConstants.GET_INKEY_1_1_1, 0);
      let InputText = await driver.waitForComponent(ON.text('Enter "+"'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_1_2_1
    // 27.22.4.2.1 GET INKEY(normal)
    // Expected Sequence 1.2 (GET INKEY, digits only for character set,SMS default Alphabet for Text String,successful)
    it('GetInkey_GET_INKEY_1_2_1', 0, async (done: Function) => {
      await sendCommandHex(GetInkeyConstants.GET_INKEY_1_2_1, 0);
      let InputText = await driver.waitForComponent(ON.text('Enter "0"'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('0');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D020430').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_1_3_1
    // 27.22.4.2.1 GET INKEY(normal)
    // Expected Sequence 1.3 (GET INKEY, backward move)
    it('GetInkey_GET_INKEY_1_3_1', 0, async (done: Function) => {
      await sendCommandHex(GetInkeyConstants.GET_INKEY_1_3_1, 0);
      let InputText = await driver.waitForComponent(ON.text('<GO-BACKWARDS>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let backButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_BACK));
      expect(!CommonUtils.isEmptyObj(backButton)).assertTrue();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301220002028281830111').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_1_4_1
    // 27.22.4.2.1 GET INKEY(normal)
    // Expected Sequence 1.4 (GET INKEY, abort)
    it('GetInkey_GET_INKEY_1_4_1', 0, async (done: Function) => {
      await sendCommandHex(GetInkeyConstants.GET_INKEY_1_4_1, 0);
      let InputText = await driver.waitForComponent(ON.text('<ABORT>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let menuButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let endSessionButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`), 2000);
      expect(!CommonUtils.isEmptyObj(endSessionButton)).assertTrue();
      await endSessionButton.click();
      await driver.delayMs(DELAY_TIME);

      expect('810301220002028281830110').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_1_5_1
    // 27.22.4.2.1 GET INKEY(normal)
    // Expected Sequence 1.5 (GET INKEY, SMS default alphabet for character set, Unpacked 8 bit data for Text String,
    // successful)
    it('GetInkey_GET_INKEY_1_5_1', 0, async (done: Function) => {
      await sendCommandHex(GetInkeyConstants.GET_INKEY_1_5_1, 0);
      let InputText = await driver.waitForComponent(ON.text('Enter "q"'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('q');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012201020282818301008D020471').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_1_6_1
    // 27.22.4.2.1 GET INKEY(normal)
    // Expected Sequence 1.6 (GET INKEY, Max length for the Text String, successful)
    it('GetInkey_GET_INKEY_1_6_1', 0, async (done: Function) => {
      await sendCommandHex(GetInkeyConstants.GET_INKEY_1_6_1, 0);
      let testStr = 'Enter "x". This command instructs the ME to display text, and to expect the user to enter a ' +
        'single character. Any response entered by the user shall be passed t';
      let InputText = await driver.waitForComponent(ON.text(testStr), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('x');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012201020282818301008D020478').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_2_1_1
    // 27.22.4.2.2 GET INKEY (No response from User)
    // Expected Sequence 2.1 (GET INKEY, no response from the user)
    it('GetInkey_GET_INKEY_2_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_2_1_1, 0);
      let InputText = await driver.waitForComponent(ON.text('<TIME-OUT>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();
      await driver.delayMs(61000);
      expect('810301220002028281830112').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_3_1_1
    // 27.22.4.2.3 GET INKEY (UCS2 display in Cyrillic)
    // Expected Sequence 3.1 (GET INKEY, Text String coding in UCS2 Alphabet in Cyrillic, successful)
    it('GetInkey_GET_INKEY_3_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_3_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('ЗДРАВСТВУЙТЕ'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_3_2_1
    // 27.22.4.2.3 GET INKEY (UCS2 display in Cyrillic)
    // Expected Sequence 3.2 (GET INKEY, max length for the Text String coding in UCS2 Alphabet in Cyrillic,successful)
    it('GetInkey_GET_INKEY_3_2_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_3_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = 'ЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙТЕЗДРАВСТВУЙ';
      let InputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_4_1_1
    // 27.22.4.2.4 GET INKEY (UCS2 entry in Cyrillic)
    // Expected Sequence 4.1 (GET INKEY, characters from UCS2 alphabet in Cyrillic, successful)
    it('GetInkey_GET_INKEY_4_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_4_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('Enter'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('Д');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012203020282818301008D03080414').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_5_1_1
    // 27.22.4.2.5 GET INKEY ("Yes/No" Response)
    // Expected Sequence 5.1 (GET INKEY, "Yes/No" Response for the input, successful)
    it('GetInkey_GET_INKEY_5_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_5_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('Enter YES'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012204020282818301008D020401').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);

      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_5_1_2, 0);
      await driver.delayMs(DELAY_TIME);
      InputText = await driver.waitForComponent(ON.text('Enter NO'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let cancelButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CANCEL));
      await cancelButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012204020282818301008D020400').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_6_1_1
    // 27.22.4.2.6 GET INKEY (display of Icon)
    // Expected Sequence 6.1A (GET INKEY, Basic icon, self-explanatory, successful)
    // Expected Sequence 6.1B (GET INKEY, Basic icon, self-explanatory, requested icon could not be displayed)
    it('GetInkey_GET_INKEY_6_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_6_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('<NO-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_6_2_1
    // 27.22.4.2.6 GET INKEY (display of Icon)
    // Expected Sequence 6.2A (GET INKEY, Basic icon, non self-explanatory, successful)
    // Expected Sequence 6.2B (GET INKEY, Basic icon, non self-explanatory, requested icon could not be displayed)
    it('GetInkey_GET_INKEY_6_2_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_6_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('<BASIC-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_6_3_1
    // 27.22.4.2.6 GET INKEY (display of Icon)
    // Expected Sequence 6.3A (GET INKEY, Colour icon, self-explanatory, successful)
    // Expected Sequence 6.3B (GET INKEY, Colour icon, self-explanatory, requested icon could not be displayed)
    it('GetInkey_GET_INKEY_6_3_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_6_3_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('<NO-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_6_4_1
    // 27.22.4.2.6 GET INKEY (display of Icon)
    // Expected Sequence 6.4A (GET INKEY, Colour icon, non self-explanatory, successful)
    // Expected Sequence 6.4B (GET INKEY, Colour icon, non self-explanatory, requested icon could not be displayed)
    it('GetInkey_GET_INKEY_6_4_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_6_4_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('<COLOUR-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301048D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_7_1_1
    // 27.22.4.2.7 GET INKEY (Help Information)
    // Expected Sequence 7.1 (GET INKEY, help information available)
    it('GetInkey_GET_INKEY_7_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_7_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('Enter "+"'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let menuButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let helpButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}1`), 2000);
      await helpButton.click();

      // check response
      await driver.delayMs(DELAY_TIME);
      expect('810301228002028281830113').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());

      // display text
      sendCommandHex('D01C8103012181820281028D110448656C7020696E666F726D6174696F6E', 0);
      let dialogText = await driver.waitForComponent(ON.text('Help information'), 2000);
      expect(!CommonUtils.isEmptyObj(dialogText)).assertTrue();
      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('810301218102028281830100').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      await sendCommandHex(GetInkeyConstants.GET_INKEY_7_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      InputText = await driver.waitForComponent(ON.text('Enter "+"'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();
      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');
      confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012280020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })


    // GetInkey GET_INKEY_8_1_1
    // 27.22.4.2.8 GET INKEY (Variable Time out)
    // Expected Sequence 8.1 (GET INKEY, variable time out of 10 seconds)
    it('GetInkey_GET_INKEY_8_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_8_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('Enter "+"'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      await driver.delayMs(11000);
      expect('8103012200020282818301120402010A').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_10_1_1
    // 27.22.4.2.10 GET INKEY (UCS2 display in Chinese)
    // Expected Sequence 10.1 (GET INKEY, Text String coding in UCS2 Alphabet in Chinese, successful)
    it('GetInkey_GET_INKEY_10_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_10_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('你好'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_10_2_1
    // 27.22.4.2.10 GET INKEY (UCS2 display in Chinese)
    // Expected Sequence 10.2 (GET INKEY, max length for the Text String coding in UCS2 Alphabet in Chinese,successful)
    it('GetInkey_GET_INKEY_10_2_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_10_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = '你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好你好' +
        '你好你好你好你好你好你好你好你好';
      let InputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_11_1_1
    // 27.22.4.2.11 GET INKEY (UCS2 entry in Chinese)
    // Expected Sequence 11.1 (GET INKEY, characters from UCS2 alphabet in Chinese, successful)
    it('GetInkey_GET_INKEY_11_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_11_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('Enter'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('好');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012203020282818301008D0308597D').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_12_1_1
    // 27.22.4.2.12 GET INKEY (UCS2 display in Katakana)
    // Expected Sequence 12.1 (GET INKEY, Text String coding in UCS2 Alphabet in Katakana, successful)
    it('GetInkey_GET_INKEY_12_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_12_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('ル'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_12_2_1
    // 27.22.4.2.12 GET INKEY (UCS2 display in Katakana)
    // Expected Sequence 12.2(GET INKEY, max length for the Text String coding in UCS2 Alphabet in Katakana,successful)
    it('GetInkey_GET_INKEY_12_2_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_12_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let textStr = 'ルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルルル' +
        'ルルルルルルルルルルルルルルルルルル';
      let InputText = await driver.waitForComponent(ON.text(textStr), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('+');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012200020282818301008D02042B').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // GetInkey GET_INKEY_13_1_1
    // 27.22.4.2.13 GET INKEY (UCS2 entry in Katakana)
    // Expected Sequence 13.1 (GET INKEY, characters from UCS2 alphabet in Katakana, successful)
    it('GetInkey_GET_INKEY_13_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(GetInkeyConstants.GET_INKEY_13_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let InputText = await driver.waitForComponent(ON.text('Enter'), 2000);
      expect(!CommonUtils.isEmptyObj(InputText)).assertTrue();

      let inputButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT));
      expect(!CommonUtils.isEmptyObj(inputButton)).assertTrue();
      await inputButton.inputText('ル');

      let confirmButton = await driver.findComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM));
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect('8103012203020282818301008D030830EB').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}
