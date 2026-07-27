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

import DisplayText from './commandtype/DisplayText.test';
import AbilityTest from './Ability.test';
import LanguageNotification from './commandtype/LanguageNotification.test';
import PlayTone from './commandtype/PlayTone.test';
import ProvideLocalInformation from './commandtype/ProvideLocalInformation.test';
import SelectItem from './commandtype/SelectItem.test';
import SetUpIdleModeText from './commandtype/SetUpIdleModeText.test';
import SetUpMenu from './commandtype/SetUpMenu.test';
import AppStorageHelperTest from './common/helper/AppStorageHelper.test';
import SettingsDataHelperTest from './common/utils/SettingsDataHelper.test';
import EncodeDecodeUtilsTest from './common/utils/EncodeDecodeUtils.test';
import SharedPreferencesUtilsTest from './common/utils/SharedPreferencesUtils.test';
import UiUtilsTest from './common/utils/UiUtils.test';
import UpParamsCacheUtilsTest from './common/utils/UpParamsCacheUtils.test';
import EntryAbilityTest from './entryability/EntryAbility.test';
import LanguageEventListEnvelopeDataTest from './model/responseData/envelopeData/LanguageEventListEnvelopeData.test';
import MenuSelectionEnvelopeDataTest from './model/responseData/envelopeData/MenuSelectionEnvelopeData.test';
import DateTimeResponseDataTest from './model/responseData/terminalResponseData/DateTimeResponseData.test';
import DefaultResponseDataTest from './model/responseData/terminalResponseData/DefaultResponseData.test';
import InputInkeyResponseDataTest from './model/responseData/terminalResponseData/InputInkeyResponseData.test';
import LanguageResponseDataTest from './model/responseData/terminalResponseData/LanguageResponseData.test';
import SelectItemResponseDataTest from './model/responseData/terminalResponseData/SelectItemResponseData.test';
import SimToolKitAppServiceTest from './model/SimToolKitAppService.test';
import TlvTest from './model/upDecode/Tlv.test';
import UpDecodeFactoryTest from './model/upDecode/UpDecodeFactory.test';
import IndexTest from './page/Index.test';
import LauncherDialogTest from './page/LauncherDialog.test';
import SimToolKitInputTest from './page/SimToolKitInput.test';
import OpenChannelTest from './commandtype/OpenChannel.test';
import CloseChannelTest from './commandtype/CloseChannel.test';
import ReceiveDataTest from './commandtype/ReceiveData.test';
import SendDataTest from './commandtype/SendData.test';
import GetChannelStatusTest from './commandtype/GetChannelStatus.test';
import GetInkeyTest from './commandtype/GetInkeyTest.test';
import GetInputTest from './commandtype/GetInputTest.test';

export default function testsuite() {
  EntryAbilityTest();
  AbilityTest();
  IndexTest();
  SimToolKitInputTest();
  LauncherDialogTest();
  SimToolKitAppServiceTest();
  SettingsDataHelperTest();
  EncodeDecodeUtilsTest();
  SharedPreferencesUtilsTest();
  UpParamsCacheUtilsTest();
  LanguageEventListEnvelopeDataTest();
  MenuSelectionEnvelopeDataTest();
  DefaultResponseDataTest();
  DateTimeResponseDataTest();
  InputInkeyResponseDataTest();
  LanguageResponseDataTest();
  SelectItemResponseDataTest();
  TlvTest();
  UpDecodeFactoryTest();
  AppStorageHelperTest();
  UiUtilsTest();

  // command type
  DisplayText();
  GetInkeyTest();
  GetInputTest();
  PlayTone();
  SetUpMenu();
  SelectItem();
  ProvideLocalInformation();
  SetUpIdleModeText();
  LanguageNotification();
  OpenChannelTest();
  CloseChannelTest();
  ReceiveDataTest();
  SendDataTest();
  GetChannelStatusTest();
}