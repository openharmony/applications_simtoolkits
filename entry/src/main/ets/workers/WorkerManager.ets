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

import { worker, ErrorEvent, MessageEvents } from '@kit.ArkTS';
import HiLog from '../common/utils/HiLog';
import { SEND_UP_PARAM, WorkerMessage } from './WorkerContant';
import { BaseUpParams } from '../model/upDecode/BaseUpParams';
import { UpParamsCacheUtils } from '../common/utils/UpParamsCacheUtils';
import { CommandType } from '../common/constant/SimToolKitConstant';
import { ContextStorageHelper } from '../common/utils/ContextStorageHelper';
import { UpDecodeFactory } from '../model/upDecode/UpDecodeFactory';

const TAG = 'WorkerManager';
const WORKER_NAME = 'simToolKit_worker';
const CMD_HEX_PROMISE_LEN = 1000;

export class WorkerManager {
  protected mWorker: worker.ThreadWorker | undefined = undefined;
  private callBacks: Map<string, (result?: BaseUpParams) => void> = new Map<string, (result?: BaseUpParams) => void>();
  private requestIndex: number = 0;
  private static sInstance: WorkerManager | undefined = undefined;

  private constructor() {
  }

  static getInstance(): WorkerManager {
    if (!WorkerManager.sInstance) {
      HiLog.info(TAG, 'WorkerManager getInstance.');
      WorkerManager.sInstance = new WorkerManager();
    }
    return WorkerManager.sInstance;
  }

  private initWorker(): void {
    if (this.mWorker) {
      return;
    }
    HiLog.info(TAG, 'WorkerManager initWorker');
    this.mWorker = new worker.ThreadWorker('entry/ets/workers/Worker.ets', { name: WORKER_NAME });
    this.mWorker.onexit = (code: number) => {
      HiLog.info(TAG, `onexit code:${code}`);
    };
    this.mWorker.onerror = (err: ErrorEvent) => {
      HiLog.error(TAG, 'onerror');
    };
    this.mWorker.onmessageerror = (event: MessageEvents) => {
      HiLog.error(TAG, 'onmessageerror');
    };
    this.mWorker.onmessage = (messageEvents: MessageEvents) => {
      let workerMessage: WorkerMessage = messageEvents.data as WorkerMessage;
      this.toCallBack(workerMessage);
    };
  }

  private async toCallBack(workerMessage: WorkerMessage): Promise<void> {
    let upParam = workerMessage.param as BaseUpParams;
    if (upParam?.commandType === CommandType.SET_UP_MENU) {
      // save main menu
      await UpParamsCacheUtils.getInstance().insertMainMenuToDB(
        ContextStorageHelper.getInstance().getServiceContext(), upParam);
    }
    const key = this.getCallBackKey(workerMessage);
    if (this.callBacks.has(key)) {
      const callback = this.callBacks.get(key);
      if (callback) {
        callback(upParam);
      }
      this.callBacks.delete(key);
    }
  }

  private getCallBackKey(message: WorkerMessage): string {
    return message.requestType + message.callBackId;
  }

  private getParseParamsPromise(cmdHex: string, slotId: number): Promise<BaseUpParams | undefined> {
    let promise: Promise<BaseUpParams | undefined> = new Promise((resolve, reject) => {
      try {
        let param = UpDecodeFactory.getInstance().parseUpData(cmdHex, slotId);
        resolve(param);
      } catch (error) {
        HiLog.error(TAG, `parseParams UpDecodeFactory.parseUpData error, ${error?.code}, ${error?.message}`);
        resolve(undefined);
      }
    });
    return promise;
  }

  private async parseParamPromise(cmdHex: string, slotId: number): Promise<BaseUpParams | undefined>{
    let upParam = await this.getParseParamsPromise(cmdHex, slotId);
    if (upParam?.commandType === CommandType.SET_UP_MENU) {
      // save main menu
      await UpParamsCacheUtils.getInstance().insertMainMenuToDB(
        ContextStorageHelper.getInstance().getServiceContext(), upParam);
    }
    return upParam;
  }

  public sendUpParams(cmdHex: string, slotId: number, callBack?: (result?: BaseUpParams) => void): void {
    if (cmdHex.length <= CMD_HEX_PROMISE_LEN) {
      HiLog.info(TAG, 'sendUpParams promise');
      this.parseParamPromise(cmdHex, slotId).then(result => {
        callBack?.(result);
      });
      return;
    }
    HiLog.info(TAG, `sendUpParams  --- ${this.requestIndex}`);
    this.initWorker();
    if (this.mWorker) {
      const message: WorkerMessage = {
        requestType: SEND_UP_PARAM,
        callBackId: this.requestIndex,
        commandHex: cmdHex,
        slotId: slotId
      }
      if (callBack) {
        this.callBacks.set(this.getCallBackKey(message), callBack);
      }
      this.mWorker?.postMessage(message);
      this.requestIndex++;
    } else {
      HiLog.error(TAG, 'sendUpParams send fail, worker has been closed!');
    }
  }
}