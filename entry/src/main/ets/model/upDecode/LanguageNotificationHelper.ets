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
import { i18n } from '@kit.LocalizationKit';
import { sharedPreferencesUtils } from '../../common/utils/SharedPreferencesUtils';
import { ResponseCode } from '../../common/constant/SimToolKitConstant';
import { LanguageNotificationParam } from './LanguageNotificationParam';

const NON_SPECIFIC_LANGUAGE = 0x00;
const SPECIFIC_LANGUAGE = 0x01;
const SP_SAVED_LANGUAGE_KEY = 'SP_SAVED_LANGUAGE_KEY_';
const SP_REQUESTED_LANGUAGE_KEY = 'SP_REQUESTED_LANGUAGE_KEY_';

export class LanguageNotificationHelper {
  public async parseLanguage(context: common.Context | undefined, param: LanguageNotificationParam): Promise<void> {
    if (!context || param.parseResultCode !== ResponseCode.OK) {
      return;
    }
    // get sp cache
    let savedLanguageKey = SP_SAVED_LANGUAGE_KEY + param.slotId;
    let requestedLanguageKey = SP_REQUESTED_LANGUAGE_KEY + param.slotId;
    let savedLanguage = await sharedPreferencesUtils.getString(context, savedLanguageKey, '');
    let requestedLanguage = await sharedPreferencesUtils.getString(context, requestedLanguageKey, '');

    let desiredLanguage: string = '';
    let currentLanguage: string = this.getCurrentLanguage();
    switch (param.commandQual) {
      case NON_SPECIFIC_LANGUAGE:
        if (savedLanguage && (requestedLanguage && requestedLanguage === currentLanguage)) {
          desiredLanguage = savedLanguage;
        }
        sharedPreferencesUtils.deleteToPreferences(context, savedLanguageKey);
        sharedPreferencesUtils.deleteToPreferences(context, requestedLanguageKey);
        break;
      case SPECIFIC_LANGUAGE:
        desiredLanguage = param.parseLanguage ?? '';
        if (desiredLanguage) {
          if (!savedLanguage || (requestedLanguage && requestedLanguage !== currentLanguage)) {
            sharedPreferencesUtils.saveString(context, savedLanguageKey, currentLanguage);
          }
          sharedPreferencesUtils.saveString(context, requestedLanguageKey, desiredLanguage);
        }
        break;
      default:
        break;
    }
    param.language = desiredLanguage;
  }

  private getCurrentLanguage(): string {
    let language = i18n.System.getSystemLanguage();
    let firstIndex = language.indexOf('-');
    if (firstIndex > 0) {
      language = language.substring(0, firstIndex);
    }
    return language;
  }
}