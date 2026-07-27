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

import { ThreadWorkerGlobalScope, MessageEvents, ErrorEvent, worker } from '@kit.ArkTS';
import HiLog from '../common/utils/HiLog';
import { UpDecodeFactory } from '../model/upDecode/UpDecodeFactory';
import { SEND_UP_PARAM, WorkerMessage } from './WorkerContant';

const TAG = 'workerPort';

const workerPort: ThreadWorkerGlobalScope = worker.workerPort;

workerPort.onmessage = (messageEvents: MessageEvents) => {
  if (!messageEvents.data) {
    HiLog.info(TAG, 'workerPort.onmessage is not have data');
    return;
  }
  let workerMessage = messageEvents.data as WorkerMessage;

  if (workerMessage.requestType !== SEND_UP_PARAM) {
    return;
  }
  let upParams = UpDecodeFactory.getInstance().parseUpData(workerMessage.commandHex ?? '', workerMessage.slotId);
  let resultMessage: WorkerMessage = {
    requestType: workerMessage.requestType,
    callBackId: workerMessage.callBackId,
    slotId: workerMessage.slotId,
    param: upParams
  }
  workerPort.postMessage(resultMessage);
};

workerPort.onmessageerror = (message: MessageEvents) => {
  HiLog.error(TAG, 'workerPort.onmessageerror');
};

workerPort.onerror = (error: ErrorEvent) => {
  HiLog.error(TAG, 'workerPort.onerror');
};

