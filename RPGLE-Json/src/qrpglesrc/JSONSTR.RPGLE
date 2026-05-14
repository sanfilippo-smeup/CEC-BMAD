      *=====================================================================
      * JSONSTR - String Utilities for RPGLE-Json Query Utility
      *=====================================================================
      * Description: Provides string manipulation utilities optimized for
      *              fixed-form RPGLE.
      *
      * Author: Mauro
      * Date: 2026-04-28
      * Version: 1.0
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
      /FREE
       RETURN %LEN(str);
      /END-FREE
     P StrLen          E

      *=====================================================================
      * Procedure: StrLenTrim
      * Purpose: Get length of string after trimming whitespace
      *=====================================================================
     P StrLenTrim      B                   EXPORT
     D StrLenTrim      PI            10I 0
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN %LEN(%TRIM(str));
      /END-FREE
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
      /FREE
       RETURN str1 + str2;
      /END-FREE
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
      /FREE
       RETURN str1 + str2 + str3;
      /END-FREE
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
      /FREE
       IF str1 = str2;
         RETURN 0;
       ELSEIF str1 < str2;
         RETURN -1;
       ELSE;
         RETURN 1;
       ENDIF;
      /END-FREE
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
      /FREE
       upper1 = %UPPER(str1);
       upper2 = %UPPER(str2);
       
       IF upper1 = upper2;
         RETURN 0;
       ELSEIF upper1 < upper2;
         RETURN -1;
       ELSE;
         RETURN 1;
       ENDIF;
      /END-FREE
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
      /FREE
       RETURN (str1 = str2);
      /END-FREE
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
      /FREE
       RETURN (%UPPER(str1) = %UPPER(str2));
      /END-FREE
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
      /FREE
       dest = src;
       RETURN *ON;
      /END-FREE
     P StrCopy         E

      *=====================================================================
      * Procedure: StrTrim
      * Purpose: Trim whitespace from both ends
      *=====================================================================
     P StrTrim         B                   EXPORT
     D StrTrim         PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN %TRIM(str);
      /END-FREE
     P StrTrim         E

      *=====================================================================
      * Procedure: StrTrimL
      * Purpose: Trim whitespace from left end
      *=====================================================================
     P StrTrimL        B                   EXPORT
     D StrTrimL        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN %TRIML(str);
      /END-FREE
     P StrTrimL        E

      *=====================================================================
      * Procedure: StrTrimR
      * Purpose: Trim whitespace from right end
      *=====================================================================
     P StrTrimR        B                   EXPORT
     D StrTrimR        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN %TRIMR(str);
      /END-FREE
     P StrTrimR        E

      *=====================================================================
      * Procedure: StrUpper
      * Purpose: Convert string to uppercase
      *=====================================================================
     P StrUpper        B                   EXPORT
     D StrUpper        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN %UPPER(str);
      /END-FREE
     P StrUpper        E

      *=====================================================================
      * Procedure: StrLower
      * Purpose: Convert string to lowercase
      *=====================================================================
     P StrLower        B                   EXPORT
     D StrLower        PI         32767A   VARYING
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN %LOWER(str);
      /END-FREE
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
      /FREE
       parmCount = %PARMS();
       
       IF parmCount >= 3;
         RETURN %SUBST(str: start: length);
       ELSE;
         RETURN %SUBST(str: start);
       ENDIF;
      /END-FREE
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
      /FREE
       parmCount = %PARMS();
       
       IF parmCount >= 3;
         pos = %SCAN(search: str: start);
       ELSE;
         pos = %SCAN(search: str);
       ENDIF;
       
       RETURN pos;
      /END-FREE
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
      /FREE
       result = str;
       searchLen = %LEN(search);
       
       IF searchLen = 0;
         RETURN result;
       ENDIF;
       
       pos = %SCAN(search: result);
       DOW pos > 0;
         result = %SUBST(result: 1: pos - 1) +
                  replace +
                  %SUBST(result: pos + searchLen);
         pos = %SCAN(search: result: pos + %LEN(replace));
       ENDDO;
       
       RETURN result;
      /END-FREE
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
      /FREE
       prefixLen = %LEN(prefix);
       
       IF prefixLen = 0;
         RETURN *ON;
       ENDIF;
       
       IF %LEN(str) < prefixLen;
         RETURN *OFF;
       ENDIF;
       
       RETURN (%SUBST(str: 1: prefixLen) = prefix);
      /END-FREE
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
      /FREE
       suffixLen = %LEN(suffix);
       strLen = %LEN(str);
       
       IF suffixLen = 0;
         RETURN *ON;
       ENDIF;
       
       IF strLen < suffixLen;
         RETURN *OFF;
       ENDIF;
       
       startPos = strLen - suffixLen + 1;
       RETURN (%SUBST(str: startPos: suffixLen) = suffix);
      /END-FREE
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
      /FREE
       RETURN (%SCAN(search: str) > 0);
      /END-FREE
     P StrContains     E

      *=====================================================================
      * Procedure: StrIsEmpty
      * Purpose: Check if string is empty
      *=====================================================================
     P StrIsEmpty      B                   EXPORT
     D StrIsEmpty      PI              N
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN (%LEN(str) = 0);
      /END-FREE
     P StrIsEmpty      E

      *=====================================================================
      * Procedure: StrIsBlank
      * Purpose: Check if string is empty or only whitespace
      *=====================================================================
     P StrIsBlank      B                   EXPORT
     D StrIsBlank      PI              N
     D   str                      32767A   CONST VARYING
      *
      /FREE
       RETURN (%LEN(%TRIM(str)) = 0);
      /END-FREE
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
      /FREE
       result = '';
       
       IF count <= 0;
         RETURN result;
       ENDIF;
       
       FOR i = 1 TO count;
         result = result + str;
       ENDFOR;
       
       RETURN result;
      /END-FREE
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
      /FREE
       parmCount = %PARMS();
       
       IF parmCount >= 3;
         pad = padChar;
       ELSE;
         pad = ' ';
       ENDIF;
       
       strLen = %LEN(str);
       
       IF strLen >= length;
         RETURN str;
       ENDIF;
       
       padLen = length - strLen;
       result = StrRepeat(pad: padLen) + str;
       
       RETURN result;
      /END-FREE
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
      /FREE
       parmCount = %PARMS();
       
       IF parmCount >= 3;
         pad = padChar;
       ELSE;
         pad = ' ';
       ENDIF;
       
       strLen = %LEN(str);
       
       IF strLen >= length;
         RETURN str;
       ENDIF;
       
       padLen = length - strLen;
       result = str + StrRepeat(pad: padLen);
       
       RETURN result;
      /END-FREE
     P StrPadRight     E

      *=====================================================================
      * End of JSONSTR
      *=====================================================================