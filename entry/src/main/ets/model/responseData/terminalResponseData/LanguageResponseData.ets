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
import HiLog from '../../../common/utils/HiLog';
import { EncodeDecodeUtils } from '../../../common/utils/EncodeDecodeUtils';
import { TlvItemType, EncodeType, VALUE_HEX_80, ARR_LENGTH_TWO } from '../../../common/constant/SimToolKitConstant';
import { DefaultResponseData } from './DefaultResponseData';
import { BaseUpParams } from '../../upDecode/BaseUpParams';
import CommonUtils from '../../../common/utils/CommonUtils';

const TAG = 'LanguageResponseData';

export class LanguageResponseData extends DefaultResponseData {
  public language: string = '';

  constructor(upParams?: BaseUpParams) {
    super(upParams);
  }

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'LanguageResponseData  parseDataToHex start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr)) {
      HiLog.error(TAG, 'LanguageResponseData paramter error');
      return [];
    }
    this.language = i18n.System.getSystemLanguage();
    vecArr.push(TlvItemType.LANGUAGE | VALUE_HEX_80);
    let encodeStrArr = EncodeDecodeUtils.getInstance().encodeStringToNumberArray(this.language, EncodeType.GSM8);
    if (CommonUtils.isEmptyArr(encodeStrArr)) {
      vecArr.push(0);
    } else {
      // Language length should be 2 byte
      vecArr.push(ARR_LENGTH_TWO);
      let maxEncodeArrCount = Math.min(ARR_LENGTH_TWO, encodeStrArr.length);
      for (let i = 0; i < maxEncodeArrCount; i++) {
        vecArr.push(encodeStrArr[i]);
      }
    }
    return vecArr;
  }
}