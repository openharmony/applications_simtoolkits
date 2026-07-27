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

import { BaseEventListEnvelopeData } from '../../model/responseData/envelopeData/BaseEventListEnvelopeData';
import { LanguageEventListEnvelopeData } from '../../model/responseData/envelopeData/LanguageEventListEnvelopeData';
import { SimToolKitResponseManager } from '../../model/SimToolKitResponseManager';
import { SetupEventKey, SimId } from '../constant/Constants';
import { DeviceId, EventIdType } from '../constant/SimToolKitConstant';
import { ContextStorageHelper } from '../utils/ContextStorageHelper';
import { sharedPreferencesUtils } from '../utils/SharedPreferencesUtils';
import HiLog from '../utils/HiLog';
import CommonUtils from '../utils/CommonUtils';
import { NewIdleScreenHelper } from './NewIdleScreenHelper';
import { BackgroundTaskRequestUtils } from '../utils/BackgroundTaskRequestUtils';
import { UserAbilityHelper } from './UserAbilityHelper';

const TAG = 'SetUpEventListHelper';
const SET_UP_EVENT_LIST_IDLE = 'set_up_event_list_idle';

export class SetUpEventListHelper {
  private static instance: SetUpEventListHelper | undefined = undefined;

  public static getInstance(): SetUpEventListHelper {
    if (!SetUpEventListHelper.instance) {
      HiLog.info(TAG, 'SetUpEventListHelper getInstance init');
      SetUpEventListHelper.instance = new SetUpEventListHelper();
    }
    return SetUpEventListHelper.instance;
  }

  private constructor() {
  }

  public handleSetupEvent(slotId: number, eventIdList: Array<number>): void {
    HiLog.info(TAG, 'handleSetupEvent start');
    let saveEventKey = `${SetupEventKey.EVENT_LIST_KEY}${slotId}`;
    if (CommonUtils.isEmptyArr(eventIdList)) {
      sharedPreferencesUtils.deleteToPreferences(
        ContextStorageHelper.getInstance().getServiceContext(), saveEventKey);
    } else {
      sharedPreferencesUtils.saveNumberArray(
        ContextStorageHelper.getInstance().getServiceContext(), saveEventKey, eventIdList);
      this.handleSetupEventInner(slotId, eventIdList);
    }
  }

  private handleSetupEventInner(slotId: number, eventIdList: Array<number>): void {
    HiLog.info(TAG, 'handleSetupEventInner start');
    if (CommonUtils.isEmptyArr(eventIdList)) {
      HiLog.info(TAG, 'handleSetupEventInner eventIdList is empty');
      return;
    }
    BackgroundTaskRequestUtils.getInstance().applyEfficiencyResourcesGreaterThanPre(
      BackgroundTaskRequestUtils.DELAY_TIME_MINUTES_5);
    if (eventIdList.includes(EventIdType.IDLE_SCREEN_AVAILABLE_EVENT)) {
      this.checkIdleScreen(slotId);
    }
    if (eventIdList.includes(EventIdType.USER_ACTIVITY_EVENT)) {
      UserAbilityHelper.getInstance().registerListener(slotId, (slotId: number) => {
        HiLog.info(TAG, `checkOneSetupEvent USER_ACTIVITY_EVENT  slotId:${slotId}`);
        this.checkForSetupEvent(slotId, EventIdType.USER_ACTIVITY_EVENT);
      });
    }
  }

  private checkIdleScreen(slotId: number): void {
    NewIdleScreenHelper.getInstance().isHomeAbilityTop().then((isHomeTop: boolean) => {
      if (isHomeTop) {
        this.checkForSetupEvent(slotId, EventIdType.IDLE_SCREEN_AVAILABLE_EVENT);
      } else {
        NewIdleScreenHelper.getInstance().registerIdleScreenListener(
          slotId, SET_UP_EVENT_LIST_IDLE, (slotId: number) => {
          this.checkForSetupEvent(slotId, EventIdType.IDLE_SCREEN_AVAILABLE_EVENT);
        });
      }
    });
  }

