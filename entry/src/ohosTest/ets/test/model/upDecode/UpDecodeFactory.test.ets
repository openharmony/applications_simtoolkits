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

import { describe, it, expect } from '@ohos/hypium';
import { UpDecodeFactory } from '../../../../../main/ets/model/upDecode/UpDecodeFactory';
import TestApplication from '../../../application/TestApplication';
import { SendAboutParam } from '../../../../../main/ets/model/upDecode/SendAboutParam';
import { PlayToneParam } from '../../../../../main/ets/model/upDecode/PlayToneParam';
import { SetUpMenuParam } from '../../../../../main/ets/model/upDecode/SetUpMenuParam';
import { SelectItemParam } from '../../../../../main/ets/model/upDecode/SelectItemParam';
import { LanguageNotificationParam } from '../../../../../main/ets/model/upDecode/LanguageNotificationParam';
import { CommandType, ResponseCode } from '../../../../../main/ets/common/constant/SimToolKitConstant';
import { CommonTestHex } from '../../constants/TestConstants';
import { LanguageNotificationHelper } from '../../../../../main/ets/model/upDecode/LanguageNotificationHelper';

export default function UpDecodeFactoryTest() {
  describe('UpDecodeFactoryTest', () => {
    it('UpDecodeFactoryTest_SET_UP_MENU', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SET_UP_MENU, 0);
      let menuParam = upParam as SetUpMenuParam;
      expect(menuParam?.commandType).assertEqual(CommandType.SET_UP_MENU);
      expect(menuParam?.menuTitle).assertEqual('中国移动');
      expect(menuParam?.itemArray[0].itemText).assertEqual('SIM快捷确认');
      expect(menuParam?.itemArray[1].itemText).assertEqual('USIM卡信息');
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_MENU_more_title', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SET_UP_MENU_01, 0);
      let menuParam = upParam as SetUpMenuParam;
      expect(menuParam?.commandType).assertEqual(CommandType.SET_UP_MENU);
      expect(menuParam?.menuTitle)
        .assertEqual('The SIM shall supply a set of menu items, which shall be integrated with the menu system ' +
          '(or other MMI facility) in order to give the user the opportunity to choose one of these menu items at ' +
          'his own discretion. Each item comprises a sh');
      expect(menuParam?.itemArray[0].itemText).assertEqual('Y');
      done();
    })
    it('UpDecodeFactoryTest_SELECT_ITEM_80_flag', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SELECT_ITEM, 0);
      let selectItemParam = upParam as SelectItemParam;
      expect(selectItemParam.commandType).assertEqual(CommandType.SELECT_ITEM);
      expect(selectItemParam.itemArray[0].itemText).assertEqual('仅在服务要求时使用口令保护');
      done();
    })
    it('UpDecodeFactoryTest_SELECT_ITEM_81_flag', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SELECT_ITEM_01, 0);
      let selectItemParam = upParam as SelectItemParam;
      expect(selectItemParam.commandType).assertEqual(CommandType.SELECT_ITEM);
      expect(selectItemParam.menuTitle).assertEqual('ЗДРАВСТВУЙТЕ');
      expect(selectItemParam.itemArray[0].itemText).assertEqual('ЗДРАВСТВУЙТЕ1');
      expect(selectItemParam.itemArray[1].itemText).assertEqual('ЗДРАВСТВУЙТЕ2');
      expect(selectItemParam.itemArray[2].itemText).assertEqual('ЗДРАВСТВУЙТЕ3');
      done();
    })
    it('UpDecodeFactoryTest_SELECT_ITEM_more_title', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SELECT_ITEM_02, 0);
      let selectItemParam = upParam as SelectItemParam;
      expect(selectItemParam.commandType).assertEqual(CommandType.SELECT_ITEM);
      expect(selectItemParam.menuTitle).assertEqual('The SIM shall supply a set of items from which the user may ' +
        'choose one. Each item comprises a short identifier (used to indicate the selection) and a text string. ' +
        'Optionally the SIM may include an alpha identifier. The alpha identifier i');
      expect(selectItemParam.itemArray[0].itemText).assertEqual('Y');
      done();
    })
    it('UpDecodeFactoryTest_DISPLAY_TEXT', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.DISPLAY_TEXT, 0);
      expect(upParam?.commandType).assertEqual(CommandType.DISPLAY_TEXT);
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_IDLE_MODE_TEXT', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SET_UP_IDLE_MODE_TEXT, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SET_UP_IDLE_MODE_TEXT);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.OK);
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_IDLE_MODE_TEXT_CLEAR', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SET_UP_IDLE_MODE_TEXT_CLEAR, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SET_UP_IDLE_MODE_TEXT);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.OK);
      done();
    })
    it('UpDecodeFactoryTest_GET_INKEY', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.GET_INKEY, 0);
      expect(upParam?.commandType).assertEqual(CommandType.GET_INKEY);
      done();
    })
    it('UpDecodeFactoryTest_GET_INPUT', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.GET_INPUT, 0);
      expect(upParam?.commandType).assertEqual(CommandType.GET_INPUT);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.OK);
      done();
    })
    it('UpDecodeFactoryTest_GET_INPUT_NULL_TEXT_STRING', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.GET_INPUT_NULL_TEXT_STRING, 0);
      expect(upParam?.commandType).assertEqual(CommandType.GET_INPUT);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.OK);
      done();
    })
    it('UpDecodeFactoryTest_SEND_DTMF', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SEND_DTMF, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SEND_DTMF);
      done();
    })
    it('UpDecodeFactoryTest_SEND_SMS', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SEND_SMS, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SEND_SMS);
      done();
    })
    it('UpDecodeFactoryTest_REFRESH', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.REFRESH, 0);
      expect(upParam?.commandType).assertEqual(CommandType.REFRESH);
      done();
    })
    it('UpDecodeFactoryTest_REFRESH_not_str', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.REFRESH_01, 0);
      expect(upParam?.commandType).assertEqual(CommandType.REFRESH);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.OK);
      done();
    })
    it('UpDecodeFactoryTest_SEND_SS', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SEND_SS, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SEND_SS);
      done();
    })
    it('UpDecodeFactoryTest_SEND_USSD', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SEND_USSD, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SEND_USSD);
      done();
    })

    it('UpDecodeFactoryTest_SET_UP_CALL', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SET_UP_CALL, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SET_UP_CALL);
      done();
    })
    it('UpDecodeFactoryTest_LAUNCH_BROWSER', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.LAUNCH_BROWSER, 0);
      expect(upParam?.commandType).assertEqual(CommandType.LAUNCH_BROWSER);
      done();
    })
    it('UpDecodeFactoryTest_PLAY_TONE', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.PLAY_TONE, 0);
      expect(upParam?.commandType).assertEqual(CommandType.PLAY_TONE);
      expect((upParam as PlayToneParam).text).assertEqual('Dial Tone');
      done();
    })
    it('UpDecodeFactoryTest_PLAY_TONE_81_flag', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.PLAY_TONE_01, 0);
      expect(upParam?.commandType).assertEqual(CommandType.PLAY_TONE);
      expect((upParam as PlayToneParam).text).assertEqual('中一');
      done();
    })
    it('UpDecodeFactoryTest_PLAY_TONE_82_flag', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.PLAY_TONE_02, 0);
      expect(upParam?.commandType).assertEqual(CommandType.PLAY_TONE);
      expect((upParam as PlayToneParam).text).assertEqual('中一');
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_EVENT_LIST', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SET_UP_EVENT_LIST, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SET_UP_EVENT_LIST);
      done();
    })
    it('UpDecodeFactoryTest_PROVIDE_LOCAL_INFORMATION', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.PROVIDE_LOCAL_INFORMATION, 0);
      expect(upParam?.commandType).assertEqual(CommandType.PROVIDE_LOCAL_INFORMATION);
      done();
    })
    it('UpDecodeFactoryTest_LANGUAGE_NOTIFICATION', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.LANGUAGE_NOTIFICATION, 0);
      let languageNo = new LanguageNotificationHelper;
      if (upParam) {
        await languageNo.parseLanguage(TestApplication.applicationContext, upParam as LanguageNotificationParam);
      }
      expect(upParam?.commandType).assertEqual(CommandType.LANGUAGE_NOTIFICATION);
      expect((upParam as LanguageNotificationParam).language).assertEqual('en');
      done();
    })
    it('UpDecodeFactoryTest_LANGUAGE_NOTIFICATION_NON', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.LANGUAGE_NOTIFICATION_NON, 0);
      expect(upParam?.commandType).assertEqual(CommandType.LANGUAGE_NOTIFICATION);
      done();
    })
    it('UpDecodeFactoryTest_OPEN_CHANNEL', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.OPEN_CHANNEL, 0);
      expect(upParam?.commandType).assertEqual(CommandType.OPEN_CHANNEL);
      done();
    })
    it('UpDecodeFactoryTest_NotCommandDetails', 0, async (done: Function) => {
      let commandHex =
        'D033820281828509804E2D56FD79FB52A88F10018000530049004D5FEB6377786E8BA48F100280005500530049004D53614FE1606F';
      let upParam = UpDecodeFactory.getInstance().parseUpData(commandHex, 0);
      expect(upParam).assertUndefined();
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_MENU_NOT_ITEM', 0, async (done: Function) => {
      let commandHex = 'D0148103012500820281828509804E2D56FD79FB52A8';
      let upParam = UpDecodeFactory.getInstance().parseUpData(commandHex, 0);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.REQUIRED_VALUES_MISSING);
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_MENU_NOT_ITEM_TAG', 0, async (done: Function) => {
      let commandHex = 'D01A810301250082028182050F80004300530049004D53615E947528';
      let upParam = UpDecodeFactory.getInstance().parseUpData(commandHex, 0);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.REQUIRED_VALUES_MISSING);
      done();
    })
    it('UpDecodeFactoryTest_SET_UP_MENU_ITEM_TAG_LENGTH', 0, async (done: Function) => {
      let commandHex = 'D01C810301250082028182050F80004300530049004D53615E9475288F00';
      let upParam = UpDecodeFactory.getInstance().parseUpData(commandHex, 0);
      expect(upParam?.parseResultCode).assertEqual(ResponseCode.OK);
      done();
    })
    it('UpDecodeFactoryTest_SEND_SHORT_MESSAGE', 0, async (done: Function) => {
      let upParam = UpDecodeFactory.getInstance().parseUpData(CommonTestHex.SEND_SHORT_MESSAGE, 0);
      expect(upParam?.commandType).assertEqual(CommandType.SEND_SMS);
      let toastText = (upParam as SendAboutParam).text;
      expect(toastText).assertEqual('The address data object holds the RP_Destination_Address');
      done();
    })
  })
}