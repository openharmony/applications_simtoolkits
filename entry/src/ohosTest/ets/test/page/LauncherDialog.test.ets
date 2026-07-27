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

import { describe, it, expect, beforeEach } from '@ohos/hypium';
import { Driver, ON, Component } from '@ohos.UiTest';
import screenLock from '@ohos.screenLock';
import notificationManager from '@ohos.notificationManager';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { sendCommandHex, sendEndSession } from '../TestUtils';
import HiLog from '../../../../main/ets/common/utils/HiLog';
import NotificationUtils from '../../../../main/ets/common/utils/NotificationUtils';
import { CONFIRM_DIALOG_CONFIRM_TEXT, DELAY_TIME, DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME_3000 } from '../constants/TestConstants';
import { CommonTestHex } from '../constants/TestConstants';
import { CONFIRM_DIALOG_CANCEL_TEXT } from '../constants/TestConstants';
import { ViewId } from '../../../../main/ets/common/constant/Constants';

const TAG = 'LauncherDialogTest';
const driver = Driver.create();

export default function LauncherDialogTest(): void {
  describe('LauncherDialogTest', () => {
    beforeEach(async (done: Function) => {
      await driver.delayMs(DELAY_TIME);
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_DISPLAY_TEXT_NoNeedResp', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_DISPLAY_TEXT_NoNeedResp start');
      let noNeedRespCmd: string = 'D01C8103012181820281028D0F04546F6F6C6B697420546573742031AB00';
      await sendCommandHex(noNeedRespCmd);
      let noNeedRespText: string = 'Toolkit Test 1';
      let dialogTextComp = await driver.waitForComponent(ON.text(noNeedRespText),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(dialogTextComp)).assertTrue();

      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);

      let normalCmd: string = 'D0288103012181820281028D1D08666E901A005500530049004D5361002000560032002E003000410027';
      await sendCommandHex(normalCmd);
      dialogTextComp = await driver.waitForComponent(ON.text('普通USIM卡 V2.0A\''),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(dialogTextComp)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_FLoat_window', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_FLoat_window start');
      await sendCommandHex(CommonTestHex.DISPLAY_TEXT);
      HiLog.info(TAG, 'FLoat_window test start');
      let unlockedCancelButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
        DELAY_TIME_3000);
      HiLog.info(TAG, 'FLoat_window test cancelButton:' + unlockedCancelButton);
      expect(!CommonUtils.isEmptyObj(unlockedCancelButton)).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await unlockedCancelButton.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_new_type', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_new_type start');
      await sendCommandHex(CommonTestHex.DISPLAY_TEXT);
      HiLog.info('LauncherDialogTest_new_type', 'isLocked wait');
      if (screenLock.isLocked()) {
        let cancelButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
          DELAY_TIME_3000);
        HiLog.info('LauncherDialogTest_new_type', 'isLocked cancelButton:' + cancelButton);
        expect(CommonUtils.isEmptyObj(cancelButton)).assertTrue();
      }

      await screenLock.unlock();
      await driver.delayMs(DELAY_TIME);
      let unlockedCancelButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
        DELAY_TIME_3000);
      HiLog.info('LauncherDialogTest_new_type', 'unlocked cancelButton:' + unlockedCancelButton);
      expect(!CommonUtils.isEmptyObj(unlockedCancelButton)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_DISPLAY_TEXT_Cancel', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_DISPLAY_TEXT_Cancel start');
      // cancel
      await sendCommandHex(CommonTestHex.DISPLAY_TEXT);
      let cancelButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
        DELAY_TIME_3000);
      expect((!CommonUtils.isEmptyObj(cancelButton))).assertTrue();
      await cancelButton.click();
      await driver.delayMs(DELAY_TIME);

      // confirm
      await sendCommandHex(CommonTestHex.DISPLAY_TEXT);
      let confirmButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT),
        DELAY_TIME_3000);
      expect((!CommonUtils.isEmptyObj(confirmButton))).assertTrue();
      await confirmButton.click();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_LOAD_ICON', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_LOAD_ICON start');
      let testHexCmd: string = 'D01A8103012181820281028D0B0442617369632049636F6E9E020001';
      await sendCommandHex(testHexCmd);
      let toastText = await driver.waitForComponent(ON.text('Basic Icon'),
        DELAY_TIME_3000);
      expect(!CommonUtils.isEmptyObj(toastText)).assertTrue();

      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_SET_UP_CALL', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_SET_UP_CALL start');
      // dialog confirm
      await sendCommandHex(CommonTestHex.SET_UP_CALL);
      let confirmButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT),
        DELAY_TIME_3000);
      HiLog.info('LauncherDialogTest_SET_UP_CALL', 'LauncherDialogTest_SET_UP_CALL  2');
      expect((!CommonUtils.isEmptyObj(confirmButton))).assertTrue();
      await confirmButton.click();
      await driver.delayMs(500);
      let toastButton = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      HiLog.info('LauncherDialogTest_SET_UP_CALL', 'LauncherDialogTest_SET_UP_CALL  3');
      expect((!CommonUtils.isEmptyObj(toastButton))).assertTrue();
      await driver.delayMs(DELAY_TIME);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_LAUNCH_BROWSER', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_LAUNCH_BROWSER start');
      // dialog cancel
      await sendCommandHex(CommonTestHex.LAUNCH_BROWSER);
      let cancelButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CANCEL_TEXT),
        DELAY_TIME_3000);
      expect((!CommonUtils.isEmptyObj(cancelButton))).assertTrue();
      await cancelButton.click();
      await driver.delayMs(DELAY_TIME);

      // dialog confirm
      await sendCommandHex(CommonTestHex.LAUNCH_BROWSER);
      let backButton = await driver.waitForComponent(ON.text(CONFIRM_DIALOG_CONFIRM_TEXT),
        DELAY_TIME_3000);
      expect((!CommonUtils.isEmptyObj(backButton))).assertTrue();
      await backButton.click();
      await driver.delayMs(DELAY_TIME);
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_SEND_DTMF', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_SEND_DTMF start');
      await sendCommandHex(CommonTestHex.SEND_DTMF);
      let toastText = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(toastText)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_SEND_SMS', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_SEND_SMS start');
      await sendCommandHex(CommonTestHex.SEND_SMS);
      let toastText = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(toastText)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_REFRESH', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_REFRESH start');
      NotificationUtils.clearNotification(0, false);
      let beforeCount = await notificationManager.getActiveNotificationCount();
      await sendCommandHex(CommonTestHex.REFRESH);
      await driver.delayMs(DELAY_TIME_3000);
      let afterCount = await notificationManager.getActiveNotificationCount();
      HiLog.info(TAG, `LauncherDialogTest_REFRESH beforeCount:${beforeCount}, afterCount:${afterCount}`)
      expect(beforeCount + 1).assertEqual(afterCount);
      NotificationUtils.clearNotification(0, false);
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_SEND_SS', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_SEND_SS start');
      await sendCommandHex(CommonTestHex.SEND_SS);
      let toastText = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(toastText)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_SEND_USSD', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_SEND_USSD start');
      await sendCommandHex(CommonTestHex.SEND_USSD);
      let toastText = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      expect(CommonUtils.isEmptyObj(toastText)).assertFalse();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_SEND_USSD_SHORT', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_SEND_USSD_SHORT start');
      await sendCommandHex(CommonTestHex.SEND_USSD_SHORT);
      let toastText: Component = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      let text: string = await toastText?.getText();
      expect('你好').assertEqual(text);
      let toastTextRow = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT_CONTAINER_ROW),
        DELAY_TIME_3000);
      if (!CommonUtils.isEmptyObj(toastText) && !CommonUtils.isEmptyObj(toastTextRow)) {
        try {
          let pointText = await toastText.getBoundsCenter();
          let pointRow = await toastTextRow.getBoundsCenter();
          expect((Math.abs(pointText.x - pointRow.x) < 5) && (Math.abs(pointText.y - pointRow.y) < 5)).assertTrue();
        } catch (exception) {
          expect(false).assertTrue();
        }
      } else {
        expect(false).assertTrue();
      }
      await driver.delayMs(DELAY_TIME_3000);
      let longCmd: string = 'D081AD8103011200820281838581A1042A2A2A313131313131313131312323232A2A2A323232323232323232322323232A2A2A333333333333333333332323232A2A2A343434343434343434342323232A2A2A353535353535353535352323232A2A2A363636363636363636362323232A2A2A373737373737373737372323232A2A2A383838383838383838382323232A2A2A393939393939393939392323232A2A2A30303030303030303030232323';
      await sendCommandHex(longCmd);
      let longText: Component = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT),
        DELAY_TIME_3000);
      let longStr: string = await longText?.getText();
      let textLongToTest: string = 'è***1111111111###***2222222222###***3333333333###***4444444444###***5555555555###***6666666666###***7777777777###***8888888888###***9999999999###***0000000000###';
      HiLog.info(TAG, `longCmd, longStr:${longStr}`);
      expect(textLongToTest).assertEqual(longStr);
      let longToastTextRow = await driver.waitForComponent(ON.id(ViewId.TOAST_DIALOG_TEXT_CONTAINER_ROW),
        DELAY_TIME_3000);
      let pointLongText = await longText?.getBoundsCenter();
      let pointLongRow = await longToastTextRow?.getBoundsCenter();
      HiLog.info(TAG,
        `longCmd, x:${pointLongText.x} y:${pointLongText.y} pointRowx:${pointLongRow.x} pointRowy:${pointLongRow.y}`);
      expect((Math.abs(pointLongText.x - pointLongRow.x) < 5) && (Math.abs(pointLongText.y - pointLongRow.y) < 5))
        .assertTrue();

      await driver.delayMs(DELAY_TIME);
      done();
    })
    it('LauncherDialogTest_PLAY_TONE', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_PLAY_TONE start');
      await sendCommandHex(CommonTestHex.PLAY_TONE);
      await driver.delayMs(DELAY_TIME);
      let backButton = await driver.waitForComponent(ON.id(ViewId.PLAY_TONE_VIEW),
        DELAY_TIME_3000);
      expect((!CommonUtils.isEmptyObj(backButton))).assertTrue();
      await driver.delayMs(3000);
      await driver.pressBack();
      done();
    })
    it('LauncherDialogTest_testnoti', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_testnoti start');
      await notificationManager.cancelAll();
      let lastNotiCount: number = await notificationManager.getActiveNotificationCount();
      await sendCommandHex(CommonTestHex.SET_UP_IDLE_MODE_TEXT);
      await driver.delayMs(DELAY_TIME_1000);
      let curNotiCount: number = await notificationManager.getActiveNotificationCount();
      expect(lastNotiCount === (curNotiCount - 1)).assertTrue();
      await sendCommandHex(CommonTestHex.SET_UP_IDLE_MODE_TEXT_CLEAR);
      await driver.delayMs(DELAY_TIME_3000);
      done();
    })
    it('LauncherDialogTest_PLAY_TONE_VIBRATE', 0, async (done: Function) => {
      HiLog.info(TAG, 'LauncherDialogTest_PLAY_TONE_VIBRATE start');
      await sendCommandHex(CommonTestHex.PLAY_TONE_VIBRATE);
      await driver.delayMs(DELAY_TIME);
      let backButton = await driver.waitForComponent(ON.id(ViewId.PLAY_TONE_VIEW),
        DELAY_TIME_3000);
      expect((!CommonUtils.isEmptyObj(backButton))).assertTrue();
      await driver.delayMs(DELAY_TIME_3000);
      await driver.pressBack();
      done();
    })
  })
}
