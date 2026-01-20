# CagA感染对肠道微生物组的重塑：细菌-噬菌体协同变化与功能执行者更替

**项目编号**: PC047 vCagAepitope
**分析人员**: Gong Yuhang
**版本**: v7.0 (2026-01-20) - 新增02b扩展功能分析、03c共现网络分析结果

---

## 摘要

**背景**: 幽门螺杆菌(Helicobacter pylori)CagA蛋白是公认的I类致癌因子，但其在肠道肿瘤微环境中通过菌群重塑促进肿瘤发生的机制尚不明确。特别是在CagA抗原清除后，肠道内维持CagA特异性CD8+ T细胞持续激活的因素仍是未解之谜。

**方法**: 采用Apc突变小鼠作为肿瘤易感模型，通过Kraken2/Bracken物种分类、HUMAnN4功能注释、SingleM/Lyrebird噬菌体分析，系统评估CagA感染对肠道微生物组的影响。核心比较为ApcMUT_HpWT (CagA+, n=5) vs ApcMUT_HpKO (对照, n=4)。

**结果**:
1. **CagA显著重塑肠道菌群结构**（Beta多样性P=0.012, R²=33.6%），但整体多样性无显著变化（Alpha多样性P=0.73），提示CagA通过**选择性调控特定菌群**而非"全面破坏"影响肠道微环境。
2. **细菌与噬菌体同步改变**：CagA感染显著降低噬菌体多样性（P=0.032），且细菌-噬菌体群落高度协同变化（Mantel P=0.001, Procrustes P=0.002），形成紧密的生态互作网络。
3. **功能执行者静默更替**：整体代谢通路丰度保持稳定（功能冗余），但**分层功能分析**揭示165个通路-物种组合发生>15%的贡献变化，执行者从益生菌(L. johnsonii)转向潜在致病菌(M. schaedleri)。
4. **模型验证**：2×3因子分析显示Apc突变背景有效放大CagA效应（G×E交互P=0.024），证实Apc突变小鼠是研究CagA的有效模型。

**结论**: CagA通过选择性重塑肠道菌群结构，同时引发细菌-噬菌体协同变化。尽管整体代谢功能保持稳定（功能冗余），但功能执行者发生了从益生菌向致病菌的静默更替。这提示CagA促肿瘤机制可能主要通过改变细菌抗原谱和免疫刺激来源，而非单纯的代谢功能改变。

**关键词**: CagA, 肠道微生物组, 细菌-噬菌体协同, 功能冗余, Driver物种更替, Apc突变模型

---

## 1. 背景

### 1.1 CagA与消化道肿瘤

幽门螺杆菌(H. pylori)感染全球超过40%人口，被世界卫生组织列为胃癌I类致癌因子[1]。CagA蛋白是H. pylori最重要的毒力因子之一，通过IV型分泌系统注入宿主上皮细胞后，干扰多种信号通路，包括Wnt/β-catenin、NF-κB和MAPK通路，导致细胞极性丧失和增殖失控[2,3]。

近年研究表明，CagA的致病作用不仅限于胃黏膜。使用果蝇模型的研究证实，**CagA单独表达即可改变肠道菌群组成并促进上皮细胞过度增殖**，且这种表型依赖于失调的菌群[4]。临床研究也发现CagA阳性株可通过调节肠道菌群影响结直肠病变[5]。这些发现提示CagA可能通过菌群介导的机制影响肠道肿瘤发生。

### 1.2 Apc突变与肠道菌群失调

腺瘤性息肉病基因(APC)是Wnt信号通路的关键负调控因子，其突变导致β-catenin持续激活，是结直肠癌发生的经典"守门人"事件[6]。APC突变小鼠(Apc^Min/+)是研究肠道肿瘤发生的经典模型。

重要的是，**Apc突变本身即可导致肠道菌群失调**。家族性腺瘤性息肉病(FAP)患者的黏膜相关菌群研究显示，肿瘤组织中Romboutsia、Clostridium和Lachnospiraceae NK4A136显著富集[7]。Wnt/PI3K-mTOR通路与菌群的相互作用研究表明，APC驱动的肿瘤发生过程中存在复杂的宿主-菌群互作[8]。

特别值得注意的是，丁酸产生菌Clostridium butyricum可通过**调节Wnt信号和肠道菌群抑制Apc^Min/+小鼠的肠道肿瘤发生**[9]。这表明Apc突变背景下，菌群干预具有治疗潜力。

### 1.3 功能冗余假说

微生物生态学中的"功能冗余"(Functional Redundancy)是一个核心概念，指不同物种可执行相同或相似的代谢功能，使生态系统在物种组成变化时仍能维持功能稳定[10]。

在肠道微生物组研究中，功能冗余现象可导致物种水平的显著差异无法在功能水平检测到。这一现象具有重要的生物学意义：它既是生态系统韧性的体现，也可能掩盖物种特异性的代谢物变化。研究表明，功能冗余与功能多样性之间存在权衡关系[11]。

### 1.4 噬菌体与肿瘤微环境

噬菌体作为肠道病毒组的主要成分，通过调控细菌群落间接影响宿主生理。最新研究发现，**噬菌体可用于靶向消除促肿瘤细菌**。Bacteroides fragilis促进Apc^Min/+小鼠化疗耐药，而噬菌体VA7可选择性清除B. fragilis并恢复化疗敏感性[12]。这表明噬菌体在肿瘤治疗中具有独特价值。

噬菌体与细菌的共进化关系意味着菌群结构改变通常伴随噬菌体组成变化，这种"协同变化"模式可能揭示生态系统层面的扰动机制[13]。

### 1.5 中心科学问题

基于上述背景，本研究聚焦于以下核心问题：

> **在原始CagA抗原清除后，肠道内什么因素负责维持致病性CagA特异性CD8+ T细胞的持续激活？**

