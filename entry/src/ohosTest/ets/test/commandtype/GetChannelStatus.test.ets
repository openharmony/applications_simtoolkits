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
import { Driver } from '@ohos.UiTest';
import { ParseParamData, setMock, sleep } from '../TestUtils';
import { UpDecodeFactory } from '../../../../main/ets/model/upDecode/UpDecodeFactory';
import { CommandType, ResponseCode } from '../../../../main/ets/common/constant/SimToolKitConstant';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { abilityDelegatorRegistry } from '@kit.TestKit';

const driver: Driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

export default function GetChannelStatusTest(): void {
  describe('GetChannelStatusTest', () => {
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

    it('GetChannelStatusTest_test', 0, async (done: Function, data: ParseParamData) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(data.commandHex, 0);
      let isSuccess =
        upParam?.commandType === CommandType.GET_CHANNEL_STATUS && upParam?.parseResultCode === ResponseCode.OK;
      expect(isSuccess).assertTrue();
      done();
    })
  })
}
