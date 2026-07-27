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

import { bundleManager } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hiSysEvent } from '@kit.PerformanceAnalysisKit';
import { SimId } from '../constant/Constants';
import { CommandType } from '../constant/SimToolKitConstant';
import HiLog from './HiLog';

const TAG: string = 'StkReport';

export class Report {
  private static reportInstance: Report = new Report();
  private static readonly DOMAIN: string = 'SIMTOOLKITS';
  private static readonly EVENT: string = 'CMD_COUNT';
  private static readonly MIN_REPORT_COUNT: number = 100;
  private commandTypeArr = [
    CommandType.SET_UP_MENU,
    CommandType.DISPLAY_TEXT,
    CommandType.SELECT_ITEM,
    CommandType.GET_INPUT,
    CommandType.GET_INKEY,
    CommandType.SET_UP_IDLE_MODE_TEXT,
    CommandType.PROVIDE_LOCAL_INFORMATION,
    CommandType.SEND_DTMF,
    CommandType.SEND_SMS,
    CommandType.SEND_SS,
    CommandType.SEND_USSD,
    CommandType.GET_CHANNEL_STATUS,
    CommandType.REFRESH,
    CommandType.LAUNCH_BROWSER,
    CommandType.SET_UP_CALL,
    CommandType.PLAY_TONE,
    CommandType.OPEN_CHANNEL,
    CommandType.CLOSE_CHANNEL,
    CommandType.RECEIVE_DATA,
    CommandType.SEND_DATA,
    CommandType.SET_UP_EVENT_LIST,
    CommandType.LANGUAGE_NOTIFICATION
  ];
  private cmdCountMap: Map<string, number> = new Map<string, number>();

  private constructor() {
  }

  public static getInstance(): Report {
    return Report.reportInstance;
  }

  public addCmdCount(type: CommandType, slotId: number): void {
    let key = `${type}_${slotId}`;
    let curCount = this.cmdCountMap.get(key) ?? 0;
    this.cmdCountMap.set(key, curCount + 1);
  }

  public async reportCbsEvent(): Promise<void> {
    try {
      let allCount = 0;
      let countArr: number[] = [];
      for (let i = 0; i < this.commandTypeArr.length; i++) {
        let count = this.cmdCountMap.get(`${this.commandTypeArr[i]}_${SimId.SLOT_ID_0}`) ?? 0;
        countArr.push(count);
        allCount += count;
      }
      for (let i = 0; i < this.commandTypeArr.length; i++) {
        let count = this.cmdCountMap.get(`${this.commandTypeArr[i]}_${SimId.SLOT_ID_1}`) ?? 0;
        countArr.push(count);
        allCount += count;
      }
      if (allCount <= Report.MIN_REPORT_COUNT) {
        HiLog.info(TAG, `STK report count too small`);
        return;
      }
      let params: Record<string, string | Array<number>> = {};
      let bundleInfo: bundleManager.BundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT);
      params.PVERSIONID = bundleInfo.versionName;
      params.COUNTR_ARR = countArr;
      let eventInfo: hiSysEvent.SysEventInfo = {
        domain: Report.DOMAIN,
        name: Report.EVENT,
        eventType: hiSysEvent.EventType.STATISTIC,
        params: params
      };
      await hiSysEvent.write(eventInfo).then(() => {
        HiLog.info(TAG, `STK report success`);
      }).catch((err: BusinessError) => {
        HiLog.error(TAG, `STK report failed. Code: ${err.code}, message: ${err.message}`);
      });
    } catch (error) {
      const err = error as BusinessError;
      HiLog.error(TAG, `STK report failed. Code: ${err.code}, message: ${err.message}`);
    }
  }
}