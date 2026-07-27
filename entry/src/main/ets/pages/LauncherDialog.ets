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

import { AlertDialog } from '@kit.ArkUI';
import { EventHub, TimeOut } from '../common/constant/Constants';
import HiLog from '../common/utils/HiLog';
import ToastDialog from '../common/components/ToastDialog';
import UiUtils from '../common/utils/UiUtils';
import ToneDialog from '../common/components/ToneDialog';
import TonePlayer from '../common/utils/TonePlayer';
import CommonUtils from '../common/utils/CommonUtils';
import { BaseUpParams } from '../model/upDecode/BaseUpParams';
import { CommandType, UIResponseCode } from '../common/constant/SimToolKitConstant';
import { SimToolKitAppService } from '../model/SimToolKitAppService';
import { FromPageFlag } from '../model/UIResponseData';
import { DisplayTextParam } from '../model/upDecode/DisplayTextParam';
import { LaunchBrowserParam } from '../model/upDecode/LaunchBrowserParam';
import { SetUpCallParam } from '../model/upDecode/SetUpCallParam';
import { PlayToneParam } from '../model/upDecode/PlayToneParam';
import { UpParamsCacheUtils } from '../common/utils/UpParamsCacheUtils';
import { AppStorageHelper, AppStorageKey } from '../common/helper/AppStorageHelper';
import { CustTimeOutHelper } from '../common/helper/CustTimeOutHelper';
import { AllBipParam } from '../model/upDecode/AllBipParam';

const TAG: string = `StkLauncherDialog_${new Date().getTime()}`;
const DIALOG_TYPE_CONFIRM = 'dialog_type_confirm';
const DIALOG_TYPE_TOAST = 'dialog_type_toast';
const DIALOG_TYPE_TONE = 'dialog_type_tone';

/**
 * 桌面弹窗界面
 *
 * @since 2023-03-16
 */
@Entry
@Component
struct LauncherDialog {
  @State private title: string = '';
  @State private content: string = '';
  private timeoutMgr?: number;
  private duration: number = 0;
  private curSlotId: number = 0;
  private curDialog?: CustomDialogController;
  private curDialogType: string = '';
  private isWaitResponse: boolean = false;
  private curDialogParams?: BaseUpParams;
  private windowId: string = '';
  @StorageProp('lastWindowId') @Watch('updateLastWindowId') lastWindowId: string = '';
  @StorageProp('onReceiveBackPress') @Watch('onReceiveBackPressed') onReceiveBackPress: boolean = false;
  private toCloseDialog = () => {
    HiLog.info(TAG, 'LauncherDialog toCloseDialog');
    this.destroyDialog();
  };

  private createConfirmDialogController(): CustomDialogController {
    return new CustomDialogController({
      builder: AlertDialog({
        primaryTitle: this.title,
        content: this.content,
        primaryButton: {
          value: $r('app.string.cancel'),
          action: () => {
            this.onEvent?.(UIResponseCode.RESPONSE_TYPE_CONFIRM_REJECT);
          }
        },
        secondaryButton: {
          value: $r('app.string.confirm'),
          action: () => {
            this.onEvent?.(UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT);
          }
        },
      }),
      cancel: () => {
        this.onDialogCancel();
      },
      autoCancel: false
    });
  }

  private toneDialog: CustomDialogController = new CustomDialogController({
    builder: ToneDialog({ content: this.content }),
    cancel: () => {
      this.onDialogCancel();
    },
    autoCancel: true,
    customStyle: true
  });
  private toastDialog: CustomDialogController = new CustomDialogController({
    builder: ToastDialog({ content: this.content }),
    alignment: DialogAlignment.Bottom,
    cancel: () => {
      this.onDialogCancel();
    },
    autoCancel: true,
    customStyle: true
  });

