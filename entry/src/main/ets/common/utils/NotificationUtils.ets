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

import { common } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { BusinessError, commonEventManager, power, screenLock } from '@kit.BasicServicesKit';
import CommonUtils from './CommonUtils';
import HiLog from './HiLog';
import UiUtils from './UiUtils';
import { HapInfo, SimId } from '../constant/Constants';
import { UpParamsCacheUtils } from './UpParamsCacheUtils';
import { ScreenUnlockedListener } from '../../model/ScreenUnlockedListener';
import { AppStorageHelper, AppStorageKey } from '../helper/AppStorageHelper';
import { BaseUpParams } from '../../model/upDecode/BaseUpParams';

const TAG = 'NotificationUtils';
const NOTIFICATION_KEYGUARD_ID = 100;
const NOTIFICATION_ID = 200;
const NOTIFICATION_LABEL = 'simToolKit_Notification';
const GROUP_NAME = 'simToolKit';

export default class NotificationUtils {
  public static startNotification(context: common.Context | undefined, title: string, text: string, slotId: number,
    isOnKeyguard: boolean): void {
    if (!context) {
      HiLog.error(TAG, 'startNotification context is undefined');
      return;
    }
    if (CommonUtils.isEmptyStr(text)) {
      HiLog.warn(TAG, 'startNotification text is null');
      NotificationUtils.clearNotification(slotId, isOnKeyguard);
      return;
    }
    HiLog.info(TAG, 'startNotification start');
    let notificationRequest: notificationManager.NotificationRequest = {
      content: {
        notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: {
          title: NotificationUtils.getNotificationTitle(context, title),
          text: text
        }
      },
      isFloatingIcon: true,
      id: NotificationUtils.getNotificationId(slotId, isOnKeyguard),
      notificationSlotType: notificationManager.SlotType.SERVICE_INFORMATION,
      groupName: GROUP_NAME,
      label: NOTIFICATION_LABEL,
      deliveryTime: new Date().getTime(),
      tapDismissed: false
    };
    notificationManager.publish(notificationRequest).then(() => {
      HiLog.info(TAG, 'startNotification publish success');
    }).catch((err: BusinessError) => {
      HiLog.error(TAG, `startNotification publish failed. Error code: ${err?.code}, message: ${err?.message}`);
    });
  }

  private static getNotificationTitle(context: common.Context, title: string): string {
    if (CommonUtils.isEmptyStr(title)) {
      HiLog.info(TAG, 'getNotificationTitle use default title');
      return UiUtils.getStringSync(context, $r('app.string.new_incoming_message').id) ?? '';
    }
    return title;
  }

  private static getNotificationId(slotId: number, isOnKeyguard: boolean): number {
    return (isOnKeyguard ? NOTIFICATION_KEYGUARD_ID : NOTIFICATION_ID) + slotId;
  }

  public static clearNotification(slotId: number, isOnKeyguard: boolean): void {
    let notiId: number = NotificationUtils.getNotificationId(slotId, isOnKeyguard);
    HiLog.info(TAG, `clearNotification on slotId:${slotId} isOnKeyguard:${isOnKeyguard}`);
    notificationManager.cancel(notiId, NOTIFICATION_LABEL).then(() => {
      HiLog.info(TAG, 'cancel noti ok');
    }).catch((err: BusinessError) => {
      HiLog.error(TAG, `cancel noti failed. Error code: ${err?.code}, message: ${err?.message}`);
    });
  }

  public static resetNotifyResponseFromUser(slotId: number): void {
    AppStorageHelper.set<boolean>(`${AppStorageKey.NOTIFY_HAS_RESPONSE_FROM_USER_KEY}${slotId}`, true);
  }

  public static setNotifyHasResponseFromUser(slotId: number, isResponseTimeOut: boolean): void {
    if (isResponseTimeOut) {
      NotificationUtils.clearNotification(SimId.SLOT_ID_0, true);
      NotificationUtils.clearNotification(SimId.SLOT_ID_1, true);
    }
    AppStorageHelper.set<boolean>(`${AppStorageKey.NOTIFY_HAS_RESPONSE_FROM_USER_KEY}${slotId}`, !isResponseTimeOut);
  }

  public static notifyUserOnKeyguard(
    serviceContext: common.ServiceExtensionContext | undefined, slotId: number, message: string,
    curParam?: BaseUpParams): void {
    if (serviceContext === undefined) {
      return;
    }
    let isResponseFromUser =
      AppStorageHelper.get<boolean>(`${AppStorageKey.NOTIFY_HAS_RESPONSE_FROM_USER_KEY}${slotId}`, true);
    if (!isResponseFromUser) {
      HiLog.info(TAG, 'notifyUserOnKeyguard is not show');
      return;
    }
    try {
      power.wakeup(HapInfo.BUNDLE_NAME);
    } catch (error) {
      HiLog.error(TAG, `wakeup error: ${error?.code} ${error?.message}`);
    }
    if (screenLock.isLocked()) {
      let titleStr = UpParamsCacheUtils.getInstance().getSimTitle(slotId);
      if (titleStr === undefined || titleStr === null || titleStr.length === 0) {
        titleStr = UiUtils.getPageTitle(serviceContext, slotId);
      }
      NotificationUtils.startNotification(serviceContext, titleStr, message, slotId, true);
      ScreenUnlockedListener.getInstance().addScreenUnlockedListener(slotId, () => {
        NotificationUtils.clearNotification(slotId, true);
      });
    }
  }
}