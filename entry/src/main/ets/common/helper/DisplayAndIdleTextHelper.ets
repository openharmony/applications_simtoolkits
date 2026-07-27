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

import { settings } from '@kit.BasicServicesKit';
import { DisplayTextParam } from '../../model/upDecode/DisplayTextParam';
import { AppStorageHelper, AppStorageKey } from './AppStorageHelper';
import NotificationUtils from '../utils/NotificationUtils';
import UiUtils from '../utils/UiUtils';
import { SimToolKitAppService } from '../../model/SimToolKitAppService';
import { FromPageFlag } from '../../model/UIResponseData';
import { UIResponseCode } from '../constant/SimToolKitConstant';
import { sharedPreferencesUtils } from '../utils/SharedPreferencesUtils';
import CommonUtils from '../utils/CommonUtils';
import { SetupEventKey, SimId, TimeOut } from '../constant/Constants';
import { SetUpIdleModeTextParam } from '../../model/upDecode/SetUpIdleModeTextParam';
import HiLog from '../utils/HiLog';
import { NewIdleScreenHelper } from './NewIdleScreenHelper';
import { ContextStorageHelper } from '../utils/ContextStorageHelper';
import { CustTimeOutHelper } from './CustTimeOutHelper';

const TAG = 'DisplayAndIdleTextHelper';
const DEVICE_PROVISIONED = 'device_provisioned';
const DEVICE_PROVISIONED_FALSE = '0';
const DEVICE_PROVISIONED_TRUE = '1';
const DISPLAY_TEXT_IDLE = 'display_Text_idle';
const SET_UP_IDLE_MODE_IDLE = 'set_up_idle_mode_idle';
const SCREEN_STATUS_DELAY_TIMEOUT = 3000;

enum ScreenStatus {
  IDLE_SCREEN_CALLBACK = 0,
  DISPLAY_TEXT_TIMEOUT = 1,
  IDLE_SCREEN_STATUS = 2,
}

export class DisplayAndIdleTextHelper {
  private static instance: Array<DisplayAndIdleTextHelper | undefined> = [undefined, undefined];
  private slotId: number;
  private displayTextParam: DisplayTextParam | undefined = undefined;
  private displayTextTimeOutId: number | undefined = undefined;
  private isExecTimeOut: boolean = false;
  private isExecIdleScreenCallback: boolean = false;

  public static getInstance(slotId: number): DisplayAndIdleTextHelper | undefined {
    if (slotId !== SimId.SLOT_ID_0 && slotId !== SimId.SLOT_ID_1) {
      return undefined;
    }
    if (DisplayAndIdleTextHelper.instance[slotId] === undefined || DisplayAndIdleTextHelper.instance[slotId] === null) {
      HiLog.info(TAG, 'DisplayAndIdleTextHelper getInstance init');
      DisplayAndIdleTextHelper.instance[slotId] = new DisplayAndIdleTextHelper(slotId);
    }
    return DisplayAndIdleTextHelper.instance[slotId];
  }

  private constructor(slotId: number) {
    this.slotId = slotId;
  }

