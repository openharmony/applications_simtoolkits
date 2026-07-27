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

// root tag type
export enum TlvType {
  PROACTIVE_COMMAND = 0xD0,
  MENU_SELECTION_ENVELOPE = 0xD3,
  EVENT_ENVELOPE = 0xD6,
}

export enum CommandType {
  SET_UP_MENU = 0x25,
  DISPLAY_TEXT = 0x21,
  SELECT_ITEM = 0x24,
  GET_INPUT = 0x23,
  GET_INKEY = 0x22,
  SET_UP_IDLE_MODE_TEXT = 0x28,
  PROVIDE_LOCAL_INFORMATION = 0x26,
  SEND_DTMF = 0x14,
  SEND_SMS = 0x13,
  SEND_SS = 0x11,
  SEND_USSD = 0x12,
  GET_CHANNEL_STATUS = 0x44,
  REFRESH = 0x01,
  LAUNCH_BROWSER = 0x15,
  SET_UP_CALL = 0x10,
  PLAY_TONE = 0x20,
  OPEN_CHANNEL = 0x40,
  CLOSE_CHANNEL = 0x41,
  RECEIVE_DATA = 0x42,
  SEND_DATA = 0x43,
  SET_UP_EVENT_LIST = 0x05,
  LANGUAGE_NOTIFICATION = 0x35,
}

export enum TlvItemType {
  COMMAND_DETAILS = 0X01,
  DEVICE_IDENTITIES = 0X02,
  RESULT = 0X03,
  DURATION = 0X04,
  ALPHA_ID = 0X05,
  ADDRESS = 0X06,
  CAPAILITY_CONFIGURATION_PARAMETER = 0X07,
  SUB_ADDRESS = 0X08,
  SS_STRING = 0X09,
  USSD_STRING = 0X0A,
  SMS_TPDU = 0X0B,
  CELL_BROADCAST_PAGE = 0X0C,
  TEXT_STRING = 0X0D,
  TONE = 0X0E,
  ITEM = 0X0F,
  ITEM_ID = 0X10,
  RESPONSE_LENGTH = 0X11,
  FILE_LIST = 0X12,
  LOCATION_INFORMATION = 0X13,
  HELP_REQUEST = 0X15,
  DEFAULT_TEXT = 0X17,
  ITEMS_NEXT_ACTION_INDICATOR = 0X18,
  EVENT_LIST = 0X19,
  CAUSE = 0X1A,
  LOCATION_STATUS = 0X1B,
  TRANSACTION_ID = 0X1C,
  ICON_ID = 0X1E,
  ITEM_ICON_ID_LIST = 0X1F,
  CARD_READER_STATUS = 0X20,
  CARD_ATR = 0x21,
  C_APDU = 0X22,
  R_APDU = 0X23,
  CALL_CONTROL_REQUESTED_ACTION = 0X27,
  AT_COMMAND = 0X28,
  AT_RESPONSE = 0X29,
  BC_REPEAT_INDICATOR = 0X2A,
  IMMEDIATE_RESPONSE = 0X2B,
  DTMF_STRING = 0X2C,
  LANGUAGE = 0X2D,
  BROWSER_IDENTITY = 0X30,
  URL = 0X31,
  BEARER = 0X32,
  PROVISIONING_REFERENCE_FILE = 0X33,
  BROWSER_TERMINATION_CAUSE = 0X34,
  BEARER_DESCRIPTION = 0X35,
  CHANNEL_DATA = 0X36,
  CHANNEL_DATA_LENGTH = 0X37,
  CHANNEL_STATUS = 0X38,
  BUFFER_SIZE = 0X39,
  CARD_READER_IDENTIFIER = 0X3A,
  OTHER_ADDRESS = 0X3E,
  SIM_ME_INTERFACE_TRANSPORT_LEVEL = 0X3C,
  NETWORK_ACCESS_NAME = 0X47,
  TEXT_ATTRIBUTE = 0X50,
}

// DeviceId
export enum DeviceId {
  DEV_ID_KEYPAD = 0x01,
  DEV_ID_DISPLAY = 0x02,
  DEV_ID_UICC = 0x81,
  DEV_ID_TERMINAL = 0x82,
}

// EventIdType
export enum EventIdType {
  USER_ACTIVITY_EVENT = 0x04,
  IDLE_SCREEN_AVAILABLE_EVENT = 0x05,
  LANGUAGE_SELECTION_EVENT = 0x07,
}

// encode type
export enum EncodeType {
  UCS2 = 0x08,
  GSM7 = 0x00,
  GSM7_0C = 0x0C,
  GSM8 = 0x04,
}

// Launch browser mode
export enum LaunchBrowserMode {
  LAUNCH_IF_NOT_ALREADY_LAUNCHED = 0x00,
  USE_EXISTING_BROWSER = 0x02,
  LAUNCH_NEW_BROWSER = 0x03,
}