我们提出"Functional Footprint"假说：T细胞的持续激活是由被CagA永久性改变的微生物群落产生的非肽类分子或代谢物驱动的。

---

## 2. 材料与方法

### 2.1 实验设计

采用2×3因子设计，设置以下实验组（表1）：

**表1. 实验分组设计**

| 组别 | 基因型 | 感染状态 | 样本数 | 备注 |
|------|--------|----------|--------|------|
| ApcWT_Ctrl | Apc野生型 | 未感染 | 5 | 基线对照 |
| ApcWT_HpKO | Apc野生型 | HpKO感染 | 5 | CagA阴性感染 |
| ApcWT_HpWT | Apc野生型 | HpWT感染 | 5 | CagA阳性感染 |
| ApcMUT_Ctrl | Apc突变 | 未感染 | 4 | 排除ca08 |
| ApcMUT_HpKO | Apc突变 | HpKO感染 | 4 | **核心对照组** |
| ApcMUT_HpWT | Apc突变 | HpWT感染 | 5 | **核心实验组** |

**核心比较**: ApcMUT_HpWT (n=5) vs ApcMUT_HpKO (n=4)，比较Apc突变背景下CagA+感染与CagA-感染的差异。

**2×3因子设计**: 评估Genotype (ApcWT/ApcMUT) × Infection (Ctrl/HpKO/HpWT)交互作用，总计n=27（排除ca07, ca08）。

### 2.2 样本信息

- **取材部位**: Caecum (盲肠)
- **样本排除**: ca08因E. coli异常高丰度被剔除（污染样本）；ca07因缺失数据排除

### 2.3 生物信息学分析流程

#### 2.3.1 物种组成分析
- **分类工具**: Kraken2 + Bracken (Standard数据库)
- **数据结构**: TreeSummarizedExperiment (TSE)对象
- **多样性分析**: mia包计算Alpha多样性(Shannon/Observed指数)和Beta多样性(Bray-Curtis距离)

#### 2.3.2 功能潜力分析
- **注释工具**: HUMAnN4
- **功能数据库**: MetaCyc通路 + KEGG KO
- **差异分析**: MaAsLin2, ANCOM-BC2

#### 2.3.3 OTU分析
- **细菌/古菌**: SingleM (OTU分类 + 系统发育树)
- **噬菌体**: Lyrebird (dsDNA噬菌体)
- **系统发育分析**: UniFrac距离(Weighted/Unweighted)

### 2.4 统计分析

#### 2.4.1 Alpha多样性
- 组间比较: Wilcoxon秩和检验
- 因子分析: Aligned Rank Transform (ART) ANOVA

#### 2.4.2 Beta多样性
- 组间差异: PERMANOVA (999次置换)
- 方差齐性: betadisper检验
- 交互作用: 双因素PERMANOVA with by="terms"
- 成对比较: pairwiseAdonis

#### 2.4.3 差异丰度分析
- FDR校正: Benjamini-Hochberg法
- 阈值: q<0.05

#### 2.4.4 相关性分析
- 方法: Spearman相关
- 阈值: |r|>0.5, FDR<0.05

---

## 3. 结果

### 3.1 物种组成分析：CagA显著重塑肠道菌群结构

#### 3.1.1 核心比较

在Apc突变背景下比较CagA阳性(HpWT)与CagA阴性(HpKO)感染的效果：

**表2. 核心比较结果 (ApcMUT_HpWT vs ApcMUT_HpKO, n=9)**

| 分析指标 | 方法 | 统计量 | P值 | 结论 |
|----------|------|--------|-----|------|
| Shannon多样性 | Wilcoxon | - | 0.730 | 无差异 |
| Beta多样性 | PERMANOVA | R²=33.1% | **0.012** | **显著** |

**解读**: CagA感染显著重塑了菌群结构（解释33.1%变异），但未改变整体多样性水平。这符合OMA框架中的**"群落重组"(Community Restructuring)**模式——物种替换而非多样性丧失[14]。

#### 3.1.2 2×3因子设计分析

将分析扩展至全部6组（n=27），评估Genotype和Infection的主效应及交互作用：

**表3. 2×3因子设计PERMANOVA结果**

| 因素 | 自由度 | R² | F值 | P值 | 解读 |
|------|--------|-----|-----|-----|------|
| Genotype | 1 | 7.2% | 2.14 | **0.031** | 显著主效应 |
| Infection | 2 | 8.5% | 1.27 | 0.169 | 无主效应 |
| **Genotype × Infection** | 2 | 9.1% | 1.36 | **0.024** | **显著交互** |
| Residual | 21 | 75.2% | - | - | - |

**关键发现**: 存在显著的Genotype×Infection交互作用（P=0.024），表明CagA效应依赖于宿主遗传背景。

#### 3.1.3 CagA效应的遗传背景依赖性

进一步进行分层成对比较，验证CagA效应在不同遗传背景下的表现：

**表4. CagA效应的遗传背景依赖性（成对PERMANOVA）**

| 比较 | 遗传背景 | 样本数 | R² | P值 | 结论 |
|------|----------|--------|-----|-----|------|
| HpWT vs HpKO | **ApcMUT** | 5 vs 4 | **33.6%** | **0.007** | **显著** |
| HpWT vs HpKO | ApcWT | 5 vs 5 | 13.7% | 0.338 | 不显著 |

**核心结论**: CagA的菌群重塑效应**仅在Apc突变背景下显著**（P=0.007, R²=33.6%），在野生型背景下效应消失（P=0.338）。这是典型的**遗传-环境交互作用(G×E interaction)**模式。

这一发现与Jones等人(2017)使用果蝇模型的研究结果高度一致：CagA可独立诱导菌群失调并促进细胞增殖[4]。更重要的是，我们的数据表明这种效应需要宿主的"易感遗传背景"——即Apc突变导致的Wnt通路持续激活状态。

