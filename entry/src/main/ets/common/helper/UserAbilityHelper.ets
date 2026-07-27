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

import { BusinessError } from '@kit.BasicServicesKit';
import { SimId } from '../constant/Constants';
import HiLog from '../utils/HiLog';
import { inputMonitor, TouchEvent } from '@kit.InputKit';

const TAG = 'UserAbilityHelper';

export class UserAbilityHelper {
  private static instance: UserAbilityHelper;
  private userAbilityListenerArr: Array<(((slotId: number) => void) | undefined)> = [undefined, undefined];
  private receiver: inputMonitor.TouchEventReceiver | undefined = undefined;

  public static getInstance(): UserAbilityHelper {
    if (!UserAbilityHelper.instance) {
      HiLog.info(TAG, 'UserAbilityHelper getInstance init');
      UserAbilityHelper.instance = new UserAbilityHelper();
    }
    return UserAbilityHelper.instance;
  }

  private constructor() {
  }

  public registerListener(slotId: number, callBack: (slotId: number) => void): void {
    HiLog.info(TAG, `registerListener  slotId:${slotId}`);
    if (slotId !== SimId.SLOT_ID_0 && slotId !== SimId.SLOT_ID_1) {
      return;
    }
    if (callBack === undefined || callBack === null) {
      return;
    }
    this.userAbilityListenerArr[slotId] = callBack;
    this.registerTouchListenerInner();
  }

  private registerTouchListenerInner(): void {
    if (this.receiver) {
      return;
    }
    try {
      this.receiver = (touchEvent: TouchEvent): boolean => {
        this.onUserAbility();
        return false;
      };
      inputMonitor.on('touch', this.receiver);
    } catch (paramError) {
      let error = paramError as BusinessError;
      HiLog.info(TAG, `[registerListenerInner] error: ${error.code}, ${error.message} `);
    }
  }

  private onUserAbility(): void {
    this.userAbilityListenerArr[SimId.SLOT_ID_0]?.(SimId.SLOT_ID_0);
    this.userAbilityListenerArr[SimId.SLOT_ID_1]?.(SimId.SLOT_ID_1);
    this.userAbilityListenerArr[SimId.SLOT_ID_0] = undefined;
    this.userAbilityListenerArr[SimId.SLOT_ID_1] = undefined;
    this.unRegisterTouchListenerInner();
  }

  private unRegisterTouchListenerInner(): void {
    if (!this.receiver) {
      return;
    }
    try {
      inputMonitor.off('touch', this.receiver);
      this.receiver = undefined;
    } catch (paramError) {
      let error = paramError as BusinessError;
      HiLog.info(TAG, `[unRegisterTouchListenerInner] error: ${error.code}, ${error.message} `);
    }
  }
}