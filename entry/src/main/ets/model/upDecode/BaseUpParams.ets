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
import { DecodeItemUtil } from './DecodeItemUtil';
import { ResponseCode } from '../../common/constant/SimToolKitConstant';

export class ItemContent {
  public itemId: number;
  public itemText: string;

  constructor(itemId: number = 0, itemText: string = '') {
    this.itemId = itemId;
    this.itemText = itemText;
  }
}

export class ResponseLength {
  public minLength: number;
  public maxLength: number;

  constructor(minLength: number = 0, maxLength: number = 0) {
    this.minLength = minLength;
    this.maxLength = maxLength;
  }
}

export class SlotIdAndParam {
  public slotId?: number;
  public upParam?: BaseUpParams;
}

export class Duration {
  public timeInterval: number;
  public timeUnit: number;

  constructor(timeInterval: number = 0, timeUnit: number = -1) {
    this.timeInterval = timeInterval;
    this.timeUnit = timeUnit;
  }
}

export class IconInfo {
  public recordNumber: number = -1;
  public selfExplanatory: boolean = false;
  public hasIconAndLoadFailed: boolean = false;
}

export class BaseUpParams {
  public slotId: number = 0;
  public commandHex: string = '';
  public commandNumber: number = 0;
  public commandType: number = 0;
  public commandQual: number = 0;
  public hasCompRequiredFlag: boolean = false;
  public devicesSource: number = 0;
  public devicesDest: number = 0;
  public parseResultCode: number = ResponseCode.OK;
  public isParseCmdDetailSuccess: boolean = false;
  public isSupport: boolean = true;
  public iconInfo: IconInfo | undefined = undefined;

  public processMsgList(tlvList: Array<Tlv>): void {
    if (tlvList.length === 0) {
      this.parseResultCode = ResponseCode.REQUIRED_VALUES_MISSING;
      return;
    }

    // parse COMMAND_DETAILS
    this.isParseCmdDetailSuccess = DecodeItemUtil.parseCommandDetails(this, tlvList);
    if (!this.isParseCmdDetailSuccess) {
      this.parseResultCode = ResponseCode.CMD_TYPE_NOT_UNDERSTOOD;
      return;
    }

    // parse ICON_ID
    this.iconInfo = DecodeItemUtil.parseIconInfo(tlvList);

    // parse DEVICE_IDENTITIES
    DecodeItemUtil.parseDevicesId(this, tlvList, false);
  }
}