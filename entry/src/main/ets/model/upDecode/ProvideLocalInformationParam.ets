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

import { ResponseCode } from '../../common/constant/SimToolKitConstant';
import { BaseUpParams } from './BaseUpParams';
import { Tlv } from './Tlv';

export enum ProvideLocalInformationMode {
  DTTZ_SETTING = 0x03,
  LANGUAGE_SETTING = 0x04,
  OTHER = 0xFF,
}

export class ProvideLocalInformationParam extends BaseUpParams {
  public infoMode: ProvideLocalInformationMode = ProvideLocalInformationMode.OTHER;

  private parseInfoMode(): void {
    if (this.commandQual === ProvideLocalInformationMode.DTTZ_SETTING ||
      this.commandQual === ProvideLocalInformationMode.LANGUAGE_SETTING) {
      this.infoMode = this.commandQual;
    } else {
      this.infoMode = ProvideLocalInformationMode.OTHER;
    }
  }

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.parseInfoMode();
    }
  }
}