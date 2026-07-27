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

import sim from '@ohos.telephony.sim';
import HiLog from '../../../main/ets/common/utils/HiLog';
import OhosTestUtils from '../../../ohosTest/ets/test/OhosTestUtils';

const TAG = 'simMocker';

export enum SimStateCust {
  SIM_STATE_UNKNOWN,
  SIM_STATE_NOT_PRESENT,
  SIM_STATE_LOCKED,
  SIM_STATE_NOT_READY,
  SIM_STATE_READY,
  SIM_STATE_LOADED
}

const simMocker: Record<string, Object> = {
  'getSimState': (slotId: number): Promise<sim.SimState> => {
    HiLog.info(TAG, `simMocker getSimState slotId:${slotId}`);
    if (OhosTestUtils.getInstance().getMockReturnSimStateLoaded()) {
      return Promise.resolve(sim.SimState.SIM_STATE_LOADED);
    } else {
      return Promise.resolve(sim.SimState.SIM_STATE_UNKNOWN);
    }
  },
  'sendTerminalResponseCmd': (slotId: number, cmd: string): Promise<void> => {
    HiLog.info(TAG, `simMocker sendTerminalResponseCmd slotId:${slotId}`);
    OhosTestUtils.getInstance().saveTerminalResponseData(cmd);
    return Promise.resolve();
  },
  'sendEnvelopeCmd': (slotId: number, cmd: string): Promise<void> => {
    HiLog.info(TAG, `simMocker sendEnvelopeCmd slotId:${slotId}`);
    OhosTestUtils.getInstance().saveMenuSelectionEnvelopeRespData(cmd);
    return Promise.resolve();
  },
  'getMaxSimCount': (): number => {
    return 2;
  },
  'SimState': SimStateCust
};

export default simMocker;
