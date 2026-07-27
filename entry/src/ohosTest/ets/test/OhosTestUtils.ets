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

import { AppStorageHelper } from '../../../main/ets/common/helper/AppStorageHelper';

const LAST_TERMINAL_RESP_DATA = 'lastTerminalRespData';
const MENU_SELECTION_ENVELOPE_RESP_DATA = 'MenuSelectionEnvelopeRespData';
const MOCK_RETURN_SIM_STATE_LOADED = 'mockReturnSimStateLoaded';

export default class OhosTestUtils {
  private static instance: OhosTestUtils | undefined = undefined;

  private constructor() {
  }

  public static getInstance(): OhosTestUtils {
    if (!OhosTestUtils.instance) {
      OhosTestUtils.instance = new OhosTestUtils();
    }
    return OhosTestUtils.instance;
  }

  public getMockReturnSimStateLoaded(): boolean {
    let stateLoad = AppStorageHelper.get<boolean>(MOCK_RETURN_SIM_STATE_LOADED, true);
    if (stateLoad === undefined) {
      return true;
    } else {
      return stateLoad;
    }
  }

  public setMockReturnSimStateLoaded(isLoaded: boolean): void {
    AppStorageHelper.set<boolean>(MOCK_RETURN_SIM_STATE_LOADED, isLoaded);
  }

  public saveTerminalResponseData(responseDataHex: string): void {
    AppStorageHelper.set<string>(LAST_TERMINAL_RESP_DATA, responseDataHex);
  }

  public getLastTerminalResponseData(): string {
    return AppStorageHelper.get<string>(LAST_TERMINAL_RESP_DATA, '') ?? '';
  }

  public saveMenuSelectionEnvelopeRespData(responseDataHex: string): void {
    AppStorageHelper.set<string>(MENU_SELECTION_ENVELOPE_RESP_DATA, responseDataHex);
  }

  public getMenuSelectionEnvelopeRespData(): string {
    return AppStorageHelper.get<string>(MENU_SELECTION_ENVELOPE_RESP_DATA, '') ?? '';
  }
}