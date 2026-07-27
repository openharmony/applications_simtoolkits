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

import { Tlv } from './Tlv';
import { BaseUpParams } from './BaseUpParams';
import { Duration, ItemContent, ResponseLength, IconInfo } from './BaseUpParams';
import { EncodeDecodeUtils } from '../../common/utils/EncodeDecodeUtils';
import CommonUtils from '../../common/utils/CommonUtils';
import HiLog from '../../common/utils/HiLog';
import {
  ARR_INDEX_ONE,
  ARR_INDEX_TWO,
  ARR_INDEX_ZERO,
  ARR_LENGTH_ONE,
  ARR_LENGTH_THREE,
  ARR_LENGTH_TWO,
  TlvItemType,
  VALUE_HEX_FF
} from '../../common/constant/SimToolKitConstant';

enum DurationConstant {
  MINUTE = 0x00,
  SECOND = 0x01,
  TENTH_SECOND = 0x02,
  TIMEOUT_UNIT_MINUTE = 60000,
  TIMEOUT_UNIT_TENTH_SECOND = 100,
  TIMEOUT_UNIT_DEFAULT = 1000,
};

export class ResultInfo<T> {
  public isHaveTag: boolean = false;
  public data?: T;
}

const TAG = 'DecodeItemUtil';

export class DecodeItemUtil {
  public static findParams(tlvList: Array<Tlv>, tag: number): Tlv | undefined {
    for (let i = 0; i < tlvList.length; i++) {
      let itemTlv = tlvList[i];
      if (!CommonUtils.isEmptyObj(itemTlv) && itemTlv.tagValue === tag) {
        tlvList.splice(i, 1);
        return itemTlv;
      }
    }
    return undefined;
  }

