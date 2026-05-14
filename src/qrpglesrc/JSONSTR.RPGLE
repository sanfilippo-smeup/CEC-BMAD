      *=====================================================================
      * JSONSTR - String Utilities for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides string manipulation utilities optimized for
      *              fixed-form RPGLE.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.1 (Refactored to fixed-form)
      *
      * Story: E1-S6 - String Utilities
      *=====================================================================

      *---------------------------------------------------------------------
      * Copy Data Structures
      *---------------------------------------------------------------------
     D/COPY QRPGLESRC,JSONDATA

      *=====================================================================
      * Procedure: StrLen
      * Purpose: Get length of a VARYING string
      *=====================================================================
     P StrLen          B                   EXPORT
     D StrLen          PI            10I 0
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %LEN(str)
     P StrLen          E

      *=====================================================================
      * Procedure: StrLenTrim
      * Purpose: Get length of string after trimming whitespace
      *=====================================================================
     P StrLenTrim      B                   EXPORT
     D StrLenTrim      PI            10I 0
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %LEN(%TRIM(str))
     P StrLenTrim      E

      *=====================================================================
      * Procedure: StrCat
      * Purpose: Concatenate two strings
      *=====================================================================
     P StrCat          B                   EXPORT
     D StrCat          PI         32767A   VARYING
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
      *
     C                   RETURN    str1 + str2
     P StrCat          E

      *=====================================================================
      * Procedure: StrCat3
      * Purpose: Concatenate three strings
      *=====================================================================
     P StrCat3         B                   EXPORT
     D StrCat3         PI         32767A   VARYING
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
     D   str3                     32767A   CONST VARYING
      *
     C                   RETURN    str1 + str2 + str3
     P StrCat3         E

      *=====================================================================
      * Procedure: StrCmp
      * Purpose: Compare two strings (case-sensitive)
      * Returns: 0 if equal, <0 if str1 < str2, >0 if str1 > str2
      *=====================================================================
     P StrCmp          B                   EXPORT
     D StrCmp          PI            10I 0
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
      *
     C                   IF        str1 = str2
     C                   RETURN    0
     C                   ELSEIF    str1 < str2
     C                   RETURN    -1
     C                   ELSE
     C                   RETURN    1
     C                   ENDIF
     P StrCmp          E

      *=====================================================================
      * Procedure: StrCmpI
      * Purpose: Compare two strings (case-insensitive)
      * Returns: 0 if equal, <0 if str1 < str2, >0 if str1 > str2
      *=====================================================================
     P StrCmpI         B                   EXPORT
     D StrCmpI         PI            10I 0
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
      *
     D upper1          S          32767A   VARYING
     D upper2          S          32767A   VARYING
      *
     C                   EVAL      upper1 = %UPPER(str1)
     C                   EVAL      upper2 = %UPPER(str2)
      *
     C                   IF        upper1 = upper2
     C                   RETURN    0
     C                   ELSEIF    upper1 < upper2
     C                   RETURN    -1
     C                   ELSE
     C                   RETURN    1
     C                   ENDIF
     P StrCmpI         E

      *=====================================================================
      * Procedure: StrEquals
      * Purpose: Check if two strings are equal (case-sensitive)
      *=====================================================================
     P StrEquals       B                   EXPORT
     D StrEquals       PI              N
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
      *
     C                   RETURN    (str1 = str2)
     P StrEquals       E

      *=====================================================================
      * Procedure: StrEqualsI
      * Purpose: Check if two strings are equal (case-insensitive)
      *=====================================================================
     P StrEqualsI      B                   EXPORT
     D StrEqualsI      PI              N
     D   str1                     32767A   CONST VARYING
     D   str2                     32767A   CONST VARYING
      *
     C                   RETURN    (%UPPER(str1) = %UPPER(str2))
     P StrEqualsI      E

      *=====================================================================
      * Procedure: StrCopy
      * Purpose: Copy string from source to destination
      *=====================================================================
     P StrCopy         B                   EXPORT
     D StrCopy         PI              N
     D   dest                     32767A   VARYING
     D   src                      32767A   CONST VARYING
      *
     C                   EVAL      dest = src
     C                   RETURN    *ON
     P StrCopy         E

      *=====================================================================
      * Procedure: StrTrim
      * Purpose: Trim whitespace from both ends
      *=====================================================================
     P StrTrim         B                   EXPORT
     D StrTrim         PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %TRIM(str)
     P StrTrim         E

      *=====================================================================
      * Procedure: StrTrimL
      * Purpose: Trim whitespace from left end
      *=====================================================================
     P StrTrimL        B                   EXPORT
     D StrTrimL        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %TRIML(str)
     P StrTrimL        E

      *=====================================================================
      * Procedure: StrTrimR
      * Purpose: Trim whitespace from right end
      *=====================================================================
     P StrTrimR        B                   EXPORT
     D StrTrimR        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %TRIMR(str)
     P StrTrimR        E

      *=====================================================================
      * Procedure: StrUpper
      * Purpose: Convert string to uppercase
      *=====================================================================
     P StrUpper        B                   EXPORT
     D StrUpper        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %UPPER(str)
     P StrUpper        E

      *=====================================================================
      * Procedure: StrLower
      * Purpose: Convert string to lowercase
      *=====================================================================
     P StrLower        B                   EXPORT
     D StrLower        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    %LOWER(str)
     P StrLower        E

      *=====================================================================
      * Procedure: StrSubstr
      * Purpose: Extract substring
      *=====================================================================
     P StrSubstr       B                   EXPORT
     D StrSubstr       PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   start                       10I 0 CONST
     D   length                      10I 0 CONST OPTIONS(*NOPASS)
      *
     D parmCount       S             10I 0
      *
     C                   EVAL      parmCount = %PARMS()
      *
     C                   IF        start < 1 OR start > %LEN(str)
     C                   RETURN    ''
     C                   ENDIF
      *
     C                   IF        parmCount >= 3
     C                   IF        start + length - 1 > %LEN(str)
     C                   RETURN    %SUBST(str: start)
     C                   ELSE
     C                   RETURN    %SUBST(str: start: length)
     C                   ENDIF
     C                   ELSE
     C                   RETURN    %SUBST(str: start)
     C                   ENDIF
     P StrSubstr       E

      *=====================================================================
      * Procedure: StrPos
      * Purpose: Find position of substring (1-based, 0 if not found)
      *=====================================================================
     P StrPos          B                   EXPORT
     D StrPos          PI            10I 0
     D   str                      32767A   CONST VARYING
     D   search                   32767A   CONST VARYING
     D   start                       10I 0 CONST OPTIONS(*NOPASS)
      *
     D parmCount       S             10I 0
     D pos             S             10I 0
      *
     C                   EVAL      parmCount = %PARMS()
      *
     C                   IF        parmCount >= 3
     C                   EVAL      pos = %SCAN(search: str: start)
     C                   ELSE
     C                   EVAL      pos = %SCAN(search: str)
     C                   ENDIF
      *
     C                   RETURN    pos
     P StrPos          E

      *=====================================================================
      * Procedure: StrReplace
      * Purpose: Replace all occurrences of search with replace
      *=====================================================================
     P StrReplace      B                   EXPORT
     D StrReplace      PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   search                   32767A   CONST VARYING
     D   replace                  32767A   CONST VARYING
      *
     D result          S          32767A   VARYING
     D pos             S             10I 0
     D searchLen       S             10I 0
      *
     C                   EVAL      result = str
     C                   EVAL      searchLen = %LEN(search)
      *
     C                   IF        searchLen = 0
     C                   RETURN    result
     C                   ENDIF
      *
     C                   EVAL      pos = %SCAN(search: result)
     C                   DOW       pos > 0
     C                   EVAL      result = %SUBST(result: 1: pos - 1) +
     C                               replace +
     C                               %SUBST(result: pos + searchLen)
     C                   EVAL      pos = %SCAN(search: result:
     C                               pos + %LEN(replace))
     C                   ENDDO
      *
     C                   RETURN    result
     P StrReplace      E

      *=====================================================================
      * Procedure: StrStartsWith
      * Purpose: Check if string starts with prefix
      *=====================================================================
     P StrStartsWith   B                   EXPORT
     D StrStartsWith   PI              N
     D   str                      32767A   CONST VARYING
     D   prefix                   32767A   CONST VARYING
      *
     D prefixLen       S             10I 0
      *
     C                   EVAL      prefixLen = %LEN(prefix)
      *
     C                   IF        prefixLen = 0
     C                   RETURN    *ON
     C                   ENDIF
      *
     C                   IF        %LEN(str) < prefixLen
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   RETURN    (%SUBST(str: 1: prefixLen) = prefix)
     P StrStartsWith   E

      *=====================================================================
      * Procedure: StrEndsWith
      * Purpose: Check if string ends with suffix
      *=====================================================================
     P StrEndsWith     B                   EXPORT
     D StrEndsWith     PI              N
     D   str                      32767A   CONST VARYING
     D   suffix                   32767A   CONST VARYING
      *
     D suffixLen       S             10I 0
     D strLen          S             10I 0
     D startPos        S             10I 0
      *
     C                   EVAL      suffixLen = %LEN(suffix)
     C                   EVAL      strLen = %LEN(str)
      *
     C                   IF        suffixLen = 0
     C                   RETURN    *ON
     C                   ENDIF
      *
     C                   IF        strLen < suffixLen
     C                   RETURN    *OFF
     C                   ENDIF
      *
     C                   EVAL      startPos = strLen - suffixLen + 1
     C                   RETURN    (%SUBST(str: startPos: suffixLen) = suffix)
     P StrEndsWith     E

      *=====================================================================
      * Procedure: StrContains
      * Purpose: Check if string contains substring
      *=====================================================================
     P StrContains     B                   EXPORT
     D StrContains     PI              N
     D   str                      32767A   CONST VARYING
     D   search                   32767A   CONST VARYING
      *
     C                   RETURN    (%SCAN(search: str) > 0)
     P StrContains     E

      *=====================================================================
      * Procedure: StrIsEmpty
      * Purpose: Check if string is empty
      *=====================================================================
     P StrIsEmpty      B                   EXPORT
     D StrIsEmpty      PI              N
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    (%LEN(str) = 0)
     P StrIsEmpty      E

      *=====================================================================
      * Procedure: StrIsBlank
      * Purpose: Check if string is empty or only whitespace
      *=====================================================================
     P StrIsBlank      B                   EXPORT
     D StrIsBlank      PI              N
     D   str                      32767A   CONST VARYING
      *
     C                   RETURN    (%LEN(%TRIM(str)) = 0)
     P StrIsBlank      E

      *=====================================================================
      * Procedure: StrRepeat
      * Purpose: Repeat a string n times
      *=====================================================================
     P StrRepeat       B                   EXPORT
     D StrRepeat       PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   count                       10I 0 CONST
      *
     D result          S          32767A   VARYING
     D i               S             10I 0
      *
     C                   EVAL      result = ''
      *
     C                   IF        count <= 0
     C                   RETURN    result
     C                   ENDIF
      *
     C                   DO        count         i
     C                   EVAL      result = result + str
     C                   ENDDO
      *
     C                   RETURN    result
     P StrRepeat       E

      *=====================================================================
      * Procedure: StrPadLeft
      * Purpose: Pad string on left to specified length
      *=====================================================================
     P StrPadLeft      B                   EXPORT
     D StrPadLeft      PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   length                      10I 0 CONST
     D   padChar                      1A   CONST OPTIONS(*NOPASS)
      *
     D result          S          32767A   VARYING
     D pad             S              1A
     D strLen          S             10I 0
     D padLen          S             10I 0
     D parmCount       S             10I 0
      *
     C                   EVAL      parmCount = %PARMS()
      *
     C                   IF        parmCount >= 3
     C                   EVAL      pad = padChar
     C                   ELSE
     C                   EVAL      pad = ' '
     C                   ENDIF
      *
     C                   EVAL      strLen = %LEN(str)
      *
     C                   IF        strLen >= length
     C                   RETURN    str
     C                   ENDIF
      *
     C                   EVAL      padLen = length - strLen
     C                   EVAL      result = StrRepeat(pad: padLen) + str
      *
     C                   RETURN    result
     P StrPadLeft      E

      *=====================================================================
      * Procedure: StrPadRight
      * Purpose: Pad string on right to specified length
      *=====================================================================
     P StrPadRight     B                   EXPORT
     D StrPadRight     PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
     D   length                      10I 0 CONST
     D   padChar                      1A   CONST OPTIONS(*NOPASS)
      *
     D result          S          32767A   VARYING
     D pad             S              1A
     D strLen          S             10I 0
     D padLen          S             10I 0
     D parmCount       S             10I 0
      *
     C                   EVAL      parmCount = %PARMS()
      *
     C                   IF        parmCount >= 3
     C                   EVAL      pad = padChar
     C                   ELSE
     C                   EVAL      pad = ' '
     C                   ENDIF
      *
     C                   EVAL      strLen = %LEN(str)
      *
     C                   IF        strLen >= length
     C                   RETURN    str
     C                   ENDIF
      *
     C                   EVAL      padLen = length - strLen
     C                   EVAL      result = str + StrRepeat(pad: padLen)
      *
     C                   RETURN    result
     P StrPadRight     E

      *=====================================================================
      * End of JSONSTR
      *=====================================================================
