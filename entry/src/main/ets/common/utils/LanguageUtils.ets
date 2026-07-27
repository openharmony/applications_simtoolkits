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

import { i18n } from '@kit.LocalizationKit';
import CommonUtils from './CommonUtils';

const TAG = 'LanguageUtils';

export default class LanguageUtils {
  private static languageNameMap: Map<string, string> = new Map([
    ['zh', 'zh-Hans']
  ]);

  public static getSystemLanguageFullName(language: string): string {
    let arrLanguage: string[] = i18n.System.getSystemLanguages();
    if (CommonUtils.isEmptyArr(arrLanguage)) {
      return language;
    }
    let curFullLanguage: string[] = [];
    for (let i = 0; i < arrLanguage.length; i++) {
      let curLanguage = arrLanguage[i];
      if (!CommonUtils.isEmptyStr(curLanguage) && curLanguage.startsWith(language)) {
        curFullLanguage.push(curLanguage);
      }
    }
    if (curFullLanguage.length === 1) {
      return curFullLanguage[0];
    }
    let mapResult = LanguageUtils.getMappingLanguageName(language);
    return mapResult;
  }

  private static getMappingLanguageName(language: string): string {
    let mapLanguage = LanguageUtils.languageNameMap.get(language);
    if (mapLanguage === undefined || mapLanguage.length === 0) {
      return language;
    }
    return mapLanguage;
  }
}