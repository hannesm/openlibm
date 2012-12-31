*DECK DXCON
      SUBROUTINE DXCON (X, IX, IERROR)
C***BEGIN PROLOGUE  DXCON
C***PURPOSE  To provide double-precision floating-point arithmetic
C            with an extended exponent range.
C***LIBRARY   SLATEC
C***CATEGORY  A3D
C***TYPE      DOUBLE PRECISION (XCON-S, DXCON-D)
C***KEYWORDS  EXTENDED-RANGE DOUBLE-PRECISION ARITHMETIC
C***AUTHOR  Lozier, Daniel W., (National Bureau of Standards)
C           Smith, John M., (NBS and George Mason University)
C***DESCRIPTION
C     DOUBLE PRECISION X
C     INTEGER IX
C
C                  CONVERTS (X,IX) = X*RADIX**IX
C                  TO DECIMAL FORM IN PREPARATION FOR
C                  PRINTING, SO THAT (X,IX) = X*10**IX
C                  WHERE 1/10 .LE. ABS(X) .LT. 1
C                  IS RETURNED, EXCEPT THAT IF
C                  (ABS(X),IX) IS BETWEEN RADIX**(-2L)
C                  AND RADIX**(2L) THEN THE REDUCED
C                  FORM WITH IX = 0 IS RETURNED.
C
C***SEE ALSO  DXSET
C***REFERENCES  (NONE)
C***ROUTINES CALLED  DXADJ, DXC210, DXRED
C***COMMON BLOCKS    DXBLK2
C***REVISION HISTORY  (YYMMDD)
C   820712  DATE WRITTEN
C   890126  Revised to meet SLATEC CML recommendations.  (DWL and JMS)
C   901019  Revisions to prologue.  (DWL and WRB)
C   901106  Changed all specific intrinsics to generic.  (WRB)
C           Corrected order of sections in prologue and added TYPE
C           section.  (WRB)
C   920127  Revised PURPOSE section of prologue.  (DWL)
C***END PROLOGUE  DXCON
      DOUBLE PRECISION X
      INTEGER IX
C
C   THE CONDITIONS IMPOSED ON L AND KMAX BY THIS SUBROUTINE
C ARE
C    (1) 4 .LE. L .LE. 2**NBITS - 1 - KMAX
C
C    (2) KMAX .LE. ((2**NBITS)-2)/LOG10R - L
C
C THESE CONDITIONS MUST BE MET BY APPROPRIATE CODING
C IN SUBROUTINE DXSET.
C
      DOUBLE PRECISION RADIX, RADIXL, RAD2L, DLG10R
      INTEGER L, L2, KMAX
      COMMON /DXBLK2/ RADIX, RADIXL, RAD2L, DLG10R, L, L2, KMAX
      SAVE /DXBLK2/, ISPACE
C
      DOUBLE PRECISION A, B, Z
C
      DATA ISPACE /1/
C   THE PARAMETER ISPACE IS THE INCREMENT USED IN FORM-
C ING THE AUXILIARY INDEX OF THE DECIMAL EXTENDED-RANGE
C FORM. THE RETURNED VALUE OF IX WILL BE AN INTEGER MULT-
C IPLE OF ISPACE. ISPACE MUST SATISFY 1 .LE. ISPACE .LE.
C L/2. IF A VALUE GREATER THAN 1 IS TAKEN, THE RETURNED
C VALUE OF X WILL SATISFY 10**(-ISPACE) .LE. ABS(X) .LE. 1
C WHEN (ABS(X),IX) .LT. RADIX**(-2L), AND 1/10 .LE. ABS(X)
C .LT. 10**(ISPACE-1) WHEN (ABS(X),IX) .GT. RADIX**(2L).
C
C***FIRST EXECUTABLE STATEMENT  DXCON
      IERROR=0
      CALL DXRED(X, IX,IERROR)
      IF (IERROR.NE.0) RETURN
      IF (IX.EQ.0) GO TO 150
      CALL DXADJ(X, IX,IERROR)
      IF (IERROR.NE.0) RETURN