  aboutToAppear(): void {
    HiLog.info(TAG, 'aboutToAppear');
    this.windowId = LocalStorage.getShared()?.get<string>('windowId') ?? '';
    let toastContent = LocalStorage.getShared()?.get<string>('toastContent');
    if (toastContent) {
      HiLog.info(TAG, 'aboutToAppear goto toast flow');
      this.createToastDialog(toastContent);
      return;
    }

    this.curDialogParams = LocalStorage.getShared()?.get('params') as BaseUpParams;
    if (!this.curDialogParams) {
      HiLog.error(TAG, 'aboutToAppear got invalid params!');
      this.destroyDialog();
      return;
    }
    // index page disappear to close dialog
    (getContext(this).getApplicationContext()).eventHub.on(EventHub.TO_CLOSE_DIALOG, this.toCloseDialog);
    this.curSlotId = this.curDialogParams.slotId;
    let isNeedResp = this.createDialog(this.curDialogParams);
    if (this.curDialog === undefined) {
      this.destroyDialog();
    } else {
      this.curDialog.open();
      this.startTimeout();
      this.isWaitResponse = isNeedResp;
    }
    if (this.curDialogType === DIALOG_TYPE_CONFIRM) {
      HiLog.info(TAG, `aboutToAppear IS_CONFIRM_DIALOG_SHOW title:${this.title}, content:${this.content}`);
      AppStorageHelper.set<boolean>(AppStorageKey.IS_CONFIRM_DIALOG_SHOW, true);
    }
  }

  private createDialog(dialogParam: BaseUpParams): boolean {
    let isNeedResp: boolean = true;
    switch (dialogParam.commandType) {
      case CommandType.DISPLAY_TEXT:
        let displayParam = dialogParam as DisplayTextParam;
        isNeedResp = displayParam.responseNeeded;
        this.createConfirmDialog(displayParam.text, displayParam.duration);
        break;
      case CommandType.LAUNCH_BROWSER:
        let displayBrowserParam = dialogParam as LaunchBrowserParam;
        this.createConfirmDialog(displayBrowserParam.confirmText, 0);
        break;
      case CommandType.SET_UP_CALL:
        let displayCallParam = dialogParam as SetUpCallParam;
        this.createConfirmDialog(displayCallParam.confirmText, 0);
        break;
      case CommandType.OPEN_CHANNEL:
        let bipParam = dialogParam as AllBipParam;
        let title = UiUtils.getPageTitleInput(getContext(this), bipParam.slotId);
        this.createConfirmDialog(bipParam.text, TimeOut.TIME_UNIT_MINUTE, title);
        break;
      case CommandType.PLAY_TONE:
        this.createToneDialog(dialogParam as PlayToneParam);
        break;
      default:
        HiLog.warn(TAG, 'aboutToAppear default, error branch, destroy dialog!');
        break;
    }
    return isNeedResp;
  }

  private updateLastWindowId(): void {
    HiLog.info(TAG, 'updateLastWindowId');
    if (this.lastWindowId === this.windowId) {
      HiLog.info(TAG, `lasWindow Id is same with current window Id, no need process`);
      return;
    }
    this.onEvent(UIResponseCode.RESPONSE_TYPE_CONFIRM_ACCEPT);
  }

  private createToneDialog(toneParam: PlayToneParam): void {
    HiLog.info(TAG, 'aboutToAppear PLAY_TONE displayToneParam');
    this.curDialog = this.toneDialog;
    this.content = toneParam.text;
    this.duration = (toneParam.duration > 0) ? toneParam.duration : TimeOut.TIMEOUT_PLAY_TONE_DEF;
    TonePlayer.startPlay(toneParam, false);
    this.curDialogType = DIALOG_TYPE_TONE;
  }

  private createToastDialog(text: string): void {
    HiLog.info(TAG, `create toast dialog text:${text}`);
    this.content = text;
    this.duration = TimeOut.TIMEOUT_TOAST;
    this.curDialog = this.toastDialog;

    this.curDialog.open();
    this.startTimeout();
    this.isWaitResponse = false;
    this.curDialogType = DIALOG_TYPE_TOAST;
  }

  private createConfirmDialog(content: string, duration: number, titleStr: string = ''): void {
    this.content = content;
    if (CommonUtils.isEmptyStr(titleStr)) {
      this.getDefaultTitle();
    } else {
      this.title = titleStr;
    }
    HiLog.info(TAG, `createConfirmDialog simToolkitAlertDialog title:${this.title}`);
    this.duration = (duration > 0) ? duration : TimeOut.TIME_UNIT_MINUTE;
    this.curDialog = this.createConfirmDialogController();
    this.curDialogType = DIALOG_TYPE_CONFIRM;
  }