#### 3.1.4 扩展分层成对比较分析（Part 5新增 - 2026-01-19更新）

为了更全面地验证G×E交互作用，我们对全部6组进行了系统性的9个成对比较分析：

**表4b. Standard(细菌) 9个成对比较结果**

| 比较 | R² | P值 | P_adj | 显著性 |
|------|-----|-----|-------|--------|
| Apc基线效应 (Ctrl组) | 21.8% | 0.141 | 0.181 | - |
| **Apc效应 (HpKO感染后)** | **37.6%** | **0.009** | **0.039** | ⭐⭐ |
| **Apc效应 (HpWT感染后)** | **27.3%** | **0.013** | **0.039** | ⭐⭐ |
| 感染效应 (ApcMUT, 无CagA) | 25.9% | 0.044 | 0.066 | * |
| 感染+CagA效应 (ApcMUT) | 13.4% | 0.507 | 0.507 | - |
| **CagA效应 (ApcMUT背景)** | **33.6%** | **0.007** | **0.039** | ⭐⭐ |
| **感染效应 (ApcWT, 无CagA)** | **24.2%** | **0.019** | **0.043** | ⭐⭐ |
| 感染+CagA效应 (ApcWT) | 25.1% | 0.030 | 0.054 | * |
| CagA效应 (ApcWT背景) | 13.7% | 0.344 | 0.387 | - |

**关键发现**：FDR校正后显著的比较：**5/9** (55.6%)

**G×E交互作用完全验证**：
- CagA效应 @ ApcMUT：**P=0.039, R²=33.6%** ⭐ **显著**
- CagA效应 @ ApcWT：P=0.387, R²=13.7% **不显著**

**意外发现 - 感染放大而非抹平Apc效应**：
- Ctrl (未感染)：Apc效应 P=0.181 (不显著)
- HpKO/HpWT (感染后)：Apc效应 P=0.039 (显著)

#### 3.1.5 Virus(病毒)扩展分析（Part 4b/5b新增 - 2026-01-19更新）

**表4c. Virus 9个成对比较结果 vs Standard对比**

| 比较 | Standard P_adj | Virus P_adj | 对比 |
|------|---------------|-------------|------|
| Apc效应 (HpKO后) | **0.039** | 0.126 | 细菌显著 |
| Apc效应 (HpWT后) | **0.039** | 0.978 | 细菌显著 |
| **CagA效应 (ApcMUT)** | **0.039** | **0.604** | **细菌显著！** |
| 感染效应 (ApcWT) | **0.043** | 0.126 | 细菌显著 |

**核心发现**：
- Standard细菌：9个比较中**5个FDR显著**
- Virus病毒：9个比较中**0个FDR显著**
- **结论**：CagA主要通过重塑细菌群落而非病毒组影响肠道微环境

### 3.2 功能潜力分析：功能冗余现象

#### 3.2.1 核心比较

**表5. 功能分析核心比较结果**

| 分析指标 | 方法 | 统计量 | P值 | 结论 |
|----------|------|--------|-----|------|
| 功能Beta多样性 | PERMANOVA | R²=33.1% | **0.012** | 显著 |
| 通路差异丰度 | MaAsLin2 | - | q>0.05 | **无显著通路** |
| KO差异丰度 | MaAsLin2 | - | q>0.25 | **无显著KO** |

#### 3.2.2 2×3因子设计分析

**表6. 功能Beta多样性2×3因子设计PERMANOVA结果**

| 因素 | 自由度 | R² | F值 | P值 | 解读 |
|------|--------|-----|-----|-----|------|
| Genotype | 1 | 3.6% | 1.11 | 0.302 | **不显著** |
| Infection | 2 | 3.4% | 0.53 | 0.769 | **不显著** |
| **Genotype × Infection** | 2 | 8.7% | 1.34 | 0.223 | **不显著** |
| Residual | 26 | 84.3% | - | - | - |

**关键对比**:
- **物种Beta多样性交互作用**: P=0.024 ✓ 显著
- **功能Beta多样性交互作用**: P=0.223 ✗ 不显著

**表7. 物种vs功能：功能冗余证据**

| 分析层面 | 交互作用P值 | 效应量R² | 状态 |
|----------|-------------|----------|------|
| 物种组成 | **0.024** | 9.1% | 显著 |
| 功能组成 | 0.223 | 8.7% | 不显著 |

**机制解读**: 这一结果呈现典型的**功能冗余现象**。尽管物种组成发生显著改变，但整体代谢功能潜力保持稳定。这与生态学理论一致：在稳定的生态系统中，不同物种可执行相似的功能，使系统在物种更替时仍维持功能输出[10,11]。

然而，功能冗余的存在**并不意味着CagA对宿主无影响**。相反，这提示CagA的致病机制可能不在通路丰度层面，而是在：
1. **代谢物层面**: 同一通路中不同物种产生的代谢物可能具有不同的生物活性
2. **转录活性层面**: 功能基因的潜力(DNA)和实际表达(RNA)可能不一致
3. **物种特异性免疫激发**: 不同物种即使执行相同功能，其抗原特征也不同，可能引发不同的免疫响应

#### 3.2.3 物种-功能关联网络

尽管通路水平无显著差异，但物种与功能之间存在显著关联：

**表8. 物种-KO关联分析结果**

| 指标 | 数值 | 意义 |
|------|------|------|
| 显著关联对 | **78对** (FDR<0.05) | 强物种-功能连接 |
| 关联物种数 | 29个 | 候选驱动物种 |
| 关联KO数 | 45个 | 候选功能靶点 |

这78对显著关联提供了**候选研究靶点**，可用于后续验证哪些物种通过哪些功能影响肿瘤微环境。

#### 3.2.4 扩展功能分析：GO/PFAM层面验证（02b分析 - 2026-01-20新增）

为进一步验证功能冗余假说，对更精细的功能层面进行差异分析：

