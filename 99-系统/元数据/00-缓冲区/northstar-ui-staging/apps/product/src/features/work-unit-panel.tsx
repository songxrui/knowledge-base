import {
  ActionBar,
  Button,
  DataGroup,
  EmptyState,
  Field,
  FormGrid,
  InlineNotice,
  Section,
} from "@northstar/design-system";
import { createStableId, toUtcTimestamp, type WorkUnit } from "@northstar/domain";
import { useCallback, useEffect, useState, type FormEvent } from "react";

import type { ProductServices } from "../bootstrap.js";

interface WorkUnitPanelProps {
  readonly core: ProductServices["core"];
  readonly snapshotReady: boolean;
  readonly onError: (error: unknown) => void;
  readonly onChanged: () => Promise<void>;
}

function value(data: FormData, key: string): string {
  const entry = data.get(key);
  return typeof entry === "string" ? entry.trim() : "";
}

function optionalList(data: FormData, key: string): string[] {
  const entry = value(data, key);
  return entry ? [entry] : [];
}

function optionalValue(data: FormData, key: string): string | null {
  return value(data, key) || null;
}

export function WorkUnitPanel({ core, snapshotReady, onError, onChanged }: WorkUnitPanelProps) {
  const [workUnits, setWorkUnits] = useState<readonly WorkUnit[]>([]);
  const [busy, setBusy] = useState(false);

  const refresh = useCallback(async () => {
    setWorkUnits(await core.listWorkUnits());
  }, [core]);

  useEffect(() => {
    refresh().catch(onError);
  }, [onError, refresh]);

  const run = async (operation: () => Promise<unknown>) => {
    setBusy(true);
    try {
      await operation();
      await Promise.all([refresh(), onChanged()]);
    } catch (error) {
      onError(error);
    } finally {
      setBusy(false);
    }
  };

  const plan = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const form = event.currentTarget;
    const data = new FormData(form);
    const timestamp = toUtcTimestamp(new Date());
    void run(async () => {
      await core.planWorkUnit({
        id: createStableId("work-unit", [timestamp, value(data, "deliverable")]),
        schemaVersion: 1,
        timestamp,
        primaryDeliverable: value(data, "deliverable"),
        completionCriteria: [value(data, "completionCriteria")],
        nextAction: value(data, "nextAction"),
        capacityLimitHours: Number(value(data, "capacityLimitHours")),
        stopSignals: [value(data, "stopSignal")],
      });
      form.reset();
    });
  };

  const active = workUnits.find((unit) => unit.status === "active") ?? null;
  const planned = workUnits.filter((unit) => unit.status === "planned");
  const recent = workUnits.filter((unit) => unit.status === "completed" || unit.status === "stopped").slice(0, 3);

  return (
    <Section title="主要交付" description="一次只推进一个活动工作单元。完成标准、容量上限和停止信号在开始前写清。">
      {active ? (
        <DataGroup label="进行中">
          <div className="product-record-heading">
            <div><h3>{active.primaryDeliverable}</h3><p>下一步：{active.nextAction}</p></div>
            <span className="product-status">进行中</span>
          </div>
          <dl className="product-facts">
            <div><dt>完成标准</dt><dd>{active.completionCriteria.join("；")}</dd></div>
            <div><dt>容量上限</dt><dd>{active.capacityLimitHours} 小时</dd></div>
            <div><dt>停止信号</dt><dd>{active.stopSignals.join("；")}</dd></div>
          </dl>
          <form className="product-subform" onSubmit={(event) => {
            event.preventDefault();
            const data = new FormData(event.currentTarget);
            void run(() => core.finishActiveWorkUnit(active.id, {
              timestamp: toUtcTimestamp(new Date()),
              outcome: value(data, "outcome") as "completed" | "stopped",
              actualOutputs: optionalList(data, "actualOutput"),
              energyCost: optionalValue(data, "energyCost"),
              residualLoad: optionalValue(data, "residualLoad"),
              recoveryActions: optionalList(data, "recoveryAction"),
            }));
          }}>
            <FormGrid>
              <label className="product-select-field"><span>收尾结果</span><select className="ns-input" name="outcome" defaultValue="completed"><option value="completed">完成</option><option value="stopped">停止</option></select></label>
              <Field name="actualOutput" label="实际输出" description="没有形成输出时可以留空。" />
              <Field name="energyCost" label="主要消耗" description="没有观察到时可以留空。" />
              <Field name="residualLoad" label="残留负荷" description="没有残留负荷时可以留空。" />
              <Field name="recoveryAction" label="恢复或收口动作" description="不需要额外动作时可以留空。" />
            </FormGrid>
            <Button type="submit" tone="primary" isDisabled={busy}>收尾并保存</Button>
          </form>
        </DataGroup>
      ) : planned.length > 0 ? (
        <div className="product-stack">
          {planned.map((unit) => (
            <DataGroup key={unit.id} label="待开始">
              <div className="product-record-heading"><div><h3>{unit.primaryDeliverable}</h3><p>{unit.nextAction}</p></div><span className="product-status">计划</span></div>
              <Button
                tone="primary"
                isDisabled={busy || !snapshotReady}
                onPress={() => void run(() => core.startPlannedWorkUnit(unit.id, toUtcTimestamp(new Date())))}
              >开始这个工作单元</Button>
              {!snapshotReady ? <InlineNotice tone="warning" title="现状边界尚未确认" detail="先完成现状快照，再开始主要交付。" /> : null}
            </DataGroup>
          ))}
        </div>
      ) : (
        <DataGroup><EmptyState title="还没有主要交付" detail="先写一个可检查的输出，不把待办列表整体搬进来。" /></DataGroup>
      )}

      {!active ? (
        <DataGroup label="计划工作单元">
          <form className="product-form" onSubmit={plan}>
            <FormGrid>
              <Field name="deliverable" label="主要交付" isRequired />
              <Field name="completionCriteria" label="完成标准" isRequired />
              <Field name="nextAction" label="下一步动作" isRequired />
              <Field name="capacityLimitHours" label="容量上限（小时）" type="number" inputMode="decimal" isRequired />
              <Field name="stopSignal" label="停止信号" isRequired />
            </FormGrid>
            <ActionBar><Button type="submit" tone="primary" isDisabled={busy}>保存计划</Button></ActionBar>
          </form>
        </DataGroup>
      ) : null}

      {recent.length > 0 ? (
        <DataGroup label="最近收尾">
          <div className="product-compact-list">
            {recent.map((unit) => <div key={unit.id}><strong>{unit.primaryDeliverable}</strong><span>{unit.status === "completed" ? "完成" : "停止"} · {unit.actualOutputs.join("；") || "未记录输出"}</span></div>)}
          </div>
        </DataGroup>
      ) : null}
    </Section>
  );
}
