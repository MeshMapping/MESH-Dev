!>\file
!!CALCULATES SCREEN RELATIVE HUMIDITY BASED ON INPUT SCREEN
!!TEMPERATURE, SCREEN SPECIFIC HUMIDITY AND SURFACE PRESSURE.
!!THE FORMULAE USED HERE ARE CONSISTENT WITH THAT USED ELSEWHERE
!!IN THE GCM PHYSICS.
!!
      SUBROUTINE SCREENRH(SRH,ST,SQ,PRESSG,FMASK,ILG,IL1,IL2)
C
C     * DEC 16, 2014 - V.FORTIN.  REPLACE MERGE AND REWORD VARIABLE
C     *                           DECLARATIONS FOR COMPATABILITY WITH F77.
C     * APR 30, 2009 - M.LAZARE.
C
      IMPLICIT NONE
C
C     * OUTPUT FIELD:
C
      REAL   SRH(ILG)
C
C     * INPUT FIELDS.
C
      REAL   ST(ILG),SQ(ILG),PRESSG(ILG),FMASK(ILG)
C
      REAL FACTE,EPSLIM,FRACW,ETMP,ESTREF,ESAT,QSW
      REAL A,B,EPS1,EPS2,T1S,T2S,AI,BI,AW,BW,SLP
      REAL RW1,RW2,RW3,RI1,RI2,RI3                 
      REAL ESW,ESI,ESTEFF,TTT,UUU
C
      INTEGER ILG,IL,IL1,IL2
C
C     * COMMON BLOCKS FOR THERMODYNAMIC CONSTANTS.
C
      COMMON /EPS /  A,B,EPS1,EPS2    
      COMMON /HTCP/  T1S,T2S,AI,BI,AW,BW,SLP
C
C     * PARAMETERS USED IN NEW SATURATION VAPOUR PRESSURE FORMULATION.
C
      COMMON /ESTWI/ RW1,RW2,RW3,RI1,RI2,RI3                 
C
C     * COMPUTES THE SATURATION VAPOUR PRESSURE OVER WATER OR ICE.
C
      ESW(TTT)        = EXP(RW1+RW2/TTT)*TTT**RW3
      ESI(TTT)        = EXP(RI1+RI2/TTT)*TTT**RI3
      ESTEFF(TTT,UUU) = UUU*ESW(TTT) + (1.-UUU)*ESI(TTT)   
C========================================================================
      EPSLIM=0.001
      FACTE=1./EPS1-1.
      DO IL=IL1,IL2
       IF(FMASK(IL).GT.0.)                                          THEN    
C
C       * COMPUTE THE FRACTIONAL PROBABILITY OF WATER PHASE      
C       * EXISTING AS A FUNCTION OF TEMPERATURE (FROM ROCKEL,     
C       * RASCHKE AND WEYRES, BEITR. PHYS. ATMOSPH., 1991.)       
C
        IF(ST(IL) .GE. T1S )             THEN
            FRACW=1.0
        ELSE
            FRACW=0.0059+0.9941*EXP(-0.003102*(T1S-ST(IL))**2)
        ENDIF 
C
        ETMP=ESTEFF(ST(IL),FRACW)
        ESTREF=0.01*PRESSG(IL)*(1.-EPSLIM)/(1.-EPSLIM*EPS2)
        IF ( ETMP.LT.ESTREF ) THEN
          ESAT=ETMP
        ELSE
          ESAT=ESTREF
        ENDIF
C
        QSW=EPS1*ESAT/(0.01*PRESSG(IL)-EPS2*ESAT)
        SRH(IL)=MIN(MAX((SQ(IL)*(1.+QSW*FACTE))
     1         /(QSW*(1.+SQ(IL)*FACTE)),0.),1.)
       ENDIF
      ENDDO
C
      RETURN
      END