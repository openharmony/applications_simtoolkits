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

import { rpc } from '@kit.IPCKit';
import { common, bundleManager } from '@kit.AbilityKit';
import { sim } from '@kit.TelephonyKit';
import { commonEventManager, settings, systemDateTime } from '@kit.BasicServicesKit';
import CommonUtils from '../utils/CommonUtils';
import { UpParamsCacheUtils } from '../utils/UpParamsCacheUtils';
import HiLog from '../utils/HiLog';
import { SimId, SimSwitchState } from '../constant/Constants';

const TAG = 'EntranceHelper';

interface SearchItems {
  itemList: string[];
}

interface CallMessage {
  method: string;
  extra?: SearchItems;
}

class EntranceHelper {
  private static readonly MAIN_MENU_PROP_KEY = 'stk_entrance';
  private static readonly MAIN_MENU_TIME_KEY = '_time';
  private static readonly SIM_SLOT_COUNT_1 = 1;
  private static readonly SETTINGS_ENABLE_SEARCH_ITEMS = 2;
  private static readonly ENTRANCE_VALUE_HIDE = '0';
  private static readonly ENTRANCE_VALUE_SHOW_ONE = '1';
  private static readonly ENTRANCE_VALUE_SHOW_TWO = '2';
  private static readonly ENTRANCE_VALUE_SHOW_ESIM = '31';
  private static readonly SEARCH_ITEM_NAME_SLOT1_STR1 = 'stk_entrance_0';
  private static readonly SEARCH_ITEM_NAME_SLOT1_STR2 = 'stk_entrance_02';
  private static readonly SEARCH_ITEM_NAME_SLOT2_STR2 = 'stk_entrance_1';
  private static readonly SEARCH_ITEM_NAME_ESIM = 'stk_entrance_esim';
  private masSimCount: number = sim.getMaxSimCount();

  private getSettingDataKey(slotId: number): string {
    return this.masSimCount === EntranceHelper.SIM_SLOT_COUNT_1 ?
    EntranceHelper.MAIN_MENU_PROP_KEY : `${EntranceHelper.MAIN_MENU_PROP_KEY}_${slotId}`;
  }

  private getSaveSettingDataValue(slotId: number, isHaveMainMenu: boolean): string {
    if (!isHaveMainMenu) {
      return EntranceHelper.ENTRANCE_VALUE_HIDE;
    }
    if (this.masSimCount === EntranceHelper.SIM_SLOT_COUNT_1) {
      return EntranceHelper.ENTRANCE_VALUE_SHOW_ONE;
    }
    let esimSwitch = CommonUtils.getEsimSwitch();
    switch (esimSwitch) {
      case SimSwitchState.PSIM2_ESIM:
        return slotId === SimId.SLOT_ID_0 ? EntranceHelper.ENTRANCE_VALUE_SHOW_TWO :
        EntranceHelper.ENTRANCE_VALUE_SHOW_ESIM;
      case SimSwitchState.PSIM1_ESIM:
        return slotId === SimId.SLOT_ID_0 ? EntranceHelper.ENTRANCE_VALUE_SHOW_ONE :
        EntranceHelper.ENTRANCE_VALUE_SHOW_ESIM;
      default:
        return EntranceHelper.ENTRANCE_VALUE_SHOW_ONE;
    }
  }

  public async checkIsHaveMainMenu(context: common.ServiceExtensionContext | undefined, slotId: number): Promise<void> {
    if (!context) {
      return;
    }
    let isHaveMainMenu = !CommonUtils.isEmptyObj(UpParamsCacheUtils.getInstance().getMainMenuParamsMemory(slotId));
    let settingDataKey = this.getSettingDataKey(slotId);
    let settingDataValue = this.getSaveSettingDataValue(slotId, isHaveMainMenu);
    try {
      await settings.setValue(context, settingDataKey, settingDataValue);
      await settings.setValue(context, `${settingDataKey}${EntranceHelper.MAIN_MENU_TIME_KEY}`,
        isHaveMainMenu ? systemDateTime.getTime().toString() : '0');
    } catch (error) {
      HiLog.error(TAG, `checkIsHaveMainMenu settings.setValue err, ${error?.code}, ${error?.message}`);
    }

    // send event
    let publishData: commonEventManager.CommonEventPublishData = {
      code: slotId,
      data: settingDataValue,
      subscriberPermissions: ['ohos.permission.SET_TELEPHONY_STATE']
    };
    try {
      commonEventManager.publish(EntranceHelper.MAIN_MENU_PROP_KEY, publishData, (error, value) => {
        if (error != null) {
          HiLog.error(TAG, 'checkIsHaveMainMenu publish failed.');
        } else {
          HiLog.info(TAG, 'checkIsHaveMainMenu publish common event success.');
        }
      });
    } catch (error) {
      HiLog.error(TAG, `checkIsHaveMainMenu publish event error, ${error?.code}, ${error?.message}`);
    }

    this.updateEnableState(context, isHaveMainMenu, this.getSettingSearchKey(slotId));
  }

