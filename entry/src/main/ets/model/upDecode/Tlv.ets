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

import { EncodeDecodeUtils } from '../../common/utils/EncodeDecodeUtils';
import HiLog from '../../common/utils/HiLog';
import CommonUtils from '../../common/utils/CommonUtils';
import {
  ARR_INDEX_ONE,
  ARR_INDEX_TWO,
  ARR_LENGTH_ONE,
  ARR_LENGTH_TWO,
  ARR_LENGTH_THREE,
  MOVE_SIZE_EIGHT,
  TlvItemType,
  TlvType,
  VALUE_HEX_100,
  VALUE_HEX_10000,
  VALUE_HEX_7F,
  VALUE_HEX_80,
  VALUE_HEX_8000,
  VALUE_HEX_FF } from '../../common/constant/SimToolKitConstant';

const TAG = 'Tlv';

export class Tlv {
  public tagValue: number = 0;
  public orgTagValue: number = 0;
  public commandType: number = -1;
  public hasCompRequiredFlag: boolean = false;
  public lengthValue: number = 0;
  public valueVec: Array<number> = [];
  public tlvList: Array<Tlv> = [];

  public static tlvDecode(msg: string, tlv: Tlv): boolean {
    let msgByte = EncodeDecodeUtils.getInstance().hexStringToNumberArr(msg);
    if (CommonUtils.isEmptyArr(msgByte)) {
      return false;
    }
    let oneItemByteSize = tlv.parseOneTlv(msgByte, 0);
    if (oneItemByteSize === -1) {
      return false;
    }
    if (tlv.orgTagValue !== TlvType.PROACTIVE_COMMAND) {
      return false;
    }
    return tlv.parseItem(tlv.valueVec, 0);
  }

  private parseItem(msg: Array<number>, startIndex: number): boolean {
    HiLog.info(TAG, 'Tlv ParseItem start.');
    if (msg.length === 0) {
      return false;
    }
    this.tlvList = [];
    while (startIndex < msg.length) {
      let tlv = new Tlv();
      let oneItemByteSize = tlv.parseOneTlv(msg, startIndex);
      if (oneItemByteSize === -1) {
        break;
      }
      this.tlvList.push(tlv);
      startIndex = startIndex + oneItemByteSize;
    }
    if (this.tlvList.length === 0) {
      return false;
    }
    HiLog.info(TAG, 'Tlv ParseItem end.');
    return this.checkALLItemLength(msg, this.tlvList, this.lengthValue) && this.checkFirstChildItem(this.tlvList[0]);
  }

  private checkALLItemLength(msg: Array<number>, allItemTlv: Array<Tlv>, allItemLength: number): boolean {
    HiLog.info(TAG, `checkALLItemLength allItemLength: ${allItemLength}`);
    let tempAllItemLength = 0;
    for (let i = 0; i < allItemTlv.length; i++) {
      let itemLength = allItemTlv[i].lengthValue;
      if (itemLength >= VALUE_HEX_80 && itemLength <= VALUE_HEX_FF) {
        tempAllItemLength += itemLength + ARR_LENGTH_THREE; // 3: 'tag'(1 byte) and 'length'(2 bytes).
      } else if (itemLength >= 0 && itemLength < VALUE_HEX_80) {
        tempAllItemLength += itemLength + ARR_LENGTH_TWO; // 2: 'tag'(1 byte) and 'length'(1 byte).
      } else {
        break;
      }
    }
    HiLog.info(TAG, `checkALLItemLength tempAllItemLength1 : ${tempAllItemLength}`);
    if (tempAllItemLength === allItemLength) {
      return true;
    }
    let startIndex = tempAllItemLength;
    for (let valueIndex = startIndex; valueIndex < msg.length; valueIndex++) {
      if (0 === msg[valueIndex]) {
        tempAllItemLength++;
      }
    }
    HiLog.info(TAG, `checkALLItemLength tempAllItemLength2 : ${allItemLength}`);
    return tempAllItemLength === allItemLength;
  }

  private checkFirstChildItem(tlv: Tlv): boolean {
    if (tlv !== null && tlv.tagValue === TlvItemType.COMMAND_DETAILS) {
      if (tlv.valueVec.length === ARR_LENGTH_THREE) {
        this.commandType = tlv.valueVec[ARR_INDEX_ONE];
        return true;
      }
    }
    HiLog.error(TAG, 'CheckFirstChildItem COMMAND_DETAILS error.');
    return false;
  }

