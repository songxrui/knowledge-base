import {
  ActionBar,
  Button,
  DataGroup,
  ErrorPanel,
  Field,
  FormGrid,
  InlineNotice,
  PageHeader,
  RiskBanner,
  Section,
} from "@northstar/design-system";
import {
  createStableId,
  DomainError,
  toUtcTimestamp,
  type BottleneckKind,
  type NorthStarKind,
  type RiskEvent,
  type TodayWorkspaceState,
} from "@northstar/domain";
import { getDomainErrorCopy } from "@northstar/methodology";
import { useCallback, useEffect, useState, type FormEvent } from "react";

import { WorkUnitPanel } from "../features/work-unit-panel.js";
import { useProduct } from "../providers.js";

const northStarLabels: Record<NorthStarKind, string> = {
  "sustainable-agency": "可持续心力",
  "compounding-assets": "复利资产",
  "personal-monopoly": "个人垄断",
};

const bottleneckLabels: Record<BottleneckKind, string> = {
  state: "状态",
  attention: "注意力",
  problem: "问题",
  expression: "表达",
  trust: "信任",
  sales: "销售",
  delivery: "交付",
  cash: "现金",
  platform: "平台",
};

const riskLabels: Record<RiskEvent["category"], string> = {
  health: "健康",
  safety: "安全",
  cash: "现金",
  customer: "客户",
  platform: "平台",
  data: "数据",
  legal: "法律",
};

function value(data: FormData, key: string): string {
  const entry = data.get(key);
  return typeof entry === "string" ? entry.trim() : "";
}

function lineValues(data: FormData, key: string): string[] {
  return value(data, key).split(/[\r\n,，]+/u).map((item) => item.trim()).filter(Boolean);
}

function describeError(error: unknown) {
  if (error instanceof DomainError) return getDomainErrorCopy(error.code);
  return { title: "操作没有完成", detail: error instanceof Error ? error.message : "未能读取错误信息。", action: "检查当前输入后重试。" };
}

