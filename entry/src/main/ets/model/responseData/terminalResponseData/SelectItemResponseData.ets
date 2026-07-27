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
import { TlvItemType, ARR_LENGTH_ONE, VALUE_HEX_80 } from '../../../common/constant/SimToolKitConstant';
import { DefaultResponseData } from './DefaultResponseData';
import { BaseUpParams } from '../../upDecode/BaseUpParams';
import CommonUtils from '../../../common/utils/CommonUtils';

const TAG = 'SelectItemResponseData';

export class SelectItemResponseData extends DefaultResponseData {
  public itemId: number | undefined = undefined;

  constructor(upParams?: BaseUpParams, itemId?: number, resultCode?: number) {
    super(upParams);
    this.itemId = itemId;
    this.resultCode = resultCode;
  }

  public parseDataToHex(): Array<number> {
    HiLog.info(TAG, 'SelectItemResponseData  parseDataToHex start');
    let vecArr = super.parseDataToHex();
    if (CommonUtils.isEmptyArr(vecArr) || this.itemId === undefined) {
      HiLog.error(TAG, 'SelectItemResponseData paramter error');
      return [];
    }
    let itemIdTag = TlvItemType.ITEM_ID | VALUE_HEX_80;
    vecArr.push(itemIdTag);
    vecArr.push(ARR_LENGTH_ONE);
    vecArr.push(this.itemId);
    return vecArr;
  }
}