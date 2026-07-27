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
import { preferences as data_preferences } from '@kit.ArkData';
import HiLog from './HiLog';

const NAME = 'STK_PREFERENCE';
const TAG = 'SharedPreferencesUtils';

class SharedPreferencesUtils {
  private mPreferences: data_preferences.Preferences | undefined;

  constructor() {
  }

  public async getString(context: common.Context | undefined, key: string, defValue: string): Promise<string> {
    let preferences = await this.getPreferences(context);
    if (!preferences) {
      HiLog.info(TAG, 'getNumberArray preferences is empty');
      return '';
    } else {
      let resultValue: string = String((await preferences.get(key, defValue)) ?? '');
      return resultValue;
    }
  }

  public async getNumberArray(context: common.Context | undefined, key: string): Promise<Array<number>> {
    let preferences = await this.getPreferences(context);
    if (!preferences) {
      HiLog.info(TAG, 'getNumberArray preferences is empty');
      return [];
    } else {
      let resultValue: number[] = await preferences.get(key, []) as Array<number>;
      return resultValue;
    }
  }

  public async saveString(context: common.Context | undefined, key: string, value: string): Promise<void> {
    let preferences = await this.getPreferences(context);
    if (!preferences) {
      HiLog.info(TAG, 'saveString preferences is empty');
    } else {
      await preferences.put(key, value);
      preferences.flush();
    }
  }

  public async saveNumberArray(context: common.Context | undefined, key: string, value: Array<number>): Promise<void> {
    let preferences = await this.getPreferences(context);
    if (!preferences) {
      HiLog.info(TAG, 'saveNumberArray preferences is empty');
    } else {
      await preferences.put(key, value);
      preferences.flush();
    }
  }

  public async deleteToPreferences(context: common.Context | undefined, key: string): Promise<void> {
    let preferences = await this.getPreferences(context);
    if (!preferences) {
      HiLog.info(TAG, 'deleteToPreferences preferences is empty');
    } else {
      await preferences.delete(key);
      preferences.flush();
    }
  }

  private async getPreferences(context: common.Context | undefined): Promise<data_preferences.Preferences | undefined> {
    if (!context) {
      HiLog.info(TAG, 'getPreferences context is empty');
      return undefined;
    }
    if (this.mPreferences) {
      return this.mPreferences;
    }
    try {
      this.mPreferences = await data_preferences.getPreferences(context, NAME);
      return this.mPreferences;
    } catch (error) {
      HiLog.error(TAG, '[getPreferences] error');
      return undefined;
    }
  }
}

export const sharedPreferencesUtils: SharedPreferencesUtils = new SharedPreferencesUtils();