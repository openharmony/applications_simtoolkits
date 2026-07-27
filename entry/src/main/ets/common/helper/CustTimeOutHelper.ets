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

import { systemDateTime, systemTimer } from '@kit.BasicServicesKit';
import HiLog from '../utils/HiLog';
import CommonUtils from '../utils/CommonUtils';
import { BackgroundTaskRequestUtils } from '../utils/BackgroundTaskRequestUtils';
import { ContextStorageHelper } from '../utils/ContextStorageHelper';

const TAG = 'CustTimeOutHelper';

export class CustTimeOutHelper {
  private static instance: CustTimeOutHelper;

  public static getInstance(): CustTimeOutHelper {
    if (!CustTimeOutHelper.instance) {
      HiLog.info(TAG, 'CustTimeOutHelper getInstance init');
      CustTimeOutHelper.instance = new CustTimeOutHelper();
    }
    return CustTimeOutHelper.instance;
  }

  private constructor() {
  }

  public setTimeOutCust(handler: () => void, delay: number): number {
    if (ContextStorageHelper.getInstance().getServiceContext() === undefined &&
      ContextStorageHelper.getInstance().getEntryUiContext() !== undefined) {
      CommonUtils.startServiceExtensionAbility(ContextStorageHelper.getInstance().getEntryUiContext());
    }
    let curDelayTime = delay;
    if (curDelayTime < BackgroundTaskRequestUtils.DELAY_TIME_MINUTES_1) {
      curDelayTime = BackgroundTaskRequestUtils.DELAY_TIME_MINUTES_1;
    }
    BackgroundTaskRequestUtils.getInstance().applyEfficiencyResourcesGreaterThanPre(curDelayTime);
    return setTimeout(handler, delay);
  }

  public async setTimeOutCustAsync(handler: () => void, delay: number): Promise<number> {
    if (ContextStorageHelper.getInstance().getServiceContext() === undefined &&
      ContextStorageHelper.getInstance().getEntryUiContext() !== undefined) {
      CommonUtils.startServiceExtensionAbility(ContextStorageHelper.getInstance().getEntryUiContext());
    }
    let curDelayTime = delay;
    if (curDelayTime < BackgroundTaskRequestUtils.DELAY_TIME_MINUTES_1) {
      curDelayTime = BackgroundTaskRequestUtils.DELAY_TIME_MINUTES_1;
    }
    BackgroundTaskRequestUtils.getInstance().applyEfficiencyResourcesGreaterThanPre(curDelayTime);
    return await this.startSystemTimer(handler, delay);
  }

  async startSystemTimer(handler: () => void, delay: number): Promise<number> {
    let options: systemTimer.TimerOptions = {
      type: systemTimer.TIMER_TYPE_WAKEUP | systemTimer.TIMER_TYPE_REALTIME | systemTimer.TIMER_TYPE_EXACT,
      callback: handler,
      repeat: false
    };
    let timerId = -1;
    try {
      timerId = await systemTimer.createTimer(options);
      HiLog.info(TAG, `creating timerId: ${timerId}`);
      let triggerTime = systemDateTime.getUptime(systemDateTime.TimeType.STARTUP);
      await systemTimer.startTimer(timerId, triggerTime + delay);
    } catch (error) {
      HiLog.error(TAG, `Failed to create timer. message:${error?.message} code:${error?.code}`);
    }
    return timerId;
  }

  async stopSystemTimer(timerId: number): Promise<void> {
    HiLog.info(TAG, `stop timerId:${timerId}`);
    if (timerId > 0) {
      try {
        await systemTimer.stopTimer(timerId);
        await systemTimer.destroyTimer(timerId);
      } catch (error) {
        HiLog.error(TAG, `Failed to destroyTimer. message:${error?.message} code:${error?.code}`);
      }
    }
  }
}