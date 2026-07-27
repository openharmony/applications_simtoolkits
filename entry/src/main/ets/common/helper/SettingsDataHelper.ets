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
import { BusinessError, settings } from '@kit.BasicServicesKit';
import HiLog from '../utils/HiLog';
import { SetUpMenuParam } from '../../model/upDecode/SetUpMenuParam';

const TAG = 'SettingsDataHelper';
const MAIN_MENU_PROP_KEY: string = 'HwSimToolkits_MainMenu_';
const SUB_USER_ABSENT_KEY: string = 'HwSimToolkits_sub_user_absent';
const SUB_USER_REFRESH_KEY: string = 'HwSimToolkits_sub_user_refresh';
const SETTINGS_DATA_VALUE_TRUE: string = '1';
const SETTINGS_DATA_VALUE_FALSE: string = '0';

export class SettingsDataHelper {
  private static instance: SettingsDataHelper | undefined = undefined;

  private constructor() {
  }

  public static getInstance(): SettingsDataHelper {
    if (!SettingsDataHelper.instance) {
      SettingsDataHelper.instance = new SettingsDataHelper();
    }
    return SettingsDataHelper.instance;
  }

  public async querySetUpParam(
    context: common.Context | undefined, slotId: number): Promise<SetUpMenuParam | undefined> {
    if (context === undefined || slotId === undefined) {
      HiLog.error(TAG, '[querySetUpParam] is empty');
      return undefined;
    }
    try {
      let menuJsonStr = await settings.getValue(context, `${MAIN_MENU_PROP_KEY}${slotId}`);
      let param = JSON.parse(menuJsonStr) as SetUpMenuParam;
      return param;
    } catch (error) {
      HiLog.error(TAG, '[querySetUpParam] error');
      return undefined;
    }
  }

  public async insertSetUpParam(context: common.Context | undefined, menuParam: SetUpMenuParam): Promise<boolean> {
    if (context === undefined || menuParam === undefined || menuParam?.slotId === undefined) {
      HiLog.error(TAG, '[insertSetUpParam] is empty');
      return Promise.resolve(false);
    }
    try {
      let jsonParam = JSON.stringify(menuParam);
      let result = await settings.setValue(context, `${MAIN_MENU_PROP_KEY}${menuParam.slotId}`, jsonParam);
      return Promise.resolve(result);
    } catch (error) {
      let paramError = error as BusinessError;
      HiLog.error(TAG, `[insertSetUpParam] error: ${paramError.code}, ${paramError.message} `);
      return Promise.resolve(false);
    }
  }

  public async deleteSetUpParam(context: common.Context | undefined, slotId: number): Promise<void> {
    if (context === undefined || slotId === undefined) {
      HiLog.error(TAG, '[deleteSetUpParam] is empty');
      return;
    }
    try {
      await settings.setValue(context, `${MAIN_MENU_PROP_KEY}${slotId}`, '');
    } catch (error) {
      let paramError = error as BusinessError;
      HiLog.error(TAG, `[deleteSetUpParam] error: ${paramError.code}, ${paramError.message} `);
    }
  }

  private setSettingsDataBoolean(context: common.Context | undefined, key: string, value: boolean): void {
    if (context === undefined) {
      HiLog.error(TAG, `[setSettingsDataBoolean] key: ${key} is empty`);
      return;
    }
    try {
      settings.setValueSync(context, key, value ? SETTINGS_DATA_VALUE_TRUE : SETTINGS_DATA_VALUE_FALSE);
    } catch (error) {
      let paramError = error as BusinessError;
      HiLog.error(TAG, `[setSettingsDataBoolean] key:${key}--error: ${paramError.code}, ${paramError.message}`);
    }
  }

  private getSettingsDataBoolean(context: common.Context | undefined, key: string): boolean {
    if (context === undefined) {
      HiLog.error(TAG, `[getSettingsDataBoolean] key: ${key} is empty`);
      return false;
    }
    try {
      return settings.getValueSync(context, key, SETTINGS_DATA_VALUE_FALSE) === SETTINGS_DATA_VALUE_TRUE;
    } catch (error) {
      let paramError = error as BusinessError;
      HiLog.error(TAG, `[getSettingsDataBoolean] key:${key}--error: ${paramError.code}, ${paramError.message}`);
    }
    return false;
  }

  public setSubUserSimAbsent(context: common.Context | undefined, isAbsent: boolean): void {
    this.setSettingsDataBoolean(context, SUB_USER_ABSENT_KEY, isAbsent);
  }

  public getSubUserSimAbsent(context: common.Context | undefined): boolean {
    return this.getSettingsDataBoolean(context, SUB_USER_ABSENT_KEY);
  }

  public setSubUserSimRefresh(context: common.Context | undefined, isRefresh: boolean): void {
    this.setSettingsDataBoolean(context, SUB_USER_REFRESH_KEY, isRefresh);
  }

  public getSubUserSimRefresh(context: common.Context | undefined): boolean {
    return this.getSettingsDataBoolean(context, SUB_USER_REFRESH_KEY);
  }
}