  private parseOneTlv(msg: Array<number>, startIndex: number): number {
    let tagByteSize = this.parseTag(msg, startIndex);
    if (tagByteSize === -1) {
      return tagByteSize;
    }
    startIndex = startIndex + tagByteSize;
    let lenByteSize = this.parseLength(msg, startIndex);
    if (lenByteSize === -1) {
      return lenByteSize;
    }
    startIndex = startIndex + lenByteSize;
    let valueByteSize = this.parseValue(msg, startIndex);
    if (valueByteSize === -1) {
      return valueByteSize;
    }
    return tagByteSize + lenByteSize + valueByteSize;
  }

  private parseTag(msg: Array<number>, startIndex: number): number {
    if (startIndex >= msg.length) {
      HiLog.info(TAG, 'Tag parseTag startIndex > msg.size().');
      return -1;
    }
    let tempTag = msg[startIndex] & VALUE_HEX_FF;
    if (tempTag === 0 || tempTag === VALUE_HEX_80 || tempTag === VALUE_HEX_FF) {
      HiLog.error(TAG, 'Tag parseTag is 0, 0x80, 0xFF.');
      return -1;
    }
    // tag is in single-byte format
    if (tempTag !== VALUE_HEX_7F) {
      this.orgTagValue = tempTag;
      this.tagValue = (tempTag & VALUE_HEX_7F);
      this.hasCompRequiredFlag = (tempTag & VALUE_HEX_80) !== 0;
      return ARR_LENGTH_ONE;
    }
    // tag is in three-byte format  0x7f
    if (startIndex + ARR_LENGTH_TWO >= msg.length) {
      HiLog.info(TAG, 'Tag ParseTag startIndex > msg.size().');
      return -1;
    }
    this.orgTagValue = ((msg[startIndex + ARR_INDEX_ONE] & VALUE_HEX_FF) <<
    MOVE_SIZE_EIGHT) | (msg[startIndex + ARR_INDEX_TWO] & VALUE_HEX_FF);
    this.tagValue = this.orgTagValue & (~VALUE_HEX_8000);
    this.hasCompRequiredFlag = (this.orgTagValue & VALUE_HEX_8000) !== 0;
    return ARR_LENGTH_THREE;
  }

  private parseLength(msg: Array<number>, startIndex: number): number {
    if (startIndex >= msg.length) {
      HiLog.error(TAG, 'Tag ParseLength startIndex > msg.size().');
      return -1;
    }
    let tempLength = msg[startIndex];
    if (tempLength === VALUE_HEX_80) {
      HiLog.error(TAG, 'Tag ParseLength is 0x80.');
      return -1;
    } else if (tempLength < VALUE_HEX_80) {
      this.lengthValue = tempLength;
      return ARR_LENGTH_ONE;
    } else {
      let lengthSize = tempLength & VALUE_HEX_7F;
      if (lengthSize > ARR_LENGTH_THREE || startIndex + lengthSize > msg.length - 1) {
        HiLog.error(TAG, 'Tag ParseLength index out of range.');
        return -1;
      }
      for (let i = startIndex + 1; i <= startIndex + lengthSize; i++) {
        this.lengthValue = (this.lengthValue << MOVE_SIZE_EIGHT) + msg[i];
      }
      if (this.checkLength(lengthSize)) {
        return lengthSize + ARR_LENGTH_ONE;
      } else {
        HiLog.error(TAG, 'Tag ParseLength CheckLength error.');
        return -1;
      }
    }
  }

  private checkLength(lengthSize: number): boolean {
    if (lengthSize === ARR_LENGTH_ONE) {
      return this.lengthValue >= VALUE_HEX_80;
    } else if (lengthSize === ARR_LENGTH_TWO) {
      return this.lengthValue >= VALUE_HEX_100;
    } else if (lengthSize === ARR_LENGTH_THREE) {
      return this.lengthValue >= VALUE_HEX_10000;
    } else {
      return false;
    }
  }

  private parseValue(msg: Array<number>, startIndex: number): number {
    if (this.lengthValue === 0) {
      HiLog.info(TAG, 'Tlv ParseValue is not value');
      return 0;
    }
    if (startIndex + this.lengthValue > msg.length) {
      HiLog.error(TAG, 'Tlv ParseValue lengthValue error.');
      return -1;
    }
    this.valueVec = msg.slice(startIndex, startIndex + this.lengthValue);
    return this.lengthValue;
  }
}