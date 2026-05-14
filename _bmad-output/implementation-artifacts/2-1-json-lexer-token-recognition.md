# Story 2.1: JSON Lexer - Token Recognition

Status: ready-for-dev

## Story

As a developer,
I want a lexer that recognizes all JSON tokens,
so that I can tokenize JSON input for parsing in subsequent stories.

## Acceptance Criteria

1. Recognizes all structural tokens: `{`, `}`, `[`, `]`, `:`, `,`
2. Recognizes value tokens: string (delegates to ParseString), number (delegates to ParseNumber), `true`, `false`, `null`
3. Skips whitespace correctly: space (x'20'), tab (x'09'), newline (x'0A'), carriage return (x'0D')
4. Tracks token position (line and column) using the buffer's `GetPosition` API
5. Returns `TOK_EOF` token when the buffer reaches EOF
6. Returns a parse error (`ERR_PARSE_UNEXP` / JSON101) for any unrecognized character
7. `NextToken()` is exported and callable from other modules via `/COPY QRPGLESRC,JSONH`

## Tasks / Subtasks

- [ ] Task 1 – Create `JSONLEX.RPGLE` source member (AC: 1, 2, 3, 4, 5, 6, 7)
  - [ ] 1.1 Add file header comment block (project, story, author, date, version)
  - [ ] 1.2 Add `/COPY QRPGLESRC,JSONDATA` and `/COPY QRPGLESRC,JSONERR` includes
  - [ ] 1.3 Declare `LexerState` DS (buffer pointer, lookahead token pointer)
  - [ ] 1.4 Implement `InitLexer(buffer)` procedure – allocate and return `LexerState` pointer
  - [ ] 1.5 Implement `CleanupLexer(lexer)` procedure – free `LexerState` and token
  - [ ] 1.6 Implement `NextToken(lexer)` procedure (main dispatcher, see algorithm below)
  - [ ] 1.7 Implement internal helper `SkipWS(lexer)` (delegates to `SkipWhitespace(buffer)`)
  - [ ] 1.8 Implement `PeekToken(lexer)` – lookahead without consuming
  - [ ] 1.9 Add EXPORT keyword to all public procedures

- [ ] Task 2 – Add prototypes to `JSONH.RPGLE` (AC: 7)
  - [ ] 2.1 Add `InitLexer`, `CleanupLexer`, `NextToken`, `PeekToken` PR declarations after the Buffer Management section

- [ ] Task 3 – Unit tests in test harness (AC: 1–6)
  - [ ] 3.1 Test all 6 structural tokens individually
  - [ ] 3.2 Test whitespace skipping (leading/trailing/mixed)
  - [ ] 3.3 Test EOF returns `TOK_EOF`
  - [ ] 3.4 Test unrecognized character returns error and sets indicator 35
  - [ ] 3.5 Test position tracking: token after newline should have correct line/col

## Dev Notes

### Critical Constraint — Fixed-Format RPGLE Only
**ALL code MUST be written in strict fixed-format RPGLE. `/FREE` blocks and free-form constructs are ABSOLUTELY PROHIBITED.** This is the single most important rule in this codebase. Every existing file follows this rule without exception.

### How the Lexer Fits the Architecture

```
Client → JSONH (public API) → [future] JSONPAR → JSONLEX → JSONBUF → JSONFILE
```

- `JSONLEX` sits directly on top of `JSONBUF` — it never calls `JSONFILE` directly.
- Token constants and the `Token` DS are already defined in `JSONDATA` — do NOT redefine them.
- `JSONLEX` produces `Token` DS instances that the parser (E2-S5+) will consume.

### Existing Structures to Reuse (JSONDATA.RPGLE)

