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

import HiLog from './HiLog';
import { ARR_INDEX_ONE,
  ARR_INDEX_TWO,
  ARR_INDEX_THREE,
  ARR_LENGTH_ONE,
  ARR_LENGTH_TWO,
  ARR_LENGTH_THREE,
  ARR_LENGTH_FOUR,
  MOVE_SIZE_SEVEN,
  MOVE_SIZE_EIGHT,
  VALUE_HEX_80,
  VALUE_HEX_81,
  VALUE_HEX_82,
  EncodeType } from '../constant/SimToolKitConstant';
import CommonUtils from './CommonUtils';

const TAG = 'EncodeDecodeUtils';
const VALUE_COUNT_TWO: number = 2;
const GSM_ONE_SIZE: number = 7;
const ONE_BYTE_SIZE: number = 8;
const HEX_DECIMAL: number = 16;
const TABLE_SIZE: number = 128;
const VALUE_HEX_7F: number = 0x7F;
const VALUE_HEX_FF: number = 0xFF;
const GSM_EXTENDED_ESCAPE: number = 0x1B;
const GSM_EXTENDED_ESCAPE_STRING: string = '\u039e';
const EMPTY_STRING: string = ' ';

export class EncodeDecodeUtils {
  private static instance: EncodeDecodeUtils;
  private languageTableToChar: string = '@\u00a3$\u00a5\u00e8\u00e9\u00f9\u00ec\u00f2\u00c7\n\u00d8\u00f8\r\u00c5\u00e5\u0394_\u03a6\u0393\u039b\u03a9\u03a0\u03a8\u03a3\u0398\u039e\uffff\u00c6\u00e6\u00df\u00c9 !"#\u00a4%&\'()*+,-./0123456789:;<=>?\u00a1ABCDEFGHIJKLMNOPQRSTUVWXYZ\u00c4\u00d6\u00d1\u00dc\u00a7\u00bfabcdefghijklmnopqrstuvwxyz\u00e4\u00f6\u00f1\u00fc\u00e0';
  private shiftTableToChar: string = '          \u000c         ^                   {}     \\            [~] |                                    \u20ac                          ';
  private charToLanguageTable: Map<string, number>;
  private charToShiftTable: Map<string, number>;

  private constructor() {
    this.charToLanguageTable = new Map<string, number>();
    this.charToShiftTable = new Map<string, number>();
    if (this.languageTableToChar.length !== TABLE_SIZE) {
      HiLog.error(TAG, `languageTableToChar is error  ${this.languageTableToChar.length}`);
      return;
    }
    if (this.shiftTableToChar.length !== TABLE_SIZE) {
      HiLog.error(TAG, `shiftTableToChar is error ${this.shiftTableToChar.length}`);
      return;
    }
    for (let i = 0; i < this.languageTableToChar.length; i++) {
      this.charToLanguageTable.set(this.languageTableToChar.charAt(i), i);
    }
    for (let i = 0; i < this.shiftTableToChar.length; i++) {
      let itemChar = this.shiftTableToChar.charAt(i);
      if (itemChar !== EMPTY_STRING) {
        this.charToShiftTable.set(itemChar, i);
      }
    }
  }

  public static getInstance(): EncodeDecodeUtils {
    if (CommonUtils.isEmptyObj(EncodeDecodeUtils.instance)) {
      HiLog.info(TAG, 'EncodeDecodeUtils getInstance init');
      EncodeDecodeUtils.instance = new EncodeDecodeUtils();
    }
    return EncodeDecodeUtils.instance;
  }

  private countGsmSeptetsUsingTables(inData: string, use7bitOnly: boolean): number {
    let count = 0;
    for (let i = 0; i < inData.length; i++) {
      let itemChar = inData.charAt(i);
      if (itemChar === GSM_EXTENDED_ESCAPE_STRING) {
        continue;
      }
      if (this.charToLanguageTable.has(itemChar)) {
        count++;
      } else if (this.charToShiftTable.has(itemChar)) {
        count += VALUE_COUNT_TWO; // escape + shift table index
      } else if (use7bitOnly) {
        count++; // encode as space
      } else {
        return -1; // caller must check for this case
      }
    }
    return count;
  }

