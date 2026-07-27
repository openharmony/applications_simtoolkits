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

import { audio } from '@kit.AudioKit';
import { HashMap } from '@kit.ArkTS';
import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';
import HiLog from './HiLog';
import { PlayToneParam } from '../../model/upDecode/PlayToneParam';
import { SimToolKitAppService } from '../../model/SimToolKitAppService';
import { UIResponseCode } from '../constant/SimToolKitConstant';
import { FromPageFlag } from '../../model/UIResponseData';
import { CustTimeOutHelper } from '../helper/CustTimeOutHelper';
import { TimeOut } from '../constant/Constants';

const TAG = 'TonePlayer';

enum Tone {
  DIAL = 0x01,
  BUSY = 0x02,
  CONGESTION = 0x03,
  RADIO_PATH_ACK = 0x04,
  RADIO_PATH_NOT_AVAILABLE = 0x05,
  ERROR_SPECIAL_INFO = 0x06,
  CALL_WAITING = 0x07,
  RINGING = 0x08,
  GENERAL_BEEP = 0x10,
  POSITIVE_ACK = 0x11,
  NEGATIVE_ACK = 0x12,
}

export default class TonePlayer {
  private static sInstance: TonePlayer | undefined = undefined;
  private tonePlayer: audio.TonePlayer | undefined = undefined;
  private toneMap: HashMap<number, number> = new HashMap<number, number>();
  private timeoutMgr: number | undefined = undefined;
  private isPlayBackground: boolean = false;
  private isVib: boolean = false;

  private constructor() {
    this.toneMap.set(Tone.DIAL, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_DIAL);
    this.toneMap.set(Tone.BUSY, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_BUSY);
    this.toneMap.set(Tone.CONGESTION, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_CONGESTION);
    this.toneMap.set(Tone.RADIO_PATH_ACK, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_RADIO_ACK);
    this.toneMap.set(Tone.RADIO_PATH_NOT_AVAILABLE, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_RADIO_NOT_AVAILABLE);
    this.toneMap.set(Tone.ERROR_SPECIAL_INFO, audio.ToneType.TONE_TYPE_COMMON_PROPRIETARY_PROMPT); // misssed
    this.toneMap.set(Tone.CALL_WAITING, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_CALL_WAITING);
    this.toneMap.set(Tone.RINGING, audio.ToneType.TONE_TYPE_COMMON_SUPERVISORY_RINGTONE);
    this.toneMap.set(Tone.GENERAL_BEEP, audio.ToneType.TONE_TYPE_COMMON_PROPRIETARY_BEEP);
    this.toneMap.set(Tone.POSITIVE_ACK, audio.ToneType.TONE_TYPE_COMMON_PROPRIETARY_ACK);
    this.toneMap.set(Tone.NEGATIVE_ACK, audio.ToneType.TONE_TYPE_COMMON_PROPRIETARY_PROMPT); // misssed
  }

  private static getInstance(): TonePlayer {
    HiLog.info(TAG, ': createTonePlayer getInstance');
    if (!TonePlayer.sInstance) {
      HiLog.info(TAG, 'TonePlayer init');
      TonePlayer.sInstance = new TonePlayer();
    }
    return TonePlayer.sInstance;
  }

  private async asyncDestroy(player: TonePlayer): Promise<void> {
    HiLog.info(TAG, 'stop tonePlayer');
    await player.tonePlayer?.stop();
    HiLog.info(TAG, 'release tonePlayer');
    await player.tonePlayer?.release().then(() => {
      player.toneMap.clear();
      if (player.tonePlayer !== undefined) {
        player.tonePlayer = undefined;
      }
      HiLog.info(TAG, 'release tonePlayer success');
    });
  }

