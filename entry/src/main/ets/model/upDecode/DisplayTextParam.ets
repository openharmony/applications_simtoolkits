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

import { ResponseCode, VALUE_HEX_01, VALUE_HEX_80 } from '../../common/constant/SimToolKitConstant';
import { BaseUpParams } from './BaseUpParams';
import { DecodeItemUtil } from './DecodeItemUtil';
import { Tlv } from './Tlv';

export class DisplayTextParam extends BaseUpParams {
  public text: string = '';
  public responseNeeded: boolean = true;
  public duration: number = 0;
  public isHighPriority: boolean = false;
  public isUserClear: boolean = false;

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.isHighPriority = (this.commandQual & VALUE_HEX_01) !== 0;
      this.isUserClear = (this.commandQual & VALUE_HEX_80) !== 0;
      let parseTest = DecodeItemUtil.parseTextString(tlvList).data;
      if (parseTest === undefined) {
        this.parseResultCode = ResponseCode.CMD_DATA_NOT_UNDERSTOOD;
      } else {
        this.text = parseTest;
      }
    }
    if (this.parseResultCode === ResponseCode.OK) {
      this.responseNeeded = DecodeItemUtil.parseHaveImmediateResponse(tlvList);
      this.duration = DecodeItemUtil.parseDurationNumber(tlvList, false);
    }
  }
}