**Token type constants** (already defined — use as-is):
```rpgle
     D TOK_LBRACE      C                   CONST('{')
     D TOK_RBRACE      C                   CONST('}')
     D TOK_LBRACKET    C                   CONST('[')
     D TOK_RBRACKET    C                   CONST(']')
     D TOK_COLON       C                   CONST(':')
     D TOK_COMMA       C                   CONST(',')
     D TOK_STRING      C                   CONST('S')
     D TOK_NUMBER      C                   CONST('#')
     D TOK_TRUE        C                   CONST('T')
     D TOK_FALSE       C                   CONST('F')
     D TOK_NULL        C                   CONST('N')
     D TOK_EOF         C                   CONST('E')
```

**Token DS** (already defined in JSONDATA — use `BASED(tokenPtr)` or `LIKEDS(Token)`):
```rpgle
     D Token           DS                  QUALIFIED BASED(tokenPtr)
     D   tokenType                    1A
     D   value                      256A   VARYING
     D   line                        10I 0
     D   column                      10I 0
     D   offset                      10I 0
     D   length                      10I 0
```

**Error codes relevant to this story** (already in JSONDATA):
- `ERR_PARSE_UNEXP` = `'JSON101'` — unexpected character
- `ERR_PARSE_EOF`   = `'JSON102'` — unexpected end of input

### Buffer API to Call (JSONBUF.RPGLE — prototypes in JSONH.RPGLE)

| Procedure | Signature | Purpose |
|-----------|-----------|---------|
| `PeekChar(buffer)` | `PR 1A` | Look at next char without consuming |
| `ReadChar(buffer)` | `PR 1A` | Read and consume next char |
| `UnreadChar(buffer)` | `PR N` | Push back last char (1 char lookahead) |
| `IsBufferEOF(buffer)` | `PR N` | Returns `*ON` when exhausted |
| `GetPosition(buffer)` | `PR LIKEDS(Position)` | Current line/col/offset |
| `GetLine(buffer)` | `PR 10I 0` | Current line number |
| `GetColumn(buffer)` | `PR 10I 0` | Current column number |
| `SkipWhitespace(buffer)` | `PR N` | Advances past space/tab/LF/CR |

### NextToken() Algorithm

```
NextToken(lexer):
  buffer = lexerDs.buffer
  CALLP SkipWhitespace(buffer)
  IF IsBufferEOF(buffer)
    → fill token: tokenType=TOK_EOF, value='', line/col from GetPosition
    RETURN token pointer
  ENDIF

  pos = GetPosition(buffer)
  ch  = ReadChar(buffer)

  SELECT
    WHEN ch = '{'  → tokenType = TOK_LBRACE,   value = ch
    WHEN ch = '}'  → tokenType = TOK_RBRACE,   value = ch
    WHEN ch = '['  → tokenType = TOK_LBRACKET, value = ch
    WHEN ch = ']'  → tokenType = TOK_RBRACKET, value = ch
    WHEN ch = ':'  → tokenType = TOK_COLON,    value = ch
    WHEN ch = ','  → tokenType = TOK_COMMA,    value = ch
    WHEN ch = '"'  → UnreadChar; CALLP ParseString (E2-S2 stub: set value='')
    WHEN ch = '-' OR (ch >= '0' AND ch <= '9')
                   → UnreadChar; CALLP ParseNumber (E2-S3 stub: set value='0')
    WHEN ch = 't'  → UnreadChar; CALLP ParseKeyword(lexer: 'true':  TOK_TRUE)
    WHEN ch = 'f'  → UnreadChar; CALLP ParseKeyword(lexer: 'false': TOK_FALSE)
    WHEN ch = 'n'  → UnreadChar; CALLP ParseKeyword(lexer: 'null':  TOK_NULL)
    OTHER          → CALLP SetParseError(ERR_PARSE_UNEXP: 'Unexpected character': pos.line: pos.col: ch)
                     set indicator *IN35 = *ON
                     tokenType = TOK_EOF  ← sentinel on error
  ENDSL
```