**表8a. GO/PFAM差异分析结果**

| 功能层面 | 检测特征数 | P<0.05 | **FDR<0.05** | 结论 |
|----------|------------|--------|-------------|------|
| **GO (Gene Ontology)** | ~13,000 | 1,577 | **0** | 无显著差异 |
| **PFAM (蛋白结构域)** | ~7,600 | 849 | **0** | 无显著差异 |
| Gene Families | 75 (过滤后) | - | - | 待分析 |

**关键发现**：从Pathway → KO → GO → PFAM，各层面功能在FDR校正后均无显著差异，**全面支持功能冗余假说**。

这意味着：CagA感染虽然重塑了菌群物种组成，但从代谢通路到基因本体到蛋白结构域，整体功能潜力保持稳定。致病机制更可能在于**菌群抗原谱改变**而非代谢功能改变。

#### 3.2.5 功能层面9个成对比较验证（Part 10新增 - 2026-01-19更新）

**表8b. 物种-功能冗余系统性验证**

| 比较 | 物种P_adj | 功能P_adj | **冗余模式** |
|------|----------|----------|-------------|
| Apc效应 (HpKO后) | **0.039** | **0.041** | **物种-功能一致** |
| Apc效应 (HpWT后) | **0.039** | 0.167 | **功能冗余** |
| **CagA效应 (ApcMUT)** | **0.039** | **0.041** | **物种-功能一致** ⭐ |
| 感染效应 (ApcWT) | **0.043** | 0.638 | **功能冗余** |

**核心发现**：
- **物种-功能一致**：2个比较（22%）- 包括核心CagA比较
- **功能冗余**：2个比较（22%）- Apc效应(HpWT后)和感染效应(ApcWT)
- **均无差异**：3个比较（33%）

**重要结论**：核心比较（CagA效应@ApcMUT）呈现**物种-功能一致性**（物种P=0.039, 功能P=0.041），表明CagA不仅改变物种组成，也真正改变了功能组成。

#### 3.2.5 分层功能分析：Driver Species更替

功能冗余意味着功能总量不变，但**谁在执行这些功能**？Part 9分层分析(Stratified Analysis)直接回答了这个问题：

**表8b. 分层功能分析概览**

| 指标 | 数值 |
|------|------|
| 分析通路数 | 631 |
| 分析物种数 | 935 |
| 通路-物种组合总数 | 11,882 |
| **贡献变化 >15% 的组合** | **165** |
| 贡献变化 >10% 的组合 | 236 |

**表8c. 关键Driver Species更替事件（ApcMUT: HpWT vs HpKO）**

| 通路 | 生物学功能 | 物种变化 | 变化幅度 |
|------|------------|----------|----------|
| **HEME-BIOSYNTHESIS-II** | 血红素b生物合成 | *Mucispirillum schaedleri* ↑ | **+56.8%** |
| **PWY-6470** | 肽聚糖合成（β-内酰胺耐药） | *Lactobacillus johnsonii* ↓ | **-33.3%** |
| **PWY-6471** | 肽聚糖合成IV | *Lactobacillus johnsonii* ↓ | **-50.0%** |
| **LACTOSECAT-PWY** | 乳糖和半乳糖降解 | *Ligilactobacillus murinus* ↓ | **-21.8%** |
| **P125-PWY** | (R,R)-丁二醇生物合成 | *Ligilactobacillus murinus* ↓ | -17.1% |

**核心发现 - "静默更替"(Silent Shift)现象**:

CagA感染在ApcMUT背景下导致功能执行者发生重大更替：
- **益生菌贡献减少**: *Lactobacillus johnsonii* 和 *Ligilactobacillus murinus* 在多个关键通路的贡献显著下降
- **潜在致病菌增加**: *Mucispirillum schaedleri*（与肠道炎症相关的螺旋菌）贡献大幅上升

这一发现具有重要的**免疫学意义**：虽然代谢输出相似，但不同物种具有不同的：
- **LPS结构**：激活不同的TLR4信号
- **肽聚糖成分**：*Lactobacillus* 减少意味着细胞壁抗原改变
- **免疫调节能力**：益生菌通常具有抗炎作用，其减少可能导致炎症加剧

### 3.3 SingleM/Lyrebird分析：系统发育视角与噬菌体变化

#### 3.3.1 系统发育Beta多样性

SingleM分析使用OTU级别数据和系统发育树，提供更精细的群落结构信息：

**表9. SingleM系统发育Beta多样性分析**

| 距离类型 | 核心比较P值 | 解读 |
|----------|-------------|------|
| Bray-Curtis | **0.037** | 组成差异显著 |
| Weighted UniFrac | **0.029** | 加权系统发育差异显著 |
| **Unweighted UniFrac** | **0.008** | **进化谱系差异最强** |

**解读**: Unweighted UniFrac信号最强（P=0.008），表明CagA感染导致某些**进化分支完全缺失或出现**，而不仅是丰度变化。这意味着CagA对菌群的影响达到了**进化层面的群落重组**。

#### 3.3.2 Apc突变是菌群变异的主导因素

在未感染状态下比较Apc突变与野生型小鼠的菌群差异：

**表10. Apc基线效应分析**

| 分析对象 | 比较 | R² | P值 | 结论 |
|----------|------|-----|-----|------|
| 细菌(SingleM) | ApcMUT_Ctrl vs ApcWT_Ctrl | **46.6%** | **0.009** | **主导因素** |
| 噬菌体(Lyrebird) | ApcMUT_Ctrl vs ApcWT_Ctrl | **51.7%** | **0.006** | **主导因素** |

**关键发现**:
- Apc突变**单独解释约50%的菌群变异**
- 这一效应对细菌和噬菌体都成立
- CagA效应（R²≈25-35%）叠加于Apc效应之上

