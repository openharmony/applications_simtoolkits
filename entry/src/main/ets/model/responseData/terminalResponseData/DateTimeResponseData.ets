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
import { DefaultResponseData } from './DefaultResponseData';
import HiLog from '../../../common/utils/HiLog';
import { BaseUpParams } from '../../upDecode/BaseUpParams';
import CommonUtils from '../../../common/utils/CommonUtils';
import { CommandType, MOVE_SIZE_FOUR, VALUE_HEX_80, VALUE_HEX_FF } from '../../../common/constant/SimToolKitConstant';

const TAG = 'DateTimeResponseData';
const VALUE_QUARTER_OF_HOUR = 900000;
const BCD_MAX_SIZE = 99;
const MODULO_SIZE_TEN = 10;
const MODULO_SIZE_100 = 100;

export class DateTimeResponseData extends DefaultResponseData {
  constructor(upParams?: BaseUpParams) {
    super(upParams);
  }

  private numberToBCD(value: number): number {
    if (value < 0 || value > BCD_MAX_SIZE) {
      HiLog.error(TAG, 'numberToBCD error');
      return 0;
    }
    let heightFour = Math.trunc(value / MODULO_SIZE_TEN);
    let lowFour = (value % MODULO_SIZE_TEN) << MOVE_SIZE_FOUR;
    return ((heightFour | lowFour) & VALUE_HEX_FF);
  }

  private getTZOffSetByte(offSetVal: number): number {
    let isNegative = (offSetVal < 0);
    let tzOffset = Math.trunc(offSetVal / VALUE_QUARTER_OF_HOUR);
    tzOffset = (isNegative ? -1 : 1) * tzOffset;
    let bcdVal = this.numberToBCD(tzOffset);
    return isNegative ? (bcdVal |= VALUE_HEX_80) : bcdVal;
  }

  private getCurrentTime(): Array<number> {
    let arr: number[] = [];
    let data = new Date();
    let year = Math.trunc(data.getFullYear() % MODULO_SIZE_100);
    arr.push(this.numberToBCD(year));

    let month = data.getMonth() + 1;
    arr.push(this.numberToBCD(month));

    let date = data.getDate();
    arr.push(this.numberToBCD(date));

    let hours = data.getHours();
    arr.push(this.numberToBCD(hours));

    let minutes = data.getMinutes();
    arr.push(this.numberToBCD(minutes));

    let seconds = data.getSeconds();
    arr.push(this.numberToBCD(seconds));

    let offset: number = i18n.getTimeZone().getOffset(data.getMilliseconds());
    let zone: number = this.getTZOffSetByte(offset);
    arr.push(zone);
    return arr;
  }

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'DTTZTimeResponseData  parseDataToHex start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr)) {
      HiLog.error(TAG, 'DTTZTimeResponseData paramter error');
      return [];
    }
    vecArr.push(VALUE_HEX_80 | CommandType.PROVIDE_LOCAL_INFORMATION);
    let timeArr = this.getCurrentTime();
    vecArr.push(timeArr.length);
    timeArr.forEach(value => {
      vecArr.push(value);
    });
    return vecArr;
  }
}