export function TodayPage() {
  const { services } = useProduct();
  const [state, setState] = useState<TodayWorkspaceState | null>(null);
  const [risks, setRisks] = useState<readonly RiskEvent[]>([]);
  const [operatingSummary, setOperatingSummary] = useState({ activeProjects: 0, reusableAssets: 0, validatedProblems: 0, quotableOffers: 0, adoptedDeliveries: 0 });
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<unknown>(null);

  const refresh = useCallback(async () => {
    const [nextState, nextRisks, nextOperatingSummary] = await Promise.all([
      services.core.getTodayWorkspaceState(),
      services.core.listRisks(),
      services.operations.getSummary(),
    ]);
    setState(nextState);
    setRisks(nextRisks.filter((risk) => risk.status !== "recovered"));
    setOperatingSummary(nextOperatingSummary);
  }, [services]);

  useEffect(() => {
    refresh().catch(setError);
  }, [refresh]);

  const run = async (operation: () => Promise<unknown>) => {
    setBusy(true);
    setError(null);
    try {
      await operation();
      await refresh();
    } catch (caught) {
      setError(caught);
    } finally {
      setBusy(false);
    }
  };

  const saveSnapshot = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const timestamp = toUtcTimestamp(new Date());
    const changes = {
      cashBufferAmount: Number(value(data, "cashBufferAmount")),
      fixedMonthlyCosts: Number(value(data, "fixedMonthlyCosts")),
      healthConstraints: [value(data, "healthConstraint")],
      recoveryConstraints: [value(data, "recoveryConstraint")],
      weeklyCapacityHours: Number(value(data, "weeklyCapacityHours")),
      capacityAllocation: {
        body: Number(value(data, "capacityBody")),
        responsibilities: Number(value(data, "capacityResponsibilities")),
        building: Number(value(data, "capacityBuilding")),
        relationships: Number(value(data, "capacityRelationships")),
        reserve: Number(value(data, "capacityReserve")),
      },
      recentWork: value(data, "recentWork") ? [value(data, "recentWork")] : [],
      platformBoundaries: [value(data, "platformBoundary")],
      dataBoundaries: [value(data, "dataBoundary")],
      stopConditions: [value(data, "stopCondition")],
    };
    void run(() => services.core.saveCompletedSnapshot({
      id: state?.snapshot?.id ?? createStableId("workspace-snapshot", [timestamp]),
      schemaVersion: 1,
      timestamp,
      ...changes,
    }));
  };

  const saveNorthStars = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    void run(async () => {
      const timestamp = toUtcTimestamp(new Date());
      await services.core.setNorthStarConstraints(
        (Object.keys(northStarLabels) as NorthStarKind[]).map((kind) => ({
          id: createStableId("north-star", [kind, timestamp]),
          schemaVersion: 1,
          timestamp,
          kind,
          observedFacts: [value(data, `${kind}-facts`)],
          userFloor: value(data, `${kind}-floor`),
          affectedActivityIds: lineValues(data, `${kind}-activities`),
        })),
      );
    });
  };

  const saveBottleneck = (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    const data = new FormData(event.currentTarget);
    const timestamp = toUtcTimestamp(new Date());
    const secondary = value(data, "secondaryConstraint");
    void run(() => services.core.selectBottleneck({
      id: createStableId("bottleneck", [timestamp, value(data, "primary")]),
      schemaVersion: 1,
      timestamp,
      primary: value(data, "primary") as BottleneckKind,
      secondaryConstraint: secondary ? secondary as BottleneckKind : null,
      selectionFacts: [value(data, "selectionFact")],
    }));
  };

  const currentNorthStars = state?.northStarConstraints.filter((item) => item.effectiveTo === null) ?? [];
  const errorMessage = error ? describeError(error) : null;

  if (state === null) {
    return (
      <>
        <PageHeader meta="今天" title="先看现实，再定交付" description="正在读取这台设备上的现状记录。" />
        {errorMessage ? <ErrorPanel whatHappened={`${errorMessage.title}：${errorMessage.detail}`} affectedData="本地记录没有变化。" nextAction={<Button onPress={() => void refresh()}>重新读取</Button>} /> : <DataGroup><p>正在读取本地记录。</p></DataGroup>}
      </>
    );
  }

  return (
    <>
      <PageHeader meta="今天" title="先看现实，再定交付" description="现状、安全边界、主瓶颈和主要交付放在同一页。页面只呈现已经记录的事实。" />

      {errorMessage ? <ErrorPanel whatHappened={`${errorMessage.title}：${errorMessage.detail}`} affectedData="已保存记录没有变化。" nextAction={<Button onPress={() => setError(null)}>{errorMessage.action}</Button>} /> : null}

      {risks.map((risk) => (
        <RiskBanner
          key={risk.id}
          title={`${riskLabels[risk.category]}风险 · ${risk.status === "active" ? "处理中" : "观察中"}`}
          detail={`${risk.facts.join("；")} 当前动作：${risk.immediateActions.join("；")}`}
        />
      ))}

      <Section title="经营摘要" description="只汇总已经保存的项目、资产、问题、产品约定和采用事实。">
        <DataGroup>
          <dl className="product-facts">
            <div><dt>活跃项目</dt><dd>{operatingSummary.activeProjects}</dd></div>
            <div><dt>未淘汰资产</dt><dd>{operatingSummary.reusableAssets}</dd></div>
            <div><dt>已核验问题</dt><dd>{operatingSummary.validatedProblems}</dd></div>
            <div><dt>可报价约定</dt><dd>{operatingSummary.quotableOffers}</dd></div>
            <div><dt>已采用交付</dt><dd>{operatingSummary.adoptedDeliveries}</dd></div>
          </dl>
        </DataGroup>
      </Section>

      <Section title="现实快照" description="现金、健康、恢复和容量边界完整后，工作单元才能开始。">
        {state?.snapshot?.status === "complete" ? (
          <DataGroup label={`第 ${state.snapshot.revision} 次更新`}>
            <dl className="product-facts">
              <div><dt>现金缓冲</dt><dd>{state.snapshot.cashBufferAmount} 元</dd></div>
              <div><dt>固定月支出</dt><dd>{state.snapshot.fixedMonthlyCosts} 元</dd></div>
              <div><dt>每周容量</dt><dd>{state.snapshot.weeklyCapacityHours} 小时</dd></div>
              <div><dt>健康边界</dt><dd>{state.snapshot.healthConstraints.join("；")}</dd></div>
              <div><dt>停止条件</dt><dd>{state.snapshot.stopConditions.join("；")}</dd></div>
            </dl>
          </DataGroup>
        ) : <InlineNotice tone="warning" title="现状边界尚未确认" detail="填写完整字段后再开始主要交付。" />}

        <DataGroup label={state?.snapshot ? "更新现状" : "建立现状"}>
          <form className="product-form" onSubmit={saveSnapshot}>
            <FormGrid>
              <Field name="cashBufferAmount" label="可用现金缓冲（元）" type="number" inputMode="decimal" defaultValue={state?.snapshot?.cashBufferAmount === null || state?.snapshot?.cashBufferAmount === undefined ? "" : String(state.snapshot.cashBufferAmount)} isRequired />
              <Field name="fixedMonthlyCosts" label="固定月支出（元）" type="number" inputMode="decimal" defaultValue={state?.snapshot?.fixedMonthlyCosts === null || state?.snapshot?.fixedMonthlyCosts === undefined ? "" : String(state.snapshot.fixedMonthlyCosts)} isRequired />
              <Field name="healthConstraint" label="健康约束" defaultValue={state?.snapshot?.healthConstraints[0] ?? ""} isRequired />
              <Field name="recoveryConstraint" label="恢复约束" defaultValue={state?.snapshot?.recoveryConstraints[0] ?? ""} isRequired />
              <Field name="weeklyCapacityHours" label="每周可用容量（小时）" type="number" inputMode="decimal" defaultValue={state?.snapshot?.weeklyCapacityHours === null || state?.snapshot?.weeklyCapacityHours === undefined ? "" : String(state.snapshot.weeklyCapacityHours)} isRequired />
              <Field name="capacityBody" label="身体与恢复（小时）" type="number" inputMode="decimal" defaultValue={String(state?.snapshot?.capacityAllocation?.body ?? 0)} isRequired />
              <Field name="capacityResponsibilities" label="必要责任（小时）" type="number" inputMode="decimal" defaultValue={String(state?.snapshot?.capacityAllocation?.responsibilities ?? 0)} isRequired />
              <Field name="capacityBuilding" label="建设投入（小时）" type="number" inputMode="decimal" defaultValue={String(state?.snapshot?.capacityAllocation?.building ?? 0)} isRequired />
              <Field name="capacityRelationships" label="关系维护（小时）" type="number" inputMode="decimal" defaultValue={String(state?.snapshot?.capacityAllocation?.relationships ?? 0)} isRequired />
              <Field name="capacityReserve" label="预留（小时）" type="number" inputMode="decimal" defaultValue={String(state?.snapshot?.capacityAllocation?.reserve ?? 0)} isRequired />
              <Field name="recentWork" label="近期已发生的工作" defaultValue={state?.snapshot?.recentWork[0] ?? ""} />
              <Field name="platformBoundary" label="平台边界" defaultValue={state?.snapshot?.platformBoundaries[0] ?? ""} isRequired />
              <Field name="dataBoundary" label="数据边界" defaultValue={state?.snapshot?.dataBoundaries[0] ?? ""} isRequired />
              <Field name="stopCondition" label="停止条件" defaultValue={state?.snapshot?.stopConditions[0] ?? ""} isRequired />
            </FormGrid>
            <ActionBar><Button type="submit" tone="primary" isDisabled={busy}>保存并确认现状</Button></ActionBar>
          </form>
        </DataGroup>
      </Section>

      <Section title="三项北极星" description="三项约束分别记录，不合并为分数。">
        {currentNorthStars.length > 0 ? (
          <div className="product-stack">
            {currentNorthStars.map((constraint) => (
              <DataGroup key={constraint.id} label={northStarLabels[constraint.kind]}>
                <dl className="product-facts">
                  <div><dt>观察事实</dt><dd>{constraint.observedFacts.join("；")}</dd></div>
                  <div><dt>用户底线</dt><dd>{constraint.userFloor}</dd></div>
                  <div><dt>受影响活动</dt><dd>{constraint.affectedActivityIds.join("；") || "未记录"}</dd></div>
                </dl>
              </DataGroup>
            ))}
          </div>
        ) : null}
        <DataGroup>
          <form className="product-form" onSubmit={saveNorthStars}>
            <FormGrid>
              {(Object.keys(northStarLabels) as NorthStarKind[]).map((kind) => {
                const current = currentNorthStars.find((item) => item.kind === kind);
                return (
                  <div className="product-field-pair" key={kind}>
                    <h3>{northStarLabels[kind]}</h3>
                    <Field name={`${kind}-facts`} label="观察事实" defaultValue={current?.observedFacts[0] ?? ""} isRequired />
                    <Field name={`${kind}-floor`} label="不可突破的底线" defaultValue={current?.userFloor ?? ""} isRequired />
                    <Field name={`${kind}-activities`} label="受影响活动 ID" description="一行一个工作单元、项目或实验 ID；没有受影响活动时留空。" defaultValue={current?.affectedActivityIds.join("\n") ?? ""} multiline />
                  </div>
                );
              })}
            </FormGrid>
            <ActionBar><Button type="submit" tone="primary" isDisabled={busy}>保存三项约束</Button></ActionBar>
          </form>
        </DataGroup>
      </Section>

      <Section title="当前主瓶颈" description="每轮只选一个主要限制，可附加一个不同的次级约束。">
        {state?.bottleneck ? <InlineNotice title={`主瓶颈：${bottleneckLabels[state.bottleneck.primary]}`} detail={state.bottleneck.selectionFacts.join("；")} /> : null}
        <DataGroup>
          <form className="product-form" onSubmit={saveBottleneck}>
            <FormGrid>
              <label className="product-select-field"><span>主瓶颈</span><select className="ns-input" name="primary" defaultValue={state?.bottleneck?.primary ?? "state"}>{Object.entries(bottleneckLabels).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>
              <label className="product-select-field"><span>次级约束（可选）</span><select className="ns-input" name="secondaryConstraint" defaultValue={state?.bottleneck?.secondaryConstraint ?? ""}><option value="">不设置</option>{Object.entries(bottleneckLabels).map(([key, label]) => <option key={key} value={key}>{label}</option>)}</select></label>
              <Field name="selectionFact" label="选择依据" defaultValue={state?.bottleneck?.selectionFacts[0] ?? ""} isRequired />
            </FormGrid>
            <ActionBar><Button type="submit" tone="primary" isDisabled={busy}>保存主瓶颈</Button></ActionBar>
          </form>
        </DataGroup>
      </Section>

      <WorkUnitPanel core={services.core} snapshotReady={state?.snapshot?.status === "complete"} onError={setError} onChanged={refresh} />
    </>
  );
}
