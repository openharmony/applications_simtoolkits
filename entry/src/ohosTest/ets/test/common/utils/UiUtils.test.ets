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

import { describe, it, expect, afterAll, beforeEach, beforeAll } from '@ohos/hypium'
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import Want from '@ohos.app.ability.Want';
import HiLog from '../../../../../main/ets/common/utils/HiLog';
import UiUtils from '../../../../../main/ets/common/utils/UiUtils';
import { sendCommandHex, setMock, sleep } from '../../TestUtils';
import { Driver, ON } from '@ohos.UiTest';
import CommonUtils from '../../../../../main/ets/common/utils/CommonUtils';
import { DELAY_TIME_3000 } from '../../constants/TestConstants';
import { DELAY_TIME } from '../../constants/TestConstants';
import { CONFIRM_DIALOG_CANCEL_TEXT } from '../../constants/TestConstants';
import { CommonTestHex } from '../../constants/TestConstants';
import { DELAY_TIME_1000 } from '../../constants/TestConstants';
import { HapInfo } from '../../../../../main/ets/common/constant/Constants';

const TAG: string = 'UiUtilsTest';
const driver = Driver.create();
const abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();

export default function UiUtilsTest() {
  describe('HWSIMTOOLKITS_FUNCTION_UiUtils', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(() => {
      HiLog.info(TAG, 'UiUtilsTest beforeEach');
      HiLog.info(TAG, `UiUtilsTest : ${new Date().getTime()}`);
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })
    it('HWSIMTOOLKITS_FUNCTION_UiUtils_start_service', 0, async (done: Function) => {
      HiLog.info(TAG, 'HWSIMTOOLKITS_FUNCTION_UiUtils_000 test start service from UiUtils');
      const testServiceWant: Want = {
        bundleName: HapInfo.BUNDLE_NAME,
        abilityName: HapInfo.SERVICE_ABILITY_NAME,
        parameters: {
          'test': 0
        }
      };
      let abilityDelegator = AbilityDelegatorRegistry.getAbilityDelegator();
      await abilityDelegator.startAbility(testServiceWant);
      expect(testServiceWant != undefined).assertTrue();
      done();
    });
    it('HWSIMTOOLKITS_FUNCTION_UiUtils_backPress_fail', 0, async (done: Function) => {
      HiLog.info(TAG, 'HWSIMTOOLKITS_FUNCTION_UiUtils_001 transBackPressToDialog empty');
      let isNeedTransBackPressToDialog: boolean = UiUtils.isNeedTransBackPressToDialog();
      HiLog.info(TAG, `HWSIMTOOLKITS_FUNCTION_UiUtils_001 get:${isNeedTransBackPressToDialog}`);
      expect(isNeedTransBackPressToDialog).assertFalse();
      HiLog.info(TAG, 'HWSIMTOOLKITS_FUNCTION_UiUtils_001 end');
      await driver.pressBack();
      done();
    });
    it('HWSIMTOOLKITS_FUNCTION_UiUtils_backPress', 0, async (done: Function) => {
      HiLog.info(TAG, 'HWSIMTOOLKITS_FUNCTION_UiUtils_002 transBackPressToDialog when only show dialog');
      let dialogCmd: string = CommonTestHex.DISPLAY_TEXT;
      await sendCommandHex(dialogCmd); // monitor show dialog

      let cancelBtn = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
        DELAY_TIME_3000);
      HiLog.info(TAG, `HWSIMTOOLKITS_FUNCTION_UiUtils_002 has cancelBtn:${cancelBtn}`);
      expect(!CommonUtils.isEmptyObj(cancelBtn)).assertTrue();

      let isNeedTransBackPressToDialog: boolean = UiUtils.isNeedTransBackPressToDialog();
      HiLog.info(TAG, `HWSIMTOOLKITS_FUNCTION_UiUtils_002 needTrans1:${isNeedTransBackPressToDialog}`);
      expect(isNeedTransBackPressToDialog).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      isNeedTransBackPressToDialog = UiUtils.isNeedTransBackPressToDialog();
      HiLog.info(TAG, `HWSIMTOOLKITS_FUNCTION_UiUtils_002 needTrans2:${isNeedTransBackPressToDialog}`);
      expect(isNeedTransBackPressToDialog).assertFalse();

      HiLog.info(TAG, 'HWSIMTOOLKITS_FUNCTION_UiUtils_002 end');
      await driver.pressBack();
      done();
    });
  })
}