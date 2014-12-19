!> *********************************************************************
!> Open and read in values from MESH_parameters_hydrology.ini file
!> *********************************************************************

SUBROUTINE READ_PARAMETERS_HYDROLOGY(INDEPPAR, DEPPAR, RELEASE, WF_R2, hp, M_C, NA, NTYPE, &
                                     SOIL_POR_MAX, SOIL_DEPTH, S0, T_ICE_LENS)

USE MESH_INPUT_MODULE
USE FLAGS

INTEGER :: M_C, INDEPPAR, DEPPAR
CHARACTER*8 :: RELEASE(10)
REAL :: SOIL_POR_MAX, SOIL_DEPTH, S0, T_ICE_LENS
REAL :: WF_R2(M_C)
TYPE(HydrologyParameters) :: hp

REAL, DIMENSION (:), ALLOCATABLE :: INDEPPARVAL
REAL, DIMENSION (:,:), ALLOCATABLE :: DEPPARVAL

!> Internal use variables
INTEGER :: IOS, I, M
CHARACTER(8) :: FILE_VER
LOGICAL :: VER_OK

OPEN (23, FILE="MESH_parameters_hydrology.ini", STATUS="OLD",IOSTAT=IOS)
!> CHECK FILE FOR IOSTAT ERRORS
!> when IOS equals 0, the file was opened successfully  
IF (IOS .NE. 0)THEN 
  WRITE (6, *)
  WRITE (6, *)
  WRITE (6, *) "MESH_parameters_hydrology.ini could not be opened.  Ensure that the file exists and restart the program."
  STOP
ELSE
  WRITE (6, '(A)', ADVANCE="NO")"READING: MESH_parameters_hydrology.ini"
END IF

!> DAN * CHECK FILE VERSION (IF RELFLG = 1.0) AS THE NEW FILE FORMATS
!> DAN * ALLOW VARIABLES AND VARIABLE PLACEMENT FILE VERSIONS TO CHANGE
IF (RELFLG .EQ. 1) THEN
  READ (23, "(A8)") FILE_VER !> READ FILE VERSION
  IF (INDEX (FILE_VER, ":") .GT. 0) THEN !> FOLLOWED BY COLON
    FILE_VER = TRIM (ADJUSTL (FILE_VER(1:INDEX (FILE_VER,":") - 1)))
  ELSEIF (INDEX (FILE_VER, " ") .GT. 0) THEN !> FOLLOWED BY SPACE
    FILE_VER = TRIM (ADJUSTL (FILE_VER(1:INDEX (FILE_VER," ") - 1)))
  ELSE !> ANYTHING ELSE
    FILE_VER = TRIM (ADJUSTL (FILE_VER))
  END IF
  VER_OK = .FALSE.
  DO I=1,6 !TODO: MAKE THIS MORE GENERIC
    IF (FILE_VER .EQ. RELEASE(I)) THEN
      VER_OK = .TRUE.
      EXIT
    END IF
  END DO
  IF (.NOT.VER_OK) THEN !WRONG FILE VERSION
    WRITE (6, *)
    WRITE (6, *)
    IF (LEN (TRIM (ADJUSTL (FILE_VER))) .GT. 0) THEN
      WRITE (6, *) "File version: ", FILE_VER
    ELSE
      WRITE (6, *) "This file is out of date."
    END IF

    WRITE (6, *) "MESH requires file version: ", RELEASE
    WRITE (6, *) "Please update MESH_parameters_hydrology.ini."
    WRITE (6, *) "The file must contain the version number"
    WRITE (6, *) "on the first line, followed by a colon."
    WRITE (6, *) "EXAMPLE:"
    WRITE (6, *) RELEASE(4),": MESH_parameters_hydrology.ini"
    WRITE (6, *) " "
    WRITE (6, *) "Please insure that all other parameters"
    WRITE (6, *) "are also updated."
    CLOSE (23)
    STOP
  END IF
ELSE
  READ (23, *)
END IF

READ(23,*)
READ(23,*)

READ(23,"(I5)") OPTFLAGS

IF(OPTFLAGS>0) THEN
  DO I=1,OPTFLAGS
    READ(23,*)
  ENDDO
ENDIF

READ(23,*)
READ(23,*)

READ (23,"(5F6.3)") (WF_R2(i),I=1,5)
  DO I=1,5
   IF (wf_r2(i) <= 0)THEN 
    WRITE (6, *)
    WRITE (6, *) "River roughness =0 (in MESH parameters_hydrology.ini) "
    WRITE (6, *) "Even if you only have only one river class, all initial wf_r2"
    WRITE (6, *) "values must be non-zero in MESH_parameters_hydrology.ini "
    WRITE (6, *) "MESH STOP "
    WRITE (6, *)
    STOP
   ENDIF
 ENDDO
