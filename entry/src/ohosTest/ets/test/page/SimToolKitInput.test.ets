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
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { inputTextCust, sendCommandHex, sendEndSession, setMock, sleep, startAbilityMine } from '../TestUtils';
import HiLog from '../../../../main/ets/common/utils/HiLog';
import OhosTestUtils from '../OhosTestUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { CommonTestHex, DELAY_TIME_1000, DELAY_TIME_3000, SLOT_ID } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { PageUrl, ViewId } from '../../../../main/ets/common/constant/Constants';

const TAG = 'SimToolKitInputTest';
const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SimToolKitInputTest(): void {
  describe('SimToolKitInputTest', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      HiLog.info(TAG, `SimToolKitInputTest : ${new Date().getTime()}`);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })
    it('SimToolKitInputTest_GET_INPUT_Back', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INPUT);
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_GET_INPUT_Backward', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
      await sendCommandHex(CommonTestHex.SELECT_ITEM);

      // click item
      let firstItemView = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}0`),
        DELAY_TIME_3000);
      HiLog.info('InputTest', 'Backward test start');
      expect(CommonUtils.isEmptyObj(firstItemView)).assertFalse();
      HiLog.info('InputTest', 'Backward test click item');
      await firstItemView.click();
      await driver.delayMs(DELAY_TIME);
      await sendCommandHex(CommonTestHex.INPUT_TEST_BACK);

      // back from inputPage
      let input = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      HiLog.info('InputTest', `Backward test input:${input}`);
      expect(!CommonUtils.isEmptyObj(input)).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      let lastRespData: string | undefined = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('InputTest', `Backward test lastTerminalRespData:${lastRespData}`);
      expect(CommonTestHex.INPUT_TEST_BACK_RESP).assertEqual(lastRespData);
      await sendCommandHex(CommonTestHex.SELECT_ITEM);

      // back from secondMenu
      await driver.delayMs(DELAY_TIME);
      let nav = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      HiLog.info('InputTest', `Backward test get back nav:${nav}`);
      expect(CommonUtils.isEmptyObj(nav)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await sendEndSession();

      // back from mainMenu
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_GET_INPUT_endSession', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INPUT);
      let menuButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_MENU),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(menuButton)).assertFalse();
      await menuButton.click();
      let sessionButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(sessionButton)).assertFalse();
      await sessionButton.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      done();
    })
    it('SimToolKitInputTest_GET_INPUT_Help', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INPUT);
      let menuButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_MENU),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(menuButton)).assertFalse();
      await menuButton.click();
      let helpButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}1`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(helpButton)).assertFalse();
      await helpButton.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      done();
    })
    it('SimToolKitInputTest_GET_INPUT_InputAndConfirm', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INPUT);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(button)).assertFalse();
      await inputTextCust(driver, 'xxxxxxxx');
      await driver.delayMs(DELAY_TIME_1000);
      button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(button)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      done();
    })
    it('SimToolKitInputTest_GET_INPUT_Cancel', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INPUT);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CANCEL),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(button)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_GET_INKEY_InputTypeCancel', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INKEY);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CANCEL),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(button)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_GET_INKEY_InputTypeConfirm', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INKEY);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(button)).assertFalse();
      await inputTextCust(driver, '8');
      await driver.delayMs(DELAY_TIME_1000);
      button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      await driver.delayMs(DELAY_TIME);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_GET_INKEY_YesNoTypeConfirm', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INKEY_YES_NO);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(button)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_GET_INKEY_YesNoTypeCancel', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.GET_INKEY_YES_NO);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CANCEL),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(button)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressHome();
      done();
    })
  })
}