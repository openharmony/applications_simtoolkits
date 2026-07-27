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

import { AbilityConstant, ConfigurationConstant, UIAbility } from '@kit.AbilityKit';
import { router, window } from '@kit.ArkUI';
import { sim } from '@kit.TelephonyKit';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from '../common/utils/HiLog';
import UiUtils from '../common/utils/UiUtils';
import CommonUtils from '../common/utils/CommonUtils';
import { BaseUpParams } from '../model/upDecode/BaseUpParams';
import { CommandType } from '../common/constant/SimToolKitConstant';
import { UpParamsCacheUtils } from '../common/utils/UpParamsCacheUtils';
import { BackgroundColor, EventHub, HapInfo, LocalStorageKey, PageUrl, SimId } from '../common/constant/Constants';
import { SimToolKitAppService } from '../model/SimToolKitAppService';
import { ContextStorageHelper } from '../common/utils/ContextStorageHelper';
import { SettingsDataHelper } from '../common/helper/SettingsDataHelper';

const TAG = 'EntryAbility';
const SIM_CARD_MANAGEMENT_BUNDLE_NAME = 'com.ohos.simcardmanagement';

export default class EntryAbility extends UIAbility {
  private localStorage: LocalStorage = new LocalStorage();
  private windowStage: window.WindowStage | undefined = undefined;
  private wantOnCreate: Want | undefined = undefined;
  private existTips: string | undefined = undefined;

  private getSlotId(want: Want): number {
    HiLog.info(TAG, 'getSlotId');
    let slotId: number;
    if (want.parameters?.slotId === undefined || (typeof want.parameters.slotId) !== 'number') {
      slotId = SimId.SLOT_ID_0;
    } else {
      slotId = want.parameters.slotId as number;
    }
    return slotId;
  }

  private getPageUrl(want: Want): string {
    HiLog.info(TAG, 'getPageUrl');
    let pageUrl: string;
    if (!want.parameters?.pageUrl || (typeof want.parameters?.pageUrl) !== 'string') {
      pageUrl = PageUrl.PAGE_URL_MAIN;
    } else {
      pageUrl = want.parameters.pageUrl as string;
    }
    return pageUrl;
  }

