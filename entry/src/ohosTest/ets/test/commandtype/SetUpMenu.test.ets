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
import { sendCommandHex, sendEndSession, setMock, sleep, startAbilityMine } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { PageUrl, ViewId } from '../../../../main/ets/common/constant/Constants';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { SetUpMenuConstants } from '../constants/CommandTypetConstants';

const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SetUpMenu(): void {
  describe('SetUpMenu', () => {
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

    // SetUpMenu SET_UP_MENU_1_1_1
    // 27.22.4.8.1 SET UP MENU (normal) and ENVELOPE MENU SELECTION
    // Expected Sequence 1.1 (SET UP MENU and MENU SELECTION, without Help Request, Replace and Remove a Toolkit Menu)
    it('SetUpMenu_SET_UP_MENU_1_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_1_1_1, 0);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));
      await driver.assertComponentExist(ON.text('Item 4'));
      let itemTwoButton = await driver.findComponent(ON.text('Item 2'));
      await itemTwoButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_1_1_2, 0);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      await driver.assertComponentExist(ON.text('One'));
      itemTwoButton = await driver.findComponent(ON.text('Two'));
      await itemTwoButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_12).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_EMPTY, 0);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      // check main menu
      let titleText = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(CommonUtils.isEmptyObj(titleText)).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_1_2_1
    // 27.22.4.8.1 SET UP MENU (normal) and ENVELOPE MENU SELECTION
    // Expected Sequence 1.2 (SET UP MENU, Large Menu with many items or with large items or with Large Alpha
    // Identifier)
    it('SetUpMenu_SET_UP_MENU_1_2_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_1_2_1, 0);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Zero'));
      await driver.assertComponentExist(ON.text('Seven'));
      let displayPoint = await driver.getDisplaySize()
      let swipeX = displayPoint.x / 2;
      let swipeY = displayPoint.y - 300;
      await driver.swipe(swipeX, swipeY, swipeX, 0, 10000);
      await driver.swipe(swipeX, swipeY, swipeX, 0, 10000);
      let itemButton = await driver.findComponent(ON.text('Orange'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_3D).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_1_2_2, 0);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      await driver.assertComponentExist(ON.text('2 Call Forward On User Busy'));
      await driver.assertComponentExist(ON.text('3 Call Forward On No Reply'));
      await driver.assertComponentExist(ON.text('4 Call Forward On User Not Reachable'));
      itemButton = await driver.findComponent(ON.text('5 Barring Of All Outgoing Calls'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_FB).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_1_2_3, 0);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      itemButton = await driver.findComponent(ON.text('Y'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_01).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_2_1_1
    // 27.22.4.8.2 SET UP MENU (help request support) and ENVELOPE MENU SELECTION
    // Expected Sequence 2.1 (SET UP MENU and MENU SELECTION, with Help Request, Replace and Remove a
    // Toolkit Menu)
    it('SetUpMenu_SET_UP_MENU_2_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_2_1_1, 0);
      expect(SetUpMenuConstants.RESPONSE_OK_2_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));
      await driver.assertComponentExist(ON.text('Item 4'));

      let itemButton = await driver.findComponent(ON.text('Item 2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_3_1_1
    // 27.22.4.8.3 SET UP MENU (next action support) and ENVELOPE MENU SELECTION
    // Expected Sequence 3.1 (SET UP MENU, next action indicator "Send SM", "Set Up Call", "Launch Browser",
    // "Provide Local Information", successful)
    it('SetUpMenu_SET_UP_MENU_3_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_3_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));
      await driver.assertComponentExist(ON.text('Item 4'));

      let itemButton = await driver.findComponent(ON.text('Item 2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_4_1_1
    // 27.22.4.8.4 SET UP MENU (display of icons) and ENVELOPE MENU SELECTION
    // Expected Sequence 4.1A(SET UP MENU,BASIC ICON NOT SELF EXPLANATORY in ALPHA ID and ITEMS DATA OBJECTS,successful)
    // Expected Sequence 4.1B (SET UP MENU, BASIC ICON NOT SELF EXPLANATORY in ALPHA ID and
    // ITEMS DATA OBJECTS, requested icon could not be displayed)
    it('SetUpMenu_SET_UP_MENU_4_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_4_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect('810301250002028281830104').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));

      let itemButton = await driver.findComponent(ON.text('Item 2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_4_2_1
    // 27.22.4.8.4 SET UP MENU (display of icons) and ENVELOPE MENU SELECTION
    // Expected Sequence 4.2A (SET UP MENU, BASIC ICON SELF EXPLANATORY in ALPHA ID and ITEMS
    // DATA OBJECTS, successful)
    // Expected Sequence 4.2B (SET UP MENU, BASIC ICON SELF EXPLANATORY in ALPHA ID and ITEMS
    // DATA OBJECTS, requested icon could not be displayed)
    it('SetUpMenu_SET_UP_MENU_4_2_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_4_2_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect('810301250002028281830104').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));

      let itemButton = await driver.findComponent(ON.text('Item 2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_5_1_1
    // Expected Sequence 5.1 (SET UP MENU, SOFT KEY PREFERRED, successful)
    it('SetUpMenu_SET_UP_MENU_5_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_5_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect('810301250102028281830100').assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('Item 1'));
      let itemButton = await driver.findComponent(ON.text('Item 2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_7_1_1
    // 27.22.4.8.7 SET UP MENU (UCS2 display in Cyrillic) and ENVELOPE MENU SELECTION
    // Expected Sequence 7.1 (SET UP MENU and MENU SELECTION, without Help Request, Replace and Remove
    // a Toolkit Menu, with UCS2 in Cyrillic Characters)
    it('SetUpMenu_SET_UP_MENU_7_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_7_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ1'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ3'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ4'));
      let itemButton = await driver.findComponent(ON.text('ЗДРАВСТВУЙТЕ2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_7_1_2, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ5'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ6'));

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_EMPTY, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      itemButton = await driver.findComponent(ON.text('ЗДРАВСТВУЙТЕ6'));
      expect(CommonUtils.isEmptyObj(itemButton)).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_8_1_1
    // 27.22.4.8.8 SET UP MENU (UCS2 display in Chinese) and ENVELOPE MENU SELECTION
    // Expected Sequence 8.1 (SET UP MENU and MENU SELECTION, without Help Request, Replace and Remove
    // a Toolkit Menu, with UCS2 - Chinese Characters)
    it('SetUpMenu_SET_UP_MENU_8_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_8_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('项目一'));
      await driver.assertComponentExist(ON.text('项目三'));
      await driver.assertComponentExist(ON.text('项目四'));
      let itemButton = await driver.findComponent(ON.text('项目二'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_8_1_2, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      await driver.assertComponentExist(ON.text('一'));
      itemButton = await driver.findComponent(ON.text('二'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_12).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_EMPTY, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      itemButton = await driver.findComponent(ON.text('二'));
      expect(CommonUtils.isEmptyObj(itemButton)).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // SetUpMenu SET_UP_MENU_9_1_1
    // 27.22.4.8.9 SET UP MENU (UCS2 display in Katakana) and ENVELOPE MENU SELECTION
    // Expected Sequence 9.1 (SET UP MENU and MENU SELECTION, without Help Request, Replace and Remove
    // a Toolkit Menu, with UCS2 in Katakana Characters)
    it('SetUpMenu_SET_UP_MENU_9_1_1', 0, async (done: Function) => {
      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_9_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();

      // start main menu
      await startAbilityMine(0, undefined, PageUrl.PAGE_URL_MAIN);
      await driver.assertComponentExist(ON.text('80ル1'));
      await driver.assertComponentExist(ON.text('80ル3'));
      await driver.assertComponentExist(ON.text('80ル4'));
      let itemButton = await driver.findComponent(ON.text('80ル2'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_02).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_9_1_2, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      await driver.assertComponentExist(ON.text('80ル5'));
      itemButton = await driver.findComponent(ON.text('80ル6'));
      await itemButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SetUpMenuConstants.MENU_SELECTION_12).assertEqual(
        OhosTestUtils.getInstance().getMenuSelectionEnvelopeRespData());
      OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData('');

      await sendCommandHex(SetUpMenuConstants.SET_UP_MENU_EMPTY, 0);
      await driver.delayMs(DELAY_TIME_1000);
      expect(SetUpMenuConstants.RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      itemButton = await driver.findComponent(ON.text('80ル6'));
      expect(CommonUtils.isEmptyObj(itemButton)).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}

