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

import {
  CommandType,
  EncodeType,
  ResponseCode,
  VALUE_HEX_01,
  VALUE_HEX_02,
  VALUE_HEX_04,
  VALUE_HEX_08,
  VALUE_HEX_80
} from '../../common/constant/SimToolKitConstant';
import HiLog from '../../common/utils/HiLog';
import { BaseUpParams } from './BaseUpParams';
import { Duration, ResponseLength } from './BaseUpParams';
import { DecodeItemUtil } from './DecodeItemUtil';
import { Tlv } from './Tlv';

const MAX_GSM7_DEFAULT_CHARS = 239;
const MAX_UCS2_CHARS = 118;
const TAG = 'GetInkeyInputParam';

export class GetInkeyInputParam extends BaseUpParams {
  public text: string = '';
  public duration: number = 0;
  public durationObj: Duration | undefined = undefined;
  public isDigitOnly: boolean = false;
  public isUcs2: boolean = false;
  public isYesNo: boolean = false;
  public isHelpAvailable: boolean = false;
  public isEcho: boolean = false;
  public isPacked: boolean = false;
  public responseMinLength: number = 1;
  public responseMaxLength: number = 1;
  public defaultText: string = '';
  public inputEncodeType: number = EncodeType.GSM8;

  constructor(commandType: number) {
    super();
    this.commandType = commandType;
  }

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.processCommandQual();
      let textResultInfo = DecodeItemUtil.parseTextString(tlvList);
      if (textResultInfo.isHaveTag) {
        this.text = textResultInfo.data ?? '';
      } else {
        this.text = '';
        this.parseResultCode = ResponseCode.REQUIRED_VALUES_MISSING;
      }
    }
    if (this.parseResultCode === ResponseCode.OK &&
      this.commandType === CommandType.GET_INPUT) {
      if (this.processInputResponse(tlvList) === undefined) {
        this.parseResultCode = ResponseCode.REQUIRED_VALUES_MISSING;
      }
    }
    if (this.parseResultCode === ResponseCode.OK) {
      this.durationObj = DecodeItemUtil.parseDuration(tlvList, false);
      this.duration = DecodeItemUtil.calculatedDuration(this.durationObj);
      if (this.duration === 0) {
        this.durationObj = undefined;
      }
    }
    if (this.parseResultCode === ResponseCode.OK &&
      this.commandType === CommandType.GET_INPUT) {
      let parseDefaultStr = DecodeItemUtil.parseDefaultString(tlvList).data;
      if (parseDefaultStr) {
        this.defaultText = parseDefaultStr;
      } else {
        this.defaultText = '';
      }
    }
  }

  private processCommandQual(): void {
    if (this.commandType === CommandType.GET_INKEY) {
      this.isDigitOnly = (this.commandQual & VALUE_HEX_01) === 0;
      this.isUcs2 = (this.commandQual & VALUE_HEX_02) !== 0;
      this.isYesNo = (this.commandQual & VALUE_HEX_04) !== 0;
      this.isHelpAvailable = (this.commandQual & VALUE_HEX_80) !== 0;
      this.isEcho = true;
      this.isPacked = false;

      this.responseMinLength = 1;
      this.responseMaxLength = 1;
    } else {
      this.isDigitOnly = (this.commandQual & VALUE_HEX_01) === 0;
      this.isUcs2 = (this.commandQual & VALUE_HEX_02) !== 0;
      this.isEcho = (this.commandQual & VALUE_HEX_04) === 0;
      this.isPacked = (this.commandQual & VALUE_HEX_08) !== 0;
      this.isHelpAvailable = (this.commandQual & VALUE_HEX_80) !== 0;
    }
    this.inputEncodeType = this.getInputEncodeType();
  }

  private processInputResponse(tlvList: Array<Tlv>): ResponseLength | undefined {
    let responseLength = DecodeItemUtil.parseResponseLength(tlvList, true);
    if (responseLength === undefined) {
      return undefined;
    }
    this.responseMinLength = responseLength.minLength;
    this.responseMaxLength = responseLength.maxLength;
    if (this.isUcs2 && this.responseMaxLength > MAX_UCS2_CHARS) {
      HiLog.info(TAG, `UCS2: received maxLen = ${this.responseMaxLength}, truncating to ${MAX_UCS2_CHARS}`);
      this.responseMaxLength = MAX_UCS2_CHARS;
    } else if (!this.isPacked && this.responseMaxLength > MAX_GSM7_DEFAULT_CHARS) {
      HiLog.info(TAG,
        `GSM 7Bit Default: received maxLen = ${this.responseMaxLength}, truncating to ${MAX_GSM7_DEFAULT_CHARS}`);
      this.responseMaxLength = MAX_GSM7_DEFAULT_CHARS;
    }
    return responseLength;
  }

  private getInputEncodeType(): number {
    if (this.isUcs2) {
      return EncodeType.UCS2;
    }
    if (this.isPacked) {
      return EncodeType.GSM7;
    }
    return EncodeType.GSM8;
  }
}