> **For E2-S1 scope:** ParseString and ParseNumber should be implemented as stubs
> (empty procedure bodies that return a minimal token) — full implementations
> are in E2-S2 and E2-S3 respectively. ParseKeyword is fully in scope for E2-S1
> (it is simple string matching, listed as E2-S4 but trivially part of the
> main dispatcher).

### ParseKeyword() Algorithm

```
ParseKeyword(lexer: keyword: tokenType):
  buffer = lexerDs.buffer
  startPos = GetPosition(buffer)
  Read len(keyword) chars from buffer
  IF chars match keyword
    fill token: tokenType=tokenType, value=keyword, pos=startPos
  ELSE
    SetParseError(ERR_PARSE_UNEXP: 'Invalid keyword': startPos.line: startPos.col)
    set *IN35 = *ON
  ENDIF
```

### LexerState DS Recommendation

```rpgle
     D LexerState      DS                  QUALIFIED BASED(lexPtr)
     D   buffer                        *        ← pointer to BufferHandle
     D   currentTok                    *        ← pointer to current Token
     D   peekTok                       *        ← pointer to lookahead Token (or *NULL)
     D   hasError                      1N
```

### File to Create

| File | Location | Action |
|------|----------|--------|
| `JSONLEX.RPGLE` | `src/qrpglesrc/JSONLEX.RPGLE` | CREATE |
| `JSONH.RPGLE`   | `src/qrpglesrc/JSONH.RPGLE`   | UPDATE — add lexer PRs |

### Naming and Style Conventions (from existing source)

- All identifiers: mixed-case PascalCase for procedures (`NextToken`, `InitLexer`)
- Constants: UPPER_CASE with prefix (`TOK_*`, `ERR_*`)
- DS fields: camelCase (`tokenType`, `firstChild`)
- Column layout: strictly columns 1–80 (fixed-format rules)
  - D-specs: name in cols 7–21, type in 22–25, length in 26–32, keywords from 44
  - C-specs: factor 1 in cols 12–25, opcode in 26–35, factor 2 in 36–49, result in 50–63
- `EXPORT` on the `P` spec B line, not the PR
- Use `CALLP` for procedure calls in C-specs
- Use `EVAL` for assignments
- Use `SELECT/WHEN/OTHER/ENDSL` for multi-branch logic
- Use `IF/ELSE/ENDIF`, `DO/ENDDO` loops

### Error Handling Pattern (from JSONERR.RPGLE)

Call `SetParseError(code: msg: line: col: near)` then set `*IN35 = *ON`. The indicator is the public error signal per the architecture contract.

### Project Structure Notes

- Source root: `src/qrpglesrc/`
- All members are flat in this directory (no sub-folders on IBM i QRPGLESRC)
- Member names ≤ 10 chars, uppercase (IBM i constraint)
- `JSONLEX` is 7 chars — valid

### References

- Token constants and DS: [src/qrpglesrc/JSONDATA.RPGLE](src/qrpglesrc/JSONDATA.RPGLE)
- Buffer API prototypes: [src/qrpglesrc/JSONH.RPGLE](src/qrpglesrc/JSONH.RPGLE#L211)
- Buffer implementation: [src/qrpglesrc/JSONBUF.RPGLE](src/qrpglesrc/JSONBUF.RPGLE)
- Error handling API: [src/qrpglesrc/JSONERR.RPGLE](src/qrpglesrc/JSONERR.RPGLE)
- Architecture: [_bmad-output/planning-artifacts/architecture.md](_bmad-output/planning-artifacts/architecture.md#JSON-Parser-Engine)
- Epics & Stories: [_bmad-output/planning-artifacts/epics-and-stories.md](_bmad-output/planning-artifacts/epics-and-stories.md#E2-S1)
- Epic 1 context (patterns established): [_bmad-output/implementation-artifacts/epic-1-context.md](_bmad-output/implementation-artifacts/epic-1-context.md)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.6

### Debug Log References

### Completion Notes List

### File List
