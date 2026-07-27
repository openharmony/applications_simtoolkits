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

import HiLog from '../common/utils/HiLog';
import { sim } from '@kit.TelephonyKit';

const TAG = 'TsManager';

export function sendCallSetupRequest(slotId: number, isAccept: boolean): void {
  HiLog.info(TAG, `sendCallSetupRequest slotId:${slotId}   isAccept:${isAccept}`);
  try {
    if (isAccept) {
      // @ts-expect-error: not have .ts interface
      sim.acceptCallSetupRequest(slotId).then(value => {
        HiLog.info(TAG, `acceptCallSetupRequest success slotId: ${slotId}`);
      }).catch((error) => {
        HiLog.error(TAG, `acceptCallSetupRequest error slotId: ${slotId}`);
      });
    } else {
      // @ts-expect-error:  not have .ts interface
      sim.rejectCallSetupRequest(slotId).then(value => {
        HiLog.info(TAG, `rejectCallSetupRequest success slotId: ${slotId}`);
      }).catch((error) => {
        HiLog.error(TAG, `rejectCallSetupRequest error slotId: ${slotId}`);
      });
    }
  } catch (error) {
    HiLog.error(TAG, `sendCallSetupRequest --error: ${error?.code}, ${error?.message}`);
  }
}

export function getSimLabelIndex(slotId: number): number {
  try {
    let simLabelIndex = sim.getSimLabelSync(slotId)?.index ?? 1;
    return simLabelIndex;
  } catch (err) {
    HiLog.error(TAG, `getSimLabelIndex error:${err?.code}, ${err?.message}`);
    return 1;
  }
}