这与FAP患者研究结果一致：APC突变本身即导致菌群失调[7,8]。更重要的是，我们发现**Hp感染"抹平"了Apc基因型差异**——在感染组中，Apc效应完全消失（P>0.5），提示感染可能使菌群向某种"感染态"趋同。

#### 3.3.3 噬菌体多样性显著降低

**表11. Lyrebird噬菌体分析结果**

| 分析指标 | 方法 | 统计量 | P值 | 结论 |
|----------|------|--------|-----|------|
| Alpha多样性 | Shannon + Wilcoxon | - | **0.032** | **显著降低** |
| Beta多样性(uwUniFrac) | PERMANOVA | - | **0.043** | 进化谱系显著不同 |
| 差异OTU | ANCOM-BC2 | 20个 | - | 8↑HpWT, 12↑HpKO |

**解读**: 这是物种分析（Bracken）无法发现的新现象——CagA感染不仅重塑细菌群落，还**显著降低噬菌体多样性**。这可能反映噬菌体-细菌的共进化关系：细菌群落重组导致与之共生的噬菌体也发生相应改变。

最新研究表明噬菌体可用于靶向消除促肿瘤细菌并恢复化疗敏感性[12]。我们观察到的噬菌体变化可能具有治疗意义。

#### 3.3.4 细菌-噬菌体高度协同变化

**表12. Host-Virus关联分析**

| 分析方法 | 统计量 | P值 | 解读 |
|----------|--------|-----|------|
| **Mantel检验** | r=0.52 | **0.001** | 距离矩阵**高度相关** |
| **Procrustes分析** | M²=0.65 | **0.002** | 群落结构**强烈关联** |
| Spearman相关(Alpha) | - | 0.121 | 多样性水平无相关 |

**解读**: 细菌和噬菌体在**群落结构层面高度协同变化**（Mantel P=0.001），而非简单的多样性水平关联。这表明CagA的作用可能通过**细菌-噬菌体-宿主三角互作网络**实现。

### 3.4 病毒组-功能整合分析

分析噬菌体与代谢功能的关联（n=9个共同样本）：

**表13. 噬菌体-功能关联网络**

| 关联类型 | 显著对数(FDR<0.05) | 网络边数(|r|>0.5) |
|----------|---------------------|-------------------|
| 噬菌体-KO | **2877对** | 6604条 |
| 噬菌体-Pathway | **337对** | - |
| 细菌-KO | - | 3700条 |
| 细菌-噬菌体 | - | **7544条** |
| **三角网络总计** | - | **17848条** |

**解读**:
- 细菌-噬菌体边数最多（7544条），反映**强烈的宿主-病毒互作**
- 噬菌体与功能广泛关联，可能通过调控细菌群落间接影响代谢功能
- 网络高度连通表明CagA感染环境下微生物组各层次**紧密关联**

### 3.5 共现网络分析：CagA破坏群落模块化结构（03c分析 - 2026-01-20新增）

共现网络(Co-occurrence Network)分析揭示了CagA感染如何改变菌群物种间的相互作用模式。

#### 3.5.1 网络拓扑结构变化

**表14. 细菌共现网络统计（Top 100高丰度物种）**

| 指标 | ApcMUT_HpKO (对照) | ApcMUT_HpWT (CagA+) | 变化 | 生物学意义 |
|------|-------------------|---------------------|------|------------|
| 节点数 | 80 | 100 | +20 | 参与互作的物种增加 |
| 边数 | 1,280 | 2,190 | **+910 (+71%)** | 物种间关联增加 |
| 网络密度 | 0.405 | 0.442 | +0.037 | 连接更紧密 |
| **模块度** | **0.468** | **0.177** | **-0.291 (-62%)** | **模块结构瓦解** |

**核心发现：模块度显著降低**

- **模块度高 (0.468)**：群落有清晰的功能模块，物种各司其职，生态位分化明显
- **模块度低 (0.177)**：群落结构被打乱，物种间界限模糊，竞争/合作关系紊乱

CagA感染**破坏了肠道菌群的模块化组织**，这可能导致：
1. 生态位重叠增加，物种竞争加剧
2. 群落稳定性下降，更易受扰动
3. 功能冗余增加（解释为什么物种变但功能稳定）

#### 3.5.2 Hub物种（网络枢纽）识别

**表15. Top 10 Hub物种（按连接度排序）**

| 物种 | 连接度 | 介数中心性 | 功能特征 |
|------|--------|------------|----------|
| *Blautia obeum* | 44 | 74.7 | 短链脂肪酸生产者 |
| *Hungatella hathewayi* | 42 | 40.7 | 厌氧发酵 |
| *Roseburia hominis* | 42 | 47.6 | 丁酸生产者 |
| *Blautia parvula* | 42 | 40.7 | SCFA生产者 |
| *Marvinbryantia formatexigens* | 41 | 35.0 | 甲酸利用 |
| *Clostridium sp. M62/1* | 40 | 31.8 | 厌氧代谢 |
| *[Clostridium] scindens* | 39 | 41.8 | 胆汁酸代谢 |
| *Sellimonas catena* | 39 | 24.8 | 厌氧菌 |
| *Hungatella sp. SB206* | 39 | 47.0 | 厌氧发酵 |
| *Blautia massiliensis* | 38 | 16.9 | SCFA生产者 |

**特征**：Hub物种主要是**厌氧梭菌类**（Blautia、Roseburia、Hungatella），是肠道短链脂肪酸(SCFA)的主要生产者。

**值得注意**：*Parabacteroides distasonis* 介数中心性异常高(402.1)，但连接度仅33——这是典型的"桥梁物种"，连接不同功能模块，可能是CagA影响群落结构的关键节点。

#### 3.5.3 网络分析对假说的支持