  public static destroy(): void {
    let curInstance = TonePlayer.sInstance;
    HiLog.info(TAG, 'TonePlayer destroy');
    if (!curInstance) {
      HiLog.warn(TAG, 'TonePlayer no need destroy, no instance, return');
      return;
    }
    if (curInstance.tonePlayer) {
      if (curInstance.isVib) {
        curInstance.stopVibrate();
      }
      curInstance.asyncDestroy(curInstance);
    }
    TonePlayer.sInstance = undefined;
    HiLog.info(TAG, 'destroy release ended');
  }

  /**
   * start to play a tone
   *
   * @param toneParams tone params
   * @param isPlayBackground play tone in background or foreground
   */
  public static startPlay(toneParams: PlayToneParam, isPlayBackground: boolean): void {
    if (!toneParams) {
      HiLog.error(TAG, 'startPlay get invalid tone params, return');
      return;
    }
    let curInstance = TonePlayer.sInstance;
    if (!curInstance) {
      HiLog.warn(TAG, 'TonePlayer no init, create');
      curInstance = TonePlayer.getInstance();
    }
    curInstance.play(toneParams, isPlayBackground);
  }

  private play(toneParams: PlayToneParam, isPlayBackground: boolean): void {
    HiLog.info(TAG, `startPlay tone:${toneParams.tone}, isInBackground:${isPlayBackground}`);
    let duration: number = (toneParams.duration > 0) ? toneParams.duration : TimeOut.TIMEOUT_PLAY_TONE_DEF;
    this.isVib = toneParams.isVibrate;
    HiLog.info(TAG, `startPlay isVib:${this.isVib}`);

    if (isPlayBackground) {
      this.isPlayBackground = true;
      this.timeoutMgr = CustTimeOutHelper.getInstance().setTimeOutCust(() => {
        HiLog.info(TAG, 'startPlay timeout');
        SimToolKitAppService.getInstance().handleCmdResponse(FromPageFlag.TYPE_DIALOG,
          UIResponseCode.RESPONSE_TYPE_TIMEOUT, toneParams, undefined, undefined);
        TonePlayer.destroy();
      }, duration);
    }
    if (this.isVib) {
      this.startVibrate(duration);
    }

    let toneId = toneParams.tone;
    HiLog.debug(TAG, `startPlay type toneId: ${toneId}`);
    if (!this.toneMap.get(toneId)) {
      HiLog.warn(TAG, `startPlay type not contain toneId: ${toneId}`);
    }
    let type = this.toneMap.get(toneId) ?? audio.ToneType.TONE_TYPE_COMMON_PROPRIETARY_BEEP;
    TonePlayer.getInstance().asyncPlay(type);
  };

  private async asyncPlay(type: number): Promise<void> {
    try {
      let audioRendererInfo: audio.AudioRendererInfo = {
        usage: audio.StreamUsage.STREAM_USAGE_RINGTONE,
        rendererFlags: 0
      };
      this.tonePlayer = await audio.createTonePlayer(audioRendererInfo);
      await this.tonePlayer.load(type);
      await this.tonePlayer.start();
    } catch (err) {
      HiLog.error(TAG, 'startPlay err');
      TonePlayer.destroy();
    }
  }

  private startVibrate(duration: number): void {
    try {
      vibrator.startVibration({
        type: 'time',
        duration: duration,
      }, {
        id: 0,
        usage: 'media'
      }, (error) => {
        if (error) {
          HiLog.error(TAG, 'startVibrate fail');
        } else {
          HiLog.info(TAG, 'startVibrate Callback returned to indicate a successful vibration.');
        }
      });
    } catch (err) {
      HiLog.error(TAG, 'startVibrate err');
    }
  }

  private stopVibrate(): void {
    HiLog.info(TAG, 'stop Vibration');
    try {
      vibrator.stopVibration(vibrator.VibratorStopMode.VIBRATOR_STOP_MODE_TIME).then(() => {
        HiLog.info(TAG, 'stopVibration successful.');
      }).catch((err: BusinessError) => {
        HiLog.error(TAG, `stopVibration failed. Error code: ${err?.code}, message: ${err?.message}`);
      });
    } catch (err) {
      HiLog.error(TAG, 'stopVibrate errCode');
    }
  }
}