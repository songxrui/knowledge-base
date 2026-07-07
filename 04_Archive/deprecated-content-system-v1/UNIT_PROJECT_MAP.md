# Content Unit to 01_Projects Bridge Mapping

> Generated: 2026-06-12 23:47
> Method: 3-hop bridge: ContentUnit → D/W source → R-series → Topic → 01_Projects

---

## Overview

| Metric | Value |
|--------|-------|
| Content units with source tags | 35 (via 107 unique tags) |
| D-tags mapped to R-series via W_TO_R_MAP | 7 |
| Content units bridged to R-series | 35 |
| W-tags mapped to R-series | 8 |
| R-series articles | 8 (R1-R8) |
| 01_Projects articles (indirectly linked) | 142 (via topic alignment) |

---

## Bridge Chain

### Layer 1: Content Unit → Source Tag

| Source Tag Type | Count | Examples |
|---------------|-------|---------|
| D-series | 103 |  |
| WLH-series | 4 |  |

### Layer 2: Source Tag → R-series (via W_TO_R_MAP)

| R1 | D84 | W1 | 5 |
| R2 | D91 | W11 | 5 |
| R3 | D87 | W2 | 5 |
| R4 | D85 | W26 | 5 |
| R5 | D103 | W4 | 5 |
| R6 | D92 | W5 | 5 |
| R7 | D99 | W3 | 5 |
| R8 |  | W14 | 0 |

### Layer 3: R-series → Topic → 01_Projects Category

| Topic | R-series | 01_Projects Categories | Total Articles |
|-------|----------|----------------------|---------------|
| Topic3 (Cognitive) | R3, R7 | book-decons, cognition, concept-anatomy, history-society, psychology, relationship | 0 |
| Topic2 (Content&Business) | R2, R6 | dankoe-methodology, self-media, visual-assets, wealth | 0 |
| Topic1 (Execution) | R1, R4, R5, R8 | decision-system, health, knowledge-cards, plain, productivity | 0 |

---

## Usage

To find which 01_Projects articles a content unit maps to:
1. Extract source tag from unit filename (e.g., D01)
2. Check W_TO_R_MAP for which R-series uses that source
3. Find the topic group for that R-series
4. Browse the corresponding 01_Projects category

Example: Content unit SOL-D01 maps to R1 (Execution System) -> cognition/ and productivity/ categories