READ(23,*)
READ(23,*)

READ(23,"(I8)") INDEPPAR

ALLOCATE(INDEPPARVAL(INDEPPAR))

DO I = 1, INDEPPAR
   READ(23,*,ERR = 9000)INDEPPARVAL(I)
ENDDO

IF(FROZENSOILINFILFLAG == 1)THEN

   !> READ FROZEN SOIL INFILTRATION PARAMETERS
   IF(INDEPPAR == 4 + NYEARS)THEN
       SOIL_POR_MAX = INDEPPARVAL(1)
       SOIL_DEPTH   = INDEPPARVAL(2)
       S0           = INDEPPARVAL(3)
       T_ICE_LENS   = INDEPPARVAL(4)
       DO I = 5,INDEPPAR
          t0_ACC(I-4) = INDEPPARVAL(I)
       ENDDO
    ELSE   
       PRINT *
       PRINT *,'ERROR: FROZEN SOIL INFILTRATION FLAG IS ON BUT CORRESPONDING PARAMETER VALUES ', & 
                          'ARE NOT CORRECTLY SPECIFIED IN THE HYDROLOGY INITIALIZATION FILE.'
       PRINT *,'PROVIDE PARAMETER VALUES FOR:'
       PRINT *,'MAXIMUM SOIL POROSITY [0 - 1]'
       PRINT *,'DEPTH FROM SURFACE TO BOTTOM OF ROOTING ZONE FOR MAXIMUM WATER HOLDING CAPACITY, m'
       PRINT *,'SURFACE SOIL SATURATION [0 - 1]' 
       PRINT *,'OVER NIGHT TEMPERATURE TO CAUSE ICE LENS [-50 - 0]'
       PRINT *,'OPPORTUNITY TIME IN HOURS [100 - 1000] FOR EACH SIMULATION YEAR'
       PRINT *,'AN EMPIRICAL EQUATION WILL BE USED FOR OPPORTUNITY TIME VALUES SET TO 0'
       PRINT *
       STOP
    ENDIF
ENDIF

READ(23,*)
READ(23,*)

READ(23,"(I8)") I
IF(I/=NTYPE) THEN
  PRINT *, 'Number of GRUs in hydrology file: ',I
  PRINT *, 'Number of GRUs in drainage database: ',NTYPE
  PRINT *, 'Please adjust these values.'
  STOP
ENDIF

READ(23,"(I8)") DEPPAR
READ(23,*)

ALLOCATE(DEPPARVAL(DEPPAR,NTYPE))

DO I = 1, DEPPAR
   READ(23,*,ERR = 9001)(DEPPARVAL(I,J),J=1,NTYPE)
ENDDO

IF(FROZENSOILINFILFLAG == 1 .AND. DEPPAR < 4)THEN
   PRINT *
   PRINT *,'ERROR: FROZEN SOIL INFILTRATION FLAG IS ON BUT CORRESPONDING PARAMETER VALUES ', & 
                      'ARE NOT CORRECTLY SPECIFIED IN THE HYDROLOGY INITIALIZATION FILE.'
   PRINT *,'PROVIDE PARAMETER VALUES FOR:'
   PRINT *,'COEFFICIENT FOR THE PARAMETERIC EQUATION OF FROZEN SOIL INFILTRATION [1 - 3]:'
   PRINT *,'VALUES FROM FIELD STUDIES: 1.14 FOR PRAIRIE AND 2.1 FOR BOREAL FOREST'
   PRINT *
   STOP
ENDIF
IF(DEPPAR >= 4)THEN
    DO I=1,NA
      DO M=1,NTYPE
        hp%FRZCROW(I,M)=DEPPARVAL(4,M)
      ENDDO
    ENDDO
ENDIF

DO I=1,NA
  DO M=1,NTYPE
    hp%ZSNLROW(I,M)=DEPPARVAL(1,M)
    hp%ZPLSROW(I,M)=DEPPARVAL(2,M)
    hp%ZPLGROW(I,M)=DEPPARVAL(3,M)
    hp%RATIOQM(I,M)=DEPPARVAL(10,M) !Ric Soulis added hp%RATIOQM
  ENDDO
ENDDO

CLOSE(UNIT=23)

RETURN

9000 PRINT*,'ERROR: READING INDEPENDANT PARAMETER ', I, 'IN THE HYDROLOGY FILE.'
     STOP

9001 PRINT*,'ERROR: READING DEPENDANT PARAMETER: ROW ', I, 'COLUMN ', J, 'IN THE HYDROLOGY FILE.'
     STOP

END SUBROUTINE