  private packSmsChar(ret: Array<number>, bitOffset: number, value: number): void {
    let byteOffset = Math.trunc(bitOffset / ONE_BYTE_SIZE) - 1;
    let shift = bitOffset % ONE_BYTE_SIZE;
    ret[++byteOffset] |= ((value << shift) & VALUE_HEX_FF);
    if (shift > 1) {
      ret[++byteOffset] = (value >> (ONE_BYTE_SIZE - shift));
    }
  }

  public stringToGsm7BitPacked(inData: string): Array<number> {
    let septetCount = this.countGsmSeptetsUsingTables(inData, false);
    if (septetCount === -1) {
      return undefined;
    }
    let septets = 0;
    let bitOffset = 0;
    let resultArray: Array<number> = [];
    for (let i = 0; i < inData.length && septets < septetCount; i++) {
      let itemChar = inData.charAt(i);
      let mapValue;
      if (this.charToLanguageTable.has(itemChar)) {
        mapValue = this.charToLanguageTable.get(itemChar);
      } else {
        if (this.charToShiftTable.has(itemChar)) {
          mapValue = this.charToShiftTable.get(itemChar);
          this.packSmsChar(resultArray, bitOffset, GSM_EXTENDED_ESCAPE);
          septets++;
          bitOffset += GSM_ONE_SIZE;
        } else {
          return undefined;
        }
      }
      this.packSmsChar(resultArray, bitOffset, mapValue);
      septets++;
      bitOffset += GSM_ONE_SIZE;
    }
    return resultArray;
  }


  public gsm7BitPackedToString(inDataArray: Array<number>): string {
    if (CommonUtils.isEmptyArr(inDataArray)) {
      return undefined;
    }
    let lengthSeptets = Math.trunc((inDataArray.length * ONE_BYTE_SIZE) / GSM_ONE_SIZE);
    let prevCharWasEscape = false;
    let resultStr = '';
    for (let i = 0; i < lengthSeptets; i++) {
      let bitOffset = GSM_ONE_SIZE * i;
      let byteOffset = Math.trunc(bitOffset / ONE_BYTE_SIZE);
      let shift = bitOffset % ONE_BYTE_SIZE;
      if (byteOffset < 0 || byteOffset >= inDataArray.length) {
        return undefined;
      }
      let gsmVal = (VALUE_HEX_7F & (inDataArray[byteOffset] >> shift));
      if (shift > 1) {
        gsmVal &= VALUE_HEX_7F >> (shift - 1);
        if (byteOffset + 1 < 0 || byteOffset + 1 >= inDataArray.length) {
          return undefined;
        }
        gsmVal |= VALUE_HEX_7F & (inDataArray[byteOffset + 1] << (ONE_BYTE_SIZE - shift));
      }
      if (gsmVal < 0 || gsmVal >= TABLE_SIZE) {
        return undefined;
      }
      if (prevCharWasEscape) {
        prevCharWasEscape = false;
        if (gsmVal === GSM_EXTENDED_ESCAPE) {
          resultStr += EMPTY_STRING;
          continue;
        }
        let charShift = this.shiftTableToChar.charAt(gsmVal);
        if (charShift === EMPTY_STRING) {
          resultStr += this.languageTableToChar.charAt(gsmVal);
        } else {
          resultStr += charShift;
        }
        continue;
      }
      if (gsmVal === GSM_EXTENDED_ESCAPE) {
        prevCharWasEscape = true;
        continue;
      }
      resultStr += this.languageTableToChar.charAt(gsmVal);
    }
    return resultStr;
  }