  private getUpParam(slotId: number, want: Want): BaseUpParams | undefined {
    HiLog.info(TAG, 'getUpParam');
    let upParam: BaseUpParams | undefined;
    if (!want.parameters?.upParam) {
      upParam = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId);
    } else {
      upParam = want.parameters.upParam as BaseUpParams;
    }
    return upParam;
  }

  private setSlotIdAndParamsToLocalStorage(slotId: number, param: BaseUpParams | undefined): void {
    this.localStorage.setOrCreate<number>(LocalStorageKey.SLOT_ID, slotId);
    this.localStorage.setOrCreate<BaseUpParams>(LocalStorageKey.UP_PARAM + slotId, param);
  }

  private checkParameterFormWant(want: Want): boolean {
    HiLog.info(TAG, 'checkParameterFormWant');
    let callerBundleName = want.parameters?.['ohos.aafwk.param.callerBundleName'];
    if (callerBundleName === HapInfo.BUNDLE_NAME) {
      return true;
    }
    // other app parameter check
    let isMainUrl = want.parameters?.pageUrl === PageUrl.PAGE_URL_MAIN;
    let slotId = want.parameters?.slotId;
    let isSupportSlotId = slotId === SimId.SLOT_ID_0 || slotId === SimId.SLOT_ID_1;
    let isNotUpParam = want.parameters?.upParam === undefined;
    return isMainUrl && isSupportSlotId && isNotUpParam;
  }

  onRequest(want: Want | undefined, isOnCreate: boolean): void {
    if (!want || !want.parameters) {
      HiLog.error(TAG, 'want want.parameters is undefined');
      CommonUtils.terminateSelfCust(this.context);
      return;
    }
    if (!this.checkParameterFormWant(want)) {
      HiLog.error(TAG, 'checkParameterFormWant error');
      CommonUtils.terminateSelfCust(this.context);
      return;
    }
    let isStartFormOut = want.parameters['ohos.aafwk.param.callerBundleName'] === SIM_CARD_MANAGEMENT_BUNDLE_NAME;
    let slotId: number = this.getSlotId(want);

    // onNewWant
    HiLog.info(TAG, 'onNewWant to refresh main menu cache');
    if (!isOnCreate && isStartFormOut && this.isRefreshPageToHome()) {
      this.refreshPageToHome(slotId);
      return;
    }

    let preSlotId = this.localStorage.get<number>(LocalStorageKey.SLOT_ID);
    if (!isOnCreate && isStartFormOut && slotId === preSlotId) {
      HiLog.info(TAG, 'menu is created, again from sim card enter, not refresh page');
      return;
    }
    this.checkSimStatusAndMenu(slotId).then((isSimActive: boolean) => {
      HiLog.info(TAG, `checkSimStatusAndMenu slotId:${slotId}, isSimActive:${isSimActive}`);
      let pageUrl: string = this.getPageUrl(want);
      let upParam: BaseUpParams | undefined = this.getUpParam(slotId, want);
      let isToSetUpMenu = this.isToSetUpMenu(pageUrl, upParam);
      let isWantHaveParam = !CommonUtils.isEmptyObj(want.parameters?.upParam);
      if (isToSetUpMenu || !isWantHaveParam) {
        if (this.isNeedExist(slotId, isSimActive)) {
          HiLog.error(TAG, 'checkSimStatusAndMenu no sim active, need exist!');
          return;
        }
      }
      this.setSlotIdAndParamsToLocalStorage(slotId, upParam);
      if (isOnCreate) {
        this.loadContent(pageUrl);
      } else {
        this.startSpecificPage(slotId, pageUrl, upParam, preSlotId);
      }
    });
  }

  private loadContent(pageUrl: string): void {
    HiLog.info(TAG, 'loadContent');
    if (this.windowStage === undefined) {
      return;
    }
    try {
      this.windowStage.loadContent(pageUrl, this.localStorage, (err, data) => {
        if (err.code) {
          HiLog.error(TAG, 'Failed to load the content.');
        } else {
          this.setSystemBar(this.context.config.colorMode as ConfigurationConstant.ColorMode);
        }
      });
    } catch (error) {
      HiLog.error(TAG, 'loadContent error');
      return;
    }
  }

  private registerColorModeChanged(): void {
    this.context.getApplicationContext().eventHub.on(EventHub.CONFIG_COLOR_MODE_CHANGE,
      (colorMode?: ConfigurationConstant.ColorMode) => {
        this.setSystemBar(colorMode);
      });
  }

  private unRegisterColorModeChanged(): void {
    this.context.getApplicationContext().eventHub.off(EventHub.CONFIG_COLOR_MODE_CHANGE);
  }

  private setSystemBar(colorMode?: ConfigurationConstant.ColorMode): void {
    if (this.windowStage === undefined) {
      return;
    }
    try {
      let mainWindow = this.windowStage.getMainWindowSync();
      let defaultBarColor = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
      BackgroundColor.WINDOW_BG_APP : BackgroundColor.WINDOW_BG_BLACK;
      mainWindow?.setWindowBackgroundColor(defaultBarColor);
      const properties: window.SystemBarProperties = {
        statusBarContentColor: colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
        BackgroundColor.WINDOW_BG_BLACK : BackgroundColor.WINDOW_BG_WHITE,
      };
      mainWindow?.setWindowSystemBarProperties(properties);
    } catch (error) {
      HiLog.error(TAG, 'getMainWindowSync error');
    }
  }

  private routerPushUrlAndClear(pageUrl: string): void {
    let options: router.RouterOptions = {
      url: pageUrl
    };
    router.pushUrl(options).then(value => {
      router.clear();
    });
  }

  private startSpecificPage(slotId: number, pageUrl: string, upParam: BaseUpParams | undefined,
    preSlotId: number | undefined): void {
    let isFirstPage = pageUrl === PageUrl.PAGE_URL_MAIN;
    let topPageUrl = router.getState()?.path + router.getState()?.name;
    if (isFirstPage) {
      if (pageUrl === topPageUrl && preSlotId === slotId) {
        HiLog.info(TAG, 'startSpecificPage REFRESH_MENU_DATA');
        this.context.eventHub.emit(EventHub.REFRESH_MENU_DATA, slotId, upParam);
      } else {
        this.routerPushUrlAndClear(pageUrl);
      }
      return;
    }
    let options: router.RouterOptions = {
      url: pageUrl
    };
    router.pushUrl(options).then(value => {
      HiLog.info(TAG, 'startSpecificPage then');
    }).catch((error: BusinessError) => {
      HiLog.error(TAG, 'startSpecificPage error');
    });
  }

  private isToSetUpMenu(pageUrl: string, upParam: BaseUpParams | undefined): boolean {
    if (pageUrl === PageUrl.PAGE_URL_MAIN) {
      let commandType = upParam?.commandType;
      return commandType === undefined || commandType === CommandType.SET_UP_MENU;
    }
    return false;
  }

  private isNeedExist(slotId: number, isSimActive: boolean): boolean {
    // sim0 is not active, sim1 is not active
    if (!isSimActive) {
      HiLog.info(TAG, 'startServiceExtensionAbility simactive fail');
      this.existTips = UiUtils.getStringSync(this.context, $r('app.string.please_insert_card').id);
      CommonUtils.terminateSelfCust(this.context);
      return true;
    }
    let simMenu = UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId);
    if (!simMenu) {
      HiLog.info(TAG, 'startServiceExtensionAbility sim menu fail, terminstate');
      this.existTips = UiUtils.getStringSync(this.context, $r('app.string.no_menu').id);
      CommonUtils.terminateSelfCust(this.context);
      return true;
    }
    return false;
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HiLog.info(TAG, 'onCreate');
    SettingsDataHelper.getInstance().setSubUserSimAbsent(this.context, false);
    this.registerColorModeChanged();
    SimToolKitAppService.getInstance().setUiContext(this.context);
    ContextStorageHelper.getInstance().setEntryUiContext(this.context);
    CommonUtils.startServiceExtensionAbility(this.context);
    this.wantOnCreate = want;
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    HiLog.info(TAG, 'onNewWant');
    this.onRequest(want, false);
  }

  onDestroy(): void {
    HiLog.info(TAG, 'onDestroy');
    this.unRegisterColorModeChanged();
    SimToolKitAppService.getInstance().setUiContext(undefined);
    SimToolKitAppService.getInstance().endSessionCurrentCmd();
    ContextStorageHelper.getInstance().setEntryUiContext(undefined);
    if (!CommonUtils.isEmptyStr(this.existTips)) {
      SimToolKitAppService.getInstance().showToast(this.existTips);
    }
    this.localStorage.clear();
  }

  private async checkSimStatusAndMenu(slotId: number): Promise<boolean> {
    let curSlotId: number;
    if (slotId === SimId.SLOT_ID_0 || (CommonUtils.isTwoSimCount() && slotId === SimId.SLOT_ID_1)) {
      curSlotId = slotId;
    } else {
      return false;
    }
    let isSimActived = CommonUtils.isSimStateValid(await sim.getSimState(curSlotId));
    await UpParamsCacheUtils.getInstance().getMainMenuParams(this.context, curSlotId);
    return isSimActived;
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    HiLog.info(TAG, 'onWindowStageCreate');
    this.windowStage = windowStage;
    this.onRequest(this.wantOnCreate, true);
  }

  onWindowStageDestroy(): void {
    HiLog.info(TAG, 'onWindowStageDestroy');
    this.windowStage = undefined;
  }

  onForeground(): void {
    HiLog.info(TAG, 'onForeground');
    if (this.isRefreshPageToHome()) {
      let slotId = this.localStorage.get<number>(LocalStorageKey.SLOT_ID);
      if (slotId === undefined) {
        return;
      }
      this.refreshPageToHome(slotId);
    }
  }

  onBackground(): void {
    HiLog.info(TAG, ' onBackground');
  }

  private isRefreshPageToHome(): boolean {
    let refreshPage = SettingsDataHelper.getInstance().getSubUserSimAbsent(this.context);
    if (refreshPage) {
      HiLog.info(TAG, 'refresh main menu cache');
      SettingsDataHelper.getInstance().setSubUserSimAbsent(this.context, false);
      return true;
    }
    return false;
  }

  private async refreshPageToHome(slotId: number): Promise<void> {
    HiLog.info(TAG, 'refreshPageToHome start');
    let isSimActive = await this.checkSimStatus(slotId);
    if (!isSimActive) {
      CommonUtils.terminateSelfCust(ContextStorageHelper.getInstance().getServiceContext());
      CommonUtils.terminateSelfCust(this.context);
      HiLog.info(TAG, 'isSimActive exit');
      return;
    }
    let mainMenu = await UpParamsCacheUtils.getInstance().getMainMenuParams(this.context, slotId);
    if (CommonUtils.isEmptyObj(mainMenu)) {
      CommonUtils.terminateSelfCust(ContextStorageHelper.getInstance().getServiceContext());
      CommonUtils.terminateSelfCust(this.context);
      HiLog.info(TAG, 'mainMenu exit');
      return;
    }
    this.context.getApplicationContext().eventHub.emit(EventHub.TO_CLOSE_DIALOG);
    this.setSlotIdAndParamsToLocalStorage(slotId, mainMenu);
    this.routerPushUrlAndClear(PageUrl.PAGE_URL_MAIN);
  }

  private async checkSimStatus(slotId: number): Promise<boolean> {
    try {
      let simStatus: sim.SimState | undefined = undefined;
      if (slotId === SimId.SLOT_ID_0) {
        simStatus = await sim.getSimState(SimId.SLOT_ID_0);
      } else if (CommonUtils.isTwoSimCount() && slotId === SimId.SLOT_ID_1) {
        simStatus = await sim.getSimState(SimId.SLOT_ID_1);
      }
      if (simStatus !== undefined) {
        return Promise.resolve(CommonUtils.isSimStateValid(simStatus));
      }
    } catch (error) {
      HiLog.error(TAG, 'checkSimStatus error');
    }
    return Promise.resolve(false);
  }
}