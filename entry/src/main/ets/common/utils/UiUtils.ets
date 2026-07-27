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

import { promptAction, window } from '@kit.ArkUI';
import { common, dialogRequest, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../utils/HiLog';
import { BaseUpParams } from '../../model/upDecode/BaseUpParams';
import { AppStorageHelper, AppStorageKey } from '../helper/AppStorageHelper';
import CommonUtils from './CommonUtils';
import { AccessibilityUtils } from './AccessibilityUtils';
import { SettingsDataHelper } from '../helper/SettingsDataHelper';
import { ContextStorageHelper } from './ContextStorageHelper';
import { BackgroundColor, HapInfo, PageUrl, SimId } from '../constant/Constants';
import { SimSwitchState } from '../constant/Constants';
import { getSimLabelIndex } from '../../model/TsManager';

const TAG = 'UiUtils';

/**
 * Ui Utils class
 *
 * @since 2023-06-10
 */
export default class UiUtils {
  /**
   * start to show toast when in foreground or in background
   *
   * @param uiContext ui current context
   * @param serviceContext service current context
   * @param content toast content
   */
  private static startToast(uiContext: common.UIAbilityContext | undefined,
    serviceContext: common.ServiceExtensionContext | undefined, content: string | undefined): void {
    if (!content) {
      HiLog.error(TAG, 'showToast invalid content');
      return;
    }
    if (AppStorageHelper.get<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false)) {
      // when ui ability exist, direct show toast
      HiLog.info(TAG, 'startToast direct show in foreground');
      try {
        promptAction.showToast({
          message: content
        });
      } catch (error) {
        HiLog.error(TAG, 'promptAction.showToast error');
      }
      return;
    }

    // when ui ability not exist, start show toast from service ability
    HiLog.info(TAG, 'startToast direct show in background');
    let want: Want = {
      bundleName: HapInfo.BUNDLE_NAME,
      abilityName: HapInfo.SERVICE_ABILITY_NAME,
      parameters: {
        'toastContent': content,
      }
    };
    if (uiContext) {
      UiUtils.startServiceExtensionAbilityCust(want, 'uiContext startToast', uiContext);
    } else if (serviceContext) {
      UiUtils.startServiceExtensionAbilityCust(want, 'serviceContext startToast', serviceContext);
    } else {
      HiLog.error(TAG, 'uiContext and serviceContext is empty');
    }
  }

  private static startServiceExtensionAbilityCust(want: Want, logText: string,
    context: common.UIAbilityContext | common.ServiceExtensionContext): void {
    try {
      context.startServiceExtensionAbility(want).then((data) => {
        HiLog.info(TAG, `${logText}, startServiceExtensionAbility success`);
      }).catch((error: BusinessError) => {
        HiLog.error(TAG, `${logText}, startServiceExtensionAbility error:${error?.code}`);
      });
    } catch (error) {
      HiLog.error(TAG, `${logText}, startServiceExtensionAbility paramError`);
    }
  }

  /**
   * Utils to show toast from service ability
   *
   * @param context service current context
   * @param content message to show
   */
  public static showToastFromServiceAbility(
    context: common.ServiceExtensionContext, content: string | undefined): void {
    HiLog.info(TAG, `showToastFromServiceAbility content: ${content}`);
    UiUtils.startToast(undefined, context, content);
  }

  /**
   * Utils to get string
   *
   * @param context Context
   * @param resId string resource id
   * @returns return string
   */
  public static getStringSync(context: common.Context | undefined, resId: number): string | undefined {
    if (!context) {
      HiLog.error(TAG, 'getStringSync invalid context');
      return undefined;
    }
    if (CommonUtils.isEmptyObj(resId) || resId <= 0) {
      HiLog.error(TAG, 'getStringSync resId is empty');
      return undefined;
    }
    try {
      return (context.resourceManager.getStringSync(resId) ?? '');
    } catch (error) {
      HiLog.error(TAG, `getStringSync failed. Error code: ${error?.code}, message: ${error?.message}`);
      return '';
    }
  }

  /**
   * Utils to get string
   *
   * @param context Context
   * @param resId string resource id
   * @param formatNumber format parameters
   * @returns return string
   */
  public static getStringFormat(
    context: common.Context | undefined, resId: number, formatNumber: string): string | undefined {
    if (!context) {
      HiLog.error(TAG, 'getStringFormat invalid context');
      return undefined;
    }
    if (CommonUtils.isEmptyObj(resId) || resId <= 0) {
      HiLog.error(TAG, 'getStringFormat resId is empty');
      return undefined;
    }
    try {
      return (context.resourceManager.getStringSync(resId, formatNumber) ?? '');
    } catch (error) {
      HiLog.error(TAG, `getStringFormat failed. Error code: ${error?.code}, message: ${error?.message}`);
      return '';
    }
  }

  /**
   * start show dialog, need create dialog window from service
   *
   * @param context Current context
   * @param params Dialog params
   */
  public static startDialog(uiContext: common.UIAbilityContext | undefined,
    serviceContext: common.ServiceExtensionContext | undefined, params: BaseUpParams): void {
    if (!(uiContext || serviceContext) || !params) {
      HiLog.error(TAG, 'startDialog invalid params');
      return;
    }
    if (uiContext && AppStorageHelper.get<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false)) {
      HiLog.info(TAG, 'startDialog by requestDialogService');
      uiContext.requestDialogService(UiUtils.getStartExtAbilityWant(params, true)).then((result) => {
        HiLog.info(TAG, 'startDialog by requestDialogService success');
      }).catch((err: BusinessError) => {
        HiLog.error(TAG, `tartDialog by requestDialogService failed. code: ${err?.code}, message: ${err?.message}`);
      });
      return;
    }
    HiLog.info(TAG, 'startDialog by startServiceExtensionAbility');
    if (serviceContext) {
      UiUtils.startServiceExtensionAbilityCust(UiUtils.getStartExtAbilityWant(params), 'serviceContext startDialog',
        serviceContext);
    } else if (uiContext) {
      UiUtils.startServiceExtensionAbilityCust(UiUtils.getStartExtAbilityWant(params), 'uiContext startDialog',
        uiContext);
    } else {
      HiLog.error(TAG, 'uiContext and serviceContext is empty');
      return;
    }
  }

  private static getStartExtAbilityWant(params: BaseUpParams, isRequestDialogService: boolean = false): Want {
    let dataWant: Want = {
      bundleName: HapInfo.BUNDLE_NAME,
      abilityName: HapInfo.SERVICE_ABILITY_NAME,
      parameters: {
        'dialogOriParams': params,
        'isRequestDialogService': isRequestDialogService
      }
    };
    return dataWant;
  }

  /**
   * show dialog by create window
   *
   * @param context Current context
   * @param windowId The window id
   * @param storage Window params saved in local storage
   * @param reqInfo Request info from foreground ability
   * @returns return dialog window created
   */
  public static async showDialog(context: common.ServiceExtensionContext, windowId: string, storage: LocalStorage,
    reqInfo?: dialogRequest.RequestInfo): Promise<void> {
    HiLog.info(TAG, 'showDialog destroy old window');
    await UiUtils.destroyWindow(windowId);

    let winType = reqInfo ? window.WindowType.TYPE_DIALOG : window.WindowType.TYPE_FLOAT;
    let config: window.Configuration = {
      name: windowId,
      windowType: winType,
      ctx: context
    };
    try {
      let dialogWindow = await window.createWindow(config);
      HiLog.info(TAG, 'create dialog window success');
      if (!dialogWindow) {
        return;
      }
      if (reqInfo) {
        HiLog.info(TAG, 'dialog bind to window');
        await dialogWindow.bindDialogTarget(reqInfo, () => {
          HiLog.info(TAG, 'bindDialogTarget destroyWindow');
          UiUtils.destroyWindow(windowId);
        });
      }
      await dialogWindow.loadContent(PageUrl.PAGE_URL_DIALOG, storage);
      if (reqInfo) {
        await dialogWindow.setWindowFocusable(AccessibilityUtils.getInstance().isStartAccessibility());
      } else {
        SettingsDataHelper.getInstance().setSubUserSimAbsent(context, false);
        UiUtils.registerWindowVisibility(dialogWindow);
      }
      dialogWindow.setWindowBackgroundColor(BackgroundColor.COLOR_TRANSPARENT);
      await dialogWindow.setWindowLayoutFullScreen(true);
      await dialogWindow.showWindow();
    } catch (error) {
      HiLog.error(TAG, `showDialog error code: ${error?.code}`);
      UiUtils.destroyWindow(windowId);
    }
  }

  private static findWindow(windowId: string | undefined): window.Window | undefined {
    if (!windowId) {
      return undefined;
    }
    try {
      return window.findWindow(windowId);
    } catch (err) {
      HiLog.warn(TAG, 'findWindow failed to getWindowInstance.');
      return undefined;
    }
  }

  /**
   * Destroy window by id
   *
   * @param windowId Window id
   */
  public static async destroyWindow(windowId: string): Promise<void> {
    HiLog.info(TAG, 'destroyWindow window');
    let curFindWindow = UiUtils.findWindow(windowId);
    UiUtils.unRegisterWindowVisibility(curFindWindow);
    try {
      await curFindWindow?.destroyWindow();
    } catch (err) {
      HiLog.error(TAG, 'destroyWindow error.');
    }
  }

  private static registerWindowVisibility(window: window.Window): void {
    try {
      window?.on('windowVisibilityChange', (isVisibility: boolean) => {
        if (isVisibility) {
          UiUtils.exitAppFormSubUser();
        }
      });
    } catch (err) {
      HiLog.warn(TAG, 'registerWindowVisibility error');
    }
  }

  private static unRegisterWindowVisibility(window: window.Window | undefined): void {
    try {
      window?.off('windowVisibilityChange');
    } catch (err) {
      HiLog.warn(TAG, 'unRegisterWindowVisibility error');
    }
  }

  /**
   * when receive onBackPress event, check is need trans to dialog to process
   *
   * @returns { boolean } true means that should dialog processes the back press logic, false means no need.
   */
  public static isNeedTransBackPressToDialog(): boolean {
    let windowId = AppStorageHelper.get<string>('lastWindowId');
    if (CommonUtils.isEmptyStr(windowId)) {
      HiLog.debug(TAG, 'isNeedTransBackPressToDialog not find dialog windowId');
      return false;
    }
    let curDialog = UiUtils.findWindow(windowId);
    if (CommonUtils.isEmptyObj(curDialog)) {
      HiLog.debug(TAG, 'isNeedTransBackPressToDialog not find dialog');
      return false;
    }
    let isOnReceiveBackPress = AppStorageHelper.get<boolean>('onReceiveBackPress', false);
    if (!isOnReceiveBackPress && curDialog?.isWindowShowing()) {
      HiLog.debug(TAG, 'isNeedTransBackPressToDialog current has dialog showing');
      AppStorageHelper.set<boolean>('onReceiveBackPress', true);
      return true;
    } else {
      HiLog.debug(TAG, 'isNeedTransBackPressToDialog cur has no dialog showing, no need process');
      return false;
    }
  }

  public static getPageTitleInput(context: common.Context, slotId: number): string {
    if (!CommonUtils.isTwoSimCount() || slotId === SimId.SLOT_ID_0) {
      return UiUtils.getStringSync(context, $r('app.string.simtoolkit_MainAbility').id) ?? '';
    }
    let esimSwitch = CommonUtils.getEsimSwitch();
    let simLabelIndex = 0;
    if (esimSwitch === SimSwitchState.PSIM2_ESIM || esimSwitch === SimSwitchState.PSIM1_ESIM) {
      simLabelIndex = getSimLabelIndex(slotId);
      return UiUtils.getStringFormat(context, $r('app.string.esim_card_application_number').id,
        CommonUtils.getNumberFormat(simLabelIndex)) ?? '';
    }
    return UiUtils.getStringSync(context, $r('app.string.simtoolkit_MainAbility').id) ?? '';
  }

  public static getPageTitle(context: common.Context, slotId: number): string {
    // single sim card
    if (!CommonUtils.isTwoSimCount()) {
      return UiUtils.getStringSync(context, $r('app.string.simtoolkit_MainAbility').id) ?? '';
    }

    // sim card 1
    let esimSwitch = CommonUtils.getEsimSwitch();
    if (slotId === SimId.SLOT_ID_0) {
      let formatNumber =
        (esimSwitch === SimSwitchState.PSIM2_ESIM) ? SimId.SLOT_INDEX_2 : SimId.SLOT_INDEX_1;
      return UiUtils.getStringFormat(context, $r('app.string.sim_card_application').id,
        CommonUtils.getNumberFormat(formatNumber)) ?? '';
    }

    // sim card 2
    if (esimSwitch === SimSwitchState.PSIM2_ESIM || esimSwitch === SimSwitchState.PSIM1_ESIM) {
      let simLabelIndex = getSimLabelIndex(slotId);
      return UiUtils.getStringFormat(context, $r('app.string.esim_card_application_number').id,
        CommonUtils.getNumberFormat(simLabelIndex)) ?? '';
    } else {
      return UiUtils.getStringFormat(context, $r('app.string.sim_card_application').id,
        CommonUtils.getNumberFormat(SimId.SLOT_INDEX_2)) ?? '';
    }
  }

  public static exitAppFormSubUser(): void {
    let exitContext: (common.Context | undefined) = ContextStorageHelper.getInstance().getEntryUiContext();
    if (!exitContext) {
      exitContext = ContextStorageHelper.getInstance().getServiceContext();
    }
    if (SettingsDataHelper.getInstance().getSubUserSimAbsent(exitContext)) {
      SettingsDataHelper.getInstance().setSubUserSimAbsent(exitContext, false);
      CommonUtils.terminateSelfCust(ContextStorageHelper.getInstance().getServiceContext());
      CommonUtils.terminateSelfCust(ContextStorageHelper.getInstance().getEntryUiContext());
    }
  }
}
