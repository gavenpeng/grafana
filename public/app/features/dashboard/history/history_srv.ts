import _ from 'lodash';
import coreModule from 'app/core/core_module';
import { DashboardModel } from '../dashboard_model';

export interface HistoryListOpts {
  limit: number;
  start: number;
}

export interface RevisionsModel {
  id: number;
  checked: boolean;
  dashboardId: number;
  parentVersion: number;
  version: number;
  created: Date;
  createdBy: string;
  message: string;
}

export interface CalculateDiffOptions {
  new: DiffTarget;
  base: DiffTarget;
  diffType: string;
}

export interface DiffTarget {
  dashboardId: number;
  version: number;
  unsavedDashboard?: DashboardModel; // when doing diffs against unsaved dashboard version
}

export class HistorySrv {
  /** @ngInject */
  constructor(private backendSrv, private $q) {}

  getHistoryList(dashboard: DashboardModel, options: HistoryListOpts) {
    const id = dashboard && dashboard.id ? dashboard.id : void 0;
    return id ? this.backendSrv.get(`api/dashboards/id/${id}/versions`, options) : this.$q.when([]);
  }

  calculateDiff(options: CalculateDiffOptions) {
    return this.backendSrv.post('api/dashboards/calculate-diff', options);
  }

  restoreDashboard(dashboard: DashboardModel, version: number) {
    const id = dashboard && dashboard.id ? dashboard.id : void 0;
    const url = `api/dashboards/id/${id}/restore`;
    return id && _.isNumber(version) ? this.backendSrv.post(url, { version }) : this.$q.when({});
  }
}

coreModule.service('historySrv', HistorySrv);