  public languageChange(language: string): void {
    this.checkForSetupEvent(SimId.SLOT_ID_0, EventIdType.LANGUAGE_SELECTION_EVENT, language);
    this.checkForSetupEvent(SimId.SLOT_ID_1, EventIdType.LANGUAGE_SELECTION_EVENT, language);
  }

  private checkForSetupEvent(slotId: number, eventId: number, language?: string): void {
    HiLog.info(TAG, `checkForSetupEvent slotId:${slotId}, eventId:${eventId}, language:${language}`);
    sharedPreferencesUtils.getNumberArray(ContextStorageHelper.getInstance().getServiceContext(),
      `${SetupEventKey.EVENT_LIST_KEY}${slotId}`).then(eventArr => {
      if (CommonUtils.isEmptyArr(eventArr)) {
        return;
      }
      let eventList = eventArr as Array<number>;
      if (eventList.includes(eventId)) {
        if (eventId === EventIdType.LANGUAGE_SELECTION_EVENT) {
          this.sendLanguageEventListEnvelopeData(slotId, language);
        } else if (eventId === EventIdType.IDLE_SCREEN_AVAILABLE_EVENT || eventId === EventIdType.USER_ACTIVITY_EVENT) {
          this.sendEventListEnvelopeData(slotId, eventId);
          this.removeSetUpEvent(eventArr, slotId, eventId);
        }
        if (eventList.length === 0 ||
          (eventList.length === 1 && eventList.includes(EventIdType.LANGUAGE_SELECTION_EVENT))) {
          BackgroundTaskRequestUtils.getInstance().applyEfficiencyResources(
            BackgroundTaskRequestUtils.DELAY_TIME_MINUTES_1);
        }
      }
    });
  }

  private removeSetUpEvent(eventArr: Array<number>, slotId: number, eventId: number): void {
    HiLog.info(TAG, `removeSetUpEvent slotId:${slotId}, eventId:${eventId}, eventArr: ${eventArr}`);
    let saveEventKey = `${SetupEventKey.EVENT_LIST_KEY}${slotId}`;
    if (CommonUtils.isEmptyArr(eventArr)) {
      return;
    }
    let eventList = eventArr as Array<number>;
    let eventListIndex = eventList.indexOf(eventId);
    if (eventListIndex < 0) {
      return;
    }
    eventList.splice(eventListIndex, 1);
    sharedPreferencesUtils.saveNumberArray(
      ContextStorageHelper.getInstance().getServiceContext(), saveEventKey, eventList);
  }

  private sendEventListEnvelopeData(slotId: number, eventId: number): void {
    HiLog.info(TAG, `sendIdleScreenEventListEnvelopeData slotId:${slotId}`);
    let data = new BaseEventListEnvelopeData();
    data.slotId = slotId;
    data.eventId = eventId;
    if (eventId === EventIdType.IDLE_SCREEN_AVAILABLE_EVENT) {
      data.devicesSource = DeviceId.DEV_ID_DISPLAY;
    } else {
      data.devicesSource = DeviceId.DEV_ID_TERMINAL;
    }
    data.devicesDest = DeviceId.DEV_ID_UICC;
    SimToolKitResponseManager.getInstance().sendEventListEnvelopeData(data);
  }

  private sendLanguageEventListEnvelopeData(slotId: number, language: string | undefined): void {
    HiLog.info(TAG, `sendLanguageEventListEnvelopeData slotId:${slotId}, language:${language}`);
    if (!language) {
      return;
    }
    let data = new LanguageEventListEnvelopeData();
    data.slotId = slotId;
    data.language = language;
    data.eventId = EventIdType.LANGUAGE_SELECTION_EVENT;
    data.devicesSource = DeviceId.DEV_ID_TERMINAL;
    data.devicesDest = DeviceId.DEV_ID_UICC;
    SimToolKitResponseManager.getInstance().sendEventListEnvelopeData(data);
  }
}