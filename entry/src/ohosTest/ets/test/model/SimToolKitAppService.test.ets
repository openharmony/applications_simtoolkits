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

import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import commonEventManager from '@ohos.commonEventManager';
import { afterAll, beforeAll, beforeEach, describe, expect, it } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { sendCommandHex, sendEndSession, setMock, sleep } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import HiLog from '../../../../main/ets/common/utils/HiLog';
import OhosTestUtils from '../OhosTestUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { HapInfo, ViewId } from '../../../../main/ets/common/constant/Constants';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { CommonTestHex } from '../constants/TestConstants';
import { DELAY_TIME_3000 } from '../constants/TestConstants';
import { CONFIRM_DIALOG_CANCEL_TEXT } from '../constants/TestConstants';
import { SLOT_ID } from '../constants/TestConstants';

const TAG = 'SimToolKitAppServiceTest';
const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function SimToolKitAppServiceTest(): void {
  describe('SimToolKitAppServiceTest', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      HiLog.info(TAG, `SimToolKitAppServiceTest : ${new Date().getTime()}`);
      OhosTestUtils.getInstance().saveTerminalResponseData('test');
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })

    it('SimToolKitAppServiceTest_SET_UP_IDLE_MODE_TEXT', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_IDLE_MODE_TEXT);
      expect(OhosTestUtils.getInstance().getLastTerminalResponseData() !== '').assertTrue();
      done();
    })
    it('SimToolKitAppServiceTest_SET_UP_EVENT_LIST', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.SET_UP_EVENT_LIST);
      expect(OhosTestUtils.getInstance().getLastTerminalResponseData() !== '').assertTrue();
      done();
    })
    it('SimToolKitAppServiceTest_PROVIDE_LOCAL_INFORMATION', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.PROVIDE_LOCAL_INFORMATION);
      expect(OhosTestUtils.getInstance().getLastTerminalResponseData() !== '').assertTrue();
      done();
    })
    it('SimToolKitAppServiceTest_OPEN_CHANNEL', 0, async (done: Function) => {
      await sendCommandHex(CommonTestHex.OPEN_CHANNEL);
      expect(OhosTestUtils.getInstance().getLastTerminalResponseData() !== '').assertTrue();
      done();
    })
    it('SimToolKitAppServiceTest_TEST_START_ABILITY_INKY', 0, async (done: Function) => {
      let testInkey: string = 'D0158103012200820281828D0A04456E74657220222B22';
      await sendCommandHex(testInkey);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CANCEL),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(button)).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitAppServiceTest_TEST_START_ABILITY_LAUNCHBROWSER', 0, async (done: Function) => {
      let testLaunchBrowser: string = 'D021810301150282028182310005104E6F742073656C66206578706C616E2E1E020101';
      await sendCommandHex(testLaunchBrowser);
      let cancelButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(cancelButton)).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_ALPHA_IDENTIFIER', 0, async (done: Function) => {
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      let data: Record<string, Object> = {
        'alphaString': 'ALPHA_IDENTIFIER',
        'slotId': SLOT_ID
      };
      let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
      await abilityDelegator.startAbility({
        bundleName: HapInfo.BUNDLE_NAME,
        abilityName: HapInfo.SERVICE_ABILITY_NAME,
        action: commonEventManager.Support.COMMON_EVENT_STK_ALPHA_IDENTIFIER,
        parameters: data
      });
      let sessionButton = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(sessionButton)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_CARD_STATE_CHANGED', 0, async (done: Function) => {
      let data: Record<string, Object> = {
        'cardStatus': 0,
        'slotId': SLOT_ID
      };
      let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
      await abilityDelegator.startAbility({
        bundleName: HapInfo.BUNDLE_NAME,
        abilityName: HapInfo.SERVICE_ABILITY_NAME,
        action: commonEventManager.Support.COMMON_EVENT_STK_CARD_STATE_CHANGED,
        parameters: data
      });
      await driver.delayMs(DELAY_TIME);
      expect(data !== undefined).assertTrue();
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_singleIcon', 0, async (done: Function) => {
      let singleIcon: string =
        'D03C810301250082028182850C546F6F6C6B6974204D656E758F07014974656D20318F07024974656D20328F07034974656D20339E0201019F0401050505';
      await sendCommandHex(singleIcon);
      let lastRespData: string | undefined = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `singleIcon lastRespData:${lastRespData}`);
      expect('810301250002028281830104' === lastRespData).assertTrue();

      let setupmenuNoIcon: string =
        'D03B810301250082028182850C546F6F6C6B6974204D656E758F07014974656D20318F07024974656D20328F07034974656D20338F07044974656D2034';
      await sendCommandHex(setupmenuNoIcon);
      lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `setupmenuNoIcon lastRespData:${lastRespData}`);
      expect('810301250002028281830100' === lastRespData).assertTrue();

      let multiIcon: string =
        'D03C810301250082028182850C546F6F6C6B6974204D656E758F07014974656D20318F07024974656D20328F07034974656D20339E0201019F0401050505';
      await sendCommandHex(multiIcon);
      lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `multiIcon lastRespData:${lastRespData}`);
      expect('810301250002028281830104' === lastRespData).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_withIconInkey', 0, async (done: Function) => {
      await driver.delayMs(DELAY_TIME);
      let withIconInkey: string = 'D0198103012200820281828D0A043C4E4F2D49434F4E3E1E020001';
      await sendCommandHex(withIconInkey);
      await driver.delayMs(DELAY_TIME);
      let input = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      await input.inputText('1');
      await driver.delayMs(DELAY_TIME);
      let submitbutton = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      await submitbutton.click();
      await driver.delayMs(DELAY_TIME);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `withIconInkey lastRespData:${lastRespData}`);
      expect('8103012200020282818301048D020431' === lastRespData).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_noIconInkey', 0, async (done: Function) => {
      let noIconInkey: string = 'D0158103012200820281828D0A04456E74657220222B22';
      await sendCommandHex(noIconInkey);
      await driver.delayMs(DELAY_TIME);
      let input = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      await input.inputText('1');
      await driver.delayMs(DELAY_TIME);
      let submitbutton = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      await submitbutton.click();
      await driver.delayMs(DELAY_TIME);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `noIconInput lastRespData:${lastRespData}`);
      expect('8103012200020282818301008D020431' === lastRespData).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_withIconInput', 0, async (done: Function) => {
      let withIconInput: string = 'D01D8103012300820281828D0A043C4E4F2D49434F4E3E9102000A1E020001';
      await sendCommandHex(withIconInput);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      await button.inputText('1');
      await driver.delayMs(DELAY_TIME);
      button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `withIconInput lastRespData:${lastRespData}`);
      expect('8103012300020282818301048D020431' === lastRespData).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_noIconInput', 0, async (done: Function) => {
      let noIconInput: string = 'D01B8103012300820281828D0C04456E74657220313233343591020505';
      await sendCommandHex(noIconInput);
      await driver.delayMs(DELAY_TIME);
      let button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_TEXT_INPUT),
        DELAY_TIME_3000);
      await button.inputText('12345');
      await driver.delayMs(DELAY_TIME);
      button = await driver.waitForComponent(ON.id(ViewId.INPUT_PAGE_CONFIRM),
        DELAY_TIME_3000);
      await button.click();
      await driver.delayMs(DELAY_TIME);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `noIconInput lastRespData:${lastRespData}`);
      expect('8103012300020282818301008D06043132333435' === lastRespData).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_selectIconItem', 0, async (done: Function) => {
      let selectIconItem: string =
        'D03E810301240082028182850E546F6F6C6B69742053656C6563748F07014974656D20318F07024974656D20328F07034974656D20339E0201019F0401050505';
      await sendCommandHex(selectIconItem);
      await driver.delayMs(DELAY_TIME);
      let firstItemView = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}0`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(firstItemView)).assertFalse();
      await firstItemView.click();
      await driver.delayMs(DELAY_TIME);
      await sendEndSession();
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      expect('810301240002028281830104900101' === lastRespData).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_selectNoIconItem', 0, async (done: Function) => {
      let selectNoIconItem: string =
        'D03D810301240082028182850E546F6F6C6B69742053656C6563748F07014974656D20318F07024974656D20328F07034974656D20338F07044974656D2034';
      await sendCommandHex(selectNoIconItem);
      await driver.delayMs(DELAY_TIME);
      let firstItemView = await driver.waitForComponent(ON.id(`${ViewId.INDEX_PAGE_ITEM_PRE}1`),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(firstItemView)).assertFalse();
      await firstItemView.click();
      await driver.delayMs(DELAY_TIME);
      await sendEndSession();
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      expect('810301240002028281830100900102' === lastRespData).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_idleModeIcon', 0, async (done: Function) => {
      let idleModeIcon: string = 'D0198103012800820281828D0A0449646C6520746578749E020001';
      await sendCommandHex(idleModeIcon);
      await driver.delayMs(DELAY_TIME);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `idleModeIcon lastRespData:${lastRespData}`);
      expect('810301280002028281830104' === lastRespData).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_idleModeNoIcon', 0, async (done: Function) => {
      let idleModeNoIcon: string = 'D01A8103012800820281828D0F0449646C65204D6F64652054657874';
      await sendCommandHex(idleModeNoIcon);
      await driver.delayMs(DELAY_TIME);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `idleModeNoIcon lastRespData:${lastRespData}`);
      expect('810301280002028281830100' === lastRespData).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_toneWithIcon', 0, async (done: Function) => {
      let toneWithIcon: string = 'D022810301200082028103850C3C42415349432D49434F4E3E8E0111840201021E020001';
      await sendCommandHex(toneWithIcon);
      await driver.delayMs(DELAY_TIME_3000);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `toneWithIcon lastRespData:${lastRespData}`);
      expect('810301200002028281830104' === lastRespData).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('SimToolKitInputTest_IconLoad_Resp_toneNoIcon', 0, async (done: Function) => {
      let toneNoIcon: string = 'D01A8103012000820281038508506F7369746976658E011184020102';
      await sendCommandHex(toneNoIcon);
      await driver.delayMs(DELAY_TIME_3000);
      let lastRespData = OhosTestUtils.getInstance().getLastTerminalResponseData();
      HiLog.info('SimToolKitInputTest_IconLoad_Resp', `toneNoIcon lastRespData:${lastRespData}`);
      expect('810301200002028281830100' === lastRespData).assertTrue();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}