  public static parseCommandDetails(params: BaseUpParams, tlvList: Array<Tlv>): boolean {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.COMMAND_DETAILS);
    if (!thisTlv || thisTlv.valueVec.length !== ARR_LENGTH_THREE) {
      return false;
    }
    params.hasCompRequiredFlag = thisTlv.hasCompRequiredFlag;
    params.commandNumber = thisTlv.valueVec[ARR_INDEX_ZERO];
    params.commandType = thisTlv.valueVec[ARR_INDEX_ONE];
    params.commandQual = thisTlv.valueVec[ARR_INDEX_TWO];
    return true;
  }

  public static parseDevicesId(params: BaseUpParams, tlvList: Array<Tlv>, isMust: boolean): boolean {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.DEVICE_IDENTITIES);
    if (!thisTlv) {
      return !isMust;
    }
    if (thisTlv.valueVec.length !== ARR_LENGTH_TWO) {
      return false;
    }
    params.devicesSource = thisTlv.valueVec[ARR_INDEX_ZERO];
    params.devicesDest = thisTlv.valueVec[ARR_INDEX_ONE];
    return true;
  }

  public static parseAlphaIdNew(tlvList: Array<Tlv>): ResultInfo<string> {
    let resultInfo: ResultInfo<string> = { isHaveTag: false };
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ALPHA_ID);
    if (!thisTlv) {
      return resultInfo;
    }
    resultInfo.isHaveTag = true;
    resultInfo.data = EncodeDecodeUtils.getInstance().adnStringFieldToStringForSTK(
      thisTlv.valueVec, 0, thisTlv.valueVec.length);
    return resultInfo;
  }

  public static parseAlphaId(tlvList: Array<Tlv>, isMust: boolean): string | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ALPHA_ID);
    if (!thisTlv) {
      return isMust ? undefined : '';
    }
    return EncodeDecodeUtils.getInstance().adnStringFieldToStringForSTK(thisTlv.valueVec, 0, thisTlv.valueVec.length);
  }

  public static parseBIPAlphaId(tlvList: Array<Tlv>): string | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ALPHA_ID);
    if (!thisTlv || thisTlv.valueVec.length === 0) {
      return undefined;
    }
    let alphaIdStr = EncodeDecodeUtils.getInstance().adnStringFieldToStringForSTK(
      thisTlv.valueVec, 0, thisTlv.valueVec.length);
    return CommonUtils.isEmptyStr(alphaIdStr) ? '' : alphaIdStr;
  }

  public static parseItem(tlvList: Array<Tlv>): Array<ItemContent> | undefined {
    let isHaveItemTag = false;
    let itemContentArr: ItemContent[] = [];
    for (let i = 0; i < tlvList.length; i++) {
      let itemTlv = tlvList[i];
      if (itemTlv.tagValue === TlvItemType.ITEM) {
        isHaveItemTag = true;
        tlvList.splice(i--, 1);
        let itemContent = DecodeItemUtil.createItemContent(itemTlv);
        if (itemContent !== undefined) {
          itemContentArr.push(itemContent);
        }
      }
    }
    if (!isHaveItemTag) {
      return undefined;
    }
    return itemContentArr;
  }

  private static createItemContent(itemTlv: Tlv): ItemContent | undefined {
    if (itemTlv.valueVec.length < ARR_LENGTH_ONE) {
      return undefined;
    }
    let itemId = itemTlv.valueVec[ARR_INDEX_ZERO];
    let arr = itemTlv.valueVec.slice(ARR_INDEX_ONE);
    let itemText = EncodeDecodeUtils.getInstance().adnStringFieldToStringForSTK(arr, 0, arr.length);
    if (CommonUtils.isEmptyStr(itemText)) {
      itemText = '';
    }
    return new ItemContent(itemId, itemText);
  }

  public static parseItemId(tlvList: Array<Tlv>, isMust: boolean): number | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ITEM_ID);
    if (!thisTlv) {
      return isMust ? undefined : 0;
    }
    if (thisTlv.valueVec.length === 0) {
      return undefined;
    }
    return thisTlv.valueVec[ARR_INDEX_ZERO] - 1;
  }

  public static parseTextString(tlvList: Array<Tlv>): ResultInfo<string> {
    return DecodeItemUtil.parseToString(tlvList, TlvItemType.TEXT_STRING);
  }

  public static parseDefaultString(tlvList: Array<Tlv>): ResultInfo<string> {
    return DecodeItemUtil.parseToString(tlvList, TlvItemType.DEFAULT_TEXT);
  }

  private static parseToString(tlvList: Array<Tlv>, tagValue: number): ResultInfo<string> {
    let thisTlv = DecodeItemUtil.findParams(tlvList, tagValue);
    let resultInfo: ResultInfo<string> = { isHaveTag: false };
    if (!thisTlv) {
      return resultInfo;
    }
    resultInfo.isHaveTag = true;
    resultInfo.data = EncodeDecodeUtils.getInstance().decodeNumberArrayToString(thisTlv.valueVec);
    return resultInfo;
  }

  public static parseHaveImmediateResponse(tlvList: Array<Tlv>): boolean {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.IMMEDIATE_RESPONSE);
    return !thisTlv;
  }

  public static parseDurationNumber(tlvList: Array<Tlv>, isMust: boolean): number {
    let duration = DecodeItemUtil.parseDuration(tlvList, isMust);
    return DecodeItemUtil.calculatedDuration(duration);
  }

  public static calculatedDuration(duration: Duration | undefined): number {
    if (!duration) {
      return 0;
    }
    let resultNumber = 0;
    switch (duration.timeUnit) {
      case DurationConstant.MINUTE:
        resultNumber = DurationConstant.TIMEOUT_UNIT_MINUTE;
        break;
      case DurationConstant.TENTH_SECOND:
        resultNumber = DurationConstant.TIMEOUT_UNIT_TENTH_SECOND;
        break;
      case DurationConstant.SECOND:
      default:
        resultNumber = DurationConstant.TIMEOUT_UNIT_DEFAULT;
        break;
    }
    resultNumber *= duration.timeInterval;
    return resultNumber;
  }

  public static parseDuration(tlvList: Array<Tlv>, isMust: boolean): Duration | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.DURATION);
    if (!thisTlv) {
      return isMust ? undefined : new Duration();
    }
    if (thisTlv.valueVec.length !== ARR_LENGTH_TWO) {
      return undefined;
    }
    let timeUnit = thisTlv.valueVec[ARR_INDEX_ZERO];
    let timeInterval = thisTlv.valueVec[ARR_INDEX_ONE];
    return new Duration(timeInterval, timeUnit);
  }

  public static parseResponseLength(tlvList: Array<Tlv>, isMust: boolean): ResponseLength | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.RESPONSE_LENGTH);
    if (!thisTlv) {
      return isMust ? undefined : new ResponseLength();
    }
    if (thisTlv.valueVec.length !== ARR_LENGTH_TWO) {
      return undefined;
    }
    let minLength = thisTlv.valueVec[ARR_INDEX_ZERO];
    let maxLength = thisTlv.valueVec[ARR_INDEX_ONE];
    return new ResponseLength(minLength, maxLength);
  }

  public static parseIconInfo(tlvList: Array<Tlv>): IconInfo | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ICON_ID);
    if (!thisTlv || thisTlv.valueVec.length < ARR_LENGTH_TWO) {
      thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ITEM_ICON_ID_LIST);
      if (!thisTlv || thisTlv.valueVec.length < ARR_LENGTH_TWO) {
        return undefined;
      }
    }
    let iconInfo: IconInfo = new IconInfo();
    iconInfo.selfExplanatory =
      ((thisTlv.valueVec[ARR_INDEX_ZERO] & VALUE_HEX_FF) === 0);
    iconInfo.recordNumber = thisTlv.valueVec[ARR_INDEX_ONE] & VALUE_HEX_FF;
    iconInfo.hasIconAndLoadFailed = true;
    HiLog.debug(TAG, 'parseIconInfo has icon info');
    return iconInfo;
  }

  public static parseFileList(tlvList: Array<Tlv>, isMust: boolean): Array<number> | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.FILE_LIST);
    if (!thisTlv) {
      return isMust ? undefined : [];
    }
    if (thisTlv.valueVec.length === 0) {
      return undefined;
    } else {
      return thisTlv.valueVec;
    }
  }

  public static parseIsHaveAddress(tlvList: Array<Tlv>): boolean {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.ADDRESS);
    return thisTlv !== undefined;
  }

  public static parseUrl(tlvList: Array<Tlv>, isMust: boolean): string | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.URL);
    if (!thisTlv) {
      return isMust ? undefined : '';
    }
    if (thisTlv.valueVec.length === 0) {
      return undefined;
    }
    return EncodeDecodeUtils.getInstance().gsm8BitPackedToString(thisTlv.valueVec);
  }

  public static parseTone(tlvList: Array<Tlv>, isMust: boolean): number | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.TONE);
    if (!thisTlv) {
      return isMust ? undefined : 0;
    }
    if (thisTlv.valueVec.length === 0) {
      return undefined;
    }
    return thisTlv.valueVec[ARR_INDEX_ZERO];
  }

  public static parseEventList(tlvList: Array<Tlv>, isMust: boolean): Array<number> | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.EVENT_LIST);
    if (!thisTlv) {
      return isMust ? undefined : [];
    }
    return thisTlv.valueVec;
  }

  public static parseLanguage(tlvList: Array<Tlv>, isMust: boolean): string | undefined {
    let thisTlv = DecodeItemUtil.findParams(tlvList, TlvItemType.LANGUAGE);
    if (!thisTlv) {
      return isMust ? undefined : '';
    }
    if (thisTlv.valueVec.length !== ARR_LENGTH_TWO) {
      return undefined;
    }
    return EncodeDecodeUtils.getInstance().gsm8BitPackedToString(thisTlv.valueVec);
  }
}