  public parseDisplayText(displayTextParam: DisplayTextParam | undefined): void {
    HiLog.info(TAG, 'parseDisplayText start');
    this.displayTextParam = displayTextParam;
    let isMenuPageShow = AppStorageHelper.get<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false);
    let isConfirmDialogShow = AppStorageHelper.get<boolean>(AppStorageKey.IS_CONFIRM_DIALOG_SHOW, false);
    if (displayTextParam?.isHighPriority || isMenuPageShow || isConfirmDialogShow) {
        this.launchTextDialog();
    } else {
      HiLog.info(TAG, 'parseNormalDisplayText  start');
      NewIdleScreenHelper.getInstance().isHomeOrStkAbilityTop().then((isTop: boolean) => {
        if (isTop) {
          this.handleScreenStatus(ScreenStatus.IDLE_SCREEN_STATUS);
        } else {
          this.registerToShowDisplayText();
        }
      });
    }
    if (!displayTextParam?.responseNeeded) {
      SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_DIALOG,
        UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT, displayTextParam,
        undefined, undefined);
    }
  }

  private sendDialogResponseDelay(): void {
    HiLog.info(TAG, 'sendDialogResponseDelay start');
    CustTimeOutHelper.getInstance().setTimeOutCust(() => {
      HiLog.info(TAG, 'sendDialogResponseDelay time out');
      SimToolKitAppService.getInstance().handleCmdResponse(
        FromPageFlag.TYPE_DIALOG, UIResponseCode.RESPONSE_TYPE_TIMEOUT, this.displayTextParam,
        undefined, undefined);
    }, TimeOut.DISP_TEXT_CLEAR_AFTER_DELAY_TIMEOUT);
  }

  private launchTextDialog(): void {
    if (this.displayTextParam === undefined) {
      return;
    }
    // device_provisioned
    let deviceProvisionedStr = DEVICE_PROVISIONED_TRUE;
    try {
      deviceProvisionedStr = settings.getValueSync(
        ContextStorageHelper.getInstance().getServiceContext(), DEVICE_PROVISIONED, DEVICE_PROVISIONED_TRUE);
      HiLog.info(TAG, `get device_provisioned:: ${deviceProvisionedStr}`);
    } catch (error) {
      HiLog.error(TAG, 'get device_provisioned error');
    }
    if (deviceProvisionedStr === DEVICE_PROVISIONED_FALSE) {
      this.sendDialogResponseDelay();
      return;
    }
    NotificationUtils.notifyUserOnKeyguard(
      ContextStorageHelper.getInstance().getServiceContext(), this.displayTextParam.slotId, this.displayTextParam.text,
      this.displayTextParam);
    UiUtils.startDialog(
      ContextStorageHelper.getInstance().getEntryUiContext(),
      ContextStorageHelper.getInstance().getServiceContext(),
      this.displayTextParam);
  }

  private registerToShowDisplayText(): void {
    HiLog.info(TAG, 'registerToShowDisplayText start');
    this.isExecIdleScreenCallback = true;
    NewIdleScreenHelper
      .getInstance()
      .registerIdleScreenListener(this.slotId, DISPLAY_TEXT_IDLE, (slotId: number) => {
        if (this.slotId !== slotId) {
          return;
        }
        this.handleScreenStatus(ScreenStatus.IDLE_SCREEN_CALLBACK);
      });
    this.isExecTimeOut = true;
    this.startDisPlayTimeOut();
  }

  private startDisPlayTimeOut(): void {
    HiLog.info(TAG, 'startSelectItemMenuTimeOut');
    this.stopDisPlayTimeOut();
    this.displayTextTimeOutId = setTimeout(() => {
      this.handleScreenStatus(ScreenStatus.DISPLAY_TEXT_TIMEOUT);
    }, SCREEN_STATUS_DELAY_TIMEOUT);
  }

  private stopDisPlayTimeOut(): void {
    if (this.displayTextTimeOutId !== undefined) {
      HiLog.info(TAG, 'stopDisPlayTimeOut');
      clearTimeout(this.displayTextTimeOutId);
      this.displayTextTimeOutId = undefined;
    }
  }

  private handleScreenStatus(status: ScreenStatus): void {
    HiLog.info(TAG, `handleScreenStatus status:${status}`);
    if (status === ScreenStatus.DISPLAY_TEXT_TIMEOUT) {
      if (this.isExecTimeOut) {
        this.isExecTimeOut = false;
        let isMenuPageShow = AppStorageHelper.get<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false);
        let isConfirmDialogShow = AppStorageHelper.get<boolean>(AppStorageKey.IS_CONFIRM_DIALOG_SHOW, false);
        if (isMenuPageShow || isConfirmDialogShow) {
          this.launchIdleText(this.slotId);
          this.launchTextDialog();
        } else {
          // to send busy
          HiLog.info(TAG, 'handleScreenStatus to send busy RESPONSE_TYPE_LOCAL_BUSY');
          SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_BACKGROUND,
            UIResponseCode.RESPONSE_TYPE_LOCAL_BUSY, this.displayTextParam);
        }
        this.isExecIdleScreenCallback = false;
        NewIdleScreenHelper.getInstance().unRegisterIdleScreenListener(this.slotId, DISPLAY_TEXT_IDLE);
      }
    } else if (status === ScreenStatus.IDLE_SCREEN_CALLBACK) {
      if (this.isExecIdleScreenCallback) {
        this.isExecTimeOut = false;
        this.isExecIdleScreenCallback = false;
        this.stopDisPlayTimeOut();
        this.launchIdleText(this.slotId);
        this.launchTextDialog();
      }
    } else if (status === ScreenStatus.IDLE_SCREEN_STATUS) {
      this.launchIdleText(this.slotId);
      this.launchTextDialog();
    } else {
      HiLog.error(TAG, `handleScreenStatus error status:${status}`);
      return;
    }
  }

  private launchIdleText(slotId: number): void {
    let serviceContext = ContextStorageHelper.getInstance().getServiceContext();
    if (serviceContext === undefined) {
      return;
    }
    let idleModeKey = `${SetupEventKey.IDLE_MODE_TEXT_KEY}${slotId}`;
    sharedPreferencesUtils.getString(serviceContext, idleModeKey, '').then((value: string) => {
      NotificationUtils.startNotification(serviceContext, '', value, slotId, false);
    });
  }

  public parseSetUpIdleModeText(idleModeParam: SetUpIdleModeTextParam): void {
    let serviceContext = ContextStorageHelper.getInstance().getServiceContext();
    NotificationUtils.startNotification(serviceContext, '', idleModeParam.text,
      idleModeParam.slotId, false);
    sharedPreferencesUtils.saveString(serviceContext,
      `${SetupEventKey.IDLE_MODE_TEXT_KEY}${idleModeParam.slotId}`, idleModeParam.text);
    if (!CommonUtils.isEmptyStr(idleModeParam.text)) {
      NewIdleScreenHelper.getInstance()
        .registerIdleScreenListener(this.slotId, SET_UP_IDLE_MODE_IDLE, (slotId: number) => {
          if (this.slotId !== slotId) {
            return;
          }
          this.launchIdleText(idleModeParam.slotId);
        });
    }
  }
}