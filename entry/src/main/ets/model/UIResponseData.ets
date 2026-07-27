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

export enum FromPageFlag {
  TYPE_MENU = 0,
  TYPE_INPUT = 1,
  TYPE_DIALOG = 2,
  TYPE_BACKGROUND = 3
}

export class UiMenuResponseData {
  public menuId: number;
  public isHelpRequired: boolean;

  constructor(menuId: number, isHelpRequired: boolean) {
    this.menuId = menuId;
    this.isHelpRequired = isHelpRequired;
  }
}

export class UiInputResponseData {
  public isYesNo: boolean;
  public inputStr: string;
  public isHelpRequired: boolean;

  constructor(isYesNo: boolean, inputStr: string, isHelpRequired: boolean) {
    this.isYesNo = isYesNo;
    this.inputStr = inputStr;
    this.isHelpRequired = isHelpRequired;
  }
}