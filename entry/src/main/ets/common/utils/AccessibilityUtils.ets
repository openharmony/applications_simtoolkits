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


import { accessibility } from '@kit.AccessibilityKit';
import { HapInfo } from '../constant/Constants';
import HiLog from './HiLog';

const TAG = 'AccessibilityUtils';
const DELAY_TIME = 300;

export class AccessibilityUtils {
  private static instance: AccessibilityUtils;
  private destroyTime: number = 0;

  private constructor() {
  }

  public static getInstance(): AccessibilityUtils {
    if (!AccessibilityUtils.instance) {
      AccessibilityUtils.instance = new AccessibilityUtils();
    }
    return AccessibilityUtils.instance;
  }

  public isStartAccessibility(): boolean {
    let isOpenAccessibility = accessibility.isOpenAccessibilitySync();
    let isOpenTouchGuide = accessibility.isOpenTouchGuideSync();
    return isOpenAccessibility && isOpenTouchGuide;
  }

  public setDialogDestroyTime(): void {
    this.destroyTime = new Date().getTime();
  }

  public sendAccessibilityEvent(id: string, isDelay: boolean): void {
    HiLog.info(TAG, `start sendAccessibilityEvent`);
    if (isDelay) {
      let nowTime = new Date().getTime();
      if (nowTime - this.destroyTime <= DELAY_TIME) {
        return;
      }
    }
    if (!this.isStartAccessibility()) {
      return;
    }
    let eventInfo: accessibility.EventInfo = ({
      type: 'requestFocusForAccessibility',
      bundleName: HapInfo.BUNDLE_NAME,
      triggerAction: 'common',
      customId: id
    });
    HiLog.info(TAG, 'start accessibility.sendAccessibilityEvent');
    accessibility.sendAccessibilityEvent(eventInfo).then(() => {
      HiLog.info(TAG, 'sendAccessibilityEvent success');
    });
  }
}