  public gsm8BitPackedToString(inDataArray: Array<number>): string {
    let prevWasEscape = false;
    let resultStr = '';
    for (let i = 0; i < inDataArray.length; i++) {
      let itemChar = inDataArray[i];
      if (itemChar >= TABLE_SIZE) {
        return undefined;
      }
      if (itemChar === GSM_EXTENDED_ESCAPE) {
        if (prevWasEscape) {
          resultStr += EMPTY_STRING;
          prevWasEscape = false;
        } else {
          prevWasEscape = true;
        }
        continue;
      }
      if (prevWasEscape) {
        let charShift = this.shiftTableToChar.charAt(itemChar);
        if (charShift === EMPTY_STRING) {
          resultStr += this.languageTableToChar.charAt(itemChar);
        } else {
          resultStr += charShift;
        }
        prevWasEscape = false;
      } else {
        resultStr += this.languageTableToChar.charAt(itemChar);
      }
    }
    return resultStr;
  }

  public stringToGsm8BitPacked(inData: string): Array<number> {
    let septetCount = this.countGsmSeptetsUsingTables(inData, true);
    if (septetCount === -1) {
      return undefined;
    }
    let outByteIndex = 0;
    let resultArray: Array<number> = [];
    for (let i = 0, sz = inData.length; i < sz && outByteIndex < septetCount; i++) {
      let itemChar = inData.charAt(i);
      if (this.charToLanguageTable.has(itemChar)) {
        resultArray.push(this.charToLanguageTable.get(itemChar));
        outByteIndex++;
        continue;
      }
      if (this.charToShiftTable.has(itemChar)) {
        if (outByteIndex + 1 >= septetCount) {
          break;
        }
        resultArray.push(GSM_EXTENDED_ESCAPE);
        resultArray.push(this.charToShiftTable.get(itemChar));
        outByteIndex = outByteIndex + VALUE_COUNT_TWO;
      } else {
        return undefined;
      }
    }
    // pad with 0xff's
    while (outByteIndex < septetCount) {
      resultArray.push(VALUE_HEX_FF);
    }
    return resultArray;
  }

  public hexStringToNumberArr(inData: string): Array<number> {
    if (inData.length % VALUE_COUNT_TWO !== 0) {
      return undefined;
    }
    let resultArray: Array<number> = [];
    for (let i = 0; i < inData.length; i += VALUE_COUNT_TWO) {
      let itemStr = inData.substr(i, VALUE_COUNT_TWO);
      resultArray.push(Number.parseInt(itemStr, HEX_DECIMAL));
    }
    return resultArray;
  }

  public numberArrToHexString(inData: Array<number>): string {
    let resultStr = '';
    if (CommonUtils.isEmptyArr(inData)) {
      return resultStr;
    }
    inData.forEach(item => {
      let str = item.toString(HEX_DECIMAL);
      resultStr += (str.length === 1 ? '0' + str : str);
    });
    return resultStr.toUpperCase();
  }

  public stringToUTF16BEArray(inData: string): Array<number> {
    let hexData = '';
    for (let i = 0; i < inData.length; i++) {
      let itemCode = inData.charCodeAt(i).toString(HEX_DECIMAL);
      while (itemCode.length !== ARR_LENGTH_FOUR) {
        itemCode = '0' + itemCode;
      }
      hexData += itemCode;
    }
    return this.hexStringToNumberArr(hexData);
  }

  public arrayUTF16BEToString(inData: Array<number>): string {
    let result = '';
    for (let i = 0; i < inData.length; i += VALUE_COUNT_TWO) {
      let item = (inData[i] << ONE_BYTE_SIZE) + inData[i + 1];
      result += String.fromCharCode(item);
    }
    return result;
  }

  public arrayAsciiToString(inData: Array<number>): string {
    let result = '';
    inData.forEach(value => {
      result += String.fromCharCode(value);
    });
    return result;
  }

