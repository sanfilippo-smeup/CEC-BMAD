---
status: 'done'
epic_num: 1
story_num: 'refactor'
story_key: '1-refactor-to-fixed-format'
baseline_commit: 'NO_VCS'
---

# Spec: Refactor to Strict Fixed-Format RPGLE

<!-- <frozen-after-approval> -->
## Intent
Convert all existing RPGLE source files from `/FREE` blocks to strict fixed-format C-specs to satisfy the project's foundational constraint.

## Goal
Eliminate all `/FREE` and `/END-FREE` delimiters and rewrite the logic using traditional RPGLE fixed-form columns (Factor 1, Op Code, Factor 2, Result, Indicators).

## Files
- `src/qrpglesrc/JSONERR.RPGLE`
- `src/qrpglesrc/JSONSTR.RPGLE`
- `src/qrpglesrc/JSONMEM.RPGLE`
- `src/qrpglesrc/JSONFILE.RPGLE`
- `src/qrpglesrc/JSONBUF.RPGLE`

## Acceptance Criteria
- [ ] No `/FREE` or `/END-FREE` tags remain in any file.
- [ ] All logic is implemented using fixed-form C-specs (columns 6-80).
- [ ] Code compiles and functions exactly as before (behavioral parity).
- [ ] All procedure boundaries (`P B` and `P E`) and parameter interfaces (`PI`) are correctly formatted in fixed-form.
<!-- </frozen-after-approval> -->

## Design Notes
- Use `EVAL` for assignments where it simplifies the translation, but ensure it's in a fixed-form C-spec.
- Use `IF/ELSE/ENDIF`, `DOW/ENDDO`, `MONITOR/ON-ERROR/ENDMON` in their fixed-form variants.
- Ensure all operation codes start in column 26.
- Maintain existing logic and procedure exports.

## Tasks
- [x] Refactor `JSONERR.RPGLE` to fixed-form
- [x] Refactor `JSONSTR.RPGLE` to fixed-form
- [x] Refactor `JSONMEM.RPGLE` to fixed-form
- [x] Refactor `JSONFILE.RPGLE` to fixed-form
- [x] Refactor `JSONBUF.RPGLE` to fixed-form
- [x] Verify all files for strict fixed-form compliance

## Suggested Review Order

**File I/O and Buffer Management**

- IFS API integration and traditional C-spec file operations.
  [`JSONFILE.RPGLE:96`](../../src/qrpglesrc/JSONFILE.RPGLE#L96)

- Multi-buffer management with read-ahead logic in fixed-form.
  [`JSONBUF.RPGLE:121`](../../src/qrpglesrc/JSONBUF.RPGLE#L121)

**Memory and Error Handling**

- Pointer-based node pooling and free-list management logic.
  [`JSONMEM.RPGLE:41`](../../src/qrpglesrc/JSONMEM.RPGLE#L41)

- Global error state and procedure interface formatting.
  [`JSONERR.RPGLE:29`](../../src/qrpglesrc/JSONERR.RPGLE#L29)

**Utilities**

- String manipulation wrapper procedures.
  [`JSONSTR.RPGLE:21`](../../src/qrpglesrc/JSONSTR.RPGLE#L21)