C
C CASE 1 IS WHEN (X,IX) IS LESS THAN RADIX**(-2L) IN MAGNITUDE,
C CASE 2 IS WHEN (X,IX) IS GREATER THAN RADIX**(2L) IN MAGNITUDE.
      ITEMP = 1
      ICASE = (3+SIGN(ITEMP,IX))/2
      GO TO (10, 20), ICASE
   10 IF (ABS(X).LT.1.0D0) GO TO 30
      X = X/RADIXL
      IX = IX + L
      GO TO 30
   20 IF (ABS(X).GE.1.0D0) GO TO 30
      X = X*RADIXL
      IX = IX - L
   30 CONTINUE
C
C AT THIS POINT, RADIX**(-L) .LE. ABS(X) .LT. 1.0D0     IN CASE 1,
C                      1.0D0 .LE. ABS(X) .LT. RADIX**L  IN CASE 2.
      I = LOG10(ABS(X))/DLG10R
      A = RADIX**I
      GO TO (40, 60), ICASE
   40 IF (A.LE.RADIX*ABS(X)) GO TO 50
      I = I - 1
      A = A/RADIX
      GO TO 40
   50 IF (ABS(X).LT.A) GO TO 80
      I = I + 1
      A = A*RADIX
      GO TO 50
   60 IF (A.LE.ABS(X)) GO TO 70
      I = I - 1
      A = A/RADIX
      GO TO 60
   70 IF (ABS(X).LT.RADIX*A) GO TO 80
      I = I + 1
      A = A*RADIX
      GO TO 70
   80 CONTINUE
C
C AT THIS POINT I IS SUCH THAT
C RADIX**(I-1) .LE. ABS(X) .LT. RADIX**I      IN CASE 1,
C     RADIX**I .LE. ABS(X) .LT. RADIX**(I+1)  IN CASE 2.
      ITEMP = ISPACE/DLG10R
      A = RADIX**ITEMP
      B = 10.0D0**ISPACE
   90 IF (A.LE.B) GO TO 100
      ITEMP = ITEMP - 1
      A = A/RADIX
      GO TO 90
  100 IF (B.LT.A*RADIX) GO TO 110
      ITEMP = ITEMP + 1
      A = A*RADIX
      GO TO 100
  110 CONTINUE
C
C AT THIS POINT ITEMP IS SUCH THAT
C RADIX**ITEMP .LE. 10**ISPACE .LT. RADIX**(ITEMP+1).
      IF (ITEMP.GT.0) GO TO 120
C ITEMP = 0 IF, AND ONLY IF, ISPACE = 1 AND RADIX = 16.0D0
      X = X*RADIX**(-I)
      IX = IX + I
      CALL DXC210(IX, Z, J,IERROR)
      IF (IERROR.NE.0) RETURN
      X = X*Z
      IX = J
      GO TO (130, 140), ICASE
  120 CONTINUE
      I1 = I/ITEMP
      X = X*RADIX**(-I1*ITEMP)
      IX = IX + I1*ITEMP
C
C AT THIS POINT,
C RADIX**(-ITEMP) .LE. ABS(X) .LT. 1.0D0        IN CASE 1,
C           1.0D0 .LE. ABS(X) .LT. RADIX**ITEMP IN CASE 2.
      CALL DXC210(IX, Z, J,IERROR)
      IF (IERROR.NE.0) RETURN
      J1 = J/ISPACE
      J2 = J - J1*ISPACE
      X = X*Z*10.0D0**J2
      IX = J1*ISPACE
C
C AT THIS POINT,
C  10.0D0**(-2*ISPACE) .LE. ABS(X) .LT. 1.0D0                IN CASE 1,
C           10.0D0**-1 .LE. ABS(X) .LT. 10.0D0**(2*ISPACE-1) IN CASE 2.
      GO TO (130, 140), ICASE
  130 IF (B*ABS(X).GE.1.0D0) GO TO 150
      X = X*B
      IX = IX - ISPACE
      GO TO 130
  140 IF (10.0D0*ABS(X).LT.B) GO TO 150
      X = X/B
      IX = IX + ISPACE
      GO TO 140
  150 RETURN
      END
