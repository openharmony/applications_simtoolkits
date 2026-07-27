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

import { describe, it, expect, afterAll, beforeAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import { ParseParamData, sendCommandHex, setMock, sleep } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import OhosTestUtils from '../OhosTestUtils';
import {
  CONFIRM_DIALOG_CANCEL_TEXT,
  CONFIRM_DIALOG_CONFIRM_TEXT,
  DELAY_TIME,
  DELAY_TIME_1000,
  DELAY_TIME_SECONDS_60
} from '../constants/TestConstants';
import { UpDecodeFactory } from '../../../../main/ets/model/upDecode/UpDecodeFactory';
import { CommandType, ResponseCode } from '../../../../main/ets/common/constant/SimToolKitConstant';
import HiLog from '../../../../main/ets/common/utils/HiLog';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { OpenChannelConstants } from '../constants/CommandTypetConstants';

const driver: Driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function OpenChannelTest(): void {
  describe('OpenChannelTest', () => {
    beforeAll(async (done: Function) => {
      await driver.pressHome();
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })

    it('OpenChannelTest_test', 0, async (done: Function, data: ParseParamData) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(data.commandHex, 0);
      let isSuccess =
        upParam?.commandType === CommandType.OPEN_CHANNEL && upParam?.parseResultCode === ResponseCode.OK;
      if (!isSuccess) {
        HiLog.error('OpenChannelTest', `OpenChannelTest_test parse erro commandHex:${data.commandHex}`);
      }
      expect(isSuccess).assertTrue();
      done();
    })

    // open_channel show dialog
    it('OpenChannelTest_show_dialog_en', 0, async (done: Function) => {
      // confirm
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_SHOW_DIALOG, 0);
      await driver.assertComponentExist(ON.text('Open Channel for UICC?'));
      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(OpenChannelConstants.OPEN_CHANNEL_DIALOG_CONFIRM)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      // cancel
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_SHOW_DIALOG, 0);
      await driver.assertComponentExist(ON.text('Open Channel for UICC?'));
      let cancelButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT));
      expect(!CommonUtils.isEmptyObj(cancelButton)).assertTrue();
      await cancelButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(OpenChannelConstants.OPEN_CHANNEL_DIALOG_CANCEL)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      // time out
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_SHOW_DIALOG, 0);
      await driver.assertComponentExist(ON.text('Open Channel for UICC?'));
      await driver.delayMs(DELAY_TIME_SECONDS_60 + DELAY_TIME);
      expect(OpenChannelConstants.OPEN_CHANNEL_DIALOG_TIMEOUT)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // open_channel show dialog
    it('OpenChannelTest_show_dialog_zh', 0, async (done: Function) => {
      // confirm
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_SHOW_DIALOG_DEFAULT_TEXT, 0);
      await driver.assertComponentExist(ON.text('是否打开通道？'));
      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(!CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(OpenChannelConstants.OPEN_CHANNEL_DIALOG_CONFIRM)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      // cancel
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_SHOW_DIALOG_DEFAULT_TEXT, 0);
      await driver.assertComponentExist(ON.text('是否打开通道？'));
      let cancelButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT));
      expect(!CommonUtils.isEmptyObj(cancelButton)).assertTrue();
      await cancelButton.click();
      await driver.delayMs(DELAY_TIME);
      expect(OpenChannelConstants.OPEN_CHANNEL_DIALOG_CANCEL)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      // time out
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_SHOW_DIALOG_DEFAULT_TEXT, 0);
      await driver.assertComponentExist(ON.text('是否打开通道？'));
      await driver.delayMs(DELAY_TIME_SECONDS_60 + DELAY_TIME);
      expect(OpenChannelConstants.OPEN_CHANNEL_DIALOG_TIMEOUT)
        .assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // open_channel not show dialog
    it('OpenChannelTest_not_show_dialog', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_NOT_TAG, 0);
      let confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(OpenChannelConstants.OPEN_CHANNEL_LENGTH_0, 0);
      confirmButton = await driver.findComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT));
      expect(CommonUtils.isEmptyObj(confirmButton)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}