// terminal response code
export enum ResponseCode {
  OK = 0x00, // Command performed successfully
  PRFRMD_WITH_PARTIAL_COMPREHENSION = 0x01, // Command performed with partial comprehension
  PRFRMD_WITH_MISSING_INFO = 0x02, // Command performed, with missing information
  PRFRMD_WITH_ADDITIONAL_EFS_READ = 0x03, // REFRESH performed with additional EFs read
  PRFRMD_ICON_NOT_DISPLAYED = 0x04, // Command performed successfully, but requested icon could not be displayed
  PRFRMD_MODIFIED_BY_NAA = 0x05, // Command performed, but modified by call control by NAA
  PRFRMD_LIMITED_SERVICE = 0x06, // Command performed successfully, limited service
  PRFRMD_WITH_MODIFICATION = 0x07, // Command performed with modification
  PRFRMD_NAA_NOT_ACTIVE = 0x08, // REFRESH performed but indicated NAA was not active
  PRFRMD_TONE_NOT_PLAYED = 0x09, // Command performed successfully, tone not played
  UICC_SESSION_TERM_BY_USER = 0x10, // Proactive UICC session terminated by the user
  BACKWARD_MOVE_BY_USER = 0x11, // Backward move in the proactive UICC session requested by the user
  NO_RESPONSE_FROM_USER = 0x12, // No response from user
  HELP_INFO_REQUIRED = 0x13, // Help information required by the user
  USSD_SS_SESSION_TERM_BY_USER = 0x14, // USSD or SS transaction terminated by the user
  TERMINAL_CRNTLY_UNABLE_TO_PROCESS = 0x20, // Terminal currently unable to process command
  NETWORK_CRNTLY_UNABLE_TO_PROCESS = 0x21, // Network currently unable to process command
  USER_NOT_ACCEPT = 0x22, // User did not accept the proactive command
  USER_CLEAR_DOWN_CALL = 0x23, // User cleared down call before connection or network release
  CONTRADICTION_WITH_TIMER = 0x24, // Action in contradiction with the current timer state
  NAA_CALL_CONTROL_TEMPORARY = 0x25, // Interaction with call control by NAA, temporary problem
  LAUNCH_BROWSER_ERROR = 0x26, // Launch browser generic error code
  MMS_TEMPORARY = 0x27, // MMS temporary problem.
  BEYOND_TERMINAL_CAPABILITY = 0x30, // Command beyond terminal's capabilities
  CMD_TYPE_NOT_UNDERSTOOD = 0x31, // Command type not understood by terminal
  CMD_DATA_NOT_UNDERSTOOD = 0x32, // Command data not understood by terminal
  CMD_NUM_NOT_KNOWN = 0x33, // Command number not known by terminal
  SS_RETURN_ERROR = 0x34, // SS Return Error
  SMS_RP_ERROR = 0x35, // SMS RP-ERROR
  REQUIRED_VALUES_MISSING = 0x36, // Error, required values are missing
  USSD_RETURN_ERROR = 0x37, // USSD Return Error
  MULTI_CARDS_CMD_ERROR = 0x38, // MultipleCard commands error
  USIM_CALL_CONTROL_PERMANENT = 0x39, // Interaction with call control by USIM or MO short message control by USIM, permanent problem
  BIP_ERROR = 0x3a, // Bearer Independent Protocol error
  ACCESS_TECH_UNABLE_TO_PROCESS = 0x3b, // Access Technology unable to process command
  FRAMES_ERROR = 0x3c, // Frames error
  MMS_ERROR = 0x3d, // MMS Error
}

// BIP OPEN CHANNEL
export enum BipResponseCode {
  CONFIRM_ACCEPT = 0x00,
  CONFIRM_REJECT = 0x01,
  TIMEOUT = 0x02
}

export enum UIResponseCode {
  RESPONSE_TYPE_LOCAL_BUSY = -0x100,
  RESPONSE_TYPE_CONFIRM = 0x100,
  RESPONSE_TYPE_CONFIRM_ACCEPT = 0x101,
  RESPONSE_TYPE_CONFIRM_REJECT = 0x102,
  RESPONSE_TYPE_BACKWARD = 0x103,
  RESPONSE_TYPE_TIMEOUT = 0x104,
  RESPONSE_TYPE_END_SESSION = 0x105,
  RESPONSE_TYPE_MENU = 0x106,
  RESPONSE_TYPE_INPUT = 0x107,
  RESPONSE_TYPE_DIALOG_CLEAN = 0x108,
}

export enum ExResponseInfo {
  SCREEN_BUSY = 0x01,
}

export const SESSION_END = -99;

export const ARR_INDEX_ZERO = 0;
export const ARR_INDEX_ONE = 1;
export const ARR_INDEX_TWO = 2;
export const ARR_INDEX_THREE = 3;

export const ARR_LENGTH_ONE = 1;
export const ARR_LENGTH_TWO = 2;
export const ARR_LENGTH_THREE = 3;
export const ARR_LENGTH_FOUR = 4;

export const MOVE_SIZE_FOUR = 4;
export const MOVE_SIZE_SEVEN = 7;
export const MOVE_SIZE_EIGHT = 8;

export const VALUE_HEX_01 = 0x01;
export const VALUE_HEX_02 = 0x02;
export const VALUE_HEX_04 = 0x04;
export const VALUE_HEX_08 = 0x08;
export const VALUE_HEX_F0 = 0xF0;
export const VALUE_HEX_0F = 0x0F;
export const VALUE_HEX_FF = 0xFF;
export const VALUE_HEX_7F = 0x7F;
export const VALUE_HEX_80 = 0x80;
export const VALUE_HEX_81 = 0x81;
export const VALUE_HEX_82 = 0x82;
export const VALUE_HEX_100 = 0x100;
export const VALUE_HEX_8000 = 0x8000;
export const VALUE_HEX_10000 = 0x10000;


