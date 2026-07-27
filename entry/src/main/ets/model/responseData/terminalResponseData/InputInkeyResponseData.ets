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

import HiLog from '../../../common/utils/HiLog';
import { EncodeDecodeUtils } from '../../../common/utils/EncodeDecodeUtils';
import { DefaultResponseData } from './DefaultResponseData';
import { BaseUpParams, Duration } from '../../upDecode/BaseUpParams';
import CommonUtils from '../../../common/utils/CommonUtils';
import {
  ARR_LENGTH_ONE,
  ARR_LENGTH_TWO, EncodeType, TlvItemType,
  VALUE_HEX_7F,
  VALUE_HEX_80,
  VALUE_HEX_81,
  VALUE_HEX_FF } from '../../../common/constant/SimToolKitConstant';

const TAG = 'InputResponseData';
const GET_INKEY_YES = 0x01;
const GET_INKEY_NO = 0x00;

export class InputInkeyResponseData extends DefaultResponseData {
  public isYesNo: boolean = false;
  public encodeType: number | undefined = undefined;
  public inputData: string | undefined = undefined;
  public isYesNoInKeyData: boolean | undefined = undefined;
  public isNoResponseFromUser: boolean = false;
  public duration: Duration | undefined = undefined;

  constructor(upParams: BaseUpParams) {
    super(upParams);
  }

  public setInputData(inputData: string, inputEncodeType: number, resultCode?: number): void {
    this.isNoResponseFromUser = false;
    this.isYesNo = false;
    this.inputData = inputData;
    this.encodeType = inputEncodeType;
    this.resultCode = resultCode;
  }

  public setYesNoInKeyData(isYesNoInKeyData: boolean, resultCode?: number): void {
    this.isNoResponseFromUser = false;
    this.isYesNo = true;
    this.isYesNoInKeyData = isYesNoInKeyData;
    this.resultCode = resultCode;
  }

  public setTimeOutHaveDuration(duration?: Duration, resultCode?: number): void {
    this.isNoResponseFromUser = true;
    this.duration = duration;
    this.resultCode = resultCode;
  }

  public parseDataToHex(): Array<number> {
    if (this.isNoResponseFromUser) {
      return this.parseDefaultHaveDuration();
    }
    if (this.isYesNo) {
      return this.parseDataToHexYesNo();
    } else {
      return this.parseDataToHexInput();
    }
  }

  private parseDefaultHaveDuration(): Array<number> {
    HiLog.info(TAG, 'parseDefaultHaveDuration start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr)) {
      HiLog.error(TAG, 'parseDefaultHaveDuration paramter error');
      return [];
    }
    if (this.duration) {
      vecArr.push(TlvItemType.DURATION);
      vecArr.push(ARR_LENGTH_TWO);
      vecArr.push(this.duration.timeUnit);
      vecArr.push(this.duration.timeInterval);
    }
    return vecArr;
  }

  private parseDataToHexYesNo(): Array<number> {
    HiLog.info(TAG, 'parseDataToHexYesNo  parseDataToHex start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr) || this.isYesNoInKeyData === undefined) {
      HiLog.error(TAG, 'parseDataToHexYesNo paramter error');
      return [];
    }
    let textTag = TlvItemType.TEXT_STRING | VALUE_HEX_80;
    vecArr.push(textTag);
    vecArr.push(ARR_LENGTH_TWO);
    vecArr.push(EncodeType.GSM8);
    vecArr.push(this.isYesNoInKeyData ? GET_INKEY_YES : GET_INKEY_NO);
    return vecArr;
  }

  private parseDataToHexInput(): Array<number> {
    HiLog.info(TAG, 'InputResponseData  parseDataToHex start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr) || this.encodeType === undefined) {
      HiLog.error(TAG, 'InputResponseData paramter error');
      return [];
    }
    let textTag = TlvItemType.TEXT_STRING | VALUE_HEX_80;
    vecArr.push(textTag);
    let encodeArr: Array<number> | undefined = undefined;
    if (!CommonUtils.isEmptyStr(this.inputData)) {
      encodeArr = EncodeDecodeUtils.getInstance().encodeStringToNumberArray(this.inputData, this.encodeType);
    }
    if (encodeArr === undefined || encodeArr.length === 0 || encodeArr.length + 1 > VALUE_HEX_FF) {
      HiLog.error(TAG, 'InputResponseData Encode inputData error');
      vecArr.push(ARR_LENGTH_ONE);
      vecArr.push(this.encodeType);
    } else {
      let encodeStrArrayLen = encodeArr.length + 1;

      // length
      if (encodeStrArrayLen > VALUE_HEX_7F) {
        vecArr.push(VALUE_HEX_81);
      }
      vecArr.push(encodeStrArrayLen);

      // encodeType
      vecArr.push(this.encodeType);

      // value
      encodeArr.forEach(value => {
        vecArr.push(value);
      });
    }
    return vecArr;
  }
}