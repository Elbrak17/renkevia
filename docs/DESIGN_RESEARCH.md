# Design research and skill provenance

Review date: 2026-07-20. The six requested sources were read as complementary design reviews, not as code generators. RENKEVIA’s Flutter implementation is original; no third-party skill runtime or source code ships in the application.

| Requested source | Reviewed source and revision | License/status | Contribution used |
|---|---|---|---|
| [ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill) | `b484e8338c25b9cea3a25981a992d2817188971a` | MIT | Domain/product/style/typography research, pre-delivery checklist, Flutter-specific responsive and accessibility guidance |
| [ui-ux-pro-mcp](https://github.com/redf0x1/ui-ux-pro-mcp) | `943385ee3e2320f493dedd86f0869260d3f8324e` | MIT | Searchable design evidence, cross-checking healthcare patterns, stack-aware recommendations |
| [victor604/frontend-design](https://github.com/victor604/frontend-design) | Requested repository was unavailable during review; its indexed content mapped to the canonical [Anthropic frontend-design skill](https://github.com/anthropics/skills/tree/main/skills/frontend-design), revision `fa0fa64bdc967915dc8399e803be67759e1e62b8` | Canonical skill: Apache-2.0 | Strong aesthetic thesis, signature visual grammar, avoidance of generic AI-dashboard composition |
| [uxuiprinciples/agent-skills](https://github.com/uxuiprinciples/agent-skills) | `2dc7f30ce8e54bc798236a9ed82b7daef0b53bc1` | Repository states skills are free to use and distribute; paid API is optional | Flow continuity, AI transparency, trust calibration, interface audit, cognitive-load and vibe-coding checks |
| [Vercel web design guidelines mirror](https://ai-learn.wangkangyi.com/skills/vercelwebdesignguidelines) | Mirror points to canonical [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills/tree/main/skills/web-design-guidelines), revision `f8a72b9603728bb92a217a879b7e62e43ad76c81` | MIT | Current web interaction, accessibility, forms, typography, performance, navigation, and responsive rules |
| [ui-ux-design-pro-skill](https://github.com/saifyxpro/ui-ux-design-pro-skill) | `7c98f97767f00dee333635c59c42e9db229f6a1f` | MIT | Token architecture, spacing, elevation, component patterns, cognitive principles, animation, critique protocol |

## Fusion, not selection

The final direction uses the intersection of all six reviews:

1. **Start with the pressured user’s job**, not a visual trend or model feature.
2. **Choose one memorable thesis:** a clinical decision room connected by one dependency line.
3. **Make the first level plain-language and actionable.** Technical proof moves to deliberate secondary surfaces.
4. **Make AI limits visible:** provenance, review independence, uncertainty, rollback, and a named human decision.
5. **Tokenize every visual decision** so desktop, tablet, mobile, and the static web boot shell remain coherent.
6. **Treat accessibility and responsiveness as correctness**, not polish after implementation.
7. **Inspect the rendered artifact**, because syntactically valid Flutter can still be visually misleading.

The initial automated healthcare palette suggestion from one research tool was rejected because it produced an undifferentiated red/neumorphic direction. The final design uses the sources as critique constraints while retaining a distinct product point of view.

## Hackathon compliance

The published Build Week materials permit third-party and open-source tools and explicitly evaluate the quality of work produced with Codex. These sources informed the engineering process; they do not replace GPT-5.6 usage in the product, and their licenses/status are documented above. No skill-provided asset or proprietary output is represented as RENKEVIA-owned training material.
