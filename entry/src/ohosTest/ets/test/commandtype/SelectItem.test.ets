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
import { SelectItemConstants } from '../constants/CommandTypetConstants';

const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SelectItem(): void {
  describe('SelectItem', () => {
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

    // SelectItem SELECT_ITEM_1_1_1
    // 27.22.4.9.1 SELECT ITEM (mandatory features for Terminal supporting SELECT ITEM)
    // Expected Sequence 1.1 (SELECT ITEM, mandatory features, successful)
    it('SelectItem_SELECT_ITEM_1_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_1_1, 0);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));
      await driver.assertComponentExist(ON.text('Item 4'));
      let itemTwoButton = await driver.findComponent(ON.text('Item 2'));
      await itemTwoButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_1_2_1
    // 27.22.4.9.1 SELECT ITEM (mandatory features for Terminal supporting SELECT ITEM)
    // Expected Sequence 1.2 (SELECT ITEM, large menu, successful)
    it('SelectItem_SELECT_ITEM_1_2_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_2_1, 0);
      await driver.assertComponentExist(ON.text('Zero'));
      await driver.assertComponentExist(ON.text('Seven'));
      let displayPoint = await driver.getDisplaySize()
      let swipeX = displayPoint.x / 2;
      let swipeY = displayPoint.y - 300;
      await driver.swipe(swipeX, swipeY, swipeX, 0, 10000);
      await driver.swipe(swipeX, swipeY, swipeX, 0, 10000);
      let itemButton = await driver.findComponent(ON.text('Orange'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_2_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_1_3_1
    // 27.22.4.9.1 SELECT ITEM (mandatory features for Terminal supporting SELECT ITEM)
    // Expected Sequence 1.3 (SELECT ITEM, call options, successful)
    it('SelectItem_SELECT_ITEM_1_3_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_3_1, 0);
      await driver.assertComponentExist(ON.text('Call Forwarding Unconditional'));
      await driver.assertComponentExist(ON.text('CLI Presentation'));
      let itemButton = await driver.findComponent(ON.text('Barring Of All Outgoing Calls'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_3_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_1_4_1
    // 27.22.4.9.1 SELECT ITEM (mandatory features for Terminal supporting SELECT ITEM)
    // Expected Sequence 1.4 (SELECT ITEM, backward move by user, successful)
    it('SelectItem_SELECT_ITEM_1_4_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_4_1, 0);
      await driver.assertComponentExist(ON.text('One'));
      await driver.assertComponentExist(ON.text('Two'));

      // back
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_4_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_4_1, 0);
      await driver.assertComponentExist(ON.text('One'));
      await driver.assertComponentExist(ON.text('Two'));

      // endSession
      let menuButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let endSessionButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`), 2000);
      expect(!CommonUtils.isEmptyObj(endSessionButton)).assertTrue();
      await endSessionButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_4_2).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');

      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_1_5_1
    // 27.22.4.9.1 SELECT ITEM (mandatory features for Terminal supporting SELECT ITEM)
    // Expected Sequence 1.5 (SELECT ITEM, "Y", successful)
    it('SelectItem_SELECT_ITEM_1_5_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_5_1, 0);
      let itemButton = await driver.waitForComponent(ON.text('Y'), 2000);
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_5_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendEndSession();
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_1_6_1
    // 27.22.4.9.1 SELECT ITEM (mandatory features for Terminal supporting SELECT ITEM)
    // Expected Sequence 1.6 (SELECT ITEM, Large menu, successful)
    it('SelectItem_SELECT_ITEM_1_6_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_1_6_1, 0);
      await driver.assertComponentExist(ON.text('1 Call Forward Unconditional'));
      await driver.assertComponentExist(ON.text('7 CLI Presentation'));
      let itemButton = await driver.waitForComponent(ON.text('5 Barring Of All Outgoing Calls'), 2000);
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_3_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_2_1_1
    // 27.22.4.9.2 SELECT ITEM (next action support)
    // Expected Sequence 2.1 (SELECT ITEM, next action indicator, successful)
    it('SelectItem_SELECT_ITEM_2_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_2_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 3'));
      let itemButton = await driver.waitForComponent(ON.text('Item 2'), 2000);
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_3_1_1
    // 27.22.4.9.3 SELECT ITEM (default item support)
    // Expected Sequence 3.1 (SELECT ITEM, default item, successful)
    it('SelectItem_SELECT_ITEM_3_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_3_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 2'));
      let itemButton = await driver.waitForComponent(ON.text('Item 3'), 2000);
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_3_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_4_1_1
    // 27.22.4.9.4 SELECT ITEM (help request support)
    // Expected Sequence 4.1 (SELECT ITEM, help request, successful)
    it('SelectItem_SELECT_ITEM_4_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_4_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 2'));
      await driver.assertComponentExist(ON.text('Item 3'));

      // help
      let menuButton = await driver.findComponent(ON.id(ViewId.NAV_BACK_MENU));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let helpButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}1`), 2000);
      await helpButton.click();
      await driver.delayMs(DELAY_TIME);

      expect(SelectItemConstants.RESPONSE_4_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_5_1_1
    // 27.22.4.9.5 SELECT ITEM (icons support)
    // Expected Sequence 5.1A (SELECT ITEM, BASIC ICON NOT SELF EXPLANATORY, successful)
    // Expected Sequence 5.1B (SELECT ITEM, BASIC ICON NOT SELF EXPLANATORY, requested icon could
    // not be displayed)
    it('SelectItem_SELECT_ITEM_5_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_5_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 2'));
      await driver.assertComponentExist(ON.text('Item 3'));
      let menuButton = await driver.findComponent(ON.text('Item 1'));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_5_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_5_2_1
    // 27.22.4.9.5 SELECT ITEM (icons support)
    // Expected Sequence 5.2A (SELECT ITEM, BASIC ICON SELF EXPLANATORY, successful)
    // Expected Sequence 5.2B (SELECT ITEM, BASIC ICON SELF EXPLANATORY, requested icon could not be
    // displayed)
    it('SelectItem_SELECT_ITEM_5_2_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_5_2_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 2'));
      await driver.assertComponentExist(ON.text('Item 3'));
      let menuButton = await driver.findComponent(ON.text('Item 1'));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_5_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_6_1_1
    // Expected Sequence 6.1 (SELECT ITEM, PRESENTATION AS A CHOICE OF NAVIGATION OPTIONS,
    // successful)
    it('SelectItem_SELECT_ITEM_6_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_6_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 2'));
      await driver.assertComponentExist(ON.text('Item 3'));
      let menuButton = await driver.findComponent(ON.text('Item 1'));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_6_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_6_2_1
    // Expected Sequence 6.2 (SELECT ITEM, PRESENTATION AS A CHOICE OF DATA VALUES, successful)
    it('SelectItem_SELECT_ITEM_6_2_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_6_2_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 2'));
      await driver.assertComponentExist(ON.text('Item 3'));
      let menuButton = await driver.findComponent(ON.text('Item 1'));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_6_2_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_7_1_1
    // Expected Sequence 7.1 (SELECT ITEM, SELECTING USING SOFT KEYS PREFERRED, successful,
    // successful)
    it('SelectItem_SELECT_ITEM_7_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_7_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('Item 2'));
      let menuButton = await driver.findComponent(ON.text('Item 1'));
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_7_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_8_1_1
    // 27.22.4.9.8 SELECT ITEM (Support of "No response from user")
    // Expected Sequence 8.1 (SELECT ITEM, no response from user)
    it('SelectItem_SELECT_ITEM_8_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_8_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('<TIME-OUT>'));
      await driver.assertComponentExist(ON.text('Item 1'));
      await driver.assertComponentExist(ON.text('Item 2'));
      await driver.assertComponentExist(ON.text('Item 3'));
      // time out
      await driver.delayMs(50000);
      expect(SelectItemConstants.RESPONSE_8_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_10_1_1
    // 27.22.4.9.10 SELECT ITEM (UCS2 display in Cyrillic)
    // Expected Sequence 10.1 (SELECT ITEM with UCS2 in Cyrillic characters, 0x80 UCS2 coding, successful)
    it('SelectItem_SELECT_ITEM_10_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_10_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ1'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ3'));
      let itemButton = await driver.findComponent(ON.text('ЗДРАВСТВУЙТЕ2'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_10_2_1
    // 27.22.4.9.10 SELECT ITEM (UCS2 display in Cyrillic)
    // Expected Sequence 10.2 (SELECT ITEM with UCS2 in Cyrillic characters, 0x81 UCS2 coding, successful)
    it('SelectItem_SELECT_ITEM_10_2_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_10_2_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ1'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ3'));
      let itemButton = await driver.findComponent(ON.text('ЗДРАВСТВУЙТЕ2'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_10_3_1
    // 27.22.4.9.10 SELECT ITEM (UCS2 display in Cyrillic)
    // Expected Sequence 10.3 (SELECT ITEM with UCS2 in Cyrillic characters, 0x82 UCS2 coding, successful
    it('SelectItem_SELECT_ITEM_10_3_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_10_3_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ1'));
      await driver.assertComponentExist(ON.text('ЗДРАВСТВУЙТЕ3'));
      let itemButton = await driver.findComponent(ON.text('ЗДРАВСТВУЙТЕ2'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_11_1_1
    // 27.22.4.9.11 SELECT ITEM (UCS2 display in Chinese)
    // Expected Sequence 11.1 (SELECT ITEM with UCS2 in Chinese Characters, successful)
    it('SelectItem_SELECT_ITEM_11_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_11_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('工具箱选择'));
      await driver.assertComponentExist(ON.text('项目一'));
      await driver.assertComponentExist(ON.text('项目三'));
      await driver.assertComponentExist(ON.text('项目四'));
      let itemButton = await driver.findComponent(ON.text('项目二'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_12_1_1
    // 27.22.4.9.12 SELECT ITEM (UCS2 display in Katakana)
    // Expected Sequence 12.1 (SELECT ITEM with UCS2 in Katakana characters, 0x80 UCS2 coding, successful)
    it('SelectItem_SELECT_ITEM_12_1_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_12_1_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('80ル0'));
      await driver.assertComponentExist(ON.text('80ル1'));
      await driver.assertComponentExist(ON.text('80ル3'));
      let itemButton = await driver.findComponent(ON.text('80ル2'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_12_2_1
    // 27.22.4.9.12 SELECT ITEM (UCS2 display in Katakana)
    // Expected Sequence 12.2 (SELECT ITEM with UCS2 in Katakana characters, 0x81 UCS2 coding, successful)
    it('SelectItem_SELECT_ITEM_12_2_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_12_2_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('81ル0'));
      await driver.assertComponentExist(ON.text('81ル1'));
      await driver.assertComponentExist(ON.text('81ル3'));
      let itemButton = await driver.findComponent(ON.text('81ル2'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })

    // SelectItem SELECT_ITEM_12_3_1
    // 27.22.4.9.12 SELECT ITEM (UCS2 display in Katakana)
    // Expected Sequence 12.3 (SELECT ITEM with UCS2 in Katakana characters, 0x82 UCS2 coding, successful)
    it('SelectItem_SELECT_ITEM_12_3_1', 0, async (done: Function) => {
      await sendCommandHex(SelectItemConstants.SELECT_ITEM_12_3_1, 0);
      await driver.delayMs(DELAY_TIME_1000);
      await driver.assertComponentExist(ON.text('82ル0'));
      await driver.assertComponentExist(ON.text('82ル1'));
      await driver.assertComponentExist(ON.text('82ル3'));
      let itemButton = await driver.findComponent(ON.text('82ル2'));
      await itemButton?.click();
      await driver.delayMs(DELAY_TIME);
      expect(SelectItemConstants.RESPONSE_1_1_1).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressBack();
      done();
    })
  })
}