  private getDefaultTitle(): void {
    let cacheTitle = UpParamsCacheUtils.getInstance().getSimTitle(this.curSlotId);
    if (!CommonUtils.isEmptyStr(cacheTitle)) {
      this.title = cacheTitle;
    } else {
      this.title = UiUtils.getPageTitle(getContext(this), this.curSlotId);
    }
  }

  /**
   * send dialog response to sim
   *
   * @param type current response type
   */
  public onEvent(type: number): void {
    HiLog.info(TAG, `onEvent type:${type}, curDialogType:${this.curDialogType}, isNeedResp:${this.isWaitResponse}`);
    if (!this.isWaitResponse) {
      HiLog.warn(TAG, 'onEvent check no need response, return!');
      this.destroyDialog();
      return;
    }
    this.isWaitResponse = false;
    HiLog.info(TAG, 'onEvent sendDialogResponseData');
    SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_DIALOG, type, this.curDialogParams,
      undefined, undefined);
    this.destroyDialog();
  }

  onReceiveBackPressed(): void {
    HiLog.info(TAG, `onReceiveBackPressed current value:${this.onReceiveBackPress}`);
    if (!this.onReceiveBackPress) {
      HiLog.debug(TAG, 'onReceiveBackPressed is false, no need triggle again');
      return;
    }
    this.onBackPress();
    AppStorageHelper.set<boolean>('onReceiveBackPress', false);
  }

  onBackPress(): void {
    HiLog.info(TAG, 'onBackPress');
    this.onEvent(UIResponseCode.RESPONSE_TYPE_BACKWARD);
  }

  onDialogCancel(): void {
    HiLog.info(TAG, 'onDialogCancel');
    this.onEvent(UIResponseCode.RESPONSE_TYPE_BACKWARD);
  }

  aboutToDisappear(): void {
    HiLog.info(TAG, 'aboutToDisappear');
    if (this.curDialogType === DIALOG_TYPE_CONFIRM) {
      HiLog.info(TAG, `aboutToDisappear IS_CONFIRM_DIALOG_SHOW title:${this.title}, content:${this.content}`);
      AppStorageHelper.set<boolean>(AppStorageKey.IS_CONFIRM_DIALOG_SHOW, false);
    }
    (getContext(this).getApplicationContext()).eventHub.off(EventHub.TO_CLOSE_DIALOG, this.toCloseDialog);
    this.destroyDialog();
  }

  private destroyDialog(): void {
    HiLog.info(TAG, 'destroyDialog');
    if (this.timeoutMgr !== undefined && this.timeoutMgr !== null) {
      HiLog.info(TAG, 'destroyDialog clearTimeout');
      CustTimeOutHelper.getInstance().stopSystemTimer(this.timeoutMgr);
      this.timeoutMgr = undefined;
    }
    this.closeCurDialog();
    TonePlayer.destroy();
  }

  onPageShow(): void {
    HiLog.info(TAG, 'onPageShow refresh last dialogId');
    AppStorageHelper.set<string>('lastWindowId', this.windowId);
  }

  private async startTimeout(): Promise<void> {
    HiLog.info(TAG, `startTimeout start current timeout id:${this.duration}`);
    this.timeoutMgr = await CustTimeOutHelper.getInstance().setTimeOutCustAsync(() => {
      HiLog.warn(TAG, 'curDialog timeout time is reach');
      this.onEvent(UIResponseCode.RESPONSE_TYPE_TIMEOUT);
    }, this.duration);
  }

  private closeCurDialog(): void {
    HiLog.info(TAG, `destroyDialog close current dialog:${this.curDialog}`);
    if (this.curDialog) {
      this.curDialog.close();
      HiLog.info(TAG, 'destroyDialog curDialog closed');
      this.curDialog = undefined;
      UiUtils.destroyWindow(this.windowId);
    } else {
      HiLog.warn(TAG, 'destroyDialog close current dialog, no dialog to close');
    }
  }

  onPageHide(): void {
    HiLog.info(TAG, 'onPageHide');
  }

  build() {
  }
}