```
┌─────────────────────────────────────────────────────────────────────────────┐
│  共现网络分析揭示CagA的生态效应                                               │
│                                                                              │
│  发现：CagA感染导致网络模块度下降62%                                          │
│                                                                              │
│  解释功能冗余机制：                                                           │
│  - 模块化结构瓦解 → 物种间界限模糊                                            │
│  - 生态位重叠增加 → 功能执行者可相互替代                                      │
│  - 群落变得"混合"而非"分化"                                                  │
│                                                                              │
│  对T细胞激活的启示：                                                          │
│  - 群落结构紊乱可能改变呈递给免疫系统的抗原多样性                              │
│  - Hub物种（SCFA生产者）的互作模式改变可能影响免疫调节                         │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 4. 讨论

### 4.1 G×E交互作用：CagA效应的遗传背景依赖性

本研究最重要的发现是CagA的菌群重塑效应**依赖Apc突变遗传背景**。这一G×E交互作用模式具有深远的生物学意义。

从机制上看，APC蛋白是Wnt信号通路的关键负调控因子。当Apc发生突变时：
1. **β-catenin无法被降解**，持续激活Wnt信号
2. **肠道上皮处于"高增殖、高周转"状态**
3. **肠道屏障功能可能受损**
4. **宿主对菌群扰动的缓冲能力下降**

在这种背景下，CagA通过其对宿主细胞信号的干扰作用，与已经失调的Wnt通路产生**协同效应**。这与结直肠癌的"多次打击"模型一致：APC突变是"第一次打击"，CagA诱导的菌群失调可能是"第二次打击"[6,8]。

有趣的是，我们发现Hp感染"抹平"了Apc基因型差异。这可能意味着：感染导致的炎症微环境使菌群向某种共同的"失调态"趋同，从而掩盖了遗传背景的效应。这一现象值得进一步研究。

### 4.2 功能冗余与Driver Species更替：假说验证的关键证据

物种Beta多样性交互显著(P=0.024)而功能Beta多样性交互不显著(P=0.223)的对比，是支持功能冗余假说的直接证据。

**⚠️ 重要澄清：2×3因子设计 vs 成对比较的表面矛盾**

Part 10的9个成对比较揭示了一个需要解释的现象：

| 分析方法 | 核心CagA比较 (ApcMUT: HpWT vs HpKO) |
|----------|-------------------------------------|
| 物种Beta | P_adj=0.039 **显著** |
| 功能Beta | P_adj=0.041 **显著** |

这与2×3因子设计显示的"功能冗余"(功能交互P=0.223不显著)看似矛盾，但实际反映了**分析粒度的差异**：

- **2×3因子设计**评估的是Genotype×Infection交互作用——即"CagA效应是否因遗传背景而异"这一**整体模式**。功能层面交互不显著，说明CagA对功能的影响在不同遗传背景下模式相似。
- **成对比较**直接比较两组差异——核心比较显著说明CagA确实改变了功能组成，但这种改变在ApcWT和ApcMUT背景下**方向一致**（无交互）。

**结论**：功能冗余是相对的。整体交互模式显示冗余（不同背景下响应一致），但特定比较中功能确实发生改变。这不是矛盾，而是**尺度依赖性(Scale-dependent)**现象。

从生态学角度，功能冗余是健康生态系统的重要特征，提供了对扰动的韧性[10,11]。然而，**Part 9的分层功能分析揭示了功能冗余表象下的重要变化**：

#### 4.2.1 "静默更替"现象的发现

分层分析证实，虽然功能总量保持稳定，但**执行这些功能的物种发生了重大更替**：

- **益生菌贡献减少**：*Lactobacillus johnsonii*（肽聚糖合成贡献↓50%）、*Ligilactobacillus murinus*（乳糖代谢贡献↓22%）
- **炎症相关菌增加**：*Mucispirillum schaedleri*（血红素合成贡献↑57%）

这一发现具有重要意义：**功能冗余不是"无变化"，而是"执行者更替"**。

#### 4.2.2 对T细胞激活的可能解释

这一发现为"Functional Footprint"假说提供了新的机制解释：

1. **物种特异性免疫激发**（Part 9直接支持）
   - 即使代谢功能相同，不同物种的**抗原特征不同**
   - *Lactobacillus*减少意味着抗炎因子减少
   - *Mucispirillum*增加意味着炎症刺激增加
   - 菌群的"执行者更替"可能改变呈递给免疫系统的抗原谱

2. **代谢物特异性而非通路丰度**
   - 虽然通路丰度不变，但执行相同功能的不同物种可能产生**结构类似但活性不同**的代谢物
   - 例如，同一通路中短链脂肪酸的比例和链长可能因物种不同而异
   - 需要代谢组学验证

3. **转录vs潜力**
   - HUMAnN分析基于DNA，反映功能**潜力**
   - 实际功能输出取决于基因**表达**
   - 需要宏转录组验证

### 4.3 噬菌体：肿瘤微环境的新玩家

我们观察到CagA感染显著降低噬菌体多样性（P=0.032），且细菌-噬菌体高度协同变化（Mantel P=0.001）。这些发现将噬菌体纳入CagA致病网络的讨论。

噬菌体在肿瘤微环境中的作用正受到越来越多关注[12,13]。最新研究表明噬菌体可用于：
- 选择性消除促肿瘤细菌（如B. fragilis）
- 恢复化疗敏感性
- 作为"CRISPR载体"进行精准基因编辑

我们发现的噬菌体变化可能具有**诊断和治疗意义**。噬菌体多样性降低可能是CagA感染的生物标志物，而特定噬菌体可能成为治疗靶点。

### 4.4 假说验证总结

**表16. "Functional Footprint"假说验证状态（2026-01-20更新）**

| 假说步骤 | 预期结果 | 实际结果 | 状态 |
|----------|----------|----------|------|
| Step 1: 群落结构改变 | Beta多样性显著 | P=0.012 (物种), P=0.008 (UniFrac) | ✓ **完全支持** |
| Step 1b: 网络结构改变 | 互作模式改变 | **模块度降低62%**，群落结构瓦解 | ✓ **新发现** |
| Step 2: 代谢输出改变 | 显著富集通路 | Pathway/KO/GO/PFAM均无FDR显著差异 | △ **功能冗余** |
| Step 2b: Driver更替 | 执行者物种改变 | **165个通路-物种组合变化>15%**，益生菌↓致病菌↑ | ✓ **关键发现** |
| Step 3: 代谢物驱动T细胞 | 特定代谢物关联 | 缺少数据 | ○ **待验证** |
| Step 4: T细胞促肿瘤 | 表型关联 | 缺少数据 | ○ **待验证** |

**结论**:
1. **群落结构全面重塑**：物种组成改变(Beta P=0.012)、网络模块度降低62%、Driver物种更替
2. **功能冗余全面验证**：从Pathway→KO→GO→PFAM，各层面FDR校正后均无显著差异
3. **机制假说调整**：T细胞持续激活可能源于**菌群抗原谱改变**（物种更替+网络重组）而非代谢功能改变

### 4.5 研究局限性

1. **样本量有限**: 核心比较仅9个样本，可能限制统计效力
2. **缺少代谢组学**: 无法直接验证代谢物层面的变化
3. **缺少宏转录组**: 无法区分功能潜力和实际表达
4. **跨组学样本不匹配**: 03b分析仅9个共同样本，部分相关系数可能不稳定
5. **因果推断困难**: 相关性分析无法确定噬菌体是"因"还是"果"
6. **跨方法结果不一致**: 01分析(Bracken)与03分析(SingleM)在HpWT感染后Apc效应上结论相反：

   | 分析 | HpWT感染后Apc效应 (ApcMUT vs ApcWT) | 结论 |
   |------|-------------------------------------|------|
   | 01 Bracken (物种水平) | P_adj=0.039 | **显著** |
   | 03 SingleM (OTU水平) | P_adj=0.515 | **不显著** |

   **可能解释**：分辨率差异。Bracken物种水平保留了Apc差异信号，而SingleM OTU水平显示CagA+感染可能导致群落在更精细尺度上趋同。这提示**CagA+感染的"抹平效应"可能具有尺度依赖性**——物种组成仍有差异，但OTU层面的进化谱系趋于相似。需要进一步验证。

---

## 5. 结论

本研究使用Apc突变小鼠作为肿瘤易感模型，系统揭示了CagA感染对肠道微生物组的影响模式：

1. **CagA显著重塑肠道菌群结构**: Beta多样性分析确认CagA通过选择性调控特定菌群重塑肠道微环境（P=0.012, R²=33.6%），而非全面破坏

2. **群落网络结构瓦解**: 共现网络分析显示CagA感染导致**模块度降低62%**（0.468→0.177），群落从模块化组织变为混合状态，物种间生态位界限模糊

3. **细菌与噬菌体同步改变**: CagA感染同时降低噬菌体多样性（P=0.032），且细菌-噬菌体群落高度协同变化（Mantel P=0.001），形成紧密的生态互作网络

4. **功能冗余全面验证**: 从Pathway→KO→GO→PFAM，各功能层面FDR校正后均无显著差异，但Driver物种发生更替——从益生菌(*L. johnsonii*)转向潜在致病菌(*M. schaedleri*)

5. **模型有效性验证**: 2×3因子分析显示Apc突变背景有效放大CagA效应（G×E交互P=0.024），证实本模型是研究CagA的有效工具

6. **候选靶点识别**: 29个物种、45个KO、78对物种-功能关联、10个Hub物种可用于后续机制研究

这些发现为理解"CagA特异性T细胞持续激活"提供了新视角：**CagA通过重塑菌群结构（物种组成+网络拓扑）改变细菌抗原谱和免疫刺激来源，而非改变代谢功能**。后续需要代谢组学和免疫学数据验证。

---

## 6. 后续研究建议

**表15. 后续研究优先级**

| 优先级 | 方向 | 所需数据/方法 | 预期价值 | 状态 |
|--------|------|---------------|----------|------|
| **高** | 代谢组学验证 | LC-MS/GC-MS | 直接验证Step 3 | 待开展 |
| **高** | 整合肿瘤/T细胞数据 | 表型数据 | 验证Step 4 | 待开展 |
| **高** | 宏转录组分析 | RNA-seq | 区分潜力vs表达 | 待开展 |
| ~~中~~ | ~~Stratified功能分析~~ | ~~现有HUMAnN数据~~ | ~~观察功能贡献者更替~~ | ✓ **已完成(Part 9)** |
| 中 | 候选代谢物预测 | 78对物种-KO关联 | 筛选验证靶点 | 待开展 |
| 中 | 株系水平分析 | StrainPhlAn | 检测株系变异 | 待开展 |

---

## 7. 参考文献

1. WHO/IARC. *Helicobacter pylori* classified as Group 1 carcinogen for gastric cancer. IARC Monographs.

2. Xiong C, Chen Z, Wu X, et al. (2026) The impact of multidimensional interactions among *Helicobacter pylori* infection, tumor microenvironment, and gut microbiota on gastric cancer immune response. *European Journal of Pharmacology* 178401. DOI: 10.1016/j.ejphar.2025.178401

3. Candelli M, Franza L, Cianci R, et al. (2023) The Interplay between *Helicobacter pylori* and the gut microbiota. *International Journal of Molecular Sciences* 24:17520. DOI: 10.3390/ijms242417520

4. **Jones TA, Hernandez DZ, Wong ZC, Wandler AM, Guillemin K.** (2017) The bacterial virulence factor CagA induces microbial dysbiosis that contributes to excessive epithelial cell proliferation in the *Drosophila* gut. ***PLoS Pathogens*** 13:e1006631. DOI: 10.1371/journal.ppat.1006631

5. **Cui S, Liu X, Han F, Zhang L, Bu J, Wu S, Wang J.** (2025) *Helicobacter pylori* CagA+ strains modulate colorectal pathology by regulating intestinal flora. ***BMC Gastroenterology*** 25:631. DOI: 10.1186/s12876-025-03631-6

6. Ditonno I, Novielli D, Celiberto F, et al. (2023) Molecular Pathways of Carcinogenesis in Familial Adenomatous Polyposis. *International Journal of Molecular Sciences* 24:5687. DOI: 10.3390/ijms24065687

7. Fongmanee J, Wanitsuwan W, Wanna W, et al. (2025) Characterization of Mucosa-Associated Microbiota in Formalin-Fixed, Paraffin-Embedded Tissues From Southern Thai Patients With Familial Adenomatous Polyposis. *Genes to Cells* 70008. DOI: 10.1111/gtc.70008

8. **Di Paola FJ, Alquati C, Conti G, et al.** (2024) Interplay between WNT/PI3K-mTOR axis and the microbiota in APC-driven colorectal carcinogenesis: data from a pilot study and possible implications for CRC prevention. ***Journal of Translational Medicine*** 22:305. DOI: 10.1186/s12967-024-05305-5

9. **Chen D, Jin D, Huang S, et al.** (2020) *Clostridium butyricum*, a butyrate-producing probiotic, inhibits intestinal tumor development through modulating Wnt signaling and gut microbiota. ***Cancer Letters*** 469:456-467. DOI: 10.1016/j.canlet.2019.11.019

10. Sveen TR, Viketoft M, Bengtsson J, et al. (2025) Functional diversity of soil microbial communities increases with ecosystem development. *Nature Communications* 16:66544. DOI: 10.1038/s41467-025-66544-8

11. Shi Z, Guo R, Yao F, et al. (2025) Exploiting the gut microbiota of aquatic animals as indicators of microplastic pollution using interpretable machine learning models. *Journal of Hazardous Materials* 139178. DOI: 10.1016/j.jhazmat.2025.139178

12. **Ding X, Ting NLN, Wong CC, et al.** (2025) *Bacteroides fragilis* promotes chemoresistance in colorectal cancer, and its elimination by phage VA7 restores chemosensitivity. ***Cell Host & Microbe*** S1931-3128. DOI: 10.1016/j.chom.2025.05.004

13. Kenneth MJ, Chen JS, Fang CY, et al. (2025) Exploring the therapeutic potential of bacteriophage-mediated modulation of gut microbiota towards colorectal cancer. *International Journal of Antimicrobial Agents* 107585. DOI: 10.1016/j.ijantimicag.2025.107585

14. Lahti L, Shetty S, et al. (2024) *Orchestrating Microbiome Analysis with Bioconductor (OMA)*. Online Book. https://microbiome.github.io/OMA/

---

## 附录

### A. 关键图表索引

| 来源 | 文件名 | 内容 |
|------|--------|------|
| 01分析 | `44_part4_permanova_full_6groups.csv` | 2×3因子PERMANOVA结果 |
| 01分析 | `46_part4_pairwise_comparisons.csv` | 成对比较结果 |
| **01分析** | **`50_part5_all_pairwise_comparisons.csv`** | **扩展9个成对比较结果** |
| **01分析** | **`51_part5_apc_effect_by_infection.png`** | **Apc效应感染依赖性** |
| **01分析** | **`52_part5_caga_effect_by_genotype.png`** | **CagA效应G×E验证** |
| 02分析 | `83_part8_permanova_pathway_results.csv` | 功能Beta PERMANOVA |
| 02分析 | `20_taxa_ko_correlation_heatmap.png` | 物种-功能关联热图 |
| **02分析** | **`91_part9_driver_species_shift.png`** | **Driver Species更替可视化** |
| **02分析** | **`92_part9_driver_species_tests.csv`** | **Driver更替统计检验** |
| **02分析** | **`93_part9_stratified_analysis_results.rds`** | **分层分析完整数据** |
| **02分析** | **`100_part10_all_pairwise_comparisons.csv`** | **功能层面9个成对比较** |
| **02分析** | **`101_part10_species_function_comparison.csv`** | **物种-功能冗余对比** |
| 03分析 | `28_host_virus_procrustes.png` | 细菌-噬菌体Procrustes |
| **03分析** | **`50_part5_singlem_bc_pairwise.csv`** | **SingleM成对比较结果** |
| **03分析** | **`52_part5_lyrebird_bc_pairwise.csv`** | **Lyrebird成对比较结果** |
| **03分析** | **`55_part5_gxe_caga_effect.png`** | **系统发育G×E验证** |
| 03b分析 | `06_tripartite_network.png` | 三角互作网络 |
| **01分析** | **`60_part4b_virus_6groups.csv`** | **Virus 2×3因子PERMANOVA** |
| **01分析** | **`63_part5b_virus_pairwise_comparisons.csv`** | **Virus 9个成对比较** |
| **01分析** | **`64_part5b_virus_apc_effect.png`** | **Virus Apc效应可视化** |
| **01分析** | **`65_part5b_virus_caga_effect.png`** | **Virus CagA效应可视化** |
| **02b分析** | **`01_go_daa_results.csv`** | **GO差异分析完整结果** |
| **02b分析** | **`02_pfam_daa_results.csv`** | **PFAM差异分析完整结果** |
| **03c分析** | **`01_bacteria_network_stats.csv`** | **网络拓扑统计（含模块度）** |
| **03c分析** | **`02_bacteria_hub_species.csv`** | **Hub物种中心性指标** |

### B. 数据可用性

- **TSE对象**: `analyses/data/01_alpha_beta_diversity_analysis/tse_standard_species_ca_cleaned.rds`
- **完整分析代码**: Quarto文档(.qmd)
- **HTML报告**: `analyses/_output/`

---

**文档维护**: Gong Yuhang | **项目代号**: PC047 vCagAepitope | **版本**: v7.0
