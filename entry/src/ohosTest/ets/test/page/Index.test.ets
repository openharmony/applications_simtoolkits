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
import { PageUrl, ViewId } from '../../../../main/ets/common/constant/Constants';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { sendCommandHex, sendEndSession, setMock, sleep, startAbilityMine, startSecondMenuPage } from '../TestUtils';
import HiLog from '../../../../main/ets/common/utils/HiLog';
import { ContextStorageHelper } from '../../../../main/ets/common/utils/ContextStorageHelper';
import OhosTestUtils from '../OhosTestUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { CommonTestHex, CONFIRM_DIALOG_CONFIRM_TEXT, DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { SLOT_ID } from '../constants/TestConstants';
import { DELAY_TIME_3000 } from '../constants/TestConstants';

const TAG: string = 'IndexTest';
const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function IndexTest(): void {
  describe('IndexTest', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      HiLog.info(TAG, `IndexTest start : ${new Date().getTime()}`);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })
    it('IndexTest_show_main_menu', 0, async (done: Function) => {
      HiLog.info(TAG, 'IndexTest_show_main_menu start');
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);

      // expect show main menu
      let menuTitle = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_TEXT),
        DELAY_TIME_3000);
      HiLog.info(TAG, 'IndexTest_show_main_menu menuTitle:' + menuTitle);
      expect(!CommonUtils.isEmptyObj(menuTitle)).assertTrue();
      let menuTitleText: string = await menuTitle.getText();
      HiLog.info(TAG, 'IndexTest_show_main_menu menuTitleText:' + menuTitleText);
      expect(!CommonUtils.isEmptyObj(menuTitleText)).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);

      // then test empty menu
      await sendCommandHex('D00D81030125008202818285008F00');
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);

      // expect show empty menu
      HiLog.info(TAG, 'Test_application test empty menu');
      menuTitle = await driver.findComponent(ON.id(ViewId.NAV_BACK_TEXT))
      HiLog.info(TAG, 'IndexTest_show_main_menu empty menu menuTitle:' + menuTitle);
      expect(CommonUtils.isEmptyObj(menuTitle)).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME_1000);
      HiLog.info(TAG, 'IndexTest_show_main_menu end');
      done();
    })
    it('IndexTest_SELECT_ITEM_Backward', 0, async (done: Function) => {
      await sendCommandHex(
        'D02B8103012400820281828F0A0180536172477C7B578B8F14028075358BDD53F7780153CA77ED4FE15BB991CF');
      let firstItemView = await driver.waitForComponent(ON.text('卡片类型'), DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(firstItemView)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      let lastRespData: string | undefined = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('IndexMenuTest', `onBackPress lastRespData:${lastRespData}`);
      expect('810301240002028281830111').assertEqual(lastRespData);
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('IndexTest_SET_UP_MENU_Back', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(backButton)).assertTrue();
      await backButton.click();
      await driver.pressBack();
      done();
    })
    it('IndexTest_SET_UP_MENU_Help', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
      // click menu--> 帮助
      let menuButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_MENU),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(menuButton)).assertFalse();
      await menuButton.click();

      let helpButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(helpButton)).assertFalse();
      await helpButton.click();
      await sendEndSession();
      // click back
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      done();
    })
    it('IndexTest_SET_UP_MENU_ItemToSecondMenu', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startAbilityMine(SLOT_ID, undefined, PageUrl.PAGE_URL_MAIN);
      let firstItemView = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(firstItemView)).assertFalse();
      await firstItemView.click();
      await driver.delayMs(DELAY_TIME);
      await sendCommandHex(CommonTestHex.SELECT_ITEM);

      // click second menu
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);

      // click main menu
      backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('IndexTest_SELECT_ITEM_EndSession', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startSecondMenuPage();

      // click menu-->endSession
      let menuButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_MENU),
        DELAY_TIME_3000);
      HiLog.info('IndexMenuTest', 'EndSession test start');
      expect(CommonUtils.isEmptyObj(menuButton)).assertFalse();
      HiLog.info('IndexMenuTest', 'EndSession click more menu');
      await menuButton.click();
      await driver.delayMs(DELAY_TIME);

      let sessionButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(sessionButton)).assertFalse();
      HiLog.info('IndexMenuTest', 'EndSession click end session');
      await sessionButton.click();
      await sendEndSession();

      let navItem = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(navItem)).assertTrue();
      HiLog.info('IndexMenuTest', 'EndSession click then nav dismiss');

      let uiContext = ContextStorageHelper.getInstance().getEntryUiContext();
      expect(CommonUtils.isEmptyObj(uiContext)).assertTrue();
      HiLog.info('IndexMenuTest', 'EndSession click then ui context is empty');
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('IndexTest_SELECT_ITEM_Help', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startSecondMenuPage();

      // click menu-->help
      let menuButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_MENU),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(menuButton)).assertTrue();
      await menuButton.click();
      let helpButton = await driver.waitForComponent(ON.id(`${ViewId.NAV_BACK_MENU_ITEM_PRE}1`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(helpButton)).assertFalse();
      await helpButton.click();
      await sendEndSession();

      // click back
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('IndexTest_SELECT_ITEM_ItemToInput', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await startSecondMenuPage();

      // click item
      let itemView = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}1`),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(itemView)).assertTrue();
      await itemView.click();
      await driver.delayMs(DELAY_TIME);
      await sendCommandHex(CommonTestHex.GET_INPUT);
      await driver.delayMs(DELAY_TIME_1000);

      // back from inputPage
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await sendCommandHex(CommonTestHex.SELECT_ITEM)
      await driver.delayMs(DELAY_TIME_1000);

      // back from secondMenu
      backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await sendEndSession();

      // back from mainMenu
      backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('IndexTest_SELECT_ITEM_ItemToDialog', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_MENU);
      await driver.delayMs(DELAY_TIME_1000);
      await startSecondMenuPage();

      // click item
      let itemView = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(itemView)).assertTrue();
      await itemView.click();
      await sendEndSession();
      await sendCommandHex(CommonTestHex.DISPLAY_TEXT);

      // click confirmDialog confirm
      let confirmButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(confirmButton)).assertFalse();
      await confirmButton.click();
      await sendEndSession();
      await sendCommandHex(CommonTestHex.DISPLAY_TEXT_RESULT);

      // click resultDialog confirm
      confirmButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(confirmButton)).assertFalse();
      await confirmButton.click();
      await sendEndSession();
      await sendCommandHex(CommonTestHex.SELECT_ITEM);

      // back from secondMenu
      let backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);

      // back from mainMenu
      backButton = await driver.waitForComponent(ON.id(ViewId.NAV_BACK_BACK),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(backButton)).assertFalse();
      await backButton.click();
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}
