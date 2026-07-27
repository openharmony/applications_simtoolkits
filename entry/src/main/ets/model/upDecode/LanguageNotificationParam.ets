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

import { BaseUpParams } from './BaseUpParams';
import { DecodeItemUtil } from './DecodeItemUtil';
import { Tlv } from './Tlv';
import { ResponseCode } from '../../common/constant/SimToolKitConstant';

const SPECIFIC_LANGUAGE = 0x01;

export class LanguageNotificationParam extends BaseUpParams {
  public language: string = '';
  public parseLanguage: string | undefined = undefined;

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK && this.commandQual === SPECIFIC_LANGUAGE) {
      let parseLanguageStr = DecodeItemUtil.parseLanguage(tlvList, false);
      if (parseLanguageStr === undefined) {
        this.parseResultCode = ResponseCode.CMD_DATA_NOT_UNDERSTOOD;
      } else {
        this.parseLanguage = parseLanguageStr;
      }
    }
  }
}