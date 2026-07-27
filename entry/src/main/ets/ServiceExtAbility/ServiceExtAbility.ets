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

import { dialogRequest, ServiceExtensionAbility, Want } from '@kit.AbilityKit';
import UiUtils from '../common/utils/UiUtils';
import HiLog from '../common/utils/HiLog';
import { SimToolKitAppService } from '../model/SimToolKitAppService';
import { AppStorageHelper, AppStorageKey } from '../common/helper/AppStorageHelper';
import { BaseUpParams } from '../model/upDecode/BaseUpParams';
import { ContextStorageHelper } from '../common/utils/ContextStorageHelper';
import { HapWindowId } from '../common/constant/Constants';

const TAG: string = 'ServiceExtAbility';

export default class ServiceExtAbility extends ServiceExtensionAbility {
  onCreate(want: Want): void {
    HiLog.info(TAG, 'onCreate');
    SimToolKitAppService.getInstance().setServiceContext(this.context);
    ContextStorageHelper.getInstance().setServiceContext(this.context);
  }

  onRequest(want: Want, startId: number): void {
    HiLog.info(TAG, `onRequest startId:${startId} action:${want?.action}`);
    this.checkIsShowDialog(want);
    this.toAppServiceDistribute(want);
  }

  private toAppServiceDistribute(want: Want): void {
    HiLog.info(TAG, 'toAppServiceDistribute');
    if (!want?.parameters) {
      HiLog.debug(TAG, 'the parameters of want is undefined.');
      return;
    }
    if (want?.action) {
      SimToolKitAppService.getInstance().callBackFromService(want.parameters, want.action);
    }
  }

  private pullDialogParamsToMemory(curDialogRequestInfo: dialogRequest.RequestInfo | undefined,
    dialogParams: BaseUpParams): void {
    if (curDialogRequestInfo) {
      AppStorageHelper.set<BaseUpParams>(AppStorageKey.PAGE_BIND_DIALOG_PARAM, dialogParams);
    }
  }

  private getDialogRequestInfo(want: Want, dialogParams: BaseUpParams): dialogRequest.RequestInfo | undefined {
    HiLog.info(TAG, 'getDialogRequestIno');
    let curDialogRequestInfo: dialogRequest.RequestInfo | undefined = undefined;
    let isRequestDialog = want?.parameters?.isRequestDialogService;
    if (isRequestDialog && dialogParams && AppStorageHelper.get<boolean>(AppStorageKey.IS_MENU_PAGE_SHOW, false)) {
      HiLog.info(TAG, 'checkIsShowDialog page isShow and isRequestDialog is true');
      try {
        curDialogRequestInfo = dialogRequest.getRequestInfo(want);
      } catch (err) {
        HiLog.error(TAG, `getDialogRequestIno error. Code: ${err?.code}, message: ${err?.message}`);

      }
    }
    this.pullDialogParamsToMemory(curDialogRequestInfo, dialogParams);
    return curDialogRequestInfo;
  }

  private checkIsShowDialog(want: Want): void {
    HiLog.info(TAG, 'checkIsShowDialog');
    let dialogParams = want?.parameters?.dialogOriParams as BaseUpParams;
    let toastContent = want?.parameters?.toastContent;
    if (dialogParams || toastContent) {
      let windowId: string =
        toastContent ? HapWindowId.DIALOG_ID_TOAST : HapWindowId.DIALOG_ID_NORMAL;
      windowId = `${windowId}_${new Date().getTime()}`;
      let storage: LocalStorage = new LocalStorage();
      storage.setOrCreate('params', dialogParams);
      storage.setOrCreate('toastContent', toastContent);
      storage.setOrCreate('windowId', windowId);
      if (dialogParams) {
        UiUtils.showDialog(this.context, windowId, storage, this.getDialogRequestInfo(want, dialogParams));
        return;
      }
      UiUtils.showDialog(this.context, windowId, storage);
    }
  }

  onDestroy(): void {
    HiLog.info(TAG, 'onDestroy');
    SimToolKitAppService.getInstance().setServiceContext(undefined);
    ContextStorageHelper.getInstance().setServiceContext(undefined);
    SimToolKitAppService.getInstance().endSessionCurrentCmd();
  }
}