# Epic 1 Context: Foundation Infrastructure

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Establish the core infrastructure required for file I/O, memory management, and basic data structures. This epic provides the foundational layer for the JSON parser and query engine, enabling efficient streaming of large files (up to 100MB) with minimal memory overhead and consistent error handling.

## Stories

- Story E1-S1: IFS File Stream Reader
- Story E1-S2: Buffer Management System
- Story E1-S3: Memory Allocation Framework
- Story E1-S4: Core Data Structures
- Story E1-S5: Error Handling Framework
- Story E1-S6: String Utilities
- Story E1-S7: Position Tracking
- Story E1-S8: Unit Test Framework Setup

## Requirements & Constraints

- **Platform:** OS/400 v7.5 or higher.
- **Zero Dependencies:** No external libraries are permitted; all functionality must be implemented natively.
- **File I/O:** Support IFS files ranging from 0 bytes to 100MB with UTF-8 encoding.
- **Memory Efficiency:** Use a streaming approach to maintain a constant memory footprint (<10MB overhead) regardless of file size.
- **Error Protocol:** Use RPGLE indicator 35 to signal errors, accompanied by a 256-character descriptive error message.
- **Scalability:** Support arbitrary nesting depth (minimum 100 levels) and multiple concurrent file sessions.

## Technical Decisions

- **STRICT Fixed-Format RPGLE:** **All code MUST be written in strict fixed-format RPGLE. The use of `/FREE` or free-form blocks is STRICTLY PROHIBITED.** This is a foundational constraint to ensure compatibility and consistency across the legacy codebase.
- **Streaming Architecture:** Use IFS C APIs (`open()`, `read()`, `close()`) for incremental file processing.
- **Buffering Strategy:** Implement read-ahead buffering with a 4KB active buffer and an 8KB read-ahead threshold to minimize I/O operations.
- **Memory Management:** Use a node pooling strategy with 10,000 pre-allocated nodes and a free list for recycling to optimize performance and prevent leaks.
- **Data Structures:** Define `JsonNode`, `Token`, and `Session` structures using `QUALIFIED` and `BASED` keywords. Use `VARYING` fields for string manipulation within fixed-format constraints.
- **Tree Design:** Implement a parent-child-sibling pointer-based tree structure for navigation.
- **Error Framework:** Categorize errors (File, Parse, Query, Runtime) with codes in the JSON001-JSON399 range.

## Cross-Story Dependencies

- **Buffer Management (E1-S2)** requires the **IFS File Stream Reader (E1-S1)**.
- **Position Tracking (E1-S7)** depends on the **Buffer Management System (E1-S2)**.
- **Error Handling Framework (E1-S5)** depends on the **Core Data Structures (E1-S4)**.
