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

import { ResponseCode, VALUE_HEX_80 } from '../../common/constant/SimToolKitConstant';
import { ItemContent } from './BaseUpParams';
import { BaseUpParams } from './BaseUpParams';
import { DecodeItemUtil } from './DecodeItemUtil';
import type { Tlv } from './Tlv';

export class SetUpMenuParam extends BaseUpParams {
  public menuTitle: string = '';
  public itemArray: Array<ItemContent> = [];
  public isHelpAvailable: boolean = false;
  public isShowEndSession: boolean = false;

  public processMsgList(tlvList: Array<Tlv>): void {
    super.processMsgList(tlvList);
    if (this.parseResultCode === ResponseCode.OK) {
      this.refreshCommandQualData();
      if (!this.parseAlphaId(tlvList)) {
        this.parseResultCode = ResponseCode.REQUIRED_VALUES_MISSING;
      }
    }
    if (this.parseResultCode === ResponseCode.OK) {
      let parseItem = DecodeItemUtil.parseItem(tlvList);
      if (parseItem === undefined) {
        this.parseResultCode = ResponseCode.REQUIRED_VALUES_MISSING;
      } else {
        this.itemArray = parseItem;
      }
    }
  }

  protected parseAlphaId(tlvList: Array<Tlv>): boolean {
    let menuTitleInfo = DecodeItemUtil.parseAlphaIdNew(tlvList);
    if (menuTitleInfo.isHaveTag) {
      this.menuTitle = menuTitleInfo.data ?? '';
      return true;
    } else {
      return false;
    }
  }

  private refreshCommandQualData(): void {
    this.isHelpAvailable = (this.commandQual & VALUE_HEX_80) !== 0;
  }
}