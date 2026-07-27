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

import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import HiLog from './HiLog';

const TAG = 'BackgroundTaskRequestUtils';

export class BackgroundTaskRequestUtils {
  private static instance: BackgroundTaskRequestUtils;
  private preDelayTime: number = 0;
  public static DELAY_TIME_MINUTES_1: number = 60000;
  public static DELAY_TIME_MINUTES_5: number = 300000;
  public static DELAY_TIME_MILLISECONDS_10: number = 10000;

  public static getInstance(): BackgroundTaskRequestUtils {
    if (!BackgroundTaskRequestUtils.instance) {
      HiLog.info(TAG, 'BackgroundTaskRequestUtils getInstance init');
      BackgroundTaskRequestUtils.instance = new BackgroundTaskRequestUtils();
    }
    return BackgroundTaskRequestUtils.instance;
  }

  private constructor() {
  }

  /**
   * request CPU resource, delay time >= pre delay time.
   *
   * @param delayTime number
   */
  public applyEfficiencyResourcesGreaterThanPre(delayTime: number): void {
    let curDelayTime = delayTime < this.preDelayTime ? this.preDelayTime : delayTime;
    this.preDelayTime = curDelayTime;
    this.applyEfficiencyResources(curDelayTime);
  }

  /**
   * request CPU resource.
   *
   * @param delayTime number
   */
  public applyEfficiencyResources(delayTime: number): void {
    HiLog.info(TAG, `BackgroundTaskRequestUtils applyEfficiencyResources delayTime: ${delayTime}`);
    this.preDelayTime = delayTime;
    let request: backgroundTaskManager.EfficiencyResourcesRequest = {
      resourceTypes: backgroundTaskManager.ResourceType.TIMER | backgroundTaskManager.ResourceType.CPU,
      isApply: true,
      timeOut: delayTime,
      reason: 'com.ohos.simtoolkits',
      isPersist: false,
      isProcess: false,
    };
    try {
      backgroundTaskManager.applyEfficiencyResources(request);
      HiLog.info(TAG, 'applyEfficiencyResources success.');
    } catch (error) {
      HiLog.error(TAG, 'applyEfficiencyResources failed.');
    }
  }

  /**
   * reset CPU resource.
   */
  public resetAllEfficiencyResources(): void {
    try {
      backgroundTaskManager.resetAllEfficiencyResources();
      HiLog.info(TAG, 'resetAllEfficiencyResources success.');
    } catch (error) {
      HiLog.error(TAG, 'resetAllEfficiencyResources failed.');
    }
  }
}