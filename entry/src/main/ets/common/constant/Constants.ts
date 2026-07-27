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

export enum EventHub {
  SESSION_END = 'SESSION_END',
  RECEIVE_COMMAND = 'RECEIVE_COMMAND',
  REFRESH_MENU_DATA = 'REFRESH_MENU_DATA',
  REFRESH_SET_UP_MENU = 'REFRESH_SET_UP_MENU',
  CONFIG_COLOR_MODE_CHANGE = 'CONFIG_COLOR_MODE_CHANGE',
  TO_CLOSE_DIALOG = 'TO_CLOSE_DIALOG'
}

export enum TimeOut {
  DELAY_TIME_UNIT_SECOND = 1000,
  TIME_UNIT_TENTH_SECOND = 10000,
  TIME_UNIT_MINUTE = 60000,
  TIMEOUT_PLAY_TONE_DEF = 2000,
  TIMEOUT_TOAST = 2000,
  TIMEOUT_UI_DEF = 45000,
  TIMEOUT_UI_HW = 59000,
  TIMEOUT_UI_HW_SCREEN_OFF = 90000,
  MENU_AND_INPUT = 45000,
  MENU_ITEM_CLICK = 10000,
  SCREEN_BUSY_RESPONSE_TIMEOUT = 3000,
  DISP_TEXT_CLEAR_AFTER_DELAY_TIMEOUT = 15000
}

export enum HapInfo {
  BUNDLE_NAME = 'com.ohos.simtoolkits',
  SERVICE_ABILITY_NAME = 'ServiceExtAbility',
  MAIN_ABILITY = 'EntryAbility',
}

export enum HapWindowId {
  DIALOG_ID_NORMAL = 'com.ohos.simtoolkits.dialog',
  DIALOG_ID_TOAST = 'com.ohos.simtoolkits.toast'
}

export enum SimId {
  SLOT_ID_0 = 0,
  SLOT_ID_1 = 1,
  SLOT_INDEX_1 = 1,
  SLOT_INDEX_2 = 2,
}

export enum PageUrl {
  PAGE_URL_INPUT = 'pages/SimToolKitInput',
  PAGE_URL_MAIN = 'pages/Index',
  PAGE_URL_DIALOG = 'pages/LauncherDialog',
}

export enum BackgroundColor {
  COLOR_TRANSPARENT = '#00000000',
  WINDOW_BG_BLACK = '#000000',
  WINDOW_BG_APP = '#F1F3F5',
  WINDOW_BG_WHITE = '#FFFFFF'
}

export enum LocalStorageKey {
  SLOT_ID = 'LocalStorage_slotId_key',
  UP_PARAM = 'LocalStorage_upParam_'
}

export enum ViewId {
  NAV_BACK_BACK = 'NavBackBack',
  NAV_BACK_MENU = 'NavBackMenu',
  NAV_BACK_TEXT = 'NavBackText',
  NAV_BACK_MENU_ITEM_PRE = 'NavBackMenuItem_',
  TOAST_DIALOG_TEXT = 'ToastDialogText',
  TOAST_DIALOG_TEXT_CONTAINER_ROW = 'ToastDialog_Text_Contianer_Row',
  PLAY_TONE_VIEW = 'PlayToneView',
  INDEX_PAGE_ITEM_PRE = 'IndexPageItem_',
  INPUT_PAGE_CANCEL = 'InputPageCancel',
  INPUT_PAGE_CONFIRM = 'InputPageConfirm',
  INPUT_PAGE_TEXT_INPUT = 'InputPageTextInput',
  FIRST_PAGE_ITEM_PRE = 'FirstPageItem_',
}

export enum FontSizeScaleLevel {
  LEVEL1 = 1.75,
  LEVEL2 = 2,
  LEVEL3 = 3.2
}

export enum SetupEventKey {
  EVENT_LIST_KEY = 'SP_SET_UP_EVENT_LIST_KEY_',
  IDLE_MODE_TEXT_KEY = 'SP_SET_UP_IDLE_MODE_TEXT_KEY_',
}

export enum SimSwitchState {
  PSIM1_PSIM2 = 0,
  PSIM1_ESIM = 1,
  PSIM2_ESIM = 2
}