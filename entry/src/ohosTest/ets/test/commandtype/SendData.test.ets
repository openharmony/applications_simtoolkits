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
  DELAY_TIME, DELAY_TIME_1000
} from '../constants/TestConstants';
import { UpDecodeFactory } from '../../../../main/ets/model/upDecode/UpDecodeFactory';
import { CommandType, ResponseCode } from '../../../../main/ets/common/constant/SimToolKitConstant';
import { ViewId } from '../../../../main/ets/common/constant/Constants';
import { abilityDelegatorRegistry } from '@kit.TestKit';

const driver: Driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();
const SEND_DATA_SHOW_TOAST = 'D016810301430182028121850B53656E6420446174612031';
const SEND_DATA_SHOW_TOAST_DEFAULT_TEXT = 'D00C8103014301820281218501FF';
const SEND_DATA_LENGTH_0 = 'D00B8103014301820281218500';
const SEND_DATA_NOT_TAG = 'D009810301430182028121';

export default function SendDataTest(): void {
  describe('SendDataTest', () => {
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

    it('SendDataTest_test', 0, async (done: Function, data: ParseParamData) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(data.commandHex, 0);
      let isSuccess =
        upParam?.commandType === CommandType.SEND_DATA && upParam?.parseResultCode === ResponseCode.OK;
      expect(isSuccess).assertTrue();
      done();
    })

    //show toast
    it('SendDataTest_show_toast', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(SEND_DATA_SHOW_TOAST, 0);
      await driver.assertComponentExist(ON.text('Send Data 1'));
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(SEND_DATA_SHOW_TOAST_DEFAULT_TEXT, 0);
      await driver.assertComponentExist(ON.text('正在发送数据'));
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    //not show toast
    it('SendDataTest_not_show_dialog', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(SEND_DATA_NOT_TAG, 0);
      let toastText = await driver.findComponent(ON.id(ViewId.TOAST_DIALOG_TEXT));
      expect(CommonUtils.isEmptyObj(toastText)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(SEND_DATA_LENGTH_0, 0);
      toastText = await driver.findComponent(ON.id(ViewId.TOAST_DIALOG_TEXT));
      expect(CommonUtils.isEmptyObj(toastText)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      expect('').assertEqual(OhosTestUtils.getInstance().getLastTerminalResponseData());

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}
