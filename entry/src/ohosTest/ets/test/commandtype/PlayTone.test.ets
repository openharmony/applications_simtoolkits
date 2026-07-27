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

import { describe, it, expect, beforeEach, afterAll, beforeAll } from '@ohos/hypium';
import { Driver, ON } from '@ohos.UiTest';
import OhosTestUtils from '../OhosTestUtils';
import { sendCommandHex, sendEndSession, setMock, sleep } from '../TestUtils';
import CommonUtils from '../../../../main/ets/common/utils/CommonUtils';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { DELAY_TIME_1000 } from '../constants/TestConstants';
import { DELAY_TIME } from '../constants/TestConstants';
import { PlayToneConstants } from '../constants/CommandTypetConstants';

const driver = Driver.create();
const abilityDelegator = abilityDelegatorRegistry.getAbilityDelegator();

async function checkPlayToneShow(toneStr: string): Promise<void> {
  let driver = Driver.create();
  let toneText = await driver.waitForComponent(ON.text(toneStr), 2000);
  expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
  await driver.delayMs(5000);
}

export default function PlayTone(): void {
  describe('PlayTone', () => {
    beforeAll(async (done: Function) => {
      //setMock api
      await setMock(abilityDelegator, 'mock/mock-config.json');
      await sleep(DELAY_TIME_1000);
      done();
    })
    beforeEach(async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
    afterAll(() => {
      abilityDelegator.setMockList({});
    })

    // PlayTone PLAY_TONE_1_1_1
    // 27.22.4.5.1 PLAY TONE (Normal)
    // Expected Sequence 1.1 (PLAY TONE)
    it('PlayTone_PLAY_TONE_1_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_1, 0);
      await checkPlayToneShow('Dial Tone');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_2
    it('PlayTone_PLAY_TONE_1_1_2', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_2, 0);
      await checkPlayToneShow('Sub. Busy');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_3
    it('PlayTone_PLAY_TONE_1_1_3', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_3, 0);
      await checkPlayToneShow('Congestion');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_4
    it('PlayTone_PLAY_TONE_1_1_4', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_4, 0);
      await checkPlayToneShow('RP Ack');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_5
    it('PlayTone_PLAY_TONE_1_1_5', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_5, 0);
      await checkPlayToneShow('No RP');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_6
    it('PlayTone_PLAY_TONE_1_1_6', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_6, 0);
      await driver.delayMs(DELAY_TIME);
      await checkPlayToneShow('Spec Info');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_7
    it('PlayTone_PLAY_TONE_1_1_7', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_7, 0);
      await driver.delayMs(DELAY_TIME);
      await checkPlayToneShow('Call Wait');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_8
    it('PlayTone_PLAY_TONE_1_1_8', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_8, 0);
      await driver.delayMs(DELAY_TIME);
      await checkPlayToneShow('Ring Tone');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_9
    it('PlayTone_PLAY_TONE_1_1_9', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_9, 0);
      await driver.delayMs(DELAY_TIME);
      let toneStr = 'This command instructs the ME to play an audio tone. Upon receiving this command, ' +
        'the ME shall check if it is currently in, or in the process of setting up (SET-UP message sent ' +
        'to the network, see GSM"04.08"(8)), a speech call. - If the ME I';
      let toneText = await driver.waitForComponent(ON.text(toneStr), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_10
    it('PlayTone_PLAY_TONE_1_1_10', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_10, 0);
      let toneText = await driver.waitForComponent(ON.text('Beep'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_11
    it('PlayTone_PLAY_TONE_1_1_11', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_11, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('Positive'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_12
    it('PlayTone_PLAY_TONE_1_1_12', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_12, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('Negative'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_13
    it('PlayTone_PLAY_TONE_1_1_13', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_13, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('Quick'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_14
    it('PlayTone_PLAY_TONE_1_1_14', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_14, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('<ABORT>'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      await driver.pressBack();
      await driver.delayMs(DELAY_TIME);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_UICC_SESSION_TERM_BY_USER).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_1_1_15
    it('PlayTone_PLAY_TONE_1_1_15', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_1_1_15, 0);
      await driver.delayMs(3000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_2_1_1
    // 27.22.4.5.2 PLAY TONE (UCS2 display in Cyrillic)
    // Expected Sequence 2.1 (PLAY TONE, character set from UCS2 alphabet in Cyrillic, successful)
    it('PlayTone_PLAY_TONE_2_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_2_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('ЗДРАВСТВУЙТЕ'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_2_1_2
    it('PlayTone_PLAY_TONE_2_1_2', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_2_1_2, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('ЗДРАВСТВУЙТЕ'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_2_1_3
    it('PlayTone_PLAY_TONE_2_1_3', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_2_1_3, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('ЗДРАВСТВУЙТЕ'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_3_1_1
    // 27.22.4.5.3 PLAY TONE (display of Icon)
    // Expected Sequence 3.1A (PLAY TONE, Basic icon, self-explanatory, successful)
    // Expected Sequence 3.1B (PLAY TONE, Basic icon, self-explanatory, requested icon could not be displayed)
    it('PlayTone_PLAY_TONE_3_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_3_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('<BASIC-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_ICON_NOT_DISPLAYED).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_3_2_1
    // 27.22.4.5.3 PLAY TONE (display of Icon)
    // Expected Sequence 3.2A (PLAY TONE, Basic icon, non self-explanatory, successful)
    // Expected Sequence 3.2B (PLAY TONE, Basic icon, non self-explanatory, requested icon could not be displayed)
    it('PlayTone_PLAY_TONE_3_2_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_3_2_1, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('<BASIC-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_ICON_NOT_DISPLAYED).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_3_3_1
    // 27.22.4.5.3 PLAY TONE (display of Icon)
    // Expected Sequence 3.3A (PLAY TONE, Colour icon, self-explanatory, successful)
    // Expected Sequence 3.3B (PLAY TONE, Colour icon, self-explanatory, requested icon could not be displayed)
    it('PlayTone_PLAY_TONE_3_3_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_3_3_1, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('<COLOUR-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_ICON_NOT_DISPLAYED).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_3_4_1
    // 27.22.4.5.3 PLAY TONE (display of Icon)
    // Expected Sequence 3.4A (PLAY TONE, Colour icon, non self-explanatory, successful)
    // Expected Sequence 3.4B (PLAY TONE, Colour icon, non self-explanatory, requested icon could not be displayed)
    it('PlayTone_PLAY_TONE_3_4_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_3_4_1, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('<COLOUR-ICON>'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_ICON_NOT_DISPLAYED).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_5_1_1
    // 27.22.4.5.5 PLAY TONE (UCS2 display in Chinese)
    // Expected Sequence 5.1 (PLAY TONE, character set from UCS2 alphabet in Chinese, successful)
    it('PlayTone_PLAY_TONE_5_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_5_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('中一'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_5_1_2
    it('PlayTone_PLAY_TONE_5_1_2', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_5_1_2, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('中一'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_5_1_3
    it('PlayTone_PLAY_TONE_5_1_3', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_5_1_3, 0);
      await driver.delayMs(DELAY_TIME);
      let toneText = await driver.waitForComponent(ON.text('中一'), 2000);
      expect(!CommonUtils.isEmptyObj(toneText)).assertTrue();
      await driver.delayMs(2000);
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_6_1_1
    // 27.22.4.5.6 PLAY TONE (UCS2 display in Katakana)
    // Expected Sequence 6.1 (PLAY TONE, with UCS2 in Katakana, successful)
    it('PlayTone_PLAY_TONE_6_1_1', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_6_1_1, 0);
      await driver.delayMs(DELAY_TIME);
      await checkPlayToneShow('80ル0');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_6_1_2
    it('PlayTone_PLAY_TONE_6_1_2', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_6_1_2, 0);
      await driver.delayMs(DELAY_TIME);
      await checkPlayToneShow('81ル1');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })

    // PlayTone PLAY_TONE_6_1_3
    it('PlayTone_PLAY_TONE_6_1_3', 0, async (done: Function) => {
      OhosTestUtils.getInstance().saveTerminalResponseData('');
      await sendCommandHex(PlayToneConstants.PLAY_TONE_6_1_3, 0);
      await driver.delayMs(DELAY_TIME);
      await checkPlayToneShow('82ル2');
      expect(PlayToneConstants.PLAY_TONE_RESPONSE_OK).assertEqual(
        OhosTestUtils.getInstance().getLastTerminalResponseData());
      await sendEndSession();
      await driver.pressHome();
      await driver.delayMs(DELAY_TIME);
      done();
    })
  })
}