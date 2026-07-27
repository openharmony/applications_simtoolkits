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

import { EncodeDecodeUtils } from '../../../common/utils/EncodeDecodeUtils';
import { BaseEventListEnvelopeData } from './BaseEventListEnvelopeData';
import HiLog from '../../../common/utils/HiLog';
import CommonUtils from '../../../common/utils/CommonUtils';
import {
  ARR_INDEX_ONE,
  ARR_LENGTH_TWO,
  EncodeType,
  TlvItemType,
  VALUE_HEX_80
} from '../../../common/constant/SimToolKitConstant';

const TAG = 'LanguageEventListEnvelopeData';

export class LanguageEventListEnvelopeData extends BaseEventListEnvelopeData {
  public language: string = '';

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'LanguageEventListEnvelopeData  parseDataToHex start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr) || (!this.language)) {
      HiLog.error(TAG, 'LanguageEventListEnvelopeData paramter error');
      return [];
    }
    let encodeStrArr = EncodeDecodeUtils.getInstance().encodeStringToNumberArray(
      this.language, EncodeType.GSM8);
    vecArr.push(VALUE_HEX_80 | TlvItemType.LANGUAGE);
    if (CommonUtils.isEmptyArr(encodeStrArr)) {
      HiLog.error(TAG, 'LanguageEventListEnvelopeData encode language error');
      return [];
    } else {
      // Language length should be 2 byte
      vecArr.push(ARR_LENGTH_TWO);
      let maxEncodeArrCount = Math.min(ARR_LENGTH_TWO, encodeStrArr.length);
      for (let i = 0; i < maxEncodeArrCount; i++) {
        vecArr.push(encodeStrArr[i]);
      }
    }

    // set total length
    vecArr[ARR_INDEX_ONE] = vecArr.length - ARR_LENGTH_TWO;
    return vecArr;
  }
}