  private getSettingSearchKey(slotId: number): string {
    if (this.masSimCount === EntranceHelper.SIM_SLOT_COUNT_1) {
      return EntranceHelper.MAIN_MENU_PROP_KEY;
    }
    let esimSwitch = CommonUtils.getEsimSwitch();
    switch (esimSwitch) {
      case SimSwitchState.PSIM2_ESIM:
        return slotId === SimId.SLOT_ID_0 ? EntranceHelper.SEARCH_ITEM_NAME_SLOT1_STR2 :
        EntranceHelper.SEARCH_ITEM_NAME_ESIM;
      case SimSwitchState.PSIM1_ESIM:
        return slotId === SimId.SLOT_ID_0 ? EntranceHelper.SEARCH_ITEM_NAME_SLOT1_STR1 :
        EntranceHelper.SEARCH_ITEM_NAME_ESIM;
      default:
        return slotId === SimId.SLOT_ID_0 ? EntranceHelper.SEARCH_ITEM_NAME_SLOT1_STR1 :
        EntranceHelper.SEARCH_ITEM_NAME_SLOT2_STR2;
    }
  }

  private async updateEnableState(context: common.ServiceExtensionContext, isEnable: boolean,
    item: string): Promise<void> {
    try {
      let connectionId = context.connectServiceExtensionAbility({
        'bundleName': 'com.ohos.settings',
        'abilityName': 'SettingsExtService'
      }, {
        onConnect: async (elementName: bundleManager.ElementName, remote: rpc.IRemoteObject) => {
          const enableObj: CallMessage =
            { method: isEnable ? 'enableSearchItems' : 'disableSearchItems', extra: { itemList: [item] } };
          await this.sendMessage(remote, enableObj);
          await this.disConnect(context, connectionId);
        },
        onDisconnect: () => {
          HiLog.info(TAG, 'updateSearch onDisconnect');
        },
        onFailed: () => {
          HiLog.info(TAG, 'updateSearch onFailed');
        }
      });
    } catch (error) {
      HiLog.error(TAG, `connectServiceExtensionAbility failed. Code: ${error?.code}, message: ${error?.message}`);
    }
  }

  private async sendMessage(remote: rpc.IRemoteObject, obj: CallMessage): Promise<void> {
    const option = new rpc.MessageOption();
    const data = new rpc.MessageSequence();
    const reply = new rpc.MessageSequence();
    try {
      data.writeString(JSON.stringify(obj));
      await remote.sendMessageRequest(EntranceHelper.SETTINGS_ENABLE_SEARCH_ITEMS, data, reply, option);
      HiLog.info(TAG, JSON.stringify(reply.readString()));
    } catch (err) {
      HiLog.error(TAG, `sendMessageRequest failed. Code: ${err.code}, message: ${err.message}`);
    } finally {
      data.reclaim();
      reply.reclaim();
    }
  }

  private async disConnect(context: common.ServiceExtensionContext, connectionId: number): Promise<void> {
    try {
      await context.disconnectServiceExtensionAbility(connectionId);
      HiLog.info(TAG, `disconnectServiceExtensionAbility succeed: ${connectionId}`);
    } catch (err) {
      HiLog.error(TAG, `disconnectServiceExtensionAbility failed. Code: ${err.code}, message: ${err.message}`);
    }
  }
}

const entranceHelper: EntranceHelper = new EntranceHelper();

export default entranceHelper;