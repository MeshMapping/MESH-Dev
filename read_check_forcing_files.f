      SUBROUTINE READ_CHECK_FORCING_FILES(NUM_CSV, NUM_R2C)
      
      USE FLAGS

      INTEGER NUM_CSV, NUM_R2C
!> local variables
      INTEGER :: IOS
!> This variable is used to ignore the header of r2c forcing files
      CHARACTER(80) end_of_r2c_header


!> Reset the number of forcing variables not in the forcing binary file
      NUM_R2C = 0
      NUM_CSV = 0
!todo change documentation to reflect that all 3 types of forcing files can be used

!> *********************************************************************
!> Open basin_shortwave.r2c or basin_shortwave.csv
!> *********************************************************************

      IF (BASINSHORTWAVEFLAG == 1) THEN
        OPEN(unit=90,file='basin_shortwave.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin shortwave file exists
          PRINT *, 'basin_shortwave.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file'
          PRINT *, 'or put the r2c file in the correct location.'
          CLOSE(90)
          STOP
        ELSE
          !> basin shortwave files does exist, 
          !> use Pablo's code related to shortwave
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_shortwave.r2c found'
          end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (90, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINSHORTWAVEFLAG == 2) THEN
        OPEN(unit=90,file='basin_shortwave.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin shortwave file exists
          PRINT *, 'basin_shortwave.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(90)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_shortwave.csv found'
        ENDIF
      ENDIF

!> *********************************************************************
!> Open basin_longwave.r2c or basin_longwave.csv
!> *********************************************************************
      IF (BASINLONGWAVEFLAG == 1) THEN
        OPEN(unit=91,file='basin_longwave.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !>no basin longwave file exists
          PRINT *, 'basin_longwave.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the r2c file in the correct location.'
          CLOSE(91)
          STOP
        ELSE
          !basin longwave files does exist, use 'default' c05 behaviour
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_longwave.r2c found'
         end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (91, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINLONGWAVEFLAG == 2) THEN
        OPEN(unit=91,file='basin_longwave.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin longwave file exists
          PRINT *, 'basin_longwave.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(91)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_longwave.csv found'
        ENDIF
      ENDIF

!> *********************************************************************
!> Open basin_rain.r2c or basin_rain.csv
!> *********************************************************************
      IF (BASINRAINFLAG == 1) THEN
        OPEN(unit=92,file='basin_rain.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin rain file exists
          PRINT *, 'basin_rain.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file'
          PRINT *, 'or put the r2c file in the correct location.'
          CLOSE(92)
          STOP
        ELSE
          !basin rain files does exist, use 'default' c05 behaviour
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_rain.r2c found'
         end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (92, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINRAINFLAG == 2) THEN
        OPEN(unit=92,file='basin_rain.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin rain file exists
          PRINT *, 'basin_rain.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(92)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_rain.csv found'
        ENDIF
      ENDIF

!> *********************************************************************
!> Open basin_temperature.r2c or basin_temperature.csv
!> *********************************************************************
      IF (BASINTEMPERATUREFLAG == 1) THEN
        OPEN(unit=93,file='basin_temperature.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin temperature file exists
          PRINT *, 'basin_temperature.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the r2c file in the correct location.'
          CLOSE(93)
          STOP
        ELSE
          !> basin temperature files does exist, use 'default' c05 behaviour
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_temperature.r2c found'
         end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (93, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINTEMPERATUREFLAG == 2) THEN
        OPEN(unit=93,file='basin_temperature.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin temperature file exists
          PRINT *, 'basin_temperature.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(93)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_temperature.csv found'
        ENDIF
      ENDIF

!> *********************************************************************
!> Open basin_wind.r2c or basin_wind.csv
!> *********************************************************************
      IF (BASINWINDFLAG == 1) THEN
        OPEN(unit=94,file='basin_wind.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin wind file exists
          PRINT *, 'basin_wind.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the r2c file in the correct location.'
          CLOSE(94)
          STOP
        ELSE
          !> basin wind files does exist, use 'default' c05 behaviour
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_wind.r2c found'
         end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (94, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINWINDFLAG == 2) THEN
        OPEN(unit=94,file='basin_wind.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin wind file exists
          PRINT *, 'basin_wind.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(94)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_wind.csv found'
        ENDIF
      ENDIF

!> *********************************************************************
!> Open basin_pres.r2c or basin_pres.csv
!> *********************************************************************
      IF (BASINPRESFLAG == 1) THEN
        OPEN(unit=95,file='basin_pres.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin pres file exists
          PRINT *, 'basin_pres.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the r2cfile in the correct location.'
          CLOSE(95)
          STOP
        ELSE
          !> basin pres files does exist, use 'default' c05 behaviour
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_pres.r2c found'
         end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (95, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINPRESFLAG == 2) THEN
        OPEN(unit=95,file='basin_pres.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin pres file exists
          PRINT *, 'basin_pres.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(95)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_pres.csv found'
        ENDIF
      ENDIF

!>  *********************************************************************
!> Open basin_humidity.r2c or basin_humidity.csv
!> *********************************************************************
      IF (BASINHUMIDITYFLAG == 1) THEN
        OPEN(unit=96,file='basin_humidity.r2c',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin humidity file exists
          PRINT *, 'basin_humidity.r2c not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the r2c file in the correct location.'
          CLOSE(96)
          STOP
        ELSE
          !> basin humidity files does exist, use 'default' c05 behaviour
          NUM_R2C = NUM_R2C + 1
          PRINT *, 'basin_humidity.r2c found'
         end_of_r2c_header = ""
          DO WHILE (end_of_r2c_header /= ":endHeader")
            READ (96, '(A10)') end_of_r2c_header
          ENDDO
        ENDIF
      ELSEIF (BASINHUMIDITYFLAG == 2) THEN
        OPEN(unit=96,file='basin_humidity.csv',
     +    STATUS='OLD',IOSTAT=IOS)
!> IOS would be 0 if the file opened successfully.
        IF(IOS/=0)THEN
          !> no basin humidity file exists
          PRINT *, 'basin_humidity.csv not found'
          PRINT *, 'please adjust the mesh_input_run_options.ini file,'
          PRINT *, 'or put the csv file in the correct location.'
          CLOSE(96)
          STOP
        ELSE
          NUM_CSV = NUM_CSV + 1
          PRINT *, 'basin_humidity.csv found'
        ENDIF
      ENDIF
      RETURN
      END SUBROUTINE READ_CHECK_FORCING_FILES