  // encode type UCS2 GSM7 GSM8
  public encodeStringToNumberArray(inData: string, encode: number): Array<number> {
    let result = undefined;
    switch (encode) {
      case EncodeType.UCS2:
        result = this.stringToUTF16BEArray(inData);
        break;
      case EncodeType.GSM7:
        result = this.stringToGsm7BitPacked(inData);
        break;
      case EncodeType.GSM8:
        result = this.stringToGsm8BitPacked(inData);
        break;
      default:
        break;
    }
    return result;
  }

  public decodeNumberArrayToString(inData: Array<number>): string {
    if (CommonUtils.isEmptyArr(inData) || inData.length < ARR_LENGTH_TWO) {
      return undefined;
    }
    let result = undefined;
    let codingScheme = inData[0] & EncodeType.GSM7_0C;
    if (codingScheme === EncodeType.GSM7 || codingScheme === EncodeType.GSM7_0C) {
      // GSM 7-bit packed
      result = this.gsm7BitPackedToString(inData.slice(ARR_INDEX_ONE));
    } else if (codingScheme === EncodeType.GSM8) {
      // GSM 8-bit unpacked
      result = this.gsm8BitPackedToString(inData.slice(ARR_INDEX_ONE));
    } else if (codingScheme === EncodeType.UCS2) {
      // UCS2
      result = this.arrayUTF16BEToString(inData.slice(ARR_INDEX_ONE));
    }
    return result;
  }

  private adnStringParseUTF16BE(data: Array<number>): string {
    let ret = this.arrayUTF16BEToString(data.slice(ARR_INDEX_ONE));
    if (CommonUtils.isEmptyStr(ret)) {
      return '';
    }
    // trim off trailing FFFF characters
    let ucsLen = ret.length;
    while (ucsLen > 0 && ret.charAt(ucsLen - 1) === '\uFFFF') {
      ucsLen--;
    }
    return ret.substring(0, ucsLen);
  }

  public adnStringFieldToStringForSTK(data: Array<number>, offset: number, length: number): string {
    if ((length === 0) || ((offset + length) > data.length)) {
      return '';
    }
    if (length >= ARR_LENGTH_ONE && data[offset] === VALUE_HEX_80) {
      return this.adnStringParseUTF16BE(data);
    }
    let isUcs2 = false;
    let base: number = 0;
    let len: number = 0;
    if (length >= ARR_LENGTH_THREE && data[offset] === VALUE_HEX_81) {
      len = data[offset + 1] & VALUE_HEX_FF;
      if (len > length - ARR_LENGTH_THREE) {
        len = length - ARR_LENGTH_THREE;
      }
      base = (data[offset + ARR_INDEX_TWO] &
        VALUE_HEX_FF) << MOVE_SIZE_SEVEN;
      offset += ARR_LENGTH_THREE;
      isUcs2 = true;
    } else if (length >= ARR_LENGTH_FOUR && data[offset] === VALUE_HEX_82) {
      len = data[offset + 1] & VALUE_HEX_FF;
      if (len > length - ARR_LENGTH_FOUR) {
        len = length - ARR_LENGTH_FOUR;
      }
      base = ((data[offset + ARR_INDEX_TWO] & VALUE_HEX_FF) <<
        MOVE_SIZE_EIGHT) |
        (data[offset + ARR_INDEX_THREE] & VALUE_HEX_FF);
      offset += ARR_LENGTH_FOUR;
      isUcs2 = true;
    }
    if (isUcs2) {
      let ret = '';
      while ((len > 0) && ((offset + len - 1) < data.length)) {
        // UCS2 subset case
        if (data[offset] > VALUE_HEX_7F) {
          ret = ret + String.fromCharCode(base + (data[offset] & VALUE_HEX_7F));
          offset++;
          len--;
        }
        // GSM character set case
        let count: number = 0;
        while (count < len && data[offset + count] <= VALUE_HEX_7F) {
          count++;
        }
        ret = ret + (this.gsm8BitPackedToString(data.slice(offset, offset + count)));
        offset += count;
        len -= count;
      }
      return ret.toString();
    }
    return this.gsm8BitPackedToString(data.slice(offset, offset + length));
  }
}