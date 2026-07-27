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

import { commonEventManager } from '@kit.BasicServicesKit';
import HiLog from '../common/utils/HiLog';
import { SimId } from '../common/constant/Constants';

const TAG = 'ScreenUnlockedListener';

export class ScreenUnlockedListener {
  private static instance: ScreenUnlockedListener;
  private commonEventSubscriber: commonEventManager.CommonEventSubscriber | undefined = undefined;
  private screenUnlockedListenerArray: Array<Array<() => void>> = [[], []];

  public static getInstance(): ScreenUnlockedListener {
    if (!ScreenUnlockedListener.instance) {
      HiLog.info(TAG, 'ScreenUnlockedListener getInstance init');
      ScreenUnlockedListener.instance = new ScreenUnlockedListener();
    }
    return ScreenUnlockedListener.instance;
  }

  private constructor() {
  }

  public addScreenUnlockedListener(slotId: number, callBack: () => void): void {
    HiLog.info(TAG, `ScreenUnlockedListener  slotId:${slotId}`);
    this.screenUnlockedListenerArray[slotId].push(callBack);
    this.registerScreenUnlocked();
  }

  private registerScreenUnlocked(): void {
    if (this.commonEventSubscriber) {
      return;
    }
    let subscribeInfo: commonEventManager.CommonEventSubscribeInfo = {
      events: [commonEventManager.Support.COMMON_EVENT_SCREEN_UNLOCKED]
    };
    commonEventManager.createSubscriber(subscribeInfo).then(data => {
      this.commonEventSubscriber = data;
      commonEventManager.subscribe(data, (err, data) => {
        if (err) {
          HiLog.error(TAG, '[screenUnlockedListener] error');
          return;
        }
        this.screenUnlockedListener();
      });
    });
  }

  private screenUnlockedListener(): void {
    this.onScreenUnlocked(SimId.SLOT_ID_0);
    this.onScreenUnlocked(SimId.SLOT_ID_1);
    this.unRegisterScreenUnlocked();
  }

  private unRegisterScreenUnlocked(): void {
    if (!this.commonEventSubscriber) {
      return;
    }
    commonEventManager.unsubscribe(this.commonEventSubscriber);
    this.commonEventSubscriber = undefined;
  }

  private onScreenUnlocked(slotId: number): void {
    this.screenUnlockedListenerArray[slotId].forEach(value => {
      value();
    });
    this.screenUnlockedListenerArray[slotId] = [];
  }
}