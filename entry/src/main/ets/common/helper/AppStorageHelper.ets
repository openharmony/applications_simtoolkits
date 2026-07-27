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

import CommonUtils from '../utils/CommonUtils';
import HiLog from '../utils/HiLog';

const TAG = 'AppStorageHelper';

/**
 * AppStorage key enum
 *
 * @since 2023-07-18
 */
export enum AppStorageKey {

  /**
   * main menu data key
   */
  MAIN_MENU_PARAM_PREFIX = 'mainMenuParamPrefix_',

  /**
   * current param key
   */
  CURRENT_UP_PARAM_PREFIX = 'currentUpParamPrefix_',

  /**
   * sim title key
   */
  SIM_TITLE_PREFIX = 'simTitlePrefix_',

  /**
   * Modal Dialog: When a page exists, the dialog and page binding are easily destroyed together.
   */
  PAGE_BIND_DIALOG_PARAM = 'pageBindDialogParam',

  /**
   * Indicates whether the menu page is on the foreground.
   */
  IS_MENU_PAGE_SHOW = 'isMenuPageShow',

  /**
   * Indicates whether the ConfirmDialog page is on the foreground.
   */
  IS_CONFIRM_DIALOG_SHOW = 'isConfirmDialogShow',

  /**
   * a session not repeat pop-up lock screen notifications
   */
  NOTIFY_HAS_RESPONSE_FROM_USER_KEY = 'notifyHasResponseFromUserKey_',

  /**
   * fontSizeScale
   */
  FONT_SIZE_SCALE_KEY = 'font_size_scale_key',
}

/**
 * AppStorageHelper
 *
 * @since 2023-07-18
 */
export class AppStorageHelper {
  /**
   * Mount the variable value to the AppStorage instance.
   *
   * @param key Key to be mounted
   * @param value Value to be mounted
   */
  public static set<T>(key: string, value: T): void {
    if (CommonUtils.isEmptyStr(key)) {
      HiLog.error(TAG, 'The key is empty, return!!');
      return;
    }
    if (AppStorage.has(key)) {
      AppStorage.set<T>(key, value);
    } else {
      AppStorage.setOrCreate<T>(key, value);
    }
  }

  /**
   * Obtaining Global Variables Mounted to AppStorage
   *
   * @param key Key to be mounted
   * @param defaultValue default value
   * @returns Success: value; Failure: default value
   */
  public static get<T>(key: string, defaultValue: T | undefined = undefined): T | undefined {
    if (!CommonUtils.isEmptyStr(key) && AppStorage.has(key)) {
      return AppStorage.get<T>(key) as T;
    }
    return defaultValue;
  }

  /**
   * Deleting Global Variables Mounted to AppStorage
   *
   * @param key Key to be mounted
   */
  public static remove(key: string): void {
    if (CommonUtils.isEmptyStr(key)) {
      HiLog.error(TAG, 'The key is empty, return remove!!');
      return;
    }
    AppStorage.delete(key);
  }
}
