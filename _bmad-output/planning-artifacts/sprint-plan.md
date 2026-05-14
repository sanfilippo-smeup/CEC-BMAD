# Sprint Planning Document
# RPGLE-Json Query Utility

**Project Name:** RPGLE-Json  
**Sprint:** Sprint 1 - Foundation Infrastructure  
**Sprint Duration:** 2-3 days  
**Sprint Goal:** Establish core infrastructure for file I/O, memory management, and basic data structures  
**Date:** 2026-04-28  
**Sprint Owner:** Mauro  
**Status:** Ready to Start  
**Related Documents:** [Product Brief](product-brief.md) | [PRD](prd.md) | [Architecture](architecture.md) | [Epics & Stories](epics-and-stories.md) | [Implementation Readiness](implementation-readiness.md)

---

## Table of Contents

1. [Sprint Overview](#sprint-overview)
2. [Sprint Goals](#sprint-goals)
3. [Sprint Backlog](#sprint-backlog)
4. [Daily Breakdown](#daily-breakdown)
5. [Definition of Done](#definition-of-done)
6. [Risk Management](#risk-management)
7. [Success Metrics](#success-metrics)
8. [Next Sprint Preview](#next-sprint-preview)

---

## Sprint Overview

### Sprint Context

This is **Sprint 1** of the RPGLE-Json Query Utility project, focusing on **Epic 1: Foundation Infrastructure**. This sprint establishes the foundational components required for all subsequent development phases.

### Why This Sprint Matters

The foundation infrastructure is critical because:
- **Zero Dependencies:** Can start immediately without waiting for other components
- **Enables Everything:** All future work depends on these core capabilities
- **Risk Mitigation:** Validates technical approach early (IFS APIs, memory management, RPGLE constraints)
- **Quality Foundation:** Sets patterns for error handling, testing, and code structure

### Sprint Statistics

| Metric | Value |
|--------|-------|
| **Total Stories** | 8 |
| **P0 Stories** | 5 (62.5%) |
| **P1 Stories** | 3 (37.5%) |
| **Estimated Effort** | 2-3 days |
| **Story Points** | 18 (Medium: 6, Small: 2) |
| **Epic** | E1: Foundation Infrastructure |
| **Dependencies** | None (can start immediately) |

---

## Sprint Goals

### Primary Goals (Must Achieve)

1. ✅ **File I/O Capability**
   - Read IFS files using streaming approach
   - Handle files up to 100MB
   - Proper error handling for file operations

2. ✅ **Memory Management**
   - Dynamic allocation/deallocation framework
   - Node pooling for performance
   - No memory leaks

3. ✅ **Core Data Structures**
   - JsonNode, Token, Session, ErrorInfo structures defined
   - Type-safe and maintainable

4. ✅ **Error Handling**
   - Consistent error framework across all components
   - Clear error messages with context

5. ✅ **Testing Framework**
   - Basic unit testing capability
   - Can validate components as built

### Secondary Goals (Nice to Have)

1. ⭐ **String Utilities** (P1)
   - Helper functions for string manipulation
   - Simplifies future development

2. ⭐ **Position Tracking** (P1)
   - Line/column tracking for error messages
   - Better debugging experience

### Success Criteria

Sprint is successful if:
- [ ] All P0 stories completed and tested
- [ ] Can read a 100MB JSON file without errors
- [ ] Memory allocation/deallocation works correctly
- [ ] Error handling framework operational
- [ ] Unit test framework can run tests
- [ ] No critical bugs or blockers
- [ ] Code compiles on OS/400 v7.5

---

## Sprint Backlog

### Story Breakdown

#### P0 Stories (Critical - Must Complete)

##### 1. E1-S1: IFS File Stream Reader
**Priority:** P0 | **Effort:** Medium (4 points) | **Day:** 1

**User Story:**
> As a developer, I want to read IFS files using a streaming approach, so that I can process large JSON files without loading them entirely into memory.

**Acceptance Criteria:**
- [ ] Can open IFS file by path (absolute and relative)
- [ ] Reads file in configurable buffer chunks (default 4KB)
- [ ] Maintains file position for sequential reading
- [ ] Properly closes file handle on completion
- [ ] Returns appropriate errors for file not found, permission denied

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- OpenFile(path: VARCHAR(256)): FileHandle
- ReadChunk(handle: FileHandle; buffer: CHAR(4096)): Int
- CloseFile(handle: FileHandle): Ind
- GetFileSize(handle: FileHandle): Int
```

**Technical Notes:**
- Use IFS C APIs: `open()`, `read()`, `close()`
- Implement buffer management with read-ahead
- Handle UTF-8 encoding
- Test with files: 1KB, 1MB, 10MB, 100MB

**Dependencies:** None

**Testing:**
- Unit test: Open/read/close small file
- Unit test: Handle file not found
- Unit test: Handle permission denied
- Integration test: Read 100MB file

---

##### 2. E1-S2: Buffer Management System
**Priority:** P0 | **Effort:** Medium (4 points) | **Day:** 1

**User Story:**
> As a developer, I want an efficient buffer management system, so that file reading is optimized with minimal I/O operations.

**Acceptance Criteria:**
- [ ] Implements read-ahead buffering (8KB default)
- [ ] Automatically refills buffer when threshold reached
- [ ] Provides `PeekChar()` and `ReadChar()` operations
- [ ] Handles EOF gracefully
- [ ] Maintains line and column tracking for error reporting

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- InitBuffer(fileHandle: FileHandle): BufferHandle
- PeekChar(buffer: BufferHandle): Char
- ReadChar(buffer: BufferHandle): Char
- IsEOF(buffer: BufferHandle): Ind
- RefillBuffer(buffer: BufferHandle): Ind
```

**Technical Notes:**
- Buffer size: 4KB active + 8KB read-ahead
- Refill threshold: 1KB remaining
- Track position for error messages
- Optimize for sequential access

**Dependencies:** E1-S1 (File Stream Reader)

**Testing:**
- Unit test: Buffer refill logic
- Unit test: PeekChar doesn't advance position
- Unit test: ReadChar advances position
- Unit test: EOF detection

---

##### 3. E1-S3: Memory Allocation Framework
**Priority:** P0 | **Effort:** Medium (4 points) | **Day:** 1-2

**User Story:**
> As a developer, I want a memory allocation framework, so that I can dynamically allocate and free memory for parse tree nodes.

**Acceptance Criteria:**
- [ ] Implements `AllocNode()` and `FreeNode()` procedures
- [ ] Uses node pooling for performance
- [ ] Tracks allocated memory for cleanup
- [ ] Provides emergency cleanup on errors
- [ ] Prevents memory leaks

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- InitMemoryPool(poolSize: Int): PoolHandle
- AllocNode(pool: PoolHandle): NodePtr
- FreeNode(pool: PoolHandle; node: NodePtr): Ind
- CleanupPool(pool: PoolHandle): Ind
- GetPoolStats(pool: PoolHandle): PoolStats
```

**Technical Notes:**
- Pre-allocate node pool (10,000 nodes)
- Use free list for recycling
- Implement reference counting if needed
- Track allocation statistics

**Dependencies:** None

**Testing:**
- Unit test: Allocate and free single node
- Unit test: Allocate 10,000 nodes
- Unit test: Free list recycling
- Memory leak test: Allocate/free cycle

---

##### 4. E1-S4: Core Data Structures
**Priority:** P0 | **Effort:** Small (2 points) | **Day:** 2

**User Story:**
> As a developer, I want well-defined data structures for nodes, tokens, and sessions, so that the codebase is maintainable and type-safe.

**Acceptance Criteria:**
- [ ] Define `JsonNode` structure (type, parent, children, value)
- [ ] Define `Token` structure (type, value, position)
- [ ] Define `Session` structure (handle, file, parse tree)
- [ ] Define `ErrorInfo` structure (code, message, position)
- [ ] All structures use QUALIFIED and BASED where appropriate

**Technical Implementation:**
```rpgle
// Data structures to define:

D JsonNode        DS                  QUALIFIED BASED(nodePtr)
D   nodeType                     1A
D   parent                        *
D   firstChild                    *
D   nextSibling                   *
D   value                      256A   VARYING

D Token           DS                  QUALIFIED BASED(tokenPtr)
D   tokenType                    1A
D   value                      256A   VARYING
D   line                        10I 0
D   column                      10I 0

D Session         DS                  QUALIFIED BASED(sessionPtr)
D   handle                      10I 0
D   fileHandle                    *
D   parseTree                     *
D   errorInfo                     *

D ErrorInfo       DS                  QUALIFIED BASED(errorPtr)
D   errorCode                   10A
D   message                    256A   VARYING
D   line                        10I 0
D   column                      10I 0
```

**Technical Notes:**
- Use VARYING fields for strings
- Use pointers for tree navigation
- Document all fields clearly
- Consider alignment for performance

**Dependencies:** None

**Testing:**
- Compile test: All structures compile
- Unit test: Structure size validation
- Unit test: Pointer navigation

---

##### 5. E1-S5: Error Handling Framework
**Priority:** P0 | **Effort:** Medium (4 points) | **Day:** 2

**User Story:**
> As a developer, I want a consistent error handling framework, so that all errors are properly detected, reported, and cleaned up.

**Acceptance Criteria:**
- [ ] Define error codes (JSON001-JSON399)
- [ ] Implement `SetError()` and `GetError()` procedures
- [ ] Set indicator 35 for all errors
- [ ] Format error messages with context
- [ ] Cleanup resources on error paths

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- SetError(code: CHAR(10); msg: VARCHAR(256); line: Int; col: Int): Ind
- GetError(errorInfo: ErrorInfo): Ind
- ClearError(): Ind
- FormatError(errorInfo: ErrorInfo): VARCHAR(512)
- IsError(): Ind

// Error code ranges:
// JSON001-JSON099: File I/O errors
// JSON100-JSON199: JSON parsing errors
// JSON200-JSON299: JSONPath query errors
// JSON300-JSON399: Runtime errors
```

**Technical Notes:**
- Error categories: File, Parse, Query, Runtime
- Include line/column in parse errors
- Use MONITOR/ON-ERROR for internal exceptions
- Thread-safe error storage

**Dependencies:** E1-S4 (Core Data Structures)

**Testing:**
- Unit test: Set and get error
- Unit test: Error formatting
- Unit test: Error indicator setting
- Unit test: Error cleanup

---

#### P1 Stories (High Priority - Complete if Time Permits)

##### 6. E1-S6: String Utilities
**Priority:** P1 | **Effort:** Small (2 points) | **Day:** 2-3

**User Story:**
> As a developer, I want string utility procedures, so that I can efficiently manipulate strings in fixed-form RPGLE.

**Acceptance Criteria:**
- [ ] `StrLen()` - Get string length
- [ ] `StrCat()` - Concatenate strings
- [ ] `StrCmp()` - Compare strings
- [ ] `StrCopy()` - Copy string
- [ ] `StrTrim()` - Trim whitespace

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- StrLen(str: VARCHAR(32767)): Int
- StrCat(str1: VARCHAR; str2: VARCHAR): VARCHAR
- StrCmp(str1: VARCHAR; str2: VARCHAR): Int
- StrCopy(dest: VARCHAR; src: VARCHAR): Ind
- StrTrim(str: VARCHAR): VARCHAR
```

**Dependencies:** None

---

##### 7. E1-S7: Position Tracking
**Priority:** P1 | **Effort:** Small (2 points) | **Day:** 3

**User Story:**
> As a developer, I want accurate position tracking during parsing, so that error messages include line and column numbers.

**Acceptance Criteria:**
- [ ] Track current line number
- [ ] Track current column number
- [ ] Update on each character read
- [ ] Handle newline characters correctly
- [ ] Provide `GetPosition()` procedure

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- InitPosition(): PositionHandle
- UpdatePosition(pos: PositionHandle; char: Char): Ind
- GetPosition(pos: PositionHandle): Position
- ResetPosition(pos: PositionHandle): Ind
```

**Dependencies:** E1-S2 (Buffer Management)

---

##### 8. E1-S8: Unit Test Framework Setup
**Priority:** P1 | **Effort:** Small (2 points) | **Day:** 3

**User Story:**
> As a developer, I want a basic unit testing framework, so that I can test components as I build them.

**Acceptance Criteria:**
- [ ] Create test harness program
- [ ] Implement assertion procedures
- [ ] Support test case registration
- [ ] Report test results clearly
- [ ] Handle test failures gracefully

**Technical Implementation:**
```rpgle
// Key procedures to implement:
- RegisterTest(name: VARCHAR; testProc: Pointer): Ind
- RunTests(): TestResults
- Assert(condition: Ind; message: VARCHAR): Ind
- AssertEquals(expected: VARCHAR; actual: VARCHAR): Ind
- ReportResults(results: TestResults): Ind
```

**Dependencies:** None

---

## Daily Breakdown

### Day 1: File I/O Foundation
**Focus:** Get file reading working

**Morning (4 hours):**
1. **E1-S1: IFS File Stream Reader** (2 hours)
   - Implement OpenFile, ReadChunk, CloseFile
   - Test with small files
   - Handle basic errors

2. **E1-S2: Buffer Management System** (2 hours)
   - Implement buffer structure
   - Implement PeekChar, ReadChar
   - Test buffer refill logic

**Afternoon (4 hours):**
3. **E1-S3: Memory Allocation Framework** (4 hours)
   - Design memory pool structure
   - Implement AllocNode, FreeNode
   - Implement free list
   - Basic testing

**End of Day Goals:**
- [ ] Can read files from IFS
- [ ] Buffer management working
- [ ] Memory allocation functional
- [ ] All code compiles

**Validation:**
- Read a 10MB file successfully
- Allocate/free 1000 nodes without leaks

---

### Day 2: Data Structures & Error Handling
**Focus:** Complete core infrastructure

**Morning (4 hours):**
1. **E1-S3: Memory Allocation Framework** (1 hour)
   - Complete testing
   - Add pool statistics
   - Verify no memory leaks

2. **E1-S4: Core Data Structures** (1 hour)
   - Define all structures
   - Document fields
   - Compile and validate

3. **E1-S5: Error Handling Framework** (2 hours)
   - Define error codes
   - Implement SetError, GetError
   - Test error propagation

**Afternoon (4 hours):**
4. **E1-S5: Error Handling Framework** (2 hours)
   - Complete error formatting
   - Test all error paths
   - Integrate with file I/O

5. **E1-S6: String Utilities** (2 hours)
   - Implement utility functions
   - Test each function
   - Document usage

**End of Day Goals:**
- [ ] All data structures defined
- [ ] Error handling complete
- [ ] String utilities working
- [ ] Integration tests passing

**Validation:**
- Error messages include line/column
- All P0 stories complete
- No compilation errors

---

### Day 3: Polish & Testing
**Focus:** Complete P1 stories and comprehensive testing

**Morning (4 hours):**
1. **E1-S7: Position Tracking** (2 hours)
   - Implement position tracking
   - Test with various inputs
   - Integrate with buffer management

2. **E1-S8: Unit Test Framework** (2 hours)
   - Create test harness
   - Implement assertions
   - Write initial tests

**Afternoon (4 hours):**
3. **Integration Testing** (2 hours)
   - Test file I/O with large files
   - Test memory allocation under load
   - Test error handling scenarios

4. **Documentation & Cleanup** (2 hours)
   - Document all procedures
   - Clean up code
   - Prepare for Sprint Review

**End of Day Goals:**
- [ ] All 8 stories complete
- [ ] Comprehensive test coverage
- [ ] Documentation complete
- [ ] Ready for Sprint 2

**Validation:**
- Can read 100MB file
- No memory leaks detected
- All tests passing
- Code review ready

---

## Definition of Done

### Story-Level DoD

A story is considered "Done" when:

**Code Quality:**
- [ ] Code compiles without errors on OS/400 v7.5
- [ ] Follows RPGLE fixed-form conventions
- [ ] All procedures documented with comments
- [ ] No hardcoded values (use constants)
- [ ] Error handling implemented

**Testing:**
- [ ] Unit tests written and passing
- [ ] Edge cases tested
- [ ] Error paths tested
- [ ] Performance acceptable

**Documentation:**
- [ ] Procedure headers complete
- [ ] Complex logic commented
- [ ] Usage examples provided
- [ ] Known limitations documented

**Integration:**
- [ ] Integrates with existing code
- [ ] No breaking changes
- [ ] Dependencies satisfied
- [ ] Code reviewed

### Sprint-Level DoD

The sprint is considered "Done" when:

**Functionality:**
- [ ] All P0 stories complete
- [ ] All acceptance criteria met
- [ ] Sprint goal achieved
- [ ] No critical bugs

**Quality:**
- [ ] All tests passing
- [ ] No memory leaks
- [ ] Performance targets met
- [ ] Code reviewed

**Documentation:**
- [ ] All code documented
- [ ] Sprint retrospective complete
- [ ] Lessons learned captured
- [ ] Next sprint planned

**Readiness:**
- [ ] Ready for Sprint 2
- [ ] No blockers identified
- [ ] Team confident in foundation
- [ ] Stakeholders satisfied

---

## Risk Management

### Identified Risks

#### Risk 1: IFS API Complexity
**Severity:** Medium | **Likelihood:** Medium

**Description:** IFS C APIs may be more complex than anticipated, especially for UTF-8 handling.

**Mitigation:**
- Start with simple file operations
- Test incrementally
- Have fallback to simpler approach
- Consult IBM documentation early

**Contingency:**
- If blocked, use simpler file I/O initially
- Enhance later in optimization phase

---

#### Risk 2: Memory Management Issues
**Severity:** High | **Likelihood:** Low

**Description:** Memory leaks or corruption could cause system instability.

**Mitigation:**
- Implement careful tracking
- Test thoroughly with valgrind-equivalent
- Use defensive programming
- Implement emergency cleanup

**Contingency:**
- If leaks detected, simplify allocation strategy
- Use simpler malloc/free initially

---

#### Risk 3: Fixed-Form RPGLE Limitations
**Severity:** Medium | **Likelihood:** Medium

**Description:** Fixed-form RPGLE may limit implementation options.

**Mitigation:**
- Use pointers for flexibility
- Use VARYING fields for strings
- Reference architecture patterns
- Consult RPGLE experts

**Contingency:**
- Adjust design to work within constraints
- Document workarounds

---

#### Risk 4: Testing Environment Access
**Severity:** Medium | **Likelihood:** Low

**Description:** May not have consistent access to OS/400 v7.5 for testing.

**Mitigation:**
- Test frequently when access available
- Use emulator if possible
- Write comprehensive unit tests
- Document test procedures

**Contingency:**
- Defer integration testing
- Focus on unit tests
- Test in batch when access available

---

### Risk Monitoring

**Daily Risk Check:**
- Review progress against plan
- Identify new risks
- Update mitigation strategies
- Escalate if needed

**Risk Indicators:**
- Stories taking longer than estimated
- Compilation errors increasing
- Test failures accumulating
- Team confidence decreasing

---

## Success Metrics

### Sprint Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Story Completion** | 100% P0 stories | Count completed/total |
| **Test Coverage** | >80% | Lines covered/total lines |
| **Defect Rate** | <5 bugs | Bugs found in testing |
| **Code Quality** | 0 compilation errors | Compiler output |
| **Performance** | Read 100MB in <5s | Benchmark test |
| **Memory** | 0 leaks | Memory profiler |

### Quality Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| **Documentation** | 100% procedures | Documented/total |
| **Code Review** | 100% reviewed | Reviewed/total |
| **Test Pass Rate** | 100% | Passing/total tests |
| **Technical Debt** | 0 critical items | Debt tracker |

### Velocity Metrics

| Metric | Value |
|--------|-------|
| **Planned Story Points** | 18 |
| **Completed Story Points** | TBD |
| **Velocity** | TBD |
| **Sprint Duration** | 2-3 days |

---

## Next Sprint Preview

### Sprint 2: JSON Parser Engine
**Duration:** 3-5 days  
**Epic:** E2  
**Stories:** 12

**Key Deliverables:**
- Complete JSON lexer (tokenization)
- Complete JSON parser (structure building)
- Parse tree construction
- JSON syntax error detection

**Dependencies:**
- Requires Sprint 1 foundation complete
- File I/O working
- Memory management operational
- Error handling in place

**Preparation Needed:**
- Review JSON specification
- Study lexer/parser patterns
- Prepare test JSON files
- Set up parser testing framework

---

## Sprint Ceremonies

### Daily Standup (15 minutes)
**Time:** Start of each day  
**Format:**
1. What did I complete yesterday?
2. What will I work on today?
3. Any blockers or risks?

### Sprint Review (1 hour)
**Time:** End of Day 3  
**Attendees:** Development team, stakeholders  
**Agenda:**
1. Demo completed functionality
2. Review acceptance criteria
3. Discuss challenges
4. Gather feedback

### Sprint Retrospective (30 minutes)
**Time:** After Sprint Review  
**Format:**
1. What went well?
2. What could be improved?
3. Action items for next sprint

---

## Notes & Assumptions

### Assumptions

1. **Development Environment:**
   - Access to OS/400 v7.5 system
   - RPGLE compiler available
   - Can compile and test daily

2. **AI Assistance:**
   - Active collaboration with AI
   - Quick iteration cycles
   - Code generation support

3. **Technical Knowledge:**
   - Familiarity with fixed-form RPGLE
   - Understanding of IFS APIs
   - Basic memory management concepts

4. **Time Availability:**
   - 8 hours per day available
   - Minimal interruptions
   - Focused work sessions

### Success Factors

1. **Clear Requirements:** Well-defined acceptance criteria
2. **Incremental Progress:** Complete stories one at a time
3. **Continuous Testing:** Test as you build
4. **Regular Validation:** Verify on target platform
5. **Documentation:** Document as you go

### Adjustment Factors

Estimates may vary based on:
- **Experience level:** More experienced = faster
- **Testing availability:** Limited testing = slower
- **Complexity discoveries:** Unexpected challenges = slower
- **Scope changes:** Additional requirements = more time

---

## Appendix

### Story Dependencies Graph

```
E1-S1 (File Reader)
  └─> E1-S2 (Buffer Management)
        └─> E1-S7 (Position Tracking)

E1-S3 (Memory Allocation)
  [No dependencies]

E1-S4 (Data Structures)
  └─> E1-S5 (Error Handling)

E1-S6 (String Utilities)
  [No dependencies]

E1-S8 (Test Framework)
  [No dependencies]
```

### Critical Path

The critical path for Sprint 1:
1. E1-S1 (File Reader) → 2. E1-S2 (Buffer Management) → 3. E1-S4 (Data Structures) → 4. E1-S5 (Error Handling)

**Total Critical Path Time:** ~14 hours (1.75 days)

### Resource Allocation

| Resource | Allocation | Notes |
|----------|------------|-------|
| **Developer Time** | 24 hours (3 days × 8 hours) | Full-time focus |
| **AI Assistance** | On-demand | Code generation, review |
| **Testing Time** | 6 hours | Integrated throughout |
| **Documentation** | 2 hours | As-you-go + final |

---

## Sign-Off

**Sprint Planning:** ✅ **COMPLETE**

**Ready to Start:** Yes

**Sprint Start Date:** 2026-04-28

**Expected Completion:** 2026-04-30 or 2026-05-01

**Next Review:** End of Day 3

---

**END OF SPRINT PLAN**