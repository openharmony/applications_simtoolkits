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
import HiLog from './HiLog';
import { BaseUpParams } from '../../model/upDecode/BaseUpParams';
import { SetUpMenuParam } from '../../model/upDecode/SetUpMenuParam';
import CommonUtils from './CommonUtils';
import { AppStorageHelper, AppStorageKey } from '../helper/AppStorageHelper';
import { SettingsDataHelper } from '../helper/SettingsDataHelper';
import { SimId } from '../constant/Constants';

const TAG = 'MainAndCurrentParamsCacheUtils';

export class UpParamsCacheUtils {
  private static instance: UpParamsCacheUtils;

  private constructor() {
  }

  public static getInstance(): UpParamsCacheUtils {
    if (!UpParamsCacheUtils.instance) {
      UpParamsCacheUtils.instance = new UpParamsCacheUtils();
    }
    return UpParamsCacheUtils.instance;
  }

  public async getCurrentUpParams(slotId: number): Promise<BaseUpParams | undefined> {
    return AppStorageHelper.get<BaseUpParams>(`${AppStorageKey.CURRENT_UP_PARAM_PREFIX}${slotId}`, undefined);
  }

  public putCurrentUpParamsMemory(upParams: BaseUpParams): boolean {
    if (CommonUtils.isEmptyObj(upParams)) {
      HiLog.error(TAG, 'putCurrentUpParams BaseUpParams undefined');
      return false;
    }
    AppStorageHelper.set<BaseUpParams>(`${AppStorageKey.CURRENT_UP_PARAM_PREFIX}${upParams.slotId}`, upParams);
    return true;
  }

  public deleteCurrentUpParams(context: common.Context | undefined, slotId: number): void {
    AppStorageHelper.remove(`${AppStorageKey.CURRENT_UP_PARAM_PREFIX}${slotId}`);
  }

  public getSimTitle(slotId: number): string {
    return AppStorageHelper.get<string>(`${AppStorageKey.SIM_TITLE_PREFIX}${slotId}`, '') ?? '';
  }

  public getMainMenuParamsMemory(slotId: number): SetUpMenuParam | undefined {
    let param = AppStorageHelper.get<SetUpMenuParam>(`${AppStorageKey.MAIN_MENU_PARAM_PREFIX}${slotId}`, undefined);
    if (!param || CommonUtils.isEmptyArr(param.itemArray)) {
      param = undefined;
    }
    return param;
  }

  public async getMainMenuParams(
    context: common.Context | undefined, slotId: number): Promise<SetUpMenuParam | undefined> {
    // to refresh memory cache
    let isRefresh = SettingsDataHelper.getInstance().getSubUserSimRefresh(context);
    if (isRefresh) {
      this.deleteMainMenuParamsCache(SimId.SLOT_ID_0);
      this.deleteMainMenuParamsCache(SimId.SLOT_ID_1);
      HiLog.info(TAG, 'refresh main menu cache');
      SettingsDataHelper.getInstance().setSubUserSimRefresh(context, false);
    }

    let param = AppStorageHelper.get<SetUpMenuParam>(`${AppStorageKey.MAIN_MENU_PARAM_PREFIX}${slotId}`,
      undefined);
    if (!param) {
      param = await SettingsDataHelper.getInstance().querySetUpParam(context, slotId);
      this.putMainMenuParamsMemory(param);
    }
    if (!param || CommonUtils.isEmptyArr(param.itemArray)) {
      param = undefined;
    }
    return param;
  }

  public putMainMenuParamsMemory(upParams: SetUpMenuParam | undefined): boolean {
    if (!upParams) {
      HiLog.error(TAG, 'putMainMenuParams SetUpMenuParam undefined');
      return false;
    }
    if (CommonUtils.isEmptyArr(upParams.itemArray)) {
      AppStorageHelper.remove(`${AppStorageKey.MAIN_MENU_PARAM_PREFIX}${upParams.slotId}`);
      AppStorageHelper.remove(`${AppStorageKey.SIM_TITLE_PREFIX}${upParams.slotId}`);
      return false;
    }
    AppStorageHelper.set<SetUpMenuParam>(`${AppStorageKey.MAIN_MENU_PARAM_PREFIX}${upParams.slotId}`, upParams);
    if (!CommonUtils.isEmptyStr(upParams.menuTitle)) {
      AppStorageHelper.set<string>(`${AppStorageKey.SIM_TITLE_PREFIX}${upParams.slotId}`, upParams.menuTitle);
    }
    return true;
  }

  public deleteMainMenuParams(context: common.Context | undefined, slotId: number): void {
    AppStorageHelper.remove(`${AppStorageKey.MAIN_MENU_PARAM_PREFIX}${slotId}`);
    AppStorageHelper.remove(`${AppStorageKey.SIM_TITLE_PREFIX}${slotId}`);
    SettingsDataHelper.getInstance().deleteSetUpParam(context, slotId);
  }

  private deleteMainMenuParamsCache(slotId: number): void {
    AppStorageHelper.remove(`${AppStorageKey.MAIN_MENU_PARAM_PREFIX}${slotId}`);
    AppStorageHelper.remove(`${AppStorageKey.SIM_TITLE_PREFIX}${slotId}`);
  }

  public async insertMainMenuToDB(context: common.Context | undefined, upParams: BaseUpParams): Promise<boolean> {
    try {
      return await SettingsDataHelper.getInstance().insertSetUpParam(context, upParams as SetUpMenuParam);
    } catch (error) {
      HiLog.error(TAG, '[insertMainMenuToDB] error');
      return